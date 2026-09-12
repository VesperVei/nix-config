local M = {}

local home = vim.loop.os_homedir() or ""
local python3 = vim.fn.exepath("python3")
local config = {
  venv_root = vim.env.CHENHUN_PYTHON_VENV_ROOT or (home .. "/.py_venvs"),
  default_bin = python3 ~= "" and python3 or "python3",
  icon = "🐍 ",
}

local cache = {
  current = nil,
  current_python_path = config.default_bin,
  current_project_root = nil,
  project_overrides = {},
  manual_fallback = nil,
  active_venv_path = nil,
  warnings = {},
}

local status_view = { buf = nil, win = nil }

local function normalize(path)
  if not path or path == "" then return nil end
  return vim.fs.normalize(path)
end

local function path_to_directory(path)
  local value = normalize(path)
  if not value then return nil end
  local stat = vim.uv.fs_stat(value)
  if stat and stat.type ~= "directory" then return vim.fs.dirname(value) end
  return value
end

local function is_directory(path)
  local stat = vim.uv.fs_stat(path)
  return stat and stat.type == "directory"
end

local function is_file(path)
  local stat = vim.uv.fs_stat(path)
  if not stat or stat.type ~= "file" then return false end
  local file = io.open(path, "r")
  if not file then return false end
  file:close()
  return true
end

local function is_shared_name(value)
  return type(value) == "string"
    and value ~= ""
    and value ~= "."
    and value ~= ".."
    and not value:match("^/")
    and not value:find("/", 1, true)
    and not value:find("..", 1, true)
end

local function is_usable_python(path)
  return is_file(path) and vim.fn.executable(path) == 1
end

