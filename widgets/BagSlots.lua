--[[
AdiBags - Adirelle's bag addon.
Copyright 2010-2011 Adirelle (adirelle@tagada-team.net)
All rights reserved.
--]]

local addonName, addon = ...
local L = addon.L

--<GLOBALS
local _G = _G
local BACKPACK_CONTAINER = _G.BACKPACK_CONTAINER
local band = _G.bit.band
local BankFrame = _G.BankFrame
local BANK_BAG = _G.BANK_BAG
local BANK_BAG_PURCHASE = _G.BANK_BAG_PURCHASE
local BANK_CONTAINER = _G.BANK_CONTAINER
local ClearCursor = _G.ClearCursor
local ContainerIDToInventoryID = _G.ContainerIDToInventoryID
local COSTS_LABEL = _G.COSTS_LABEL
local CreateFrame = _G.CreateFrame
local CursorHasItem = _G.CursorHasItem
local CursorUpdate = _G.CursorUpdate
local GameTooltip = _G.GameTooltip
local GetBankSlotCost = _G.GetBankSlotCost
local GetCoinTextureString = _G.GetCoinTextureString
local GetContainerItemID = _G.GetContainerItemID
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetContainerNumFreeSlots = _G.GetContainerNumFreeSlots
local GetContainerNumSlots = _G.GetContainerNumSlots
local geterrorhandler = _G.geterrorhandler
local GetInventoryItemTexture = _G.GetInventoryItemTexture
local GetItemInfo = _G.GetItemInfo
local GetNumBankSlots = _G.GetNumBankSlots
local ipairs = _G.ipairs
local IsInventoryItemLocked = _G.IsInventoryItemLocked
local KEYRING_CONTAINER = _G.KEYRING_CONTAINER
local next = _G.next
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS
local NUM_BANKGENERIC_SLOTS = _G.NUM_BANKGENERIC_SLOTS
local pairs = _G.pairs
local pcall = _G.pcall
local PickupBagFromSlot = _G.PickupBagFromSlot
local PickupContainerItem = _G.PickupContainerItem
local PlaySound = _G.PlaySound
local PutItemInBag = _G.PutItemInBag
local select = _G.select
local SetItemButtonDesaturated = _G.SetItemButtonDesaturated
local SetItemButtonTexture = _G.SetItemButtonTexture
local SetItemButtonTextureVertexColor = _G.SetItemButtonTextureVertexColor
local StaticPopup_Show = _G.StaticPopup_Show
local strjoin = _G.strjoin
local tinsert = _G.tinsert
local tsort = _G.table.sort
local unpack = _G.unpack
local wipe = _G.wipe
--GLOBALS>

local ITEM_SIZE = addon.ITEM_SIZE
local ITEM_SPACING = addon.ITEM_SPACING
local BAG_INSET = addon.BAG_INSET
local TOP_PADDING = addon.TOP_PADDING

--------------------------------------------------------------------------------
-- Swaping process
--------------------------------------------------------------------------------

