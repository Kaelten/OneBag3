local OneBag3 = LibStub('AceAddon-3.0'):NewAddon('OneBag3', 'OneCore-1.0', 'OneFrame-1.0', 'OneConfig-1.0',
	'OnePlugin-1.0', 'AceHook-3.0', 'AceEvent-3.0', 'AceConsole-3.0')
local AceDB3 = LibStub('AceDB-3.0')
local L = LibStub("AceLocale-3.0"):GetLocale("OneBag3")

OneBag3.IsRetail = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE
OneBag3.IsClassic = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC
OneBag3.IsBC = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC

OneBag3:InitializePluginSystem()

--- Handles the do once configuration, including db, frames and configuration
function OneBag3:OnInitialize()
	self.db = AceDB3:New("OneBag3DB")
	self.db:RegisterDefaults(self.defaults)

	self.displayName = "OneBag3"

	self.bagIndexes = { 0, 1, 2, 3, 4 }

	self.frame = self:CreateMainFrame("OneBagFrame")
	self.frame.handler = self
	self:UpdateFrameHeader()

	self.frame:ClearAllPoints()
	self.frame:SetPosition(self.db.profile.position)
	self.frame:CustomizeFrame(self.db.profile)
	self.frame:SetSize(200, 200)

	self.Show = self.OpenBag
	self.Hide = self.CloseBag

	self.frame:SetScript("OnShow", function()
		if not self.frame.slots then
			self.frame.slots = {}
		end

		self:BuildFrame()
		self:OrganizeFrame()
		self:UpdateFrame()

		local UpdateBag = function(_event, bag)
			self:UpdateBag(bag)
		end

		self:RegisterEvent("BAG_UPDATE", UpdateBag)
		self:RegisterEvent("BAG_UPDATE_COOLDOWN", UpdateBag)
		self:RegisterEvent("BANK_BAG_SLOT_FLAGS_UPDATED", UpdateBag)

		self:RegisterEvent("BAG_NEW_ITEMS_UPDATED", "UpdateFrame")
		self:RegisterEvent("UPDATE_INVENTORY_ALERTS", "UpdateFrame")
		self:RegisterEvent("QUEST_ACCEPTED", "UpdateFrame")

		self:RegisterEvent("UNIT_QUEST_LOG_CHANGED", function(_event, unit)
			if unit == "player" then
				self:UpdateFrame()
			end
		end)

		self:RegisterEvent("ITEM_LOCK_CHANGED", "UpdateItemLock")

		self.frame.name:SetText(L["%s's Bags"]:format(UnitName("player")))

		if self.frame.sidebarButton:GetChecked() then
			self.frame.sidebar:Show()
		end
	end)

	self.frame:SetScript("OnHide", function()
		self:UnregisterEvent("BAG_UPDATE")
		self:UnregisterEvent("BAG_UPDATE_COOLDOWN")
		self:UnregisterEvent("BANK_BAG_SLOT_FLAGS_UPDATED")

		self:UnregisterEvent("BAG_NEW_ITEMS_UPDATED")
		self:UnregisterEvent("UPDATE_INVENTORY_ALERTS")
		self:UnregisterEvent("QUEST_ACCEPTED")
		self:UnregisterEvent("UNIT_QUEST_LOG_CHANGED")
		self:UnregisterEvent("ITEM_LOCK_CHANGED")

		self.sidebar:Hide()
		self:CloseBag()
	end)

	self.frame.name:ClearAllPoints()
	self.frame.name:SetPoint("LEFT", self.frame.sidebarButton, "RIGHT", 0, 0)

	self.sidebar = self:CreateSideBar("OneBagSideFrame", self.frame)
	self.sidebar.handler = self
	self.frame.sidebar = self.sidebar

	self.sidebar:CustomizeFrame(self.db.profile)

	self.sidebar:SetScript("OnShow", function()
		if not self.sidebar.buttons then
			self.sidebar.buttons = {}
			local button = self:CreateBackpackButton(self.sidebar)
			button:ClearAllPoints()
			button:SetPoint("TOP", self.sidebar, "TOP", 0, -15)

			self.sidebar.buttons[-1] = button
			for bag = 0, 3 do
				local bagButton = self:CreateBagButton(bag, self.sidebar)
				bagButton:ClearAllPoints()
				-- 				button:SetPoint("TOP", self.sidebar, "TOP", 0, (bag + 1) * -31 - 10)

				bagButton:SetPoint("TOP", self.sidebar.buttons[bag - 1], "BOTTOM", 0, -2)

				self.sidebar.buttons[bag] = bagButton
			end
		end
	end)

	self.sidebar:Hide()
	self:InitializeConfiguration()


	--	self:EnablePlugins()
	--	self:OpenConfig()
