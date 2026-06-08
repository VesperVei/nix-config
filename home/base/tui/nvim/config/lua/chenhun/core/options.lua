vim.cmd("let g:netrw_liststyle = 3")
local opt = vim.opt -- for conciseness
-- line numbers
opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- line wrapping
opt.wrap = false

-- search settings
opt.ignorecase = true
opt.smartcase = true

-- cursor line
opt.cursorline = true

-- appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- backspace

opt.backspace = "indent,eol,start"

-- clipboard
opt.clipboard:append("unnamedplus")

-- split windows
opt.splitright = true
opt.splitbelow = true
opt.iskeyword:append("_")

-- 1. 隐藏命令行：设为 0 只有在报错或输入命令时才显现（Neovim 0.8+ 支持）
opt.cmdheight = 0

-- 2. 隐藏模式：既然 Lualine 已经有 INSERT 块了，底部的文字就是多余的
opt.showmode = false

-- 3. 确保全局状态栏开启
opt.laststatus = 3
