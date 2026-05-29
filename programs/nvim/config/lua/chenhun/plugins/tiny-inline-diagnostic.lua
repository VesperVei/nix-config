return {
  "rachartier/tiny-inline-diagnostic.nvim",
  enabled = false,
  event = "VeryLazy",
  priority = 1000,
  config = function()
    require("tiny-inline-diagnostic").setup({
      preset = "modern",
      transparent_bg = false,
      transparent_cursorline = true,
      hi = {
        error = "DiagnosticError",
        warn = "DiagnosticWarn",
        info = "DiagnosticInfo",
        hint = "DiagnosticHint",
        arrow = "TinyInlineArrow",
        background = "TinyInlineBackground",
        mixing_color = "Normal",
      },
      options = {
        show_source = {
          enabled = false,
          if_many = false,
        },
        use_icons_from_diagnostic = true,
        set_arrow_to_diag_color = false,
        throttle = 20,
        softwrap = 30,
        add_messages = {
          messages = true,
          display_count = false,
          use_max_severity = false,
          show_multiple_glyphs = true,
        },
        multilines = {
          enabled = false,
          always_show = false,
          trim_whitespaces = true,
          tabstop = 2,
          severity = nil,
        },
        show_all_diags_on_cursorline = false,
        show_diags_only_under_cursor = false,
        show_related = {
          enabled = true,
          max_count = 2,
        },
        enable_on_insert = false,
        enable_on_select = false,
        override_open_float = true,
        overflow = {
          mode = "wrap",
          padding = 0,
        },
        break_line = {
          enabled = false,
          after = 32,
        },
        virt_texts = {
          priority = 2048,
        },
      },
    })

    -- 交给 tiny-inline-diagnostic 渲染，避免与原生 virtual_text 重叠。
    vim.diagnostic.config({
      virtual_text = false,
    })
  end,
}
