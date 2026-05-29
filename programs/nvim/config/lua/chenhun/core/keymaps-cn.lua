local keymap = vim.keymap.set

local function register_which_key_zh()
	local ok, which_key = pcall(require, "which-key")
	if not ok then
		return false
	end

	which_key.add({
		{ "af", desc = "选择函数外层", mode = { "o", "x" } },
		{ "if", desc = "选择函数内层", mode = { "o", "x" } },
		{ "ac", desc = "选择类外层", mode = { "o", "x" } },
		{ "ic", desc = "选择类内层", mode = { "o", "x" } },
		{ "aa", desc = "选择参数外层", mode = { "o", "x" } },
		{ "ia", desc = "选择参数内层", mode = { "o", "x" } },
		{ "]m", desc = "跳到下一个函数开始" },
		{ "]M", desc = "跳到下一个函数结束" },
		{ "[m", desc = "跳到上一个函数开始" },
		{ "[M", desc = "跳到上一个函数结束" },
		{ "]]", desc = "跳到下一个类开始" },
		{ "][", desc = "跳到下一个类结束" },
		{ "[[", desc = "跳到上一个类开始" },
		{ "[]", desc = "跳到上一个类结束" },
	})

	return true
end

if not register_which_key_zh() then
	vim.api.nvim_create_autocmd("User", {
		pattern = "VeryLazy",
		once = true,
		callback = register_which_key_zh,
	})
end

-- ======================
-- General（通用）
-- ======================
keymap("i", "jk", "<ESC>", { desc = "退出插入模式（jk）" })

keymap("n", "<leader>nh", ":nohl<CR>", { desc = "清除搜索高亮" })

keymap("n", "<leader>+", "<C-a>", { desc = "数字加一" })
keymap("n", "<leader>-", "<C-x>", { desc = "数字减一" })

keymap("n", "<leader>sv", "<C-w>v", { desc = "垂直分屏" })
keymap("n", "<leader>sh", "<C-w>s", { desc = "水平分屏" })
keymap("n", "<leader>se", "<C-w>=", { desc = "均分窗口大小" })
keymap("n", "<leader>sx", "<cmd>close<CR>", { desc = "关闭当前分屏" })

