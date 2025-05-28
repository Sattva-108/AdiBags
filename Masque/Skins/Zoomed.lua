--[[

	This file is part of 'Masque', an add-on for World of Warcraft. For bug reports,
	suggestions and license information, please visit https://github.com/SFX-WoW/Masque.

	* File...: Skins\Zoomed.lua
	* Author.: StormFX, JJSheets

	'Zoomed' Skin

]]
local _, Core = ...

----------------------------------------
-- Locals
---

local L = Core.Locale

----------------------------------------
-- Zoomed
---

Core.AddSkin("Zoomed", {
	Template = "Default",
	-- API_VERSION = Default.API_VERSION,
	-- Shape = Default.Shape,

	-- Info
	Description = L["A square skin with zoomed icons and a semi-transparent background."],
	-- Version = Default.Version,
	Authors = Core.Authors,
	Websites = Core.Websites,
	-- Skin
	-- Mask = Default.Mask,
	Backdrop = {
		Color = {0, 0, 0, 0.5},
		BlendMode = "BLEND",
		DrawLayer = "BACKGROUND",
		DrawLevel = -1,
		Width = 36,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		UseColor = true
	},
	Icon = {
		TexCoords = {0.07, 0.93, 0.07, 0.93},
		DrawLayer = "BACKGROUND",
		DrawLevel = 0,
		Width = 36,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	-- Shadow = Default.Shadow,
	Normal = Core.__Hidden,
	-- Disabled = Default.Disabled,
	-- Pushed = Default.Pushed,
	-- Flash = Default.Flash,
	HotKey = {
		JustifyH = "RIGHT",
		JustifyV = "MIDDLE",
		DrawLayer = "OVERLAY",
		Width = 36,
		Height = 10,
		Point = "TOPRIGHT",
		RelPoint = "TOPRIGHT",
		OffsetX = -1,
		OffsetY = -2
	},
	Count = {
		JustifyH = "RIGHT",
		JustifyV = "MIDDLE",
		DrawLayer = "OVERLAY",
		Width = 36,
		Height = 10,
		Point = "BOTTOMRIGHT",
		RelPoint = "BOTTOMRIGHT",
		OffsetX = -1,
		OffsetY = 2,
		Item = {
			JustifyH = "RIGHT",
			JustifyV = "MIDDLE",
			DrawLayer = "ARTWORK",
			Width = 36,
			Height = 10,
			Point = "BOTTOMRIGHT",
			RelPoint = "BOTTOMRIGHT",
			OffsetX = -1,
			OffsetY = 2
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
		OffsetY = -3
	},
	Checked = {
		Texture = [[Interface\Buttons\CheckButtonHilight]],
		BlendMode = "ADD",
		DrawLayer = "OVERLAY",
		DrawLevel = 0,
		Width = 38,
		Height = 38,
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
		Width = 66,
		Height = 66,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0.5,
		OffsetY = 0.5,
		Item = {
			Texture = [[Interface\Buttons\UI-ActionButton-Border]],
			BlendMode = "ADD",
			DrawLayer = "OVERLAY",
			DrawLevel = 0,
			Width = 66,
			Height = 66,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0.5,
			OffsetY = 0.5
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
			Width = 40,
			Height = 40,
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
		Width = 38,
		Height = 38,
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
		Width = 38,
		Height = 38,
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
	NewAction = {
		Atlas = "bags-newitem",
		BlendMode = "ADD",
		DrawLayer = "OVERLAY",
		DrawLevel = 1,
		Width = 46,
		Height = 46,
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
		Width = 46,
		Height = 46,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	UpgradeIcon = {
		Atlas = "bags-greenarrow",
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 3, --1
		Width = 16,
		Height = 17,
		Point = "TOPLEFT",
		RelPoint = "TOPLEFT",
		OffsetX = 0,
		OffsetY = 0
	},
	IconOverlay = {
		-- Atlas = "AzeriteIconFrame",
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 1,
		Width = 38,
		Height = 38,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0
	},
	IconOverlay2 = {
		-- Atlas = "ConduitIconFrame-Corners",
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 2,
		Width = 38,
		Height = 38,
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
		Width = 36,
		Height = 36,
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
		Width = 38,
		Height = 38,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		UseColor = true
	},
	ContextOverlay = {
		Color = {0, 0, 0, 0.8},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 4,
		Width = 38,
		Height = 38,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		UseColor = true
	},
	JunkIcon = {
		Atlas = "bags-junkcoin",
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 3,
		Width = 16,
		Height = 16,
		Point = "TOPLEFT",
		RelPoint = "TOPLEFT",
		OffsetX = 0,
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
		OffsetY = 0
	},
	-- Highlight = Default.Highlight,
	AutoCastShine = {
		Width = 36,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0.5,
		OffsetY = -0.5
	}
	-- Cooldown = Default.Cooldown,
	-- ChargeCooldown = Default.ChargeCooldown,
})