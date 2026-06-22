return {
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 3000,
      render = "default",
      stages = "fade_in_slide_out",
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    cmd = { "Noice" },
    keys = {
      { "<leader>nn", "<cmd>Noice<CR>", desc = "Noice picker" },
      { "<leader>nl", "<cmd>Noice last<CR>", desc = "Noice last message" },
      { "<leader>na", "<cmd>Noice all<CR>", desc = "Noice all messages" },
      { "<leader>nd", "<cmd>Noice dismiss<CR>", desc = "Noice dismiss notifications" },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
      },
      popupmenu = {
        enabled = true,
        backend = "nui",
      },
      messages = {
        enabled = true,
        view = "notify",
        view_error = "notify",
        view_warn = "notify",
        view_history = "messages",
        view_search = "virtualtext",
      },
      views = {
        cmdline_popup = {
          backend = "popup",
          position = {
            row = "50%",
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = {
              Normal = "NoiceCmdlinePopup",
              FloatBorder = "NoiceCmdlinePopupBorder",
              FloatTitle = "NoiceCmdlinePopupTitle",
            },
          },
        },
        hover_popup = {
          backend = "popup",
          relative = "cursor",
          anchor = "auto",
          position = { row = 1, col = 0 },
          size = {
            width = "auto",
            height = "auto",
            max_width = 90,
            max_height = 16,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            wrap = true,
            linebreak = true,
            winhighlight = {
              Normal = "NoicePopup",
              FloatBorder = "NoicePopupBorder",
              FloatTitle = "NoicePopupTitle",
            },
          },
        },
        signature_popup = {
          backend = "popup",
          relative = "cursor",
          anchor = "auto",
          position = { row = 2, col = 0 },
          size = {
            width = "auto",
            height = "auto",
            max_width = 90,
            max_height = 12,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            wrap = true,
            linebreak = true,
            winhighlight = {
              Normal = "NoicePopup",
              FloatBorder = "NoicePopupBorder",
              FloatTitle = "NoicePopupTitle",
            },
          },
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            min_height = 12,
          },
          view = "split",
        },
        {
          filter = {
            event = "msg_show",
            kind = { "", "echo", "echomsg", "lua_print" },
          },
          view = "notify",
        },
        {
          filter = {
            event = "notify",
            min_height = 12,
          },
          view = "split",
        },
      },
      lsp = {
        progress = { enabled = false },
        hover = {
          enabled = true,
          view = "hover_popup",
        },
        signature = {
          enabled = true,
          view = "signature_popup",
          auto_open = {
            enabled = true,
            trigger = true,
            luasnip = false,
            snipppets = false,
            throttle = 150,
          },
        },
        message = { enabled = true },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
    },
    config = function(_, opts)
      require("noice").setup(opts)
      vim.notify = require("notify")

      -- Pyright / Python 内建函数经常会返回多个 overload。
      -- Noice 默认会把所有签名一口气展开，视觉上会像“重复提示”。
      -- 这里收敛为只渲染当前激活签名；没有 activeSignature 时退回第一条。
      local signature = require("noice.lsp.signature")
      local original_format_signature = signature.format_signature

      signature.format = function(self)
        local active = (self.activeSignature or 0) + 1
        local sig = self.signatures[active] or self.signatures[1]
        if not sig then
          return
        end
        original_format_signature(self, active, sig)
      end
    end,
  },
}
