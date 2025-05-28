--[[

	This file is part of 'Masque', an add-on for World of Warcraft. For bug reports,
	suggestions and license information, please visit https://github.com/SFX-WoW/Masque.

	* File...: Skins\Default.lua
	* Author.: Blizzard Entertainment

	'Default' Skin

	* Note: Some attributes are modified for internal consistency.

]]
local _, Core = ...

----------------------------------------
-- Locals
---

local L = Core.Locale

----------------------------------------
-- Default
---

Core.SkinList.Default = "Default"
Core.Skins.Default = {
	SkinID = "Default",
	API_VERSION = Core.API_VERSION,
	Shape = "Square",
	-- Info
	Description = L["The default button style."],
	Version = Core.Version,
	Author = "|cff0099ffBlizzard Entertainment|r",
	-- Skin
	-- Mask = nil,
	Backdrop = {
		Texture = [[Interface\Buttons\UI-Quickslot]],
		Color = {1, 1, 1, 0.4},
		BlendMode = "BLEND",
		DrawLayer = "BACKGROUND",
		DrawLevel = -1,
		Width = 66,
		Height = 66,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	Icon = {
		DrawLayer = "BACKGROUND",
		DrawLevel = 0,
		Width = 36,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	Shadow = {Hide = true},
	Normal = {
		Texture = [[Interface\Buttons\UI-Quickslot2]],
		Color = {1, 1, 1, 1},
		EmptyColor = {1, 1, 1, 0.5},
		BlendMode = "BLEND",
		DrawLayer = "ARTWORK",
		DrawLevel = 0,
		Width = 66,
		Height = 66,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		UseStates = true,
		Pet = {
			Texture = "Interface\\Buttons\\UI-Quickslot2",
			Color = {1, 1, 1, 1},
			EmptyColor = {1, 1, 1, 0.5},
			BlendMode = "BLEND",
			DrawLayer = "ARTWORK",
			DrawLevel = 0,
			Width = 65,
			Height = 65,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = -1,
			UseStates = true
		},
		Item = {
			Texture = "Interface\\Buttons\\UI-Quickslot2",
			Color = {1, 1, 1, 1},
			BlendMode = "BLEND",
			DrawLayer = "ARTWORK",
			DrawLevel = 0,
			Width = 62,
			Height = 62,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = -1,
			UseStates = true
		}
	},
	Disabled = {Hide = true},
	Pushed = {
		Texture = [[Interface\Buttons\UI-Quickslot-Depress]],
		BlendMode = "BLEND",
		DrawLayer = "ARTWORK",
		DrawLevel = 0,
		Width = 36,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	Flash = {
		Texture = [[Interface\Buttons\UI-QuickslotRed]],
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
	HotKey = {
		JustifyH = "RIGHT",
		JustifyV = "MIDDLE",
		DrawLayer = "ARTWORK",
		Width = 36,
		Height = 10,
		Point = "TOPRIGHT",
		RelPoint = "TOPRIGHT",
		OffsetX = 1,
		OffsetY = -3,
		Pet = {
			JustifyH = "RIGHT",
			JustifyV = "MIDDLE",
			DrawLayer = "ARTWORK",
			Width = 36,
			Height = 10,
			Point = "TOPRIGHT",
			RelPoint = "TOPRIGHT",
			OffsetX = 4,
			OffsetY = -4
		}
	},
	Count = {
		JustifyH = "RIGHT",
		JustifyV = "MIDDLE",
		DrawLayer = "ARTWORK",
		Width = 36,
		Height = 10,
		Point = "BOTTOMRIGHT",
		RelPoint = "BOTTOMRIGHT",
		OffsetX = -2,
		OffsetY = 4.5,
		Item = {
			JustifyH = "RIGHT",
			JustifyV = "MIDDLE",
			DrawLayer = "ARTWORK",
			Width = 36,
			Height = 10,
			Point = "BOTTOMRIGHT",
			RelPoint = "BOTTOMRIGHT",
			OffsetX = -5,
			OffsetY = 4.5
		}
	},
	Duration = {
		JustifyH = "CENTER",
		JustifyV = "MIDDLE",
		DrawLayer = "ARTWORK",
		Width = 36,
		Height = 10,
		Point = "TOP",
		RelPoint = "BOTTOM",
		OffsetX = 0,
		OffsetY = -1.5
	},
	Checked = {
		Texture = [[Interface\Buttons\CheckButtonHilight]],
		BlendMode = "ADD",
		DrawLayer = "OVERLAY",
		DrawLevel = 0,
		Width = 36,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	Border = {
		Texture = [[Interface\Buttons\UI-ActionButton-Border]],
		BlendMode = "ADD",
		DrawLayer = "OVERLAY",
		DrawLevel = 0,
		Width = 62,
		Height = 62,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		Item = {
			Texture = [[Interface\Buttons\UI-ActionButton-Border]],
			BlendMode = "ADD",
			DrawLayer = "OVERLAY",
			DrawLevel = 0,
			Width = 66,
			Height = 66,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0
		},
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
			OffsetY = 0
		},
		Enchant = {
			Texture = [[Interface\Buttons\UI-TempEnchant-Border]],
			BlendMode = "BLEND",
			DrawLayer = "OVERLAY",
			DrawLevel = 0,
			Width = 38,
			Height = 38,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0
		}
	},
	IconBorder = {
		Texture = [[Interface\Common\WhiteIconFrame]],
		RelicTexture = [[Interface\Artifacts\RelicIconFrame]],
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 0,
		Width = 36,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	SlotHighlight = {
		Texture = [[Interface\Buttons\CheckButtonHilight]],
		BlendMode = "ADD",
		DrawLayer = "OVERLAY",
		DrawLevel = 0,
		Width = 36,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	Gloss = {Hide = true},
	AutoCastable = {
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 1,
		Width = 70,
		Height = 70,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	NewAction = {
		Atlas = "bags-newitem",
		BlendMode = "ADD",
		DrawLayer = "OVERLAY",
		DrawLevel = 1,
		Width = 44,
		Height = 44,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	SpellHighlight = {
		Atlas = "bags-newitem",
		BlendMode = "ADD",
		DrawLayer = "OVERLAY",
		DrawLevel = 1,
		Width = 44,
		Height = 44,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	UpgradeIcon = {
		Atlas = "bags-greenarrow",
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 1,
		Width = 20,
		Height = 22,
		Point = "TOPLEFT",
		RelPoint = "TOPLEFT",
		OffsetX = 0,
		OffsetY = 0
	},
	IconOverlay = {
		Atlas = "AzeriteIconFrame",
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 1,
		Width = 36,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	IconOverlay2 = {
		Atlas = "ConduitIconFrame-Corners",
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 2,
		Width = 36,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	NewItem = {
		Atlas = "bags-glow-white",
		BlendMode = "ADD",
		DrawLayer = "OVERLAY",
		DrawLevel = 2,
		Width = 38,
		Height = 38,
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
		Width = 36,
		Height = 37,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	SearchOverlay = {
		Color = {0, 0, 0, 0.8},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 4,
		Width = 36,
		Height = 36,
		UseColor = true,
		SetAllPoints = true
	},
	ContextOverlay = {
		Color = {0, 0, 0, 0.8},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 4,
		Width = 36,
		Height = 36,
		UseColor = true,
		SetAllPoints = true
	},
	JunkIcon = {
		Atlas = "bags-junkcoin",
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 5,
		Width = 20,
		Height = 18,
		Point = "TOPLEFT",
		RelPoint = "TOPLEFT",
		OffsetX = 1,
		OffsetY = 0
	},
	Name = {
		JustifyH = "CENTER",
		JustifyV = "MIDDLE",
		DrawLayer = "OVERLAY",
		Width = 36,
		Height = 10,
		Point = "BOTTOM",
		RelPoint = "BOTTOM",
		OffsetX = 0,
		OffsetY = 2
	},
	Highlight = {
		Texture = [[Interface\Buttons\ButtonHilight-Square]],
		BlendMode = "ADD",
		DrawLayer = "HIGHLIGHT",
		DrawLevel = 0,
		Width = 36,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	AutoCastShine = {
		Width = 34,
		Height = 34,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	Cooldown = {
		EdgeTexture = [[Interface\Cooldown\edge]],
		PulseTexture = [[Interface\Cooldown\star4]],
		Color = {0, 0, 0, 0.8},
		Width = 36,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	ChargeCooldown = {
		EdgeTexture = [[Interface\Cooldown\edge]],
		PulseTexture = [[Interface\Cooldown\star4]],
		Width = 36,
		Height = 36,
		SetAllPoints = true
	}
}