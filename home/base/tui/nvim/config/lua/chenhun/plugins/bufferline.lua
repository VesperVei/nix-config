return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	version = "*",
	config = function()
		require("bufferline").setup({
			options = {
				mode = "tabs", -- 严格保持你的原有标签页模式
				separator_style = "rounded", -- 仅保留圆角边框样式
				show_buffer_close_icons = false,
				show_close_icon = false,
				-- 去掉了 offsets 配置，左上角将恢复默认或不显示额外标题
			},
			highlights = {
				-- 仅保留透明背景处理，确保它能透出你的 Kitty 毛玻璃效果
				fill = {
					bg = "NONE",
				},
				background = {
					bg = "NONE",
				},
				tab = {
					bg = "NONE",
				},
				tab_selected = {
					bg = "NONE",
				},
				separator = {
					bg = "NONE",
				},
				separator_selected = {
					bg = "NONE",
				},
			},
		})
	end,
}
