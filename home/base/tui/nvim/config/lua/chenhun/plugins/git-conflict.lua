return {
	"akinsho/git-conflict.nvim",
	version = "*",
	event = { "BufReadPre", "BufNewFile" },
	cmd = {
		"GitConflictChooseOurs",
		"GitConflictChooseTheirs",
		"GitConflictChooseBoth",
		"GitConflictChooseNone",
		"GitConflictNextConflict",
		"GitConflictPrevConflict",
		"GitConflictListQf",
	},
	opts = {
		default_mappings = false,
		default_commands = true,
		disable_diagnostics = false,
		list_opener = "copen",
	},
	keys = {
		{ "<leader>go", "<cmd>GitConflictChooseOurs<CR>", desc = "Git conflict choose ours" },
		{ "<leader>gt", "<cmd>GitConflictChooseTheirs<CR>", desc = "Git conflict choose theirs" },
		{ "<leader>gb", "<cmd>GitConflictChooseBoth<CR>", desc = "Git conflict choose both" },
		{ "<leader>g0", "<cmd>GitConflictChooseNone<CR>", desc = "Git conflict choose none" },
		{
			"<leader>gn",
			"<Plug>(git-conflict-next-conflict)zt7<C-y>",
			desc = "Git conflict next and keep 7 lines above",
			remap = true,
		},
		{
			"<leader>gp",
			"<Plug>(git-conflict-prev-conflict)zt7<C-y>",
			desc = "Git conflict previous and keep 7 lines above",
			remap = true,
		},
	},
}
