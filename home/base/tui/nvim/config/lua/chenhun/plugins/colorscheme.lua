return {
	"folke/tokyonight.nvim",
	priority = 1000,
	config = function()
		-- 核心：直接调用 core 文件夹里的详细配置
		require("chenhun.core.colorscheme")
	end,
}
