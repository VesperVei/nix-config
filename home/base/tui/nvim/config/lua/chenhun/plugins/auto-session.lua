return {
  "rmagatti/auto-session",
  config = function()
    local auto_session = require("auto-session")

    auto_session.setup({
      auto_restore = false,
      suppressed_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
    })

    local keymap = vim.keymap

    keymap.set("n", "<leader>wr", "<cmd>AutoSession restore<CR>", { desc = "恢复当前目录会话" })
    keymap.set("n", "<leader>ws", "<cmd>AutoSession save<CR>", { desc = "保存当前目录会话" })
    keymap.set("n", "<leader>wf", "<cmd>AutoSession search<CR>", { desc = "搜索并切换会话" })
    keymap.set("n", "<leader>wa", "<cmd>AutoSession toggle<CR>", { desc = "切换会话自动保存" })
  end,
}
