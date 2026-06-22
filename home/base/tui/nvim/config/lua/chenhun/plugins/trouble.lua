return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
  opts = {
    focus = true,
  },
  cmd = "Trouble",
  keys = {
    { "<leader>xw", "<cmd>Trouble diagnostics toggle<CR>", desc = "显示工作区诊断信息" },
    { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "显示当前文件诊断信息" },
    { "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", desc = "显示 Quickfix 列表" },
    { "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "显示位置列表" },
    { "<leader>xt", "<cmd>Trouble todo toggle<CR>", desc = "在 Trouble 中显示 TODO" },
  },
}
