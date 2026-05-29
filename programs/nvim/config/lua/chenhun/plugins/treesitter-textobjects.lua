return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  keys = {
    {
      "af",
      function()
        require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
      end,
      desc = "Select around function",
      mode = { "o", "x" },
    },
    {
      "if",
      function()
        require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
      end,
      desc = "Select inside function",
      mode = { "o", "x" },
    },
    {
      "ac",
      function()
        require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
      end,
      desc = "Select around class",
      mode = { "o", "x" },
    },
    {
      "ic",
      function()
        require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
      end,
      desc = "Select inside class",
      mode = { "o", "x" },
    },
    {
      "aa",
      function()
        require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer", "textobjects")
      end,
      desc = "Select around parameter",
      mode = { "o", "x" },
    },
    {
      "ia",
      function()
        require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner", "textobjects")
      end,
      desc = "Select inside parameter",
      mode = { "o", "x" },
    },
    {
      "]m",
      function()
        require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
      end,
      desc = "Next function start",
      mode = { "n", "x", "o" },
    },
    {
      "]M",
      function()
        require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
      end,
      desc = "Next function end",
      mode = { "n", "x", "o" },
    },
    {
      "[m",
      function()
        require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
      end,
      desc = "Previous function start",
      mode = { "n", "x", "o" },
    },
    {
      "[M",
      function()
        require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
      end,
      desc = "Previous function end",
      mode = { "n", "x", "o" },
    },
    {
      "]]",
      function()
        require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
      end,
      desc = "Next class start",
      mode = { "n", "x", "o" },
    },
    {
      "][",
      function()
        require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer", "textobjects")
      end,
      desc = "Next class end",
      mode = { "n", "x", "o" },
    },
    {
      "[[",
      function()
        require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
      end,
      desc = "Previous class start",
      mode = { "n", "x", "o" },
    },
    {
      "[]",
      function()
        require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects")
      end,
      desc = "Previous class end",
      mode = { "n", "x", "o" },
    },
  },
  config = function()
    require("nvim-treesitter-textobjects").setup({
      select = {
        lookahead = true,
      },
      move = {
        set_jumps = true,
      },
    })
  end,
}
