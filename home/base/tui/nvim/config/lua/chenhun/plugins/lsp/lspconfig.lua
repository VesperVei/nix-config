return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local lspconfig = require("lspconfig")
		local lspconfig_util = require("lspconfig.util")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		-- Python venv 模块是 Pyright 的唯一环境状态来源。
		local python_venv = require("chenhun.core.python_venv")

		local keymap = vim.keymap

		-- ========== LSP Keymaps (保持你原有的配置) ==========
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }
				local client = vim.lsp.get_client_by_id(ev.data.client_id)

				if client and client.name == "pyright" then
					python_venv.on_pyright_attach(ev.buf)
				end

				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
				keymap.set("n", "K", vim.lsp.buf.hover, opts)
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
			end,
		})

		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- ========== Diagnostic Icons (保持不变) ==========
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- 像 VSCode 一样在行尾显示诊断信息（LSP 与 nvim-lint 共用）
		vim.diagnostic.config({
			-- 行内 extmark 很难做出真正“悬浮卡片”的质感。
			-- 这里关闭原生 virtual_text，改为保留 signs/underline，
			-- 再配合下方的自动诊断浮窗，得到更统一的圆角浮层效果。
			virtual_text = false,
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
			float = {
				border = "rounded",
				source = "if_many",
				focusable = false,
				header = "",
				prefix = "",
			},
		})

		-- 让诊断浮窗同时在普通模式和插入模式可用，但要避免和补全菜单/签名窗重叠。
		-- 这里的策略是：有其他浮窗在前台时，诊断先让路；等界面空下来再补弹。
		local function has_active_popup()
			if vim.fn.pumvisible() == 1 then
				return true
			end

			local current_win = vim.api.nvim_get_current_win()
			for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
				if win ~= current_win then
					local config = vim.api.nvim_win_get_config(win)
					if config.relative ~= "" then
						return true
					end
				end
			end

			return false
		end

		local function open_diagnostic_float()
			local bufnr = vim.api.nvim_get_current_buf()
			if vim.bo[bufnr].buftype ~= "" then
				return
			end

			if has_active_popup() then
				return
			end

			local line = vim.api.nvim_win_get_cursor(0)[1] - 1
			local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })
			if vim.tbl_isempty(diagnostics) then
				return
			end

			vim.diagnostic.open_float(bufnr, {
				scope = "line",
				focusable = false,
				close_events = { "CursorMoved", "CursorMovedI", "InsertEnter", "BufLeave", "WinLeave" },
				border = "rounded",
				source = "if_many",
				header = "",
				prefix = "",
			})
		end

		vim.opt.updatetime = math.min(vim.o.updatetime, 180)

		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			group = vim.api.nvim_create_augroup("UserDiagnosticFloat", { clear = true }),
			callback = open_diagnostic_float,
		})

		vim.api.nvim_create_autocmd({ "CompleteDone", "InsertLeave" }, {
			group = vim.api.nvim_create_augroup("UserDiagnosticFloatResume", { clear = true }),
			callback = function()
				vim.defer_fn(open_diagnostic_float, 80)
			end,
		})

		local function build_pyright_settings_for_path(path)
			return {
				python = vim.tbl_deep_extend("force", python_venv.get_pyright_python_settings_for_path(path), {
					analysis = {
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
						diagnosticMode = "workspace",
						diagnosticSeverityOverrides = {
							reportWildcardImportFromLibrary = "none",
						},
					},
				}),
			}
		end

		local function resolve_pyright_root(bufnr)
			local bufname = vim.api.nvim_buf_get_name(bufnr)
			if bufname == "" then
				return vim.fn.getcwd()
			end

			return python_venv.resolve_project_root(bufname)
				or lspconfig_util.root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git")(
					bufname
				)
				or vim.fs.dirname(vim.fs.normalize(bufname))
		end

		local function sync_pyright_client_settings(client, settings)
			client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, settings)
			client.settings = vim.tbl_deep_extend("force", client.settings or {}, settings)
			client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
		end

		local function start_pyright(bufnr)
			if
				not vim.api.nvim_buf_is_valid(bufnr)
				or vim.bo[bufnr].buftype ~= ""
				or vim.bo[bufnr].filetype ~= "python"
			then
				return
			end

			local root_dir = resolve_pyright_root(bufnr)
			if not root_dir or root_dir == "" then
				return
			end

			local bufname = vim.api.nvim_buf_get_name(bufnr)
			local settings = build_pyright_settings_for_path(bufname ~= "" and bufname or root_dir)

			vim.lsp.start({
				name = "pyright",
				cmd = { "pyright-langserver", "--stdio" },
				root_dir = root_dir,
				cmd_cwd = root_dir,
				workspace_folders = {
					{
						uri = vim.uri_from_fname(root_dir),
						name = root_dir,
					},
				},
				capabilities = capabilities,
				settings = settings,
			}, {
				bufnr = bufnr,
				reuse_client = function(client, config)
					if client.name ~= "pyright" then
						return false
					end

					if client.config.root_dir ~= config.root_dir then
						return false
					end

					sync_pyright_client_settings(client, config.settings or {})
					return true
				end,
			})
		end

		-- 所有 server 只在这里注册一次，避免重复 attach 造成双诊断。
		local handlers = {
			function(server_name)
				lspconfig[server_name].setup({
					capabilities = capabilities,
				})
			end,

			["lua_ls"] = function()
				lspconfig.lua_ls.setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
							completion = { callSnippet = "Replace" },
						},
					},
				})
			end,

			["clangd"] = function()
				lspconfig.clangd.setup({
					capabilities = capabilities,
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--completion-style=detailed",
						"--header-insertion=never",
					},
					filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
				})
			end,
		}

		-- 启用的 LSP 列表
		local servers = {
			"clangd",
			"lua_ls",
			"ts_ls",
			"html",
			"cssls",
			"graphql",
			"emmet_ls",
			"svelte",
			"bashls",
			"jsonls",
		}

		for _, server_name in ipairs(servers) do
			if handlers[server_name] then
				handlers[server_name]()
			else
				lspconfig[server_name].setup({
					capabilities = capabilities,
				})
			end
		end

		if vim.fn.executable("nil") == 1 then
			lspconfig.nil_ls.setup({
				capabilities = capabilities,
			})
		elseif vim.fn.executable("nixd") == 1 then
			lspconfig.nixd.setup({
				capabilities = capabilities,
			})
		end

		-- Pyright 不能使用 lspconfig 默认的“同名 client 直接复用”策略。
		-- 否则先打开 pwn、再打开 crypto 时，第二个项目会被挂到第一个 client 上，
		-- 导致 workspace folders 混在一起，而解释器设置仍然停留在第一次启动的项目。
		-- 这里改成手动启动：
		-- 1. 只复用同一个 root_dir 的 pyright client
		-- 2. 不同 root_dir 强制使用独立 client
		-- 3. 同根复用时同步 settings，避免手动切换 venv 后 client 状态陈旧
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("UserPyrightConfig", { clear = true }),
			pattern = "python",
			callback = function(args)
				start_pyright(args.buf)
			end,
		})
	end,
}
