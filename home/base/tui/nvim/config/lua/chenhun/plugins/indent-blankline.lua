return {
	"lukas-reineke/indent-blankline.nvim",
	event = { "BufReadPre", "BufNewFile" },
	main = "ibl",
	config = function()
		local hooks = require("ibl.hooks")

		-- 这组颜色同时服务于彩虹缩进和 rainbow-delimiters，保持整体视觉一致。
		-- 缩进线恢复为连续竖线；当前作用域单独用偏青色高亮，和你的背景更协调。
		hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
			vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = "#E06C75" })
			vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = "#E5C07B" })
			vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = "#61AFEF" })
			vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = "#D19A66" })
			vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { fg = "#98C379" })
			vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = "#C678DD" })
			vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = "#56B6C2" })
			vim.api.nvim_set_hl(0, "IndentScopeCyan", { fg = "#7DD3CF", bold = true })
		end)

		require("ibl").setup({
			indent = {
				char = "│",
				highlight = {
					"RainbowDelimiterRed",
					"RainbowDelimiterYellow",
					"RainbowDelimiterBlue",
					"RainbowDelimiterOrange",
					"RainbowDelimiterGreen",
					"RainbowDelimiterViolet",
					"RainbowDelimiterCyan",
				},
			},
			scope = {
				enabled = true,
				highlight = {
					"IndentScopeCyan",
				},
			},
		})
	end,
}
