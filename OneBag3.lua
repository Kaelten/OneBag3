
local OneCore3 = LibStub('AceAddon-3.0'):GetAddon('OneCore3')
OneBag3 = OneCore3:NewModule("OneBag3")
local AceDB3 = LibStub('AceDB-3.0')

function OneBag3:OnInitialize()
	self.db = AceDB3:New("OneBagDB")
	self.db:RegisterDefaults(self.defaults)
	
	self.core = OneCore3
	
	self.bagIndexes = {0, 1, 2, 3, 4}
	
	self.frame = self.core:BuildFrame("OneBagFrame")
	self.frame.handler = self
	
	self.frame:SetPosition(self.db.profile.position)
	self.frame:CustomizeFrame(self.db.profile)
	self.frame:SetSize(200, 200)
	
	self.Show = function() self.frame:Show() end
	
	self.frame:SetScript("OnShow", function()
		if not self.frame.slots then
			self.frame.slots = {}
		end

		self:BuildFrame()
		self:OrganizeFrame()
		
		self:UpdateFrame()
		
		local UpdateBag = function(event, bag) 
			self:UpdateBag(bag)
		end
		
		self:RegisterEvent("BAG_UPDATE", UpdateBag)
		self:RegisterEvent("BAG_UPDATE_COOLDOWN", UpdateBag)
		self:RegisterEvent("UPDATE_INVENTORY_ALERTS", "UpdateFrame")
		
		self.frame.name:SetText(UnitName("player").."'s Bags")
		
		if self.frame.sidebarButton:GetChecked() then
			self.frame.sidebar:Show()
		end
	end)
	
	self.frame:SetScript("OnHide", function()
		self:UnregisterEvent("BAG_UPDATE")
		self:UnregisterEvent("BAG_UPDATE_COOLDOWN")
		self:UnregisterEvent("UPDATE_INVENTORY_ALERTS")
		
		self.sidebar:Hide()
	end)
	
	self.sidebar = OneCore3:BuildSideBar("OneBagSideFrame", self.frame)
	self.sidebar.handler = self
	self.frame.sidebar = self.sidebar
	
	self.sidebar:CustomizeFrame(self.db.profile)
	
	self.sidebar:SetScript("OnShow", function()
		if not self.sidebar.buttons then
			self.sidebar.buttons = {}
			local button = self:GetBackbackButton(self.sidebar)
			button:ClearAllPoints()
			button:SetPoint("TOP", self.sidebar, "TOP", 0, -15)
			
			self.sidebar.buttons[-1] = button
			for bag=0, 3 do
				local button = self:GetBagButton(bag, self.sidebar)
				button:ClearAllPoints()
				button:SetPoint("TOP", self.sidebar, "TOP", 0, (bag + 1) * -31 - 10)
				
				self.sidebar.buttons[bag] = button
			end
		end
	end)
	
	self.sidebar:Hide()
	
	--self:OpenConfig()
	
end

function OneBag3:OnEnable()
	self:SecureHook("IsBagOpen")
	self:RawHook("ToggleBag", true)
	self:RawHook("OpenBag", true)
	self:RawHook("CloseBag", true)
	self:RawHook("OpenBackpack", "OpenBag", true)
	self:RawHook("CloseBackpack", "CloseBag", true)
	self:RawHook("ToggleBackpack", "ToggleBag", true)
	
	local open = function() self:OpenBag() end
	local close = function() self:CloseBag() end
	
	self:RegisterEvent("AUCTION_HOUSE_SHOW", 	open)
	self:RegisterEvent("AUCTION_HOUSE_CLOSED", 	close)
	self:RegisterEvent("BANKFRAME_OPENED", 		open)
	self:RegisterEvent("BANKFRAME_CLOSED", 		close)
	self:RegisterEvent("MAIL_CLOSED", 			close)
	self:RegisterEvent("MERCHANT_SHOW", 		open)
	self:RegisterEvent("MERCHANT_CLOSED", 		close)
	self:RegisterEvent("TRADE_SHOW", 			open)
	self:RegisterEvent("TRADE_CLOSED", 			close)
	self:RegisterEvent("GUILDBANKFRAME_OPENED", 			open)
	self:RegisterEvent("GUILDBANKFRAME_CLOSED", 			close)
	
end

-- Hooks handlers
function OneBag3:IsBagOpen(bag)
	if bag < 0 or bag > 4 then
		return 
	end
	
	if self.frame:IsVisible() then
		return bag
	else
		return nil	
	end
end

function OneBag3:ToggleBag(bag)
	if bag and (bag < 0 or bag > 4) then
		return self.hooks.ToggleBag(bag)
	end
	
	if self.frame:IsVisible() then
		self.frame:Hide()
	else
		self.frame:Show()
	end
end

function OneBag3:OpenBag(bag)
	if bag and (bag < 0 or bag > 4) then
		return self.hooks.OpenBag(bag)
	end
	
	self.frame:Show()
end


function OneBag3:CloseBag(bag)
	if bag and (bag < 0 or bag > 4) then
		return self.hooks.CloseBag(bag)
	end
	
	self.frame:Hide()
end

