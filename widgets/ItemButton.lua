--[[
AdiBags - Adirelle's bag addon.
Copyright 2010-2011 Adirelle (adirelle@tagada-team.net)
All rights reserved.
--]]

local addonName, addon = ...

--<GLOBALS
local _G = _G
local BankButtonIDToInvSlotID = _G.BankButtonIDToInvSlotID
local BANK_CONTAINER = _G.BANK_CONTAINER
local ContainerFrame_UpdateCooldown = _G.ContainerFrame_UpdateCooldown
local format = _G.format
local GetContainerItemID = _G.GetContainerItemID
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetContainerItemLink = _G.GetContainerItemLink
local GetContainerItemQuestInfo = _G.GetContainerItemQuestInfo
local GetContainerNumFreeSlots = _G.GetContainerNumFreeSlots
local GetItemInfo = _G.GetItemInfo
local GetItemQualityColor = _G.GetItemQualityColor
local IsInventoryItemLocked = _G.IsInventoryItemLocked
local ITEM_QUALITY_POOR = _G.ITEM_QUALITY_POOR
local ITEM_QUALITY_UNCOMMON = _G.ITEM_QUALITY_UNCOMMON
local KEYRING_CONTAINER = _G.KEYRING_CONTAINER
local next = _G.next
local pairs = _G.pairs
local select = _G.select
local SetItemButtonDesaturated = _G.SetItemButtonDesaturated
local StackSplitFrame = _G.StackSplitFrame
local TEXTURE_ITEM_QUEST_BANG = _G.TEXTURE_ITEM_QUEST_BANG
local TEXTURE_ITEM_QUEST_BORDER = _G.TEXTURE_ITEM_QUEST_BORDER
local tostring = _G.tostring
local wipe = _G.wipe
--GLOBALS>

local GetSlotId = addon.GetSlotId
local GetBagSlotFromId = addon.GetBagSlotFromId

local ITEM_SIZE = addon.ITEM_SIZE

local Masque = LibStub('Masque', true)
local AceTimer = LibStub('AceTimer-3.0')

--------------------------------------------------------------------------------
-- Button initialization
--------------------------------------------------------------------------------

local buttonClass, buttonProto = addon:NewClass("ItemButton", "Button", "ContainerFrameItemButtonTemplate", "AceEvent-3.0")

local childrenNames = { "Cooldown", "IconTexture", "IconQuestTexture", "Count", "Stock", "NormalTexture" }

function buttonProto:OnCreate()
	local name = self:GetName()
	for i, childName in pairs(childrenNames) do
		self[childName] = _G[name .. childName]
	end
	self:RegisterForDrag("LeftButton")
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	self:SetScript("OnShow", self.OnShow)
	self:SetScript("OnHide", self.OnHide)
	self:SetWidth(ITEM_SIZE)
	self:SetHeight(ITEM_SIZE)
end

function buttonProto:OnAcquire(container, bag, slot)
	self.container = container
	self.bag = bag
	self.slot = slot
	self.stack = nil
	self:SetParent(addon.itemParentFrames[bag])
	self:SetID(slot)
	self:FullUpdate()
end