local EmptyBag
do
	local swapFrame = CreateFrame("Frame")
	local otherBags = {}
	local locked = {}
	local timeout = 0
	local currentBag, currentSlot, numSlots

	function swapFrame:Done()
		self:UnregisterAllEvents()
		self:Hide()
		currentBag = nil
		wipe(locked)
		addon:SetGlobalLock(false)
	end

	local function FindSlotForItem(bags, itemId, itemCount)
		local itemFamily = addon.GetItemFamily(itemId)
		local maxStack = select(8, GetItemInfo(itemId)) or 1
		addon:Debug('FindSlotForItem', itemId, GetItemInfo(itemId), 'count=', itemCount, 'maxStack=', maxStack, 'family=', itemFamily, 'bags:', unpack(bags))
		local bestBag, bestSlot, bestScore
		for i, bag in pairs(bags) do
			if bag == KEYRING_CONTAINER and itemFamily ~= 256 then
				addon:Debug('Skipping bag', bag, '(keyring): itemFamily is not 256')
			else
				local scoreBonus = band(bag == KEYRING_CONTAINER and 256 or select(2, GetContainerNumFreeSlots(bag)) or 0, itemFamily) ~= 0 and maxStack or 0
				for slot = 1, GetContainerNumSlots(bag) do
					local texture, slotCount, locked = GetContainerItemInfo(bag, slot)
					if not locked and (not texture or GetContainerItemID(bag, slot) == itemId) then
						slotCount = slotCount or 0
						if slotCount + itemCount <= maxStack then
							local slotScore = slotCount + scoreBonus
							if not bestScore or slotScore > bestScore then
								addon:Debug('FindSlotForItem', bag, slot, 'slotCount=', slotCount, 'score=', slotScore, 'NEW BEST SLOT')
								bestBag, bestSlot, bestScore = bag, slot, slotScore
								--[===[@debug@]
                                else
                                    addon:Debug('FindSlotForItem', bag, slot, 'slotCount=', slotCount, 'score=', slotScore, '<', bestScore)
                                --@end-debug@]===]
							end
							--[===[@debug@]
                            else
                                addon:Debug('FindSlotForItem', bag, slot, 'slotCount=', slotCount, ': not enough space')
                            --@end-debug@]===]
						end
					end
				end
			end
		end
		addon:Debug('FindSlotForItem =>', bestBag, bestSlot)
		return bestBag, bestSlot
	end

	function swapFrame:ProcessInner()
		if not CursorHasItem() then
			while currentSlot < numSlots do
				currentSlot = currentSlot + 1
				local itemId = GetContainerItemID(currentBag, currentSlot)
				if itemId then
					local _, count = select(2, GetContainerItemInfo(currentBag, currentSlot))
					PickupContainerItem(currentBag, currentSlot)
					if CursorHasItem() then
						locked[currentBag] = true
						local destBag, destSlot = FindSlotForItem(otherBags, itemId, count or 1)
						if destBag and destSlot then
							PickupContainerItem(destBag, destSlot)
							if not CursorHasItem() then
								locked[destBag] = true
								return
							end
						end
						break
					end
				end
			end
		end
		ClearCursor()
		self:Done()
	end

	function swapFrame:Process()
		local ok, msg = pcall(self.ProcessInner, self)
		if not ok then
			self:Done()
			geterrorhandler()(msg)
		else
			timeout = 2
			self:Show()
		end
	end

	swapFrame:Hide()
	swapFrame:SetScript('OnUpdate', function(self, elapsed)
		if elapsed > timeout then
			self:Done()
		else
			timeout = timeout - elapsed
		end
	end)

	swapFrame:SetScript('OnEvent', function(self, event, bagOrSlot)
		addon:Debug(event, bagOrSlot)
		if event == 'PLAYERBANKSLOTS_CHANGED' then
			if bagOrSlot > 0 and bagOrSlot <= NUM_BANKGENERIC_SLOTS then
				bagOrSlot = -1
			else
				return
			end
		end
		locked[bagOrSlot] = nil
		if not next(locked) then
			self:Process()
		end
	end)

	function EmptyBag(bag)
		ClearCursor()
		wipe(otherBags)
		local bags = addon.BAG_IDS.BANK[bag] and addon.BAG_IDS.BANK or addon.BAG_IDS.BAGS
		for otherBag in pairs(bags) do
			if otherBag ~= bag then
				tinsert(otherBags, otherBag)
			end
		end
		if #otherBags > 0 then
			tsort(otherBags)
			currentBag, currentSlot, numSlots = bag, 0, GetContainerNumSlots(bag)
			addon:SetGlobalLock(true)
			swapFrame:RegisterEvent('PLAYERBANKSLOTS_CHANGED')
			swapFrame:RegisterEvent('BAG_UPDATE')
			swapFrame:Process()
		end
	end
end

--------------------------------------------------------------------------------
-- Regular bag buttons
--------------------------------------------------------------------------------

local bagButtonClass, bagButtonProto = addon:NewClass("BagSlotButton", "Button", "ItemButtonTemplate", "AceEvent-3.0")

