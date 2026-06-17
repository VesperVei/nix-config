-- =============================================================================
-- Python venv 状态管理
-- 说明：
-- 1. 不再按项目目录名猜测 venv，而是只认 python_venv_map.lua 的显式映射
-- 2. 自动切换按“当前文件路径 -> 项目根 -> venv”直接解析，降低启动时序带来的不确定性
-- 3. Pyright 的配置也按路径实时生成，避免首次打开文件时读到旧的全局状态
-- =============================================================================

local M = {}

local home = vim.loop.os_homedir() or ""
local python3 = vim.fn.exepath("python3")

local config = {
	venv_root = vim.env.CHENHUN_PYTHON_VENV_ROOT or (home .. "/.virtualenvs"),
	default_bin = python3 ~= "" and python3 or "python3",
	icon = "🐍 ",
}

local ok, raw_project_venv_map = pcall(require, "chenhun.core.python_venv_map")
if not ok or type(raw_project_venv_map) ~= "table" then
	raw_project_venv_map = {}
end

local project_venv_map = {}
local project_roots = {}
for project_root, venv_name in pairs(raw_project_venv_map) do
	local normalized_root = vim.fs.normalize(project_root)
	project_venv_map[normalized_root] = venv_name
	table.insert(project_roots, normalized_root)
end

table.sort(project_roots, function(a, b)
	return #a > #b
end)

local cache = {
	current = nil,
	current_python_path = config.default_bin,
	current_project_root = nil,
	manual_fallback = nil,
	project_overrides = {},
	notified_projects = {},
}

local status_view = {
	buf = nil,
	win = nil,
}

local status_ns = vim.api.nvim_create_namespace("PythonVenvStatus")

vim.api.nvim_set_hl(0, "PythonStatusNumber", { fg = "#ff9e64", bold = true })

local function file_exists(path)
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	end
	return false
end

local function is_directory(path)
	local stat = vim.uv.fs_stat(path)
	return stat and stat.type == "directory"
end

local function normalize_path(path)
	if not path or path == "" then
		return nil
	end
	return vim.fs.normalize(path)
end

local function path_to_directory(path)
	local normalized = normalize_path(path)
	if not normalized then
		return nil
	end

	local stat = vim.uv.fs_stat(normalized)
	if stat and stat.type ~= "directory" then
		return vim.fs.dirname(normalized)
	end

	return normalized
end

local function get_current_path()
	local buf_path = vim.api.nvim_buf_get_name(0)
	if buf_path and buf_path ~= "" then
		return buf_path
	end
	return vim.fn.getcwd()
end