do
	local buttonProtoHook = addon:GetClass("ItemButton").prototype
	local orig_OnAcquire = buttonProtoHook.OnAcquire

	function buttonProtoHook:OnAcquire(container, bag, slot)
		-- 1) vanilla AdiBags acquire
		orig_OnAcquire(self, container, bag, slot)

		-- 2) only if AddOnSkins is present, retrigger OnCreate hooks
		if IsAddOnLoaded("ElvUI") then
			-- safely unpack ElvUI (won't error if ElvUI is nil)
			local E, L, V, P, G = unpack(_G.ElvUI or {})
			local AS = E and E:GetModule("AddOnSkins", true)
			if AS then
				-- this will fire every hooksecurefunc(*, "OnCreate", …)
				self:OnCreate()
			end
		end
	end
end

function buttonProto:OnRelease()
	self:SetSection(nil)
	self.container = nil
	self.itemId = nil
	self.itemLink = nil
	self.hasItem = nil
	self.texture = nil
	self.bagFamily = nil
	self.stack = nil
	self.isUpgrade = nil
	self.isDowngrade = nil
	self.beingSold = nil
end

function buttonProto:ToString()
	return format("Button-%s-%s", tostring(self.bag), tostring(self.slot))
end

function buttonProto:IsLocked()
	return select(3, GetContainerItemInfo(self.bag, self.slot))
end

--------------------------------------------------------------------------------
-- Generic bank button sub-type
--------------------------------------------------------------------------------

local bankButtonClass, bankButtonProto = addon:NewClass("BankItemButton", "ItemButton")
bankButtonClass.frameTemplate = "BankItemButtonGenericTemplate"

function bankButtonProto:IsLocked()
	return IsInventoryItemLocked(BankButtonIDToInvSlotID(self.slot))
end

--------------------------------------------------------------------------------
-- Pools and acquistion
--------------------------------------------------------------------------------

local containerButtonPool = addon:CreatePool(buttonClass)
local bankButtonPool = addon:CreatePool(bankButtonClass)

function addon:AcquireItemButton(container, bag, slot)
	if bag == BANK_CONTAINER then
		return bankButtonPool:Acquire(container, bag, slot)
	else
		return containerButtonPool:Acquire(container, bag, slot)
	end
end

-- Pre-spawn a bunch of buttons, when we are out of combat
-- because buttons created in combat do not work well
hooksecurefunc(addon, 'OnInitialize', function()
	addon:Debug('Prespawning buttons')
	containerButtonPool:PreSpawn(100)
end)

--------------------------------------------------------------------------------
-- Model data
--------------------------------------------------------------------------------

function buttonProto:SetSection(section)
	local oldSection = self.section
	if oldSection ~= section then
		if oldSection then
			oldSection:RemoveItemButton(self)
		end
		self.section = section
		return true
	end
end

function buttonProto:GetSection()
	return self.section
end

function buttonProto:GetItemId()
	return self.itemId
end

function buttonProto:GetItemLink()
	return self.itemLink
end

function buttonProto:GetCount()
	return select(2, GetContainerItemInfo(self.bag, self.slot)) or 0
end

function buttonProto:GetBagFamily()
	return self.bagFamily
end

local BANK_BAG_IDS = addon.BAG_IDS.BANK
function buttonProto:IsBank()
	return not not BANK_BAG_IDS[self.bag]
end

function buttonProto:IsStack()
	return false
end

function buttonProto:GetRealButton()
	return self
end

function buttonProto:SetStack(stack)
	self.stack = stack
end

function buttonProto:GetStack()
	return self.stack
end

local function SimpleButtonSlotIterator(self, slotId)
	if not slotId and self.bag and self.slot then
		return GetSlotId(self.bag, self.slot), self.bag, self.slot, self.itemId, self.stack
	end
end

function buttonProto:IterateSlots()
	return SimpleButtonSlotIterator, self
end

--------------------------------------------------------------------------------
-- Scripts & event handlers
--------------------------------------------------------------------------------

function buttonProto:OnShow()
	self:RegisterEvent('BAG_UPDATE_COOLDOWN', 'UpdateCooldown')
	self:RegisterEvent('ITEM_LOCK_CHANGED', 'UpdateLock')
	self:RegisterEvent('QUEST_ACCEPTED', 'UpdateBorder')
	if self.UpdateSearch then
		self:RegisterEvent('INVENTORY_SEARCH_UPDATE', 'UpdateSearch')
	end
	self:RegisterEvent('UNIT_QUEST_LOG_CHANGED')
	self:RegisterMessage('AdiBags_UpdateAllButtons', 'Update')
	self:RegisterMessage('AdiBags_GlobalLockChanged', 'UpdateLock')
	self:FullUpdate()
end

function buttonProto:OnHide()
	self:UnregisterAllEvents()
	self:UnregisterAllMessages()
	if self.hasStackSplit and self.hasStackSplit == 1 then
		StackSplitFrame:Hide()
	end
end

function buttonProto:UNIT_QUEST_LOG_CHANGED(event, unit)
	if unit == "player" then
		self:UpdateBorder(event)
	end
end

--------------------------------------------------------------------------------
-- Display updating
--------------------------------------------------------------------------------

function buttonProto:CanUpdate()
	if not self:IsVisible() or addon.holdYourBreath then
		return false
	end
	return true
end

function buttonProto:FullUpdate()
	local bag, slot = self.bag, self.slot
	self.itemId = GetContainerItemID(bag, slot)
	self.itemLink = GetContainerItemLink(bag, slot)
	self.hasItem = not not self.itemId
	self.texture = GetContainerItemInfo(bag, slot)
	self.bagFamily = bag == KEYRING_CONTAINER and 256 or select(2, GetContainerNumFreeSlots(bag))
	self:Update()
end

function buttonProto:Update()
	if not self:CanUpdate() then return end

	-- icon & empty-slot handling
	local icon = self.IconTexture
	if self.texture then
		icon:SetTexture(self.texture)
		icon:SetTexCoord(0, 1, 0, 1)
	else
		if Masque then
			icon:SetTexCoord(12/64, 51/64, 12/64, 51/64)
			icon:SetTexture(nil)
		else
			icon:SetTexture([[Interface\BUTTONS\UI-EmptySlot]])
			icon:SetTexCoord(12/64, 51/64, 12/64, 51/64)
		end
	end

	-- bag-type tag
	local tag = (not self.itemId or addon.db.profile.showBagType) and addon:GetFamilyTag(self.bagFamily)
	if tag then
		self.Stock:SetText(tag)
		self.Stock:Show()
	else
		self.Stock:Hide()
	end

	------------------------------------------------------------
	-- 1) upgrade‐overlay (lazy create + show/hide)
	------------------------------------------------------------
	if self.isUpgrade then
		if not self.upgradeTexture then
			local t = self:CreateTexture(nil, "OVERLAY")
			t:SetTexture([[Interface\AddOns\AdiBags\assets\UpgradeArrow.tga]])
			t:SetPoint("TOPLEFT", self.IconTexture,  10, -2)
			t:SetSize(18,18)
			self.upgradeTexture = t
		end
		self.upgradeTexture:Show()
	elseif self.upgradeTexture then
		self.upgradeTexture:Hide()
	end

	------------------------------------------------------------
	-- 2) sell‐overlay (lazy create + show/hide)
	------------------------------------------------------------
	if self.beingSold then
		if not self.sellTexture then
			local t = self:CreateTexture(nil, "OVERLAY")
			t:SetTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Up.blp")
			t:SetPoint("TOPRIGHT", self.IconTexture, -10, -1)
			t:SetSize(18,18)
			self.sellTexture = t
		end
		self.sellTexture:Show()
	elseif self.sellTexture then
		self.sellTexture:Hide()
	end

	-- the rest of your existing update chain
	self:UpdateCount()
	self:UpdateBorder()
	self:UpdateCooldown()
	self:UpdateLock()
	if self.UpdateSearch then
		self:UpdateSearch()
	end

	addon:SendMessage("AdiBags_UpdateButton", self)
