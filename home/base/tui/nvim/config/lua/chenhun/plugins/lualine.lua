return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status")

		local colors = {
			blue = "#65D1FF",
			green = "#3EFFDC",
			violet = "#FF61EF",
			yellow = "#FFDA7B",
			red = "#FF4A4A",
			fg = "#c3ccdc",
			bg = "NONE",
		}

		local my_lualine_theme = {
			normal = {
				a = { bg = colors.blue, fg = "#011628", gui = "bold" },
				b = { bg = "NONE", fg = colors.violet },
				c = { bg = "NONE", fg = colors.fg },
			},
			insert = {
				a = { bg = colors.green, fg = "#011628", gui = "bold" },
			},
			visual = {
				a = { bg = colors.violet, fg = "#011628", gui = "bold" },
			},
		}

		lualine.setup({
			options = {
				theme = my_lualine_theme,
				component_separators = { left = "｜", right = "｜" },
				section_separators = { left = "", right = "" },
				globalstatus = true,
			},
			sections = {
				lualine_a = {
					{ "mode", separator = { left = "" }, right_padding = 2 },
				},
				lualine_b = {
					{ "branch", icon = "", color = { fg = colors.violet, gui = "bold" } },
					{ "diff", symbols = { added = " ", modified = " ", removed = " " } },
				},
				lualine_c = {
					-- ✅ 左侧：仅在 Python 文件中显示虚拟环境
					{
						require("chenhun.core.python_venv").lualine_component,
						color = { fg = colors.green, gui = "bold" },
						cond = function()
							return vim.bo.filetype == "python"
						end,
					},
					{
						"filename",
						file_status = true,
						path = 1,
						color = { fg = "#cbcb5a", gui = "italic" }, -- 你要求的绝对路径/文件名颜色
					},
				},
				lualine_x = {
					{
						"diagnostics",
						symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
					},
					-- ✅ 右侧：自动适配“图标 + 语言名称”（如： json）
					{
						"filetype",
						colored = true, -- 显示图标原本的颜色
						icon_only = false, -- 同时显示文字
						icon = { align = "left" },
						color = { fg = colors.blue, gui = "bold" },
					},
					{ lazy_status.updates, cond = lazy_status.has_updates, color = { fg = "#ff9e64" } },
				},
				lualine_y = { "progress" },
				lualine_z = {
					{ "location", separator = { right = "" }, left_padding = 2 },
				},
			},
		})
	end,
}
