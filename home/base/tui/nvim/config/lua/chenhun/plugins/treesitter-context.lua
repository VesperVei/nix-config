return {
  "nvim-treesitter/nvim-treesitter-context",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    max_lines = 4,
    multiline_threshold = 1,
  },
}
