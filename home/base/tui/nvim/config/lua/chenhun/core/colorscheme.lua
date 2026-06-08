-- lua/chenhun/core/colorscheme.lua

local status, tokyonight = pcall(require, "tokyonight")
if not status then
	return
end

local fg = "#CBE0F0"
local border = "#547998"
local bg_visual = "#275378"
local float_bg = "#112031"
local float_bg_soft = "#0F1C2C"
local float_border = "#4F7083"
local float_border_soft = "#3E5D72"
local float_title = "#79C6D9"
local float_fg = "#D6E5EF"
local float_fg_muted = "#8EA7B8"
local float_fg_soft = "#7391A6"
local float_select = "#193247"
local float_select_soft = "#163042"
local float_scroll = "#274456"
local accent = "#73C7D8"
local accent_soft = "#5FB1C5"
local warm = "#D7A86E"

tokyonight.setup({
	style = "night",
	transparent = true, -- 1. 开启官方透明支持
	styles = {
		sidebars = "transparent",
		floats = "transparent",
	},
	on_colors = function(colors)
		-- 这里只负责定义“颜色数值”，千万不要写 "NONE"
		colors.border = border
		colors.fg = fg
		colors.bg_visual = bg_visual
	end,
		on_highlights = function(hl, c)
		-- 2. 主编辑区继续保持透明，浮窗类组件单独走一套蓝青卡片语言。
		local comps = {
			"Normal",
			"NormalNC",
			"MsgArea",
			"NvimTreeNormal",
			"NvimTreeNormalNC",
			"SignColumn",
		}
		for _, comp in ipairs(comps) do
			hl[comp] = { bg = "NONE" }
		end

		-- Dropbar lives in winbar; keep the bar transparent so devicons do not
		-- inherit a dark cell background when opened from Telescope.
		hl.WinBar = { fg = float_fg, bg = "NONE" }
		hl.WinBarNC = { fg = float_fg, bg = "NONE" }
		hl.DropBarKindFile = { fg = float_fg, bg = "NONE" }
		hl.DropBarKindDir = { fg = accent_soft, bg = "NONE" }
		hl.DropBarIconKindFile = { bg = "NONE" }
		hl.DropBarIconKindFolder = { fg = accent_soft, bg = "NONE" }
		hl.DropBarIconUISeparator = { fg = float_fg_soft, bg = "NONE" }

		-- 通用浮窗卡片：深海蓝底、柔和蓝青边框、冷白正文、蓝灰次要信息。
		hl.NormalFloat = { fg = float_fg, bg = float_bg }
		hl.FloatBorder = { fg = float_border, bg = float_bg }
		hl.FloatTitle = { fg = float_title, bg = float_bg, bold = true }
		hl.DiagnosticFloatingError = { fg = "#E58C88", bg = float_bg_soft }
		hl.DiagnosticFloatingWarn = { fg = warm, bg = float_bg_soft }
		hl.DiagnosticFloatingInfo = { fg = accent_soft, bg = float_bg_soft }
		hl.DiagnosticFloatingHint = { fg = "#8AC6B9", bg = float_bg_soft }

		-- cmp 补全菜单 / 文档窗
		hl.Pmenu = { fg = float_fg, bg = float_bg }
		hl.PmenuSel = { fg = "#E6F4FB", bg = float_select }
		hl.PmenuSbar = { bg = float_bg_soft }
		hl.PmenuThumb = { bg = float_scroll }
		hl.CmpBorder = { fg = float_border, bg = float_bg }
		hl.CmpDoc = { fg = float_fg, bg = float_bg_soft }
		hl.CmpDocBorder = { fg = float_border_soft, bg = float_bg_soft }
		hl.CmpItemAbbr = { fg = float_fg }
		hl.CmpItemAbbrMatch = { fg = accent, bold = true }
		hl.CmpItemAbbrMatchFuzzy = { fg = accent_soft }
		hl.CmpItemMenu = { fg = float_fg_soft, italic = true }
		hl.CmpItemKind = { fg = accent_soft }
		hl.CmpItemKindFunction = { fg = accent }
		hl.CmpItemKindMethod = { fg = accent }
		hl.CmpItemKindVariable = { fg = float_fg_muted }
		hl.CmpItemKindField = { fg = "#88BFD0" }
		hl.CmpItemKindModule = { fg = "#7FB5C7" }

		-- Noice / Hover / Signature 统一为同一套浮窗语言。
		hl.NoicePopup = { fg = float_fg, bg = float_bg_soft }
		hl.NoicePopupBorder = { fg = float_border_soft, bg = float_bg_soft }
		hl.NoicePopupTitle = { fg = float_title, bg = float_bg_soft, bold = true }
		hl.NoicePopupmenu = { fg = float_fg, bg = float_bg }
		hl.NoicePopupmenuSelected = { fg = "#E6F4FB", bg = float_select_soft }
		hl.NoiceCmdlinePopup = { fg = float_fg, bg = float_bg_soft }
		hl.NoiceCmdlinePopupBorder = { fg = float_border_soft, bg = float_bg_soft }
		hl.NoiceCmdlinePopupTitle = { fg = float_title, bg = float_bg_soft, bold = true }
		hl.LspSignatureActiveParameter = { fg = warm, bold = true }

		-- 让常见的工具浮窗也保持同一语言，避免界面里出现第二套风格。
		hl.TelescopeNormal = { fg = float_fg, bg = float_bg_soft }
		hl.TelescopeBorder = { fg = float_border_soft, bg = float_bg_soft }
		hl.TelescopeTitle = { fg = float_title, bg = float_bg_soft, bold = true }

		-- 行内诊断插件已停用；保留这些组不会影响显示，但主诊断体验改由圆角浮窗承担。
		hl.TinyInlineBackground = { fg = float_fg, bg = float_bg_soft }
		hl.TinyInlineArrow = { fg = accent_soft, bg = "NONE" }
	end,
})

-- 启动主题
vim.cmd([[colorscheme tokyonight]])