end

--- Sets up hooks and registers events
function OneBag3:OnEnable()
	self:SecureHook("IsBagOpen")
	self:RawHook("ToggleBag", true)
	self:RawHook("ToggleBackpack", "ToggleBag", true)
	self:RawHook("ToggleAllBags", "ToggleBag", true)
	self:RawHook("OpenBag", true)
	self:RawHook("CloseBag", true)

	local open = function()
		self.wasOpened = self.isOpened
		if not self.isOpened then
			self:OpenBag()
		end
	end

	local close = function(event)
		if (event == "MAIL_CLOSED" and not self.isReopened) or not self.wasOpened then
			self:CloseBag()
		end
	end

	self:RegisterEvent("AUCTION_HOUSE_SHOW", open)
	self:RegisterEvent("AUCTION_HOUSE_CLOSED", close)
	self:RegisterEvent("BANKFRAME_OPENED", open)
	self:RegisterEvent("BANKFRAME_CLOSED", close)
	self:RegisterEvent("MAIL_SHOW", open)
	self:RegisterEvent("MAIL_CLOSED", close)
	self:RegisterEvent("MERCHANT_SHOW", open)
	self:RegisterEvent("MERCHANT_CLOSED", close)
	self:RegisterEvent("TRADE_SHOW", open)
	self:RegisterEvent("TRADE_CLOSED", close)

	if self.IsRetail then
		self:RegisterEvent("GUILDBANKFRAME_OPENED", open)
		self:RegisterEvent("GUILDBANKFRAME_CLOSED", close)
	end
end

--- Provides the custom config options for OneConfig
-- @param baseconfig the base configuration table into which the custom options are injected
function OneBag3:LoadCustomConfig(baseconfig)
	local bagvisibility = {
		type = "group",
		name = L["Specific Bag Filters"],
		order = 2,
		inline = true,
		args = {}
	}

	local names = {
		[0] = 'Backpack',
		[1] = 'First Bag',
		[2] = 'Second Bag',
		[3] = 'Third Bag',
		[4] = 'Fourth Bag',
	}

	-- this gets localized kinda oddly, should let both the desc and name localized seperately
	for id, text in pairs(names) do
		bagvisibility.args[tostring(id)] = {
			order = 5 * id + 5,
			type = "toggle",
			name = L[text],
			desc = L[("Toggles the display of your %s."):format(text)],
			get = function(_info)
				return self.db.profile.show[id]
			end,
			set = function(_info, value)
				self.db.profile.show[id] = value
				self:OrganizeFrame(true)
			end
		}
	end

	baseconfig.args.showbags.args.bag = bagvisibility
end

-- Hooks handlers

function OneBag3:OpenAllBags() self:CloseBag() end

function OneBag3:CloseAllBags() self:CloseBag() end

--- A replacement for the IsBagOpen function that provides valid results when using OneBag
-- @param bagid the numeric id of the bag being checked
function OneBag3:IsBagOpen(bagid)
	if type(bagid) == "number" and (bagid < 0 or bagid > 4) then
		return
	end

	return self.isOpened and bagid or nil
end

--- Toggles the visibility of the bag frame
-- @param bagid the numeric id of the bag being checked
function OneBag3:ToggleBag(bagid)
	if type(bagid) == "number" and (bagid < 0 or bagid > 4) then
		return self.hooks.ToggleBag(bagid)
	end

	if self.frame:IsVisible() then
		self:CloseBag()
	else
		self:OpenBag()
	end
end

