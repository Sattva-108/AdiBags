--[[

	This file is part of 'Masque', an add-on for World of Warcraft. For bug reports,
	suggestions and license information, please visit https://github.com/SFX-WoW/Masque.

	* File...: Core\Regions\Mask.lua
	* Author.: StormFX, Kader

	Button/Region Mask

]]
local _, Core = ...

----------------------------------------
-- Lua
---

local type = type

----------------------------------------
-- Internal
---

-- @ Core\Utility
-- local GetSize = Core.GetSize
-- local SetPoints = Core.SetPoints
-- local CreateMaskTexture = Core.CreateMaskTexture
-- local AddMaskTexture = Core.AddMaskTexture
-- local RemoveMaskTexture = Core.RemoveMaskTexture
-- local SetMask = Core.SetMask

----------------------------------------
-- Core
---

-- Skins a button or region mask.
function Core.SkinMask(Region, Button, Skin, xScale, yScale)
	return -- Sorry, until i find a solution
	-- local ButtonMask = Button.__MSQ_Mask

	-- -- Region
	-- if Region then
	-- 	local SkinMask = Skin.Mask

	-- 	-- Button Mask
	-- 	if Skin.UseMask and ButtonMask and not SkinMask then
	-- 		if not Region.__MSQ_ButtonMask then
	-- 			AddMaskTexture(Region, ButtonMask, Skin.DrawLayer, Skin.DrawLevel)
	-- 			Region.__MSQ_ButtonMask = true
	-- 		end
	-- 	elseif Region.__MSQ_ButtonMask then
	-- 		RemoveMaskTexture(Region, ButtonMask)
	-- 		Region.__MSQ_ButtonMask = nil
	-- 	end

	-- 	-- Region Mask
	-- 	local RegionMask = Region.__MSQ_Mask

	-- 	if SkinMask then
	-- 		if not RegionMask then
	-- 			RegionMask = CreateMaskTexture(Button)
	-- 			Region.__MSQ_Mask = RegionMask
	-- 		end

	-- 		if type(SkinMask) == "table" then
	-- 			RegionMask:SetTexture(SkinMask.Texture)
	-- 			RegionMask:SetSize(GetSize(SkinMask.Width, SkinMask.Height, xScale, yScale))
	-- 			SetPoints(RegionMask, Region, Skin, nil, SkinMask.SetAllPoints)
	-- 		else
	-- 			RegionMask:SetTexture(SkinMask)
	-- 			RegionMask:SetAllPoints(Region)
	-- 		end

	-- 		if not Region.__MSQ_RegionMask then
	-- 			AddMaskTexture(Region, RegionMask, Skin.DrawLayer, Skin.DrawLevel)
	-- 			Region.__MSQ_RegionMask = true
	-- 		end
	-- 	elseif Region.__MSQ_RegionMask then
	-- 		RemoveMaskTexture(Region, RegionMask)
	-- 		Region.__MSQ_RegionMask = nil
	-- 	end

	-- -- Button
	-- else
	-- 	ButtonMask = ButtonMask or CreateMaskTexture(Button)
	-- 	Button.__MSQ_Mask = ButtonMask

	-- 	if type(Skin) == "table" then
	-- 		ButtonMask:SetTexture(Skin.Texture)
	-- 		ButtonMask:SetSize(GetSize(Skin.Width, Skin.Height, xScale, yScale))
	-- 		SetPoints(ButtonMask, Button, Skin, nil, Skin.SetAllPoints)
	-- 	else
	-- 		ButtonMask:SetTexture(Skin)
	-- 		ButtonMask:SetAllPoints(Button)
	-- 	end
	-- end
end