function bagButtonProto:OnCreate(bag)
	self.bag = bag
	self.invSlot = ContainerIDToInventoryID(bag)

	self:GetNormalTexture():SetSize(64 * 37 / ITEM_SIZE, 64 * 37 / ITEM_SIZE)
	self:SetSize(ITEM_SIZE, ITEM_SIZE)

	self:EnableMouse(true)
	self:RegisterForDrag("LeftButton")
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	self:SetScript('OnShow', self.OnShow)
	self:SetScript('OnHide', self.OnHide)
	self:SetScript('OnEnter', self.OnEnter)
	self:SetScript('OnLeave', self.OnLeave)
	self:SetScript('OnDragStart', self.OnDragStart)
	self:SetScript('OnReceiveDrag', self.OnClick)
	self:SetScript('OnClick', self.OnClick)
	self.UpdateTooltip = self.OnEnter

	self.Count = _G[self:GetName().."Count"]
end

function bagButtonProto:UpdateLock()
	if addon.globalLock then
		self:Disable()
		SetItemButtonDesaturated(self, true)
	else
		self:Enable()
		SetItemButtonDesaturated(self, IsInventoryItemLocked(self.invSlot))
	end
end

function bagButtonProto:Update()
	local icon = GetInventoryItemTexture("player", self.invSlot)
	self.hasItem = not not icon
	if self.hasItem then
		local total, free = GetContainerNumSlots(self.bag), GetContainerNumFreeSlots(self.bag)
		if total > 0 then
			self.isEmpty = (total == free)
			self.Count:SetFormattedText("%d", total-free)
			if free == 0 then
				self.Count:SetTextColor(1, 0, 0)
			else
				self.Count:SetTextColor(1, 1, 1)
			end
			self.Count:Show()
		else
			self.Count:Hide()
		end
	else
		icon = [[Interface\PaperDoll\UI-PaperDoll-Slot-Bag]]
		self.Count:Hide()
	end
	SetItemButtonTexture(self, icon)
	self:UpdateLock()
end

function bagButtonProto:OnShow()
	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("ITEM_LOCK_CHANGED")
	self:RegisterMessage("AdiBags_GlobalLockChanged", "Update")
	self:Update()
end

function bagButtonProto:OnHide()
	self:UnregisterAllEvents()
	self:UnregisterAllMessages()
end

function bagButtonProto:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	if not GameTooltip:SetInventoryItem("player", self.invSlot) then
		if self.tooltipText then
			GameTooltip:SetText(self.tooltipText)
		end
	elseif not self.isEmpty then
		GameTooltip:AddLine(L['Right-click to try to empty this bag.'])
		GameTooltip:Show()
	end
	CursorUpdate(self)
end

function bagButtonProto:OnLeave()
	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide()
	end
end

local pendingUpdate = {}

function bagButtonProto:OnClick(button)
	if self.hasItem and button == "RightButton" then
		if not self.isEmpty then
			EmptyBag(self.bag)
		end
	else
		if not PutItemInBag(self.invSlot) and self.hasItem then
			PickupBagFromSlot(self.invSlot)
		end
		pendingUpdate[self.invSlot] = true
	end
end

function bagButtonProto:OnDragStart()
	if self.hasItem then
		PickupBagFromSlot(self.invSlot)
		pendingUpdate[self.invSlot] = true
	end
end

function bagButtonProto:BAG_UPDATE(event, bag, ...)
	if bag == self.bag then
		return self:Update()
	end
end

function bagButtonProto:ITEM_LOCK_CHANGED(event, invSlot, containerSlot)
	if not (containerSlot and invSlot == self.invSlot) or pendingUpdate[self.invSlot] then
		return self:Update()
	end
end

--------------------------------------------------------------------------------
-- Bank bag buttons
--------------------------------------------------------------------------------

local bankButtonClass, bankButtonProto = addon:NewClass("BankSlotButton", "BagSlotButton")

function bankButtonProto:OnClick(button)
	if self.toPurchase then
		PlaySound("igMainMenuOption")
		StaticPopup_Show("CONFIRM_BUY_BANK_SLOT")
	else
		return bagButtonProto.OnClick(self, button)
	end
end