end

function buttonProto:UpdateCount()
	local count = self:GetCount() or 0
	self.count = count
	if count > 1 then
		self.Count:SetText(count)
		self.Count:Show()
	else
		self.Count:Hide()
	end
end

function buttonProto:UpdateLock(isolatedEvent)
	if addon.globalLock then
		SetItemButtonDesaturated(self, true)
		self:Disable()
	else
		self:Enable()
		SetItemButtonDesaturated(self, self:IsLocked())
	end
	if isolatedEvent then
		addon:SendMessage('AdiBags_UpdateLock', self)
	end
end

if select(4, GetBuildInfo()) == 40300 then
	function buttonProto:UpdateSearch()
		local _, _, _, _, _, _, _, isFiltered = GetContainerItemInfo(self.bag, self.slot)
		if isFiltered then
			self.searchOverlay:Show();
		else
			self.searchOverlay:Hide();
		end
	end
end

function buttonProto:UpdateCooldown()
	return ContainerFrame_UpdateCooldown(self.bag, self)
end

function buttonProto:UpdateBorder(isolatedEvent)
	if self.hasItem then
		local texture, r, g, b, a, x1, x2, y1, y2, blendMode = nil, 1, 1, 1, 1, 0, 1, 0, 1, "BLEND"
		local isQuestItem, questId, isActive = GetContainerItemQuestInfo(self.bag, self.slot)
		if addon.db.profile.questIndicator and (questId and not isActive) then
			texture = TEXTURE_ITEM_QUEST_BANG
		elseif addon.db.profile.questIndicator and (questId or isQuestItem) then
			texture = TEXTURE_ITEM_QUEST_BORDER
		elseif addon.db.profile.qualityHighlight then
			local _, _, quality = GetItemInfo(self.itemId)
			if quality and quality >= ITEM_QUALITY_UNCOMMON then
				r, g, b = GetItemQualityColor(quality)
				a = addon.db.profile.qualityOpacity
				texture, x1, x2, y1, y2 = [[Interface\Buttons\UI-ActionButton-Border]], 14/64, 49/64, 15/64, 50/64
				blendMode = "ADD"
			elseif quality == ITEM_QUALITY_POOR and addon.db.profile.dimJunk then
				if Masque then -- <<<< ADD THIS IF CONDITION
					texture = nil -- Tell AdiBags to do nothing with the border for junk if Masque is on
				else
					-- Original AdiBags junk border logic (only if Masque is NOT active)
					local v = 1 - 0.5 * addon.db.profile.qualityOpacity
					texture, blendMode, r, g, b = true, "MOD", v, v, v
				end -- <<<< END IF
			end
		end
		if texture then
			local border = self.IconQuestTexture
			if texture == true then
				border:SetVertexColor(1, 1, 1, 1)
				border:SetTexture(r, g, b, a)
			else
				border:SetTexture(texture)
				border:SetVertexColor(r, g, b, a)
			end
			border:SetTexCoord(x1, x2, y1, y2)
			border:SetBlendMode(blendMode)
			border:Show()
			if isolatedEvent then
				addon:SendMessage('AdiBags_UpdateBorder', self)
			end
			return
		end
	end
	self.IconQuestTexture:Hide()
	if isolatedEvent then
		addon:SendMessage('AdiBags_UpdateBorder', self)
	end