function OneBag3:GetBackbackButton(parent)
	local button = CreateFrame("CheckButton", "OBSideBarBackpackButton", parent, "ItemButtonTemplate")
	button:SetID(0)
	
	local itemAnim = CreateFrame("Model", "OBSideBarBackpackButtonItemAnim", button, "ItemAnimTemplate")
	itemAnim:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -10, 0)
	
	button:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")
	
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	OBSideBarBackpackButtonIconTexture:SetTexture("Interface\\Buttons\\Button-Backpack-Up")
--	OBSideBarBackpackButtonIconTexture:Show()
	
	button:SetScript("OnEnter", function()
		GameTooltip:SetOwner(button, "ANCHOR_LEFT")
		GameTooltip:SetText(BACKPACK_TOOLTIP, 1.0, 1.0, 1.0)
		local keyBinding = GetBindingKey("TOGGLEBACKPACK")
		if ( keyBinding ) then
			GameTooltip:AppendText(" "..NORMAL_FONT_COLOR_CODE.."("..keyBinding..")"..FONT_COLOR_CODE_CLOSE)
		end
		GameTooltip:AddLine(string.format(NUM_FREE_SLOTS, (MainMenuBarBackpackButton.freeSlots or 0)))
		GameTooltip:Show()
	end)
	
	button:SetScript("OnLeave", function() GameTooltip:Hide() end)
	button:SetScript("OnReceiveDrag", function(event, btn) BackpackButton_OnClick(button, btn) end)
	
	return button
	
end

function OneBag3:GetBagButton(bag, parent)
	local button = CreateFrame("CheckButton", "OBSideBarBag"..bag.."Slot", parent, "BagSlotButtonTemplate")
	
	button:SetScale(1.27)
	
	return button
end

function OneBag3:GetBag(parent, id)
	local frame = CreateFrame("Frame", parent:GetName().."Bag"..id, parent)
	frame:SetID(id)
	
	frame.meta = {}
	frame.slots = {}
	
	return frame
end

function OneBag3:GetButton(parent, id)
	local frame = CreateFrame("Button", parent:GetName().."Item"..id, parent, "ContainerFrameItemButtonTemplate")
	frame:SetID(id)
	
	frame.meta = {
		name = '',
	}
	
	parent.slots[id] = frame
	
	return frame
end

function OneBag3:GetButtonOrder()
	slots = {}
	
	for _, bagid in pairs(self.bagIndexes) do
		for slotid = 1, self.frame.bags[bagid].size do
			tinsert(slots,  self.frame.slots[('%s:%s'):format(bagid, slotid)])
		end		
	end

	return slots
end

function OneBag3:BuildFrame()
	for _, bag in pairs(self.bagIndexes) do
		local size = GetContainerNumSlots(bag)
		
		if not self.frame.bags then
			self.frame.bags = {}
		end
		
		if not self.frame.bags[bag] then
			self.frame.bags[bag] = self:GetBag(self.frame, bag)
		end		
		
		if self.frame.bags[bag].size ~= size then
			self.frame.bags[bag].size = size
			self.doOrganization = true
		end
		
		for slot = 1, size do
			slotkey = ('%s:%s'):format(bag, slot)
			if not self.frame.slots[slotkey] then
				self.frame.slots[slotkey] = self:GetButton(self.frame.bags[bag], slot)
				self.doOrganization = true
			end
		end
		
	end
end

function OneBag3:OrganizeFrame(force)
	if not self.doOrganization and not force then
		return 
	end
	
	local cols, curCol, curRow, justinc = self.db.profile.appearance.cols, 1, 1, false
	
	for slotkey, slot in pairs(self.frame.slots) do
		slot:Hide()
	end
	
	for slotkey, slot in pairs(self:GetButtonOrder()) do
		justinc = false
		slot:ClearAllPoints()
		slot:SetPoint("TOPLEFT", self.frame:GetName(), "TOPLEFT", self.leftBorder + self.colWidth * (curCol - 1), 0 - self.topBorder - (self.rowHeight * curRow))
		slot:Show()
		curCol = curCol + 1
		if curCol > cols then
			curCol, curRow, justinc = 1, curRow + 1, true
		end
	end
	
	if not justinc then curRow = curRow + 1 end
	self.frame:SetHeight(curRow * self.rowHeight + self.bottomBorder + self.topBorder) 
	self.frame:SetWidth(cols * self.colWidth + self.leftBorder + self.rightBorder)
	
	self.doOrganization = false
end

function OneBag3:UpdateBag(bag)
	if not self.frame.bags[bag] then
		return
	end
	
	self:BuildFrame()
	self:OrganizeFrame()
	
	if not self.frame.bags[bag].colorLocked then
		for slot=1, self.frame.bags[bag].size do
			self:ColorBorder(self:GetSlot(bag, slot))
		end
	end
	
	if self.frame.bags[bag].size and self.frame.bags[bag].size > 0 then
		ContainerFrame_Update(self.frame.bags[bag])
	end
end

function OneBag3:GetSlot(bagid, slotid)
	key = ('%s:%s'):format(bagid, slotid)
	return self.frame.slots[key]
end

function OneBag3:UpdateFrame()
	for _, bag in pairs(self.bagIndexes) do
		self:UpdateBag(bag)
	end
end