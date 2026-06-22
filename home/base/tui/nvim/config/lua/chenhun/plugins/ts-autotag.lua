return {
  "windwp/nvim-ts-autotag",
  ft = {
    "html",
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "tsx",
    "jsx",
  },
  config = function()
    -- 独立配置 nvim-ts-autotag，避免继续依赖 nvim-treesitter.configs 中已过时的 autotag 接法。
    require("nvim-ts-autotag").setup()
  end,
}
