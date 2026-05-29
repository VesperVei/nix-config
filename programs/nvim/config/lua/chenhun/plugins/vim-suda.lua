return {
	"lambdalisue/vim-suda",
	lazy = false,
	init = function()
		vim.g.suda_smart_edit = 1
	end,
	keys = {
		{ "<leader>sw", "<cmd>SudaWrite<CR>", desc = "Suda Write" },
		{ "<leader>sr", "<cmd>SudaRead<CR>", desc = "Suda Read" },
	},
}