end

--------------------------------------------------------------------------------
-- Masque Support
--------------------------------------------------------------------------------

if Masque then
	-- 1px transparent frame for dummy texture (YOURS)
	local dummyFrame = CreateFrame("Frame", "AdiBagsMasqueDummy", UIParent)
	dummyFrame:SetSize(1, 1); dummyFrame:SetAlpha(0)
	local dummyTex = dummyFrame:CreateTexture(nil, "OVERLAY")
	dummyTex:SetAllPoints(dummyFrame); dummyTex:SetAlpha(0)

	-- 1) Prepare the data Masque expects for every button (YOURS)
	hooksecurefunc(buttonProto, "OnCreate", function(self)
		self.masqueData = {
			Icon        = self.IconTexture,
			Cooldown    = self.Cooldown,
			Normal      = self.NormalTexture,
			Border      = self.IconQuestTexture,
			QuestBorder = self.IconQuestTexture,
			HotKey      = self.Stock,
			Count       = self.Count,
		}
	end)

	-- 2) Re-skin each time AdiBags updates the border
	hooksecurefunc(buttonProto, "UpdateBorder", function(self)
		local iqTex    = self.IconQuestTexture
		local icon     = self.IconTexture
		local isJunk   = false
		local quality, isQuest

		if self.hasItem then
			local _, _, q = GetItemInfo(self.itemId); quality = q
			local questItem, questId = GetContainerItemQuestInfo(self.bag, self.slot)
			if addon.db.profile.questIndicator and (questItem or questId) then
				isQuest = true
			end
			if quality == ITEM_QUALITY_POOR and addon.db.profile.dimJunk then
				isJunk = true
			end
		end

		local originalMasqueBorderTarget = self.masqueData.Border -- Store original before potentially changing for junk
		if isJunk then
			self.masqueData.Border      = iqTex -- Masque skins the real border for junk
			self.masqueData.QuestBorder = iqTex -- Masque skins the real border for junk
		else
			self.masqueData.Border      = iqTex
			self.masqueData.QuestBorder = iqTex
		end

		-- Re-register so Masque reapplies its skin
		if self.masqueGroup and self.masqueGroup.AddButton then
			self.masqueGroup:RemoveButton(self)
			self.masqueGroup:AddButton(self, self.masqueData)
		end

		self.masqueData.Border      = originalMasqueBorderTarget
		self.masqueData.QuestBorder = originalMasqueBorderTarget


		-- 2.b) Post-Masque: just force-show the texture if needed
		-- This section is now carefully split to handle junk separately.

		if isQuest then
			-- YOUR ORIGINAL LOGIC FOR isQuest (WHEN isJunk IS FALSE)
			iqTex:SetDrawLayer("OVERLAY", 7)
			iqTex:Show()
			icon:SetBlendMode("DISABLE")
			icon:SetVertexColor(1, 1, 1, 1)

		elseif isJunk then
			-- 1. Dim the icon
			icon:SetBlendMode("BLEND")
			icon:SetVertexColor(1, 1, 1, 0.4)
			if icon.SetDrawLayer then icon:SetDrawLayer("ARTWORK", 1) end

			-- 2. Border styling
			iqTex:SetTexture(nil)
			iqTex:SetVertexColor(0.5, 0.5, 0.5, 0.5)
			iqTex:SetDrawLayer("OVERLAY", 10)
			iqTex:Show()

		elseif quality and quality >= ITEM_QUALITY_UNCOMMON then
			icon:SetBlendMode("DISABLE")
			icon:SetVertexColor(1, 1, 1, 1)
			-- YOUR ORIGINAL LOGIC FOR QUALITY ITEMS (WHEN isJunk and isQuest ARE FALSE)
			local r, g, b = GetItemQualityColor(quality)
			local qualityOpacityVal = addon.db.profile.qualityOpacity
			if type(qualityOpacityVal) ~= "number" then qualityOpacityVal = 1 end -- ensure number
			iqTex:SetVertexColor(r, g, b, qualityOpacityVal)
			iqTex:SetDrawLayer("OVERLAY", 7)
			iqTex:Show()

		 else
			icon:SetBlendMode("DISABLE")
			icon:SetVertexColor(1, 1, 1, 1)
		end
	end)

	-- 3) Masque groups (YOURS)
	buttonProto.masqueGroup     = Masque:Group(addonName, addon.L["Backpack button"])
	bankButtonProto.masqueGroup = Masque:Group(addonName, addon.L["Bank button"])