local function in_scope(path, root)
  return path == root or path:sub(1, #root + 1) == root .. "/"
end

local function get_current_path()
  local path = vim.api.nvim_buf_get_name(0)
  return path ~= "" and path or vim.fn.getcwd()
end

local function shorten_path(path)
  local value = normalize(path)
  if not value then return "[无路径]" end
  local user_home = normalize(vim.loop.os_homedir() or "")
  if user_home and in_scope(value, user_home) then return "~" .. value:sub(#user_home + 1) end
  return value
end

local function resolve_project_root(path)
  local directory = path_to_directory(path)
  if not directory then return nil end
  local current = directory
  while current do
    if is_file(current .. "/.pyvenv") then return current end
    for _, marker in ipairs({ "pyproject.toml", "setup.py", "setup.cfg", ".git" }) do
      if vim.uv.fs_stat(current .. "/" .. marker) then return current end
    end
    if current == "/" then break end
    local parent = vim.fs.dirname(current)
    if parent == current then break end
    current = parent
  end
  return nil
end

local function record(kind, name, path)
  local value = {
    kind = kind,
    name = name,
    path = path,
    venv_path = path,
    venv_name = name,
  }
  if kind == "system" then
    value.path, value.venv_path, value.name, value.venv_name = nil, nil, nil, nil
    value.python_path = config.default_bin
  elseif path then
    value.python_path = path .. "/bin/python"
  end
  return value
end

local function warn_broken(key, path)
  if cache.warnings[key] then return end
  cache.warnings[key] = true
  vim.notify(
    "Python environment is missing or unusable: " .. path
      .. ". Rebuild with: uv venv --python " .. config.default_bin .. " " .. path,
    vim.log.levels.WARN
  )
end

local function validate(value)
  local path
  if value == "system" or value == nil or value == "" then return record("system") end
  if value:sub(1, 1) == "/" then
    path = normalize(value)
    if not path or not is_directory(path) then
      warn_broken("local:" .. tostring(value), value)
      return record("broken", ".venv", path or value)
    end
  elseif not is_shared_name(value) then
    local invalid_path = config.venv_root .. "/" .. tostring(value)
    warn_broken("invalid:" .. tostring(value), invalid_path)
    return record("system")
  else
    path = normalize(config.venv_root .. "/" .. value)
  end
  local result = record(value:sub(1, 1) == "/" and "local" or "shared", value:sub(1, 1) == "/" and ".venv" or value, path)
  if not is_usable_python(result.python_path) then
    warn_broken(result.kind .. ":" .. tostring(result.name or result.path), path)
    result.kind = "broken"
    result.python_path = config.default_bin
  end
  return result
end

local function read_declared_name(root)
  if not root or not is_file(root .. "/.pyvenv") then return nil end
  local ok, lines = pcall(vim.fn.readfile, root .. "/.pyvenv")
  if not ok then return nil end
  for _, line in ipairs(lines) do
    local name = vim.trim(line)
    if name ~= "" then return name end
  end
  return nil
end

local function find_local_venv(path)
  local current = path_to_directory(path)
  while current do
    local candidate = current .. "/.venv"
    if is_directory(candidate) then return normalize(candidate) end
    if current == "/" then break end
    local parent = vim.fs.dirname(current)
    if parent == current then break end
    current = parent
  end
  return nil
end

local function resolve_state(path, opts)
  opts = opts or {}
  local target = path or get_current_path()
  local root = resolve_project_root(target)
  local selection
  if opts.manual ~= nil then
    selection = opts.manual
    if type(selection) == "string" and selection:sub(1, 1) == "/" then
      local local_path = find_local_venv(target)
      if not local_path or normalize(selection) ~= local_path then
        warn_broken("local-boundary:" .. selection, selection)
        selection = "system"
      end
    end
  elseif root and cache.project_overrides[root] ~= nil then
    selection = cache.project_overrides[root]
  elseif root then
    selection = find_local_venv(target)
    if not selection then selection = read_declared_name(root) end
  elseif cache.manual_fallback and normalize(target) == cache.manual_fallback.target then
    selection = cache.manual_fallback.value
  end
  local state = validate(selection)
  state.project_root = root
  state.target_dir = path_to_directory(target)
  return state
end

local function pyright_settings(state)
  local settings = { pythonPath = state.python_path }
  if state.kind == "local" then
    settings.venvPath = vim.fs.dirname(state.path)
    settings.venv = vim.fs.basename(state.path)
  elseif state.kind == "shared" then
    settings.venvPath = config.venv_root
    settings.venv = state.name
  end
  return settings
end

local function refresh_lualine()
  local ok, lualine = pcall(require, "lualine")
  if ok then lualine.refresh() end
end

local function same_scope(client, state)
  local client_root = normalize((client.config or {}).root_dir)
  local root = normalize(state.project_root)
  if not client_root or not root then return false end
  return client_root == root or in_scope(client_root, root)
end

local function sync_pyright(state)
  local next_settings = { python = pyright_settings(state) }
  for _, client in ipairs(vim.lsp.get_clients({ name = "pyright" })) do
    if same_scope(client, state) then
      client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, next_settings)
      client.settings = vim.tbl_deep_extend("force", client.settings or {}, next_settings)
      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
  end
end

local function apply_state(state, opts)
  opts = vim.tbl_extend("force", { restart = true, notify = true, force_refresh = false }, opts or {})
  local effective = state.kind == "broken" and record("system") or state
  effective.project_root = state.project_root
  effective.target_dir = state.target_dir
  local current_key = effective.kind == "system" and nil or (effective.kind == "local" and effective.path or effective.name)
  local changed = cache.current ~= current_key or cache.current_python_path ~= effective.python_path
    or cache.current_project_root ~= state.project_root
  if cache.active_venv_path then
    local old_bin = cache.active_venv_path .. "/bin"
    local parts = {}
    for part in string.gmatch(vim.env.PATH or "", "[^:]+") do
      if part ~= old_bin then table.insert(parts, part) end
    end
    vim.env.PATH = table.concat(parts, ":")
  end
  vim.g.python3_host_prog = effective.python_path
  if effective.kind == "local" or effective.kind == "shared" then
    vim.env.VIRTUAL_ENV = effective.path
    vim.env.PATH = effective.path .. "/bin:" .. (vim.env.PATH or "")
    cache.active_venv_path = effective.path
  else
    vim.env.VIRTUAL_ENV = nil
    cache.active_venv_path = nil
  end
  cache.current, cache.current_python_path, cache.current_project_root = current_key, effective.python_path, state.project_root
  refresh_lualine()
  if (changed or opts.force_refresh) and opts.restart then sync_pyright(effective) end
  return changed
end

function M.resolve_project_root(path) return resolve_project_root(path) end
function M.get_current_venv() return cache.current end
function M.get_current_python_path() return cache.current_python_path end
function M.get_pyright_client_name() return "pyright" end
function M.is_managed_pyright_client(client) return client and client.name == "pyright" end
function M.register_managed_pyright() end
function M.cleanup_ghost_pyright() return false end
function M.get_pyright_python_settings_for_path(path) return pyright_settings(resolve_state(path)) end
function M.get_pyright_python_settings() return M.get_pyright_python_settings_for_path(get_current_path()) end
function M.sync_for_path(path, opts) return apply_state(resolve_state(path), opts) end

function M.set_venv(value, opts)
  opts = vim.tbl_extend("force", { path = get_current_path() }, opts or {})
  local root = resolve_project_root(opts.path)
  local local_path = find_local_venv(opts.path)
  if value and value:sub(1, 1) == "/" and (not local_path or normalize(value) ~= local_path) then
    return false
  end
  local state = resolve_state(opts.path, { manual = value or "system" })
  if state.kind == "broken" then return false end
  if root then
    cache.project_overrides[root] = value or "system"
  else
    cache.manual_fallback = { value = value or "system", target = normalize(opts.path) }
  end
  return apply_state(state, { restart = true, notify = true })
end

local function list_choices(path)
  local choices = {}
  local local_path = find_local_venv(path)
  if local_path and is_directory(local_path) then table.insert(choices, record("local", ".venv", local_path)) end
  local entries = {}
  local ok, iterator = pcall(vim.fs.dir, config.venv_root)
  if ok and iterator then
    for name, type in iterator do
      if type == "directory" then table.insert(entries, name) end
    end
  end
  table.sort(entries)
  for _, name in ipairs(entries) do table.insert(choices, validate(name)) end
  table.insert(choices, record("system"))
  return choices
end

function M.choose_venv()
  local choices = list_choices(get_current_path())
  local labels, by_label = {}, {}
  for index, choice in ipairs(choices) do
    local label = config.icon .. (choice.kind == "local" and "local: .venv" or choice.kind == "shared" and "shared: " .. choice.name or "system")
    if choice.kind == "broken" then label = label .. " (broken)" end
    labels[index], by_label[label] = label, choice
  end
  vim.ui.select(labels, { prompt = "Select Python environment: " }, function(label)
    if label then
      local choice = by_label[label]
      M.set_venv(choice.kind == "system" and "system" or choice.kind == "local" and choice.path or choice.name)
    end
  end)
end

function M.on_pyright_attach(bufnr)
  local state = resolve_state(vim.api.nvim_buf_get_name(bufnr))
  apply_state(state, { restart = false, notify = false })
end

function M.autoset_venv(opts)
  opts = vim.tbl_extend("force", { path = get_current_path(), notify = false, restart = false }, opts or {})
  return M.sync_for_path(opts.path, opts)
end

function M.lualine_component()
  if not cache.current then return "" end
  local label = cache.current:sub(1, 1) == "/" and vim.fs.basename(cache.current) or cache.current
  return config.icon .. label
end

local function close_status_window()
  if status_view.win and vim.api.nvim_win_is_valid(status_view.win) then vim.api.nvim_win_close(status_view.win, true) end
  status_view.win, status_view.buf = nil, nil
end

function M.show_session_status()
  if status_view.win and vim.api.nvim_win_is_valid(status_view.win) then close_status_window(); return end
  local visible_windows, python_buffers = 0, 0
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(winid) then visible_windows = visible_windows + 1 end
  end
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype == "python" then python_buffers = python_buffers + 1 end
  end
  local clients = vim.lsp.get_clients({ name = "pyright" })
  local lines = {
    "Python / LSP session status",
    "",
    "  File: " .. shorten_path(vim.api.nvim_buf_get_name(0)),
    "  Environment: " .. (cache.current or "system"),
    "  Interpreter: " .. shorten_path(cache.current_python_path),
    "",
    "  Session overview",
    "    Windows: " .. visible_windows,
    "    Tabs: " .. #vim.api.nvim_list_tabpages(),
    "    Python buffers: " .. python_buffers,
    "",
    "  Pyright clients: " .. #clients,
  }
  for index, client in ipairs(clients) do
    local settings = (((client.config or {}).settings or {}).python or {})
    table.insert(lines, string.format("    %d. %s", index, settings.venv or "system"))
    table.insert(lines, "    Root: " .. shorten_path((client.config or {}).root_dir or "unknown"))
    table.insert(lines, "    Python: " .. shorten_path(settings.pythonPath or config.default_bin))
  end
  if #clients == 0 then table.insert(lines, "    No active Pyright client") end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden, vim.bo[buf].modifiable = "wipe", true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  local width = 0
  for _, line in ipairs(lines) do width = math.max(width, vim.fn.strdisplaywidth(line)) end
  width = math.min(math.max(width + 4, 72), math.max(vim.o.columns - 8, 60))
  local height = math.min(#lines + 2, math.max(vim.o.lines - 6, 12))
  local win = vim.api.nvim_open_win(buf, true, { relative = "editor", width = width, height = height, row = math.floor((vim.o.lines - height) / 2) - 1, col = math.floor((vim.o.columns - width) / 2), style = "minimal", border = "rounded", title = " Python / LSP status ", title_pos = "center" })
  status_view.buf, status_view.win = buf, win
  vim.keymap.set("n", "q", close_status_window, { buffer = buf, nowait = true, silent = true })
  vim.keymap.set("n", "<Esc>", close_status_window, { buffer = buf, nowait = true, silent = true })
end

M._test = {
  resolve_project_root = resolve_project_root,
  resolve_state = function(path, opts) return resolve_state(path, opts) end,
  list_choices = list_choices,
}

M.autoset_venv({ path = vim.fn.getcwd(), notify = false, restart = false })

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile", "BufEnter" }, {
  pattern = "*.py",
  callback = function(args) M.autoset_venv({ path = args.file, notify = false, restart = false }) end,
})
vim.api.nvim_create_autocmd("DirChanged", {
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.bo[bufnr].filetype == "python" then M.autoset_venv({ path = vim.api.nvim_buf_get_name(bufnr), notify = false, restart = false }) end
  end,
})

return M
