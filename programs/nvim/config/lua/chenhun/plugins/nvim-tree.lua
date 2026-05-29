return {
	"nvim-tree/nvim-tree.lua",
	dependencies = "nvim-tree/nvim-web-devicons",
	config = function()
		local nvimtree = require("nvim-tree")

		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		nvimtree.setup({
			-- 移除背景色干扰，确保在 colorscheme.lua 中设置的透明生效
			sync_root_with_cwd = true,
			respect_buf_cwd = true,
			view = {
				-- 行号保留给快速跳转，用更窄的宽度来平衡空间占用。
				width = 27,
				relativenumber = true,
				number = true,
				side = "left",
			},
			renderer = {
				-- 缩小缩进宽度，同时保留连续层级线和图标。
				indent_width = 1,
				group_empty = true,
				-- 开启缩进线，在透明背景下更容易看清层级
				indent_markers = {
					enable = true,
					inline_arrows = true,
					icons = {
						corner = "└",
						edge = "│",
						item = "│",
						bottom = "─",
						none = " ",
					},
				},
				icons = {
					webdev_colors = true,
					git_placement = "before",
					glyphs = {
						folder = {
							arrow_closed = "󰅂", -- 更现代的箭头符号
							arrow_open = "󰅀",
							default = "󰉋",
							open = "󰝰",
							empty = "󰜌",
							empty_open = "󰜌",
							symlink = "󰉒",
						},
						git = {
							unstaged = "✗",
							staged = "✓",
							unmerged = "",
							renamed = "➜",
							untracked = "★",
							deleted = "",
							ignored = "◌",
						},
					},
				},
			},
			-- 交互优化
			actions = {
				open_file = {
					window_picker = { enable = false },
					quit_on_open = false, -- 打开文件时不自动关闭树，方便连续操作
				},
			},
			filters = {
				custom = { ".DS_Store", "^.git$" },
			},
			git = {
				ignore = false,
			},
		})

		-- 快捷键保持不变
		local keymap = vim.keymap
		keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
		keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Find file in explorer" })
		keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse explorer" })
		keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh explorer" })
	end,
}