end

--------------------------------------------------------------------------------
-- Item stack button
--------------------------------------------------------------------------------

local stackClass, stackProto = addon:NewClass("StackButton", "Frame", "AceEvent-3.0")
addon:CreatePool(stackClass, "AcquireStackButton")

function stackProto:OnCreate()
	self:SetWidth(ITEM_SIZE)
	self:SetHeight(ITEM_SIZE)
	self.slots = {}
	self:SetScript('OnShow', self.OnShow)
	self:SetScript('OnHide', self.OnHide)
	self.GetCountHook = function()
		return self.count
	end
end

function stackProto:OnAcquire(container, key)
	self.container = container
	self.key = key
	self.count = 0
	self.dirtyCount = true
	self:SetParent(container)
end

function stackProto:OnRelease()
	self:SetVisibleSlot(nil)
	self:SetSection(nil)
	self.key = nil
	self.container = nil
	wipe(self.slots)
end

function stackProto:GetCount()
	return self.count
end

function stackProto:IsStack()
	return true
end

function stackProto:GetRealButton()
	return self.button
end

function stackProto:GetKey()
	return self.key
end

function stackProto:UpdateVisibleSlot()
	local bestLockedId, bestLockedCount
	local bestUnlockedId, bestUnlockedCount
	if self.slotId and self.slots[self.slotId] then
		local _, count, locked = GetContainerItemInfo(GetBagSlotFromId(self.slotId))
		count = count or 1
		if locked then
			bestLockedId, bestLockedCount = self.slotId, count
		else
			bestUnlockedId, bestUnlockedCount = self.slotId, count
		end
	end
	for slotId in pairs(self.slots) do
		local _, count, locked = GetContainerItemInfo(GetBagSlotFromId(slotId))
		count = count or 1
		if locked then
			if not bestLockedId or count > bestLockedCount then
				bestLockedId, bestLockedCount = slotId, count
			end
		else
			if not bestUnlockedId or count > bestUnlockedCount then
				bestUnlockedId, bestUnlockedCount = slotId, count
			end
		end
	end
	return self:SetVisibleSlot(bestUnlockedId or bestLockedId)
