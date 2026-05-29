return {
  "akinsho/toggleterm.nvim",
  version = "*",
  cmd = { "ToggleTerm", "TermExec" },
  keys = {
    { "<leader>tt", "<cmd>ToggleTerm direction=float<CR>", desc = "Toggle floating terminal" },
    { "<leader>th", "<cmd>ToggleTerm size=15 direction=horizontal<CR>", desc = "Toggle horizontal terminal" },
  },
  opts = {
    open_mapping = [[<c-\>]],
    direction = "float",
    float_opts = {
      border = "curved",
    },
  },
}