-- ======================
-- Tabs（标签页）
-- ======================
keymap("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "新建标签页" })
keymap("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "关闭当前标签页" })
keymap("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "下一个标签页" })
keymap("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "上一个标签页" })
keymap("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "当前文件在新标签页打开" })

-- ======================
-- Auto Session（会话管理）
-- ======================
keymap("n", "<leader>wr", "<cmd>AutoSession restore<CR>", {
	desc = "恢复当前目录的会话",
})

keymap("n", "<leader>ws", "<cmd>AutoSession save<CR>", {
	desc = "保存当前目录的会话",
})

keymap("n", "<leader>wf", "<cmd>AutoSession search<CR>", {
	desc = "搜索、恢复或删除已保存会话",
})

keymap("n", "<leader>wa", "<cmd>AutoSession toggle<CR>", {
	desc = "切换会话自动保存",
})

-- ======================
-- Python Venv（Python 虚拟环境）
-- ======================
keymap("n", "<leader>pv", require("chenhun.core.python_venv").choose_venv, {
	desc = "选择 Python 虚拟环境",
})

keymap("n", "<leader>pr", function()
	require("chenhun.core.python_venv").set_venv(nil)
end, {
	desc = "退出当前 Python 虚拟环境",
})

keymap("n", "<leader>ps", require("chenhun.core.python_venv").show_session_status, {
	desc = "查看当前 Neovim 的 Python/LSP 状态",
})

-- ======================
-- Treesitter Textobjects（语法对象）
-- ======================

-- ======================
-- Dropbar（面包屑导航）
-- ======================
keymap("n", "<leader>;", function()
	require("dropbar.api").pick()
end, {
	desc = "选择 winbar 中的符号",
})

keymap("n", "[;", function()
	require("dropbar.api").goto_context_start()
end, {
	desc = "跳到当前上下文开头",
})

keymap("n", "];", function()
	require("dropbar.api").select_next_context()
end, {
	desc = "选择下一个上下文",
})

-- ======================
-- File Explorer（文件树）
-- ======================

keymap("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", {
	desc = "切换文件树显示",
})

keymap("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", {
	desc = "在文件树中定位当前文件",
})

keymap("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", {
	desc = "折叠文件树",
})

keymap("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", {
	desc = "刷新文件树",
})

-- ======================
-- Search / Telescope（搜索）
-- ======================
keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", {
	desc = "模糊查找当前目录下的文件",
})

keymap("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", {
	desc = "查找最近打开的文件",
})

keymap("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", {
	desc = "在当前目录中搜索字符串",
})

keymap("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", {
	desc = "搜索光标下的字符串",
})

keymap("n", "<leader>ft", "<cmd>TodoTelescope<cr>", {
	desc = "查找待办事项（TODO）",
})

-- ======================
-- Noice（消息与通知）
-- ======================
keymap("n", "<leader>nn", "<cmd>Noice<CR>", {
	desc = "打开 Noice 面板",
})

keymap("n", "<leader>nl", "<cmd>Noice last<CR>", {
	desc = "查看上一条 Noice 消息",
})

keymap("n", "<leader>na", "<cmd>Noice all<CR>", {
	desc = "查看所有 Noice 消息",
})

keymap("n", "<leader>nd", "<cmd>Noice dismiss<CR>", {
	desc = "清除 Noice 通知",
})

-- ======================
-- TODO Comments（待办跳转）
-- ======================
keymap("n", "]t", function()
	require("todo-comments").jump_next()
end, {
	desc = "跳转到下一个 TODO",
})

keymap("n", "[t", function()
	require("todo-comments").jump_prev()
end, {
	desc = "跳转到上一个 TODO",
})

-- ======================
-- Substitute（快速替换）
-- ======================

keymap("n", "s", require("substitute").operator, {
	desc = "按动作替换文本",
})

keymap("n", "ss", require("substitute").line, {
	desc = "替换当前行",
})

keymap("n", "S", require("substitute").eol, {
	desc = "替换至行尾",
})

keymap("x", "s", require("substitute").visual, {
	desc = "在可视模式下替换",
})

-- ======================
-- Git UI（LazyGit
--=====================

keymap("n", "<leader>lg", "<cmd>LazyGit<cr>", {
	desc = "打开 LazyGit",
})

-- ======================
-- ToggleTerm（终端）
-- ======================
keymap("n", "<leader>tt", "<cmd>ToggleTerm direction=float<CR>", {
	desc = "切换浮动终端",
})

keymap("n", "<leader>th", "<cmd>ToggleTerm size=15 direction=horizontal<CR>", {
	desc = "切换水平终端",
})

-- ======================
-- Trouble（诊断面板）
-- ======================

keymap("n", "<leader>xw", "<cmd>Trouble diagnostics toggle<CR>", {
	desc = "显示工作区诊断信息",
})

keymap("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", {
	desc = "显示当前文件诊断信息",
})

keymap("n", "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", {
	desc = "显示 Quickfix 列表",
})

keymap("n", "<leader>xl", "<cmd>Trouble loclist toggle<CR>", {
	desc = "显示位置列表（Loclist）",
})

keymap("n", "<leader>xt", "<cmd>Trouble todo toggle<CR>", {
	desc = "在 Trouble 中显示 TODO",
})

-- ======================
-- Formatting / Lint（格式化与检查）
-- ======================
keymap({ "n", "v" }, "<leader>mp", function()
	require("conform").format({
		lsp_fallback = true,
		async = false,
		timeout_ms = 1000,
	})
end, {
	desc = "格式化当前文件或所选内容",
})

keymap("n", "<leader>l", function()
	require("lint").try_lint()
end, {
	desc = "立即运行当前文件的代码检查",
})

-- ======================
-- GitSigns（Git 变更）
-- ======================
keymap("n", "]h", function()
	require("gitsigns").next_hunk()
end, {
	desc = "跳转到下一个变更块",
})

keymap("n", "[h", function()
	require("gitsigns").prev_hunk()
end, {
	desc = "跳转到上一个变更块",
})

keymap("n", "<leader>hs", function()
	require("gitsigns").stage_hunk()
end, {
	desc = "暂存当前变更块",
})

keymap("n", "<leader>hr", function()
	require("gitsigns").reset_hunk()
end, {
	desc = "撤销当前变更块",
})

keymap("v", "<leader>hs", function()
	require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, {
	desc = "暂存所选变更块",
})

keymap("v", "<leader>hr", function()
	require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, {
	desc = "撤销所选变更块",
})

keymap("n", "<leader>hS", function()
	require("gitsigns").stage_buffer()
end, {
	desc = "暂存当前文件的所有变更",
})

keymap("n", "<leader>hR", function()
	require("gitsigns").reset_buffer()
end, {
	desc = "撤销当前文件的所有变更",
})

keymap("n", "<leader>hu", function()
	require("gitsigns").undo_stage_hunk()
end, {
	desc = "取消暂存当前变更块",
})

keymap("n", "<leader>hp", function()
	require("gitsigns").preview_hunk()
end, {
	desc = "预览当前变更块",
})

keymap("n", "<leader>hb", function()
	require("gitsigns").blame_line({ full = true })
end, {
	desc = "查看当前行的完整 Git 归属",
})

keymap("n", "<leader>hB", function()
	require("gitsigns").toggle_current_line_blame()
end, {
	desc = "切换当前行 Git 归属显示",
})

keymap("n", "<leader>hd", function()
	require("gitsigns").diffthis()
end, {
	desc = "对比当前文件变更",
})

keymap("n", "<leader>hD", function()
	require("gitsigns").diffthis("~")
end, {
	desc = "对比当前文件与上一个版本的差异",
})

keymap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", {
	desc = "选择当前变更块",
})

-- ======================
-- Window Layout（窗口布局）
-- ======================
-- 强制加载maximizer插件
require("lazy").load({ plugins = { "vim-maximizer" } })

keymap("n", "<leader>sm", "<cmd>MaximizerToggle<CR>", {
	desc = "最大化 / 还原当前窗口",
})

-- ======================
-- Git Conflict（Git 冲突处理）
-- ======================
keymap("n", "<leader>go", "<cmd>GitConflictChooseOurs<CR>", {
	desc = "冲突块选择当前分支版本（ours）",
})

keymap("n", "<leader>gt", "<cmd>GitConflictChooseTheirs<CR>", {
	desc = "冲突块选择目标分支版本（theirs）",
})

keymap("n", "<leader>gb", "<cmd>GitConflictChooseBoth<CR>", {
	desc = "冲突块同时保留双方内容",
})

keymap("n", "<leader>g0", "<cmd>GitConflictChooseNone<CR>", {
	desc = "冲突块清空双方内容",
})

-- 这里是你的定制化行为，不完全等同于 git-conflict 插件原始默认行为。
-- 原插件的前后跳转只负责移动到冲突块；这里保留插件原始跳转能力，
-- 但在跳转后追加 `zt7<C-y>`，先把当前光标行置顶，再向上回卷 7 行，
-- 也就是给顶部留出 7 行上下文空间。这样既能沿用插件自己的落点，
-- 又能让后续冲突内容尽量完整地留在视野里。
keymap("n", "<leader>gn", "<Plug>(git-conflict-next-conflict)zt7<C-y>", {
	remap = true,
	desc = "跳转到下一个 Git 冲突块，并在顶部保留 7 行上下文",
})

keymap("n", "<leader>gp", "<Plug>(git-conflict-prev-conflict)zt7<C-y>", {
	remap = true,
	desc = "跳转到上一个 Git 冲突块，并在顶部保留 7 行上下文",
})
-- ======================
-- vim suda（nvim获取 sudo 权限）
-- ======================

keymap("n", "<leader>sw", "<cmd>SudaWrite<CR>", {
	desc = "sudo写权限",
})
keymap("n", "<leader>sr", "<cmd>SudaRead<CR>", {
	desc = "sudo读权限",
})
