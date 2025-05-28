--[[

	This file is part of 'Masque', an add-on for World of Warcraft. For bug reports,
	suggestions and license information, please visit https://github.com/SFX-WoW/Masque.

	* File...: Skins\Classic.lua
	* Author.: StormFX, Maul, Blizzard Entertainment

	'Classic' Skin

]]
local _, Core = ...

----------------------------------------
-- Locals
---

local L = Core.Locale

----------------------------------------
-- Classic
---

Core.AddSkin("Classic", {
	Template = "Default",
	-- API_VERSION = Default.API_VERSION,
	-- Shape = Default.Shape,

	-- Info
	Description = L["An improved version of the game's default button style."],
	-- Version = Default.Version,
	Authors = {"|cfff58cbaKader|r", "StormFX", "|cff999999Maul|r", "|cff999999Blizzard Entertainment|r"},
	Websites = Core.Websites,
	-- Skin
	-- Mask = Default.Mask,
	Backdrop = {
		Texture = [[Interface\Buttons\UI-Quickslot]],
		Color = {1, 1, 1, 0.8},
		BlendMode = "BLEND",
		DrawLayer = "BACKGROUND",
		DrawLevel = -1,
		Width = 64,
		Height = 64,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	Icon = {
		TexCoords = {0.07, 0.93, 0.07, 0.93},
		DrawLayer = "BACKGROUND",
		DrawLevel = 0,
		Width = 32,
		Height = 32,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	-- Shadow = Default.Shadow,
	Normal = {
		Texture = [[Interface\Buttons\UI-Quickslot2]],
		Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "ARTWORK",
		DrawLevel = 0,
		Width = 60,
		Height = 60,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0.5,
		OffsetY = -0.5,
		Pet = {
			Texture = "Interface\\Buttons\\UI-Quickslot2",
			Color = {1, 1, 1, 1},
			BlendMode = "BLEND",
			DrawLayer = "ARTWORK",
			DrawLevel = 0,
			Width = 58,
			Height = 58,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0.5,
			OffsetY = -0.5
		}
	},
	-- Disabled = Default.Disabled,
	Pushed = {
		Texture = [[Interface\Buttons\UI-Quickslot-Depress]],
		BlendMode = "BLEND",
		DrawLayer = "ARTWORK",
		DrawLevel = 1,
		Width = 36,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	Flash = {
		Texture = [[Interface\Buttons\UI-QuickslotRed]],
		Color = {1, 1, 1, 0.75},
		BlendMode = "BLEND",
		DrawLayer = "BORDER",
		DrawLevel = 1,
		Width = 34,
		Height = 34,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	HotKey = {
		JustifyH = "RIGHT",
		JustifyV = "MIDDLE",
		DrawLayer = "OVERLAY",
		Width = 36,
		Height = 10,
		Point = "TOPRIGHT",
		RelPoint = "TOPRIGHT",
		OffsetX = -2,
		OffsetY = -4
	},
	Count = {
		JustifyH = "RIGHT",
		JustifyV = "MIDDLE",
		DrawLayer = "OVERLAY",
		Width = 36,
		Height = 10,
		Point = "BOTTOMRIGHT",
		RelPoint = "BOTTOMRIGHT",
		OffsetX = -1.5,
		OffsetY = 3,
		Item = {
			JustifyH = "RIGHT",
			JustifyV = "MIDDLE",
			DrawLayer = "ARTWORK",
			Width = 36,
			Height = 10,
			Point = "BOTTOMRIGHT",
			RelPoint = "BOTTOMRIGHT",
			OffsetX = -1.5,
			OffsetY = 3
		}
	},
	Duration = {
		JustifyH = "CENTER",
		JustifyV = "MIDDLE",
		DrawLayer = "OVERLAY",
		Width = 36,
		Height = 10,
		Point = "TOP",
		RelPoint = "BOTTOM",
		OffsetX = 0,
		OffsetY = -2
	},
	Checked = {
		Texture = [[Interface\Buttons\CheckButtonHilight]],
		Color = {1, 1, 1, 0.8},
		BlendMode = "ADD",
		DrawLayer = "OVERLAY",
		DrawLevel = 0,
		Width = 33,
		Height = 33,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		Pet = {
			Texture = [[Interface\Buttons\CheckButtonHilight]],
			Color = {1, 1, 1, 0.8},
			BlendMode = "ADD",
			DrawLayer = "OVERLAY",
			DrawLevel = 0,
			Width = 32,
			Height = 32,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0
		}
	},
	Border = {
		Texture = [[Interface\Buttons\UI-ActionButton-Border]],
		BlendMode = "ADD",
		DrawLayer = "OVERLAY",
		DrawLevel = 0,
		Width = 57,
		Height = 57,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0.5,
		OffsetY = 0.5,
		Debuff = {
			Texture = [[Interface\Buttons\UI-Debuff-Overlays]],
			TexCoords = {0.296875, 0.5703125, 0, 0.515625},
			BlendMode = "BLEND",
			DrawLayer = "OVERLAY",
			DrawLevel = 0,
			Width = 40,
			Height = 38,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 1
		},
		Enchant = {
			Texture = [[Interface\Buttons\UI-TempEnchant-Border]],
			BlendMode = "BLEND",
			DrawLayer = "OVERLAY",
			DrawLevel = 0,
			Width = 40,
			Height = 40,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0
		}
	},
	-- IconBorder = Default.IconBorder,
	SlotHighlight = {
		Texture = [[Interface\Buttons\CheckButtonHilight]],
		BlendMode = "ADD",
		DrawLayer = "OVERLAY",
		DrawLevel = 0,
		Width = 34,
		Height = 34,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	-- Gloss = Default.Gloss,
	AutoCastable = {
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 1,
		Width = 66,
		Height = 66,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0.5,
		OffsetY = -0.5
	},
	-- NewAction = Default.NewAction,
	-- SpellHighlight = Default.SpellHighlight,
	UpgradeIcon = {
		Atlas = "bags-greenarrow",
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 3, --1
		Width = 16,
		Height = 17,
		Point = "TOPLEFT",
		RelPoint = "TOPLEFT",
		OffsetX = 1,
		OffsetY = -1
	},
	-- IconOverlay = Default.IconOverlay,
	-- IconOverlay2 = Default.IconOverlay2,
	NewItem = {
		-- Atlas = "bags-glow-white",
		BlendMode = "ADD",
		DrawLayer = "OVERLAY",
		DrawLevel = 2,
		Width = 36,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	QuestBorder = {
		Border = [[Interface\ContainerFrame\UI-Icon-QuestBorder]],
		Texture = [[Interface\ContainerFrame\UI-Icon-QuestBang]],
		Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 2,
		Width = 32,
		Height = 32,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	-- SearchOverlay = Default.SearchOverlay,
	-- ContextOverlay = Default.ContextOverlay,
	JunkIcon = {
		Atlas = "bags-junkcoin",
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 3,
		Width = 16,
		Height = 16,
		Point = "TOPLEFT",
		RelPoint = "TOPLEFT",
		OffsetX = 1,
		OffsetY = 0
	},
	-- Name = Default.Name,
	Highlight = {
		Texture = [[Interface\Buttons\ButtonHilight-Square]],
		BlendMode = "ADD",
		DrawLayer = "HIGHLIGHT",
		DrawLevel = 0,
		Width = 32,
		Height = 32,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	AutoCastShine = {
		Width = 32,
		Height = 32,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0.5,
		OffsetY = -0.5
	},
	Cooldown = {
		Color = {0, 0, 0, 0.8},
		Width = 32,
		Height = 32,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	ChargeCooldown = {
		Width = 32,
		Height = 32,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	}
})