function bankButtonProto:UpdateStatus()
	local numSlots = GetNumBankSlots()
	local bankSlot = self.bag - NUM_BAG_SLOTS
	self.toPurchase = nil
	if bankSlot <= numSlots then
		SetItemButtonTextureVertexColor(self, 1, 1, 1)
		self.tooltipText = BANK_BAG
	else
		SetItemButtonTextureVertexColor(self, 1, 0.1, 0.1)
		local cost = GetBankSlotCost(bankSlot)
		if bankSlot == numSlots + 1 then
			BankFrame.nextSlotCost = cost
			self.tooltipText = strjoin("",
				BANK_BAG_PURCHASE, "\n",
				COSTS_LABEL, " ", GetCoinTextureString(cost), "\n",
				L["Click to purchase"]
			)
			self.toPurchase = true
		else
			self.tooltipText = strjoin("", BANK_BAG_PURCHASE, "\n", COSTS_LABEL, " ", GetCoinTextureString(cost))
		end
	end
end

function bankButtonProto:Update()
	bagButtonProto.Update(self)
	self:UpdateStatus()
end

function bankButtonProto:PLAYERBANKSLOTS_CHANGED(event, bankSlot)
	if bankSlot - NUM_BANKGENERIC_SLOTS == self.bag - NUM_BAG_SLOTS then
		self:Update()
	end
end

function bankButtonProto:OnShow()
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
	self:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED", "UpdateStatus")
	self:RegisterEvent("PLAYER_MONEY", "UpdateStatus")
	bagButtonProto.OnShow(self)
end

--------------------------------------------------------------------------------
-- Backpack bag panel scripts
--------------------------------------------------------------------------------

local function Panel_OnShow(self)
	PlaySound(self.openSound)
	addon:SendMessage('AdiBags_FiltersChanged', true)
end

local function Panel_OnHide(self)
	PlaySound(self.closeSound)
	addon:SendMessage('AdiBags_FiltersChanged', true)
	addon:SendMessage('AdiBags_BagSwapPanelClosed', true)
end

local function Panel_UpdateSkin(self)
	local backdrop, r, g, b, a = addon:GetContainerSkin(self:GetParent().name)
	self:SetBackdrop(backdrop)
	self:SetBackdropColor(r, g, b, a)
	local m = max(r, g, b)
	if m == 0 then
		self:SetBackdropBorderColor(0.5, 0.5, 0.5, a)
	else
		self:SetBackdropBorderColor(0.5+(0.5*r/m), 0.5+(0.5*g/m), 0.5+(0.5*b/m), a)
	end
end

local function Panel_ConfigChanged(self, event, name)
	if strsplit('.', name) == 'skin' then
		return Panel_UpdateSkin(self)
	end
end

--------------------------------------------------------------------------------
-- Panel creation
--------------------------------------------------------------------------------

function addon:CreateBagSlotPanel(container, name, bags, isBank)
	local self = CreateFrame("Frame", container:GetName().."Bags", container)
	-- self:SetBackdrop(addon.BACKDROP)
	self:SetPoint("BOTTOMLEFT", container, "TOPLEFT", 0, 4)

	self.openSound = isBank and "igMainMenuOpen" or "igBackPackOpen"
	self.closeSound = isBank and "igMainMenuClose" or "igBackPackClose"
	self:SetScript('OnShow', Panel_OnShow)
	self:SetScript('OnHide', Panel_OnHide)

	local title = self:CreateFontString(nil, "OVERLAY")
	self.Title = title
	title:SetFontObject(addon.bagFont)
	title:SetText(L["Equipped bags"])
	title:SetJustifyH("LEFT")
	title:SetPoint("TOPLEFT", BAG_INSET, -BAG_INSET)

	tsort(bags)
	self.buttons = {}
	local buttonClass = isBank and bankButtonClass or bagButtonClass
	local x = BAG_INSET
	local height = 0
	for i, bag in ipairs(bags) do
		if bag ~= KEYRING_CONTAINER and bag ~= BACKPACK_CONTAINER and bag ~= BANK_CONTAINER then
			local button = buttonClass:Create(bag)
			button:SetParent(self)
			button:SetPoint("TOPLEFT", x, -TOP_PADDING)
			button:Show()
			x = x + ITEM_SIZE + ITEM_SPACING
			tinsert(self.buttons, button)
		end
	end

	self:SetWidth(x + BAG_INSET)
	self:SetHeight(BAG_INSET + TOP_PADDING + ITEM_SIZE)

	LibStub('AceEvent-3.0').RegisterMessage(self:GetName(), 'AdiBags_ConfigChanged', Panel_ConfigChanged, self)
	Panel_UpdateSkin(self)

	return self
end