--- Shows the bag frame
-- @param bagid the numeric id of the bag being checked
function OneBag3:OpenBag(bagid)
	if type(bagid) == "number" and (bagid < 0 or bagid > 4) then
		return self.hooks.OpenBag(bagid)
	end

	self.frame:Show()
	self.isReopened = self.isOpened
	self.isOpened = true
end

--- Hides the bag frame
-- @param bagid the numeric id of the bag being checked
function OneBag3:CloseBag(bagid)
	if type(bagid) == "number" and (bagid < 0 or bagid > 4) then
		return self.hooks.CloseBag(bagid)
	end

	self.frame:Hide()
	self.isOpened = false
end

--- Handles Bag Sorting
function OneBag3:SortBags()
	SortBags()
end

-- Custom button getters

--- Creates the backpack button, which differs significantly from the other bag buttons
-- @param parent the parent frame which the button will be attached to.
function OneBag3:CreateBackpackButton(parent)
	local frameType = self.IsRetail and "ItemButton" or "Button"
	local template = self.IsRetail and "ItemAnimTemplate" or "ItemButtonTemplate"
	local button = CreateFrame(frameType, "OBSideBarBackpackButton", parent, template)
	local highlight = self:CreateButtonHighlight(button)

	button:SetID(0)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	SetItemButtonTexture(button, "Interface\\Buttons\\Button-Backpack-Up")

	button:SetScript("OnEnter", function()
		self:HighlightBagSlots(0)
		highlight:Show()

		GameTooltip:SetOwner(button, "ANCHOR_LEFT")
		GameTooltip:SetText(BACKPACK_TOOLTIP, 1.0, 1.0, 1.0)
		local keyBinding = GetBindingKey("TOGGLEBACKPACK")
		if (keyBinding) then
			GameTooltip:AppendText(" " .. NORMAL_FONT_COLOR_CODE .. "(" .. keyBinding .. ")" .. FONT_COLOR_CODE_CLOSE)
		end
		GameTooltip:AddLine(string.format(NUM_FREE_SLOTS, (MainMenuBarBackpackButton.freeSlots or 0)))
		GameTooltip:Show()
	end)

	button:SetScript("OnLeave", function()
		if not self.frame.bags[0].checked then
			self:UnhighlightBagSlots(0)
			highlight:Hide()

			self.frame.bags[0].colorLocked = false
		else
			self.frame.bags[0].colorLocked = true
		end
		GameTooltip:Hide()
	end)

	button:SetScript("OnReceiveDrag", function(_event, this)
		BackpackButton_OnClick(button, this)
	end)

	button:SetScript("OnClick", function()
		if (not PutItemInBackpack()) then
			self.frame.bags[0].checked = not self.frame.bags[0].checked
		end
	end)

	return button
end

--- Creates a button for a bag
-- @param bagid the numeric id of the bag being checked
-- @param parent the parent frame which the button will be attached to.
function OneBag3:CreateBagButton(bag, parent)
	local frameType = self.IsRetail and "ItemButton" or "CheckButton"
	local button = CreateFrame(frameType, "OBSideBarBag" .. bag .. "Slot", parent, 'BagSlotButtonTemplate')
	local highlight = self:CreateButtonHighlight(button)

	if self.IsRetail then
		button:SetScale(1.27)
	end

	self:SecureHookScript(button, "OnEnter", function(this)
		self:HighlightBagSlots(this:GetID() - 19)
		highlight:Show()
	end)

	button:SetScript("OnLeave", function(this)
		local index = this:GetID() - 19
		if not self.frame.bags[index].checked then
			self:UnhighlightBagSlots(index)
			highlight:Hide()
			self.frame.bags[index].colorLocked = false
		else
			self.frame.bags[index].colorLocked = true
		end
		GameTooltip:Hide()
	end)

	button:SetScript("OnClick", function(this)
		local haditem = PutItemInBag(this:GetID())

		if not haditem then
			local index = button:GetID() - 19
			self.frame.bags[index].checked = not self.frame.bags[index].checked
		end
	end)

	button:SetScript("OnReceiveDrag", function(this)
		PutItemInBag(this:GetID())
	end)

	return button
end