local function shorten_path(path)
	local normalized = normalize_path(path)
	if not normalized then
		return "[无路径]"
	end

	local home = normalize_path(vim.loop.os_homedir() or "")
	if home and normalized:sub(1, #home) == home then
		return "~" .. normalized:sub(#home + 1)
	end

	return normalized
end

local function is_tree_window(winid)
	local bufnr = vim.api.nvim_win_get_buf(winid)
	local name = vim.api.nvim_buf_get_name(bufnr)
	local filetype = vim.bo[bufnr].filetype

	return filetype == "NvimTree" or name:match("NvimTree")
end

local function get_venv_path(venv_name)
	return string.format("%s/%s", config.venv_root, venv_name)
end

local function get_python_bin(venv_name)
	return string.format("%s/bin/python", get_venv_path(venv_name))
end

local function remove_venvs_from_path()
	local cur_path = vim.env.PATH or ""
	local parts = {}
	for part in string.gmatch(cur_path, "([^:]+)") do
		if not string.find(part, config.venv_root, 1, true) then
			table.insert(parts, part)
		end
	end
	vim.env.PATH = table.concat(parts, ":")
end

local function refresh_lualine()
	local ok, lualine = pcall(require, "lualine")
	if ok then
		lualine.refresh()
	end
end

local function has_active_pyright()
	return #vim.lsp.get_clients({ name = "pyright" }) > 0
end

local function build_pyright_python_settings(state)
	local python_settings = {
		pythonPath = state.python_path,
	}

	if state.venv_path and state.local_venv then
		python_settings.venvPath = vim.fs.dirname(state.venv_path)
		python_settings.venv = vim.fs.basename(state.venv_path)
	elseif state.venv_name then
		python_settings.venvPath = config.venv_root
		python_settings.venv = state.venv_name
	end

	return python_settings
end

local function display_venv_name(state)
	if state.local_venv and state.venv_path then
		return vim.fs.basename(state.venv_path)
	end

	return state.venv_name
end

local function is_client_in_state_scope(client, state)
	local root_dir = normalize_path((client.config or {}).root_dir)
	if not root_dir then
		return false
	end

	local project_root = normalize_path(state.project_root)
	if project_root then
		return root_dir == project_root or root_dir:sub(1, #project_root + 1) == project_root .. "/"
	end

	local target_dir = normalize_path(state.target_dir)
	if target_dir then
		return root_dir == target_dir or target_dir:sub(1, #root_dir + 1) == root_dir .. "/"
	end

	return false
end

local function sync_active_pyright_settings(state)
	local next_settings = {
		python = build_pyright_python_settings(state),
	}

	for _, client in ipairs(vim.lsp.get_clients({ name = "pyright" })) do
		if is_client_in_state_scope(client, state) then
			client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, next_settings)
			client.settings = vim.tbl_deep_extend("force", client.settings or {}, next_settings)
			client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
		end
	end
end

local function restart_pyright(state)
	-- Do not stop/restart Pyright from the venv module. New buffers receive
	-- settings from get_pyright_python_settings_for_path(), and current Neovim
	-- process shutdown naturally owns client cleanup.
	if state then
		sync_active_pyright_settings(state)
	end
end

local function resolve_project_root(path)
	local directory = path_to_directory(path)
	if not directory then
		return nil
	end

	for _, project_root in ipairs(project_roots) do
		if directory == project_root then
			return project_root
		end

		local prefix = project_root .. "/"
		if directory:sub(1, #prefix) == prefix then
			return project_root
		end
	end

	return nil
end

-- 解释器选择优先级：
-- 1. 手动 `<leader>pv` / `set_venv()` 覆盖当前项目
-- 2. 项目根目录中的 `.pyvenv` 声明文件，内容只写 venv 名字
-- 3. 项目本地 `.venv/` 目录
-- 4. `python_venv_map.lua` 里的显式映射
-- 5. 系统解释器
-- `.pyvenv` 只存“名字”，例如 `pwn`，最终会去 `config.venv_root` 下找对应环境。
-- `.venv` 目录则表示项目本地环境，Neovim 会直接使用该目录下的 `bin/python`。
local function read_declared_venv_name(path)
	local directory = path_to_directory(path)
	if not directory then
		return nil
	end

	local declaration_path = vim.fs.find(".pyvenv", {
		path = directory,
		upward = true,
		limit = 1,
	})[1]
	if not declaration_path then
		return nil
	end

	local lines = vim.fn.readfile(declaration_path)
	local declared = vim.trim(lines[1] or "")
	if declared == "" then
		return nil
	end

	return declared
end

local function resolve_local_venv_name(path)
	local directory = path_to_directory(path)
	if not directory then
		return nil
	end

	local current = directory
	while current and current ~= "/" do
		local venv_dir = current .. "/.venv"
		if is_directory(venv_dir) and file_exists(venv_dir .. "/bin/python") then
			return venv_dir
		end

		current = vim.fs.dirname(current)
		if current == directory then
			break
		end
	end

	return nil
end

local function resolve_venv_name(path)
	local project_root = resolve_project_root(path)
	if project_root then
		local override = cache.project_overrides[project_root]
		if override == "system" then
			return nil, project_root
		end
		if override and override ~= "" then
			return override, project_root
		end
	elseif cache.manual_fallback == "system" then
		return nil, nil
	elseif cache.manual_fallback and cache.manual_fallback ~= "" then
		return cache.manual_fallback, nil
	end

	local declared_venv = read_declared_venv_name(path)
	if declared_venv then
		return declared_venv, project_root
	end

	local local_venv = resolve_local_venv_name(path)
	if local_venv then
		return local_venv, project_root
	end

	if not project_root then
		return nil, nil
	end

	return project_venv_map[project_root], project_root
end

local function build_state_for_path(path)
	local target_path = path or get_current_path()
	local target_dir = path_to_directory(target_path)
	local venv_name, project_root = resolve_venv_name(target_path)

	if not venv_name then
		return {
			project_root = project_root,
			target_dir = target_dir,
			venv_name = nil,
			python_path = config.default_bin,
			venv_path = nil,
			local_venv = false,
		}
	end

	local venv_path = get_venv_path(venv_name)
	local local_venv = false
	local python_bin = get_python_bin(venv_name)
	if venv_name:sub(1, 1) == "/" then
		venv_path = venv_name
		python_bin = venv_path .. "/bin/python"
		local_venv = true
	end
	if not file_exists(python_bin) then
		return {
			project_root = project_root,
			target_dir = target_dir,
			venv_name = nil,
			python_path = config.default_bin,
			venv_path = nil,
			local_venv = false,
		}
	end

	return {
		project_root = project_root,
		target_dir = target_dir,
		venv_name = venv_name,
		python_path = python_bin,
		venv_path = venv_path,
		local_venv = local_venv,
	}
end

local function apply_state(state, opts)
	opts = vim.tbl_extend("force", {
		restart = true,
		notify = true,
		force_refresh = false,
	}, opts or {})

	local changed = cache.current ~= state.venv_name
		or cache.current_python_path ~= state.python_path
		or cache.current_project_root ~= state.project_root

	remove_venvs_from_path()
	vim.g.python3_host_prog = state.python_path

	if state.venv_path then
		vim.env.VIRTUAL_ENV = state.venv_path
		vim.env.PATH = state.venv_path .. "/bin:" .. (vim.env.PATH or "")
	else
		vim.env.VIRTUAL_ENV = nil
	end

	cache.current = state.venv_name
	cache.current_python_path = state.python_path
	cache.current_project_root = state.project_root

	refresh_lualine()

	if (changed or opts.force_refresh) and opts.restart then
		restart_pyright(state)
	end

	if opts.notify and state.venv_name and changed then
		vim.notify(config.icon .. "已激活环境: " .. (display_venv_name(state) or state.venv_name), vim.log.levels.INFO)
		if state.project_root then
			cache.notified_projects[state.project_root] = state.venv_name
		end
	end

	if changed and not state.venv_name and opts.notify then
		vim.notify("🚫 已退出虚拟环境，使用系统解释器", vim.log.levels.INFO)
	end

	return changed
end

function M.resolve_project_root(path)
	return resolve_project_root(path)
end

function M.get_current_venv()
	return cache.current
end

function M.get_current_python_path()
	return cache.current_python_path or config.default_bin
end

function M.get_pyright_client_name()
	return "pyright"
end

function M.is_managed_pyright_client(client)
	return client and client.name == "pyright"
end

function M.register_managed_pyright(_root_dir, _client_id)
	-- Compatibility shim for lspconfig.lua. Client lifecycle is intentionally unmanaged here.
end

function M.cleanup_ghost_pyright(_bufnr)
	-- Do not detach/stop Pyright clients; a new Neovim process owns its own LSP lifecycle.
	return false
end

function M.get_pyright_python_settings_for_path(path)
	local state = build_state_for_path(path)
	return build_pyright_python_settings(state)
end

function M.get_pyright_python_settings()
	return M.get_pyright_python_settings_for_path(get_current_path())
end

function M.sync_for_path(path, opts)
	return apply_state(build_state_for_path(path), opts)
end

function M.set_venv(venv_name, opts)
	opts = vim.tbl_extend("force", {
		path = get_current_path(),
	}, opts or {})

	local project_root = resolve_project_root(opts.path)
	local target_dir = path_to_directory(opts.path)
	cache.manual_fallback = venv_name or "system"

	if project_root then
		cache.project_overrides[project_root] = venv_name or "system"
	end

	local state
	if venv_name and venv_name ~= "" and venv_name ~= "system" then
		local python_bin = get_python_bin(venv_name)
		if not file_exists(python_bin) then
			vim.notify("错误：环境不存在 -> " .. python_bin, vim.log.levels.ERROR)
			return false
		end

		state = {
			project_root = project_root,
			target_dir = target_dir,
			venv_name = venv_name,
			python_path = python_bin,
			venv_path = get_venv_path(venv_name),
		}
	else
		state = {
			project_root = project_root,
			target_dir = target_dir,
			venv_name = nil,
			python_path = config.default_bin,
			venv_path = nil,
		}
	end

	return apply_state(state, {
		restart = true,
		notify = true,
	})
end

function M.choose_venv()
	local venvs = {}
	local p = io.popen('ls -1 "' .. config.venv_root .. '" 2>/dev/null')
	if p then
		for name in p:lines() do
			if name and #name > 0 then
				table.insert(venvs, name)
			end
		end
		p:close()
	end

	local choices = {}
	for _, v in ipairs(venvs) do
		table.insert(choices, config.icon .. v)
	end

	if #choices == 0 then
		vim.notify("未在 .venvs 目录下发现任何环境", vim.log.levels.WARN)
		return
	end

	vim.ui.select(choices, { prompt = "选择虚拟环境：" }, function(choice)
		if not choice then
			return
		end
		local selected_venv = choice:gsub(config.icon, "")
		M.set_venv(selected_venv)
	end)
end

function M.on_pyright_attach(bufnr)
	local path = vim.api.nvim_buf_get_name(bufnr)
	local state = build_state_for_path(path)

	apply_state(state, {
		restart = false,
		notify = false,
	})

	if state.venv_name and state.project_root then
		local last_notified = cache.notified_projects[state.project_root]
		if last_notified ~= state.venv_name then
			vim.notify(config.icon .. "已激活环境: " .. (display_venv_name(state) or state.venv_name), vim.log.levels.INFO)
			cache.notified_projects[state.project_root] = state.venv_name
		end
	end
end

function M.autoset_venv(opts)
	opts = vim.tbl_extend("force", {
		path = get_current_path(),
		notify = false,
		-- 自动切换只负责同步 Neovim 的环境状态，不负责在切文件时重启全部 Pyright。
		-- Pyright 现在由 lspconfig.lua 按 root_dir 独立启动；自动重启反而会把多个项目一起打断。
		restart = false,
		force_refresh = false,
	}, opts or {})

	return M.sync_for_path(opts.path, opts)
end

function M.lualine_component()
	if not cache.current or cache.current == "" then
		return ""
	end
	local current = cache.current
	if cache.current:sub(1, 1) == "/" then
		current = vim.fs.basename(cache.current)
	end
	return config.icon .. current
end

local function close_status_window()
	if status_view.win and vim.api.nvim_win_is_valid(status_view.win) then
		vim.api.nvim_win_close(status_view.win, true)
	end
	status_view.win = nil
	status_view.buf = nil
end

local function highlight_status_buffer(buf, lines)
	vim.api.nvim_buf_clear_namespace(buf, status_ns, 0, -1)

	for row, line in ipairs(lines) do
		local linenr = row - 1

		if row == 1 then
			vim.api.nvim_buf_add_highlight(buf, status_ns, "Title", linenr, 0, -1)
		elseif line:match("^  [📄📦⚙📊🧠💡⌨]") then
			vim.api.nvim_buf_add_highlight(buf, status_ns, "Keyword", linenr, 2, math.min(6, #line))
		elseif line:match("^  %[") or line:match("^  [^:]+:") then
			local colon = line:find(":")
			if colon then
				vim.api.nvim_buf_add_highlight(buf, status_ns, "Identifier", linenr, 2, colon)
			end
		elseif line:match("^    • ") then
			vim.api.nvim_buf_add_highlight(buf, status_ns, "Special", linenr, 4, 5)
			local colon = line:find(":")
			if colon then
				vim.api.nvim_buf_add_highlight(buf, status_ns, "Identifier", linenr, 6, colon - 1)
				vim.api.nvim_buf_add_highlight(buf, status_ns, "PythonStatusNumber", linenr, colon + 2, -1)
			end
		elseif line:match("^    %d+%. ") then
			vim.api.nvim_buf_add_highlight(buf, status_ns, "PythonStatusNumber", linenr, 4, 8)
			vim.api.nvim_buf_add_highlight(buf, status_ns, "String", linenr, 8, -1)
			local pid_start, pid_end = line:find("PID:")
			if pid_start and pid_end then
				vim.api.nvim_buf_add_highlight(buf, status_ns, "Identifier", linenr, pid_start - 1, pid_end)
				local pid_value_start = pid_end + 2
				local pid_value_end = line:find("%)", pid_value_start) or #line
				vim.api.nvim_buf_add_highlight(buf, status_ns, "PythonStatusNumber", linenr, pid_value_start - 1, pid_value_end - 1)
			end

			local mem_start, mem_end = line:find("占用:")
			if mem_start and mem_end then
				vim.api.nvim_buf_add_highlight(buf, status_ns, "Identifier", linenr, mem_start - 1, mem_end)
				vim.api.nvim_buf_add_highlight(buf, status_ns, "PythonStatusNumber", linenr, mem_end + 1, -1)
			end
		elseif line:match("^    目录:") then
			vim.api.nvim_buf_add_highlight(buf, status_ns, "Identifier", linenr, 4, 8)
			vim.api.nvim_buf_add_highlight(buf, status_ns, "Directory", linenr, 10, -1)
		elseif line:match("^  %-%-%-%-%-") then
			vim.api.nvim_buf_add_highlight(buf, status_ns, "Comment", linenr, 0, -1)
		end
	end
end

function M.show_session_status()
	if status_view.win and vim.api.nvim_win_is_valid(status_view.win) then
		close_status_window()
		return
	end

	local wins = vim.api.nvim_list_wins()
	local tabs = vim.api.nvim_list_tabpages()
	local python_buffers = 0
	local current_file = vim.api.nvim_buf_get_name(0)

	if current_file == "" then
		current_file = "[无文件名 Buffer]"
	end

	local visible_windows = 0
	for _, winid in ipairs(wins) do
		if vim.api.nvim_win_is_valid(winid) and not is_tree_window(winid) then
			visible_windows = visible_windows + 1
		end
	end

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype == "python" then
			python_buffers = python_buffers + 1
		end
	end

	local lines = {
		"Python / LSP 会话状态",
		"",
		"  📄 文件: " .. shorten_path(current_file),
		"  📦 环境: " .. (cache.current or "系统解释器"),
		"  ⚙️ 解释器: " .. shorten_path(cache.current_python_path or config.default_bin),
		"",
		"  📊 会话概览",
		"    • 窗口数      : " .. visible_windows,
		"    • 标签页数    : " .. #tabs,
		"    • Python Buff : " .. python_buffers,
	}

	local pyright_clients = vim.lsp.get_clients({ name = "pyright" })
	table.insert(lines, "")
	-- 这里只展示当前 Neovim 会话内的 Python/LSP 结构信息。
	-- 不再尝试读取外部进程的 PID/内存，避免平台差异导致的噪声和误判。
	table.insert(lines, string.format("  🧠 Pyright Clients (共 %d 个)", #pyright_clients))

	for index, client in ipairs(pyright_clients) do
		local python_settings = (((client.config or {}).settings or {}).python or {})
		local venv_name = python_settings.venv or "系统解释器"
		table.insert(
			lines,
			string.format("    %d. %s", index, venv_name)
		)
		table.insert(lines, string.format("    目录: %s", shorten_path(client.config.root_dir or "未知根目录")))
	end

	if #pyright_clients == 0 then
		table.insert(lines, "    当前没有活动的 Pyright Client")
	end

	table.insert(lines, "")
	table.insert(lines, "  ⌨ 按 [q] 或 [<Esc>] 关闭")

	local width = 0
	for _, line in ipairs(lines) do
		width = math.max(width, vim.fn.strdisplaywidth(line))
	end

	width = math.min(math.max(width + 4, 72), math.max(vim.o.columns - 8, 60))
	local height = math.min(#lines + 2, math.max(vim.o.lines - 6, 12))

	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].filetype = "pythonvenvstatus"
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	highlight_status_buffer(buf, lines)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2) - 1,
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		title = " Python / LSP 状态 ",
		title_pos = "center",
	})

	status_view.buf = buf
	status_view.win = win

	vim.wo[win].wrap = true
	vim.wo[win].linebreak = true
	vim.wo[win].cursorline = false
	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].signcolumn = "no"
	vim.wo[win].winhighlight = "NormalFloat:Normal,FloatBorder:FloatBorder,FloatTitle:Title"

	local close_keys = { "q", "<Esc>" }
	for _, lhs in ipairs(close_keys) do
		vim.keymap.set("n", lhs, close_status_window, {
			buffer = buf,
			nowait = true,
			silent = true,
		})
	end
end

-- 启动时只按当前目录初始化一次本地状态，不触发重启。
M.autoset_venv({
	path = vim.fn.getcwd(),
	notify = false,
	restart = false,
})

vim.keymap.set("n", "<leader>pv", M.choose_venv, { desc = "Python: 选择环境" })

vim.keymap.set("n", "<leader>pr", function()
	M.set_venv(nil)
end, { desc = "Python: 退出环境" })

vim.keymap.set("n", "<leader>ps", M.show_session_status, { desc = "Python: 查看当前会话状态" })

-- 进入 Python buffer 前先同步环境，让随后 attach 的 Pyright 直接读到当前项目的解释器。
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
	pattern = "*.py",
	callback = function(args)
		M.autoset_venv({
			path = args.file,
			notify = false,
			restart = false,
		})
	end,
})

-- 切到 Python buffer 时，同步当前项目对应的本地环境状态，但不主动重启 Pyright。
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.py",
	callback = function(args)
		M.autoset_venv({
			path = args.file,
			notify = false,
			restart = false,
		})
	end,
})

vim.api.nvim_create_autocmd("DirChanged", {
	callback = function()
		local current_buf = vim.api.nvim_get_current_buf()
		if vim.bo[current_buf].filetype ~= "python" then
			return
		end

		M.autoset_venv({
			path = vim.api.nvim_buf_get_name(current_buf),
			notify = false,
			restart = false,
		})
	end,
})

return M
