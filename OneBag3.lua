
local OneCore3 = LibStub('AceAddon-3.0'):GetAddon('OneCore3')
OneBag3 = OneCore3:NewModule("OneBag3")
local AceDB3 = LibStub('AceDB-3.0')

function OneBag3:OnInitialize()
	self.db = AceDB3:New("OneBagDB")
	self.db:RegisterDefaults(self.defaults)
	
	self.displayName = "OneBag3"
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
	
	self:InitializeConfiguration()
	self:OpenConfig()
	
end

function OneBag3:OnEnable()
	self:SecureHook("IsBagOpen")
	self:RawHook("ToggleBag", true)
	self:RawHook("OpenBag", true)
	self:RawHook("CloseBag", true)
	self:RawHook("OpenBackpack", "OpenBag", true)
	self:RawHook("CloseBackpack", "CloseBag", true)
	self:RawHook("ToggleBackpack", "ToggleBag", true)
	
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
	
	self:RegisterEvent("AUCTION_HOUSE_SHOW", 	open)
	self:RegisterEvent("AUCTION_HOUSE_CLOSED", 	close)
	self:RegisterEvent("BANKFRAME_OPENED", 		open)
	self:RegisterEvent("BANKFRAME_CLOSED", 		close)
	self:RegisterEvent("MAIL_SHOW",				open)
	self:RegisterEvent("MAIL_CLOSED", 			close)
	self:RegisterEvent("MERCHANT_SHOW", 		open)
	self:RegisterEvent("MERCHANT_CLOSED", 		close)
	self:RegisterEvent("TRADE_SHOW", 			open)
	self:RegisterEvent("TRADE_CLOSED", 			close)
	self:RegisterEvent("GUILDBANKFRAME_OPENED", open)
	self:RegisterEvent("GUILDBANKFRAME_CLOSED", close)
	
end

-- Hooks handlers
function OneBag3:IsBagOpen(bag)
	if type(bag) == "number" and (bag < 0 or bag > 4) then
		return 
	end
	
	if self.frame:IsVisible() then
		return bag
	else
		return nil	
	end
end

function OneBag3:ToggleBag(bag)
	if type(bag) == "number" and (bag < 0 or bag > 4) then
		return self.hooks.ToggleBag(bag)
	end
	
	if self.frame:IsVisible() then
		self:CloseBag()
	else
		self:OpenBag()
	end
end

function OneBag3:OpenBag(bag)
	if type(bag) == "number" and (bag < 0 or bag > 4) then
		return self.hooks.OpenBag(bag)
	end
	
	self.frame:Show()
	self.isReopened = self.isOpened
	self.isOpened = true
end


function OneBag3:CloseBag(bag)
	if type(bag) == "number" and (bag < 0 or bag > 4) then
		return self.hooks.CloseBag(bag)
	end
	
	self.frame:Hide()
	self.isOpened = false
end

function OneBag3:GetBackbackButton(parent)
	local button = CreateFrame("CheckButton", "OBSideBarBackpackButton", parent, "ItemButtonTemplate")
	button:SetID(0)
	
	local itemAnim = CreateFrame("Model", "OBSideBarBackpackButtonItemAnim", button, "ItemAnimTemplate")
	itemAnim:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -10, 0)
	
	button:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")
	
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	OBSideBarBackpackButtonIconTexture:SetTexture("Interface\\Buttons\\Button-Backpack-Up")
	
	button:SetScript("OnEnter", function()
		self:HighlightBagSlots(0)
		GameTooltip:SetOwner(button, "ANCHOR_LEFT")
		GameTooltip:SetText(BACKPACK_TOOLTIP, 1.0, 1.0, 1.0)
		local keyBinding = GetBindingKey("TOGGLEBACKPACK")
		if ( keyBinding ) then
			GameTooltip:AppendText(" "..NORMAL_FONT_COLOR_CODE.."("..keyBinding..")"..FONT_COLOR_CODE_CLOSE)
		end
		GameTooltip:AddLine(string.format(NUM_FREE_SLOTS, (MainMenuBarBackpackButton.freeSlots or 0)))
		GameTooltip:Show()
	end)
	
	button:SetScript("OnLeave", function(button)
		if not button:GetChecked() then
			self:UnhighlightBagSlots(0)
			self.frame.bags[0].colorLocked = false
		else
			self.frame.bags[0].colorLocked = true
		end
		GameTooltip:Hide()
	end)
	
	button:SetScript("OnReceiveDrag", function(event, btn) BackpackButton_OnClick(button, btn) end)
	
	return button
	
end