end

function stackProto:ITEM_LOCK_CHANGED()
	return self:Update()
end

function stackProto:AddSlot(slotId)
	local slots = self.slots
	if not slots[slotId] then
		slots[slotId] = true
		self.dirtyCount = true
		self:Update()
	end
end

function stackProto:RemoveSlot(slotId)
	local slots = self.slots
	if slots[slotId] then
		slots[slotId] = nil
		self.dirtyCount = true
		self:Update()
	end
end

function stackProto:IsEmpty()
	return not next(self.slots)
end

function stackProto:OnShow()
	self:RegisterMessage('AdiBags_UpdateAllButtons', 'Update')
	self:RegisterMessage('AdiBags_PostContentUpdate')
	self:RegisterEvent('ITEM_LOCK_CHANGED')
	if self.button then
		self.button:Show()
	end
	self:Update()
end

function stackProto:OnHide()
	if self.button then
		self.button:Hide()
	end
	self:UnregisterAllEvents()
	self:UnregisterAllMessages()
end

function stackProto:SetVisibleSlot(slotId)
	if slotId == self.slotId then return end
	self.slotId = slotId
	local button = self.button
	if button then
		button.GetCount = nil
		button:Release()
	end
	if slotId then
		button = addon:AcquireItemButton(self.container, GetBagSlotFromId(slotId))
		button.GetCount = self.GetCountHook
		button:SetAllPoints(self)
		button:SetStack(self)
		button:Show()
	else
		button = nil
	end
	self.button = button
	return true
end

function stackProto:Update()
	if not self:CanUpdate() then return end
	self:UpdateVisibleSlot()
	self:UpdateCount()
	if self.button then
		self.button:Update()
	end
end

stackProto.FullUpdate = stackProto.Update

function stackProto:UpdateCount()
	local count = 0
	for slotId in pairs(self.slots) do
		count = count + (select(2, GetContainerItemInfo(GetBagSlotFromId(slotId))) or 1)
	end
	self.count = count
	self.dirtyCount = nil
end

function stackProto:AdiBags_PostContentUpdate()
	if self.dirtyCount then
		self:UpdateCount()
	end
end

function stackProto:GetItemId()
	return self.button and self.button:GetItemId()
end

function stackProto:GetItemLink()
	return self.button and self.button:GetItemLink()
end

function stackProto:IsBank()
	return self.button and self.button:IsBank()
end

function stackProto:GetBagFamily()
	return self.button and self.button:GetBagFamily()
end

local function StackSlotIterator(self, previous)
	local slotId = next(self.slots, previous)
	if slotId then
		local bag, slot = GetBagSlotFromId(slotId)
		local _, count = GetContainerItemInfo(bag, slot)
		return slotId, bag, slot, self:GetItemId(), count
	end
end
function stackProto:IterateSlots()
	return StackSlotIterator, self
end

-- Reuse button methods
stackProto.CanUpdate = buttonProto.CanUpdate
stackProto.SetSection = buttonProto.SetSection
stackProto.GetSection = buttonProto.GetSection