function OneBag3:GetBagButton(bag, parent)
	local button = CreateFrame("CheckButton", "OBSideBarBag"..bag.."Slot", parent, "BagSlotButtonTemplate")
	
	button:SetScale(1.27)
	
	self:SecureHookScript(button, "OnEnter", function(button)
		self:HighlightBagSlots(button:GetID()-19)
	end)
	
	button:SetScript("OnLeave", function(button)
		if not button:GetChecked() then
			self:UnhighlightBagSlots(button:GetID()-19)
			self.frame.bags[button:GetID()-19].colorLocked = false
		else
			self.frame.bags[button:GetID()-19].colorLocked = true
		end
		GameTooltip:Hide()
	end)
	
	button:SetScript("OnClick", function(button) 
		local haditem = PutItemInBag(button:GetID())

		if haditem then
			button:SetChecked(not button:GetChecked())
		end 
	end)
	
	button:SetScript("OnReceiveDrag", function(button) 
		PutItemInBag(button:GetID())
	end)
	
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
	frame:SetFrameLevel(parent:GetParent():GetFrameLevel()+20)
	
	frame.meta = {
		name = '',
	}
	
	parent.slots[id] = frame
	
	return frame
end

function OneBag3:GetButtonOrder()
	slots = {}
	
	if self.db.profile.behavior.bagorder == 2 then
		start, stop, step = #self.bagIndexes, 1, -1
	else
		start, stop, step = 1, #self.bagIndexes, 1
	end

	for i=start, stop, step do
		bagid = self.bagIndexes[i]

		for slotid = 1, self.frame.bags[bagid].size do
			table.insert(slots,  self.frame.slots[('%s:%s'):format(bagid, slotid)])
		end	
		
		if self.db.profile.behavior.bagbreak then
			table.insert(slots, "NEWLINE")
		end
	end
	
	if self.db.profile.behavior.valign == 2 and not self.db.profile.behavior.bagbreak then
		local totalSlots, cols = #slots, self.db.profile.appearance.cols
		local leftover = math.fmod(totalSlots, cols)
		local spaces = leftover > 0 and cols - leftover or 0
		for i=1, spaces do
			table.insert(slots, 1, "BLANK")
		end
	end
	
	return slots
end

function OneBag3:BuildFrame()
	for _, bag in pairs(self.bagIndexes) do
		local size = GetContainerNumSlots(bag)
		local bagType = select(2, GetContainerNumFreeSlots(bag))
		
		if not self.frame.bags then
			self.frame.bags = {}
		end
		
		if not self.frame.bags[bag] then
			self.frame.bags[bag] = self:GetBag(self.frame, bag)
		end		
		
		self.frame.bags[bag].type = bagType
		
		if self.frame.bags[bag].size ~= size then
			self.frame.bags[bag].size = size
			self.doOrganization = true
		end
		
		for slot = 1, size do
			slotkey = ('%s:%s'):format(bag, slot)
			if not self.frame.slots[slotkey] then
				self.frame.slots[slotkey] = self:GetButton(self.frame.bags[bag], slot)
				self.frame.slots[slotkey]:SetFrameStrata(self.stratas[self.db.profile.behavior.strata])
				self.doOrganization = true
			end
		end
	end
end

function OneBag3:OrganizeFrame(force)
	if not self.doOrganization and not force then
		return 
	end
	
	local cols, curCol, curRow, maxCol, justinc = self.db.profile.appearance.cols, 1, 1, 0, false
	
	for slotkey, slot in pairs(self.frame.slots) do
		slot:Hide()
	end
	
	for slotkey, slot in pairs(self:GetButtonOrder()) do
		if slot.ClearAllPoints then
			justinc = false
			slot:ClearAllPoints()
			slot:SetPoint("TOPLEFT", self.frame:GetName(), "TOPLEFT", self.leftBorder + self.colWidth * (curCol - 1), 0 - self.topBorder - (self.rowHeight * curRow))
			slot:SetFrameLevel(self.frame:GetFrameLevel()+20)
			slot:Show()
			curCol = curCol + 1
		end
		
		if slot == "BLANK" then
			curCol = curCol + 1
		end
		
		maxCol = math.max(maxCol, curCol-1)
		
		if (curCol > cols or slot == "NEWLINE") and not justinc then
			curCol, curRow, justinc = 1, curRow + 1, true
		end
	end
	
	if not justinc then curRow = curRow + 1 end
	self.frame:SetHeight(curRow * self.rowHeight + self.bottomBorder + self.topBorder) 
	self.frame:SetWidth(maxCol * self.colWidth + self.leftBorder + self.rightBorder)
	
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