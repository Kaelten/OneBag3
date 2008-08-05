
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
			self:BuildFrame()
			self:OrganizeFrame()
		end
		
		self:UpdateFrame()
		
		local UpdateBag = function(event, bag) 
			self:UpdateBag(bag)
		end
		
		self:RegisterEvent("BAG_UPDATE", UpdateBag)
		self:RegisterEvent("BAG_UPDATE_COOLDOWN", UpdateBag)
		self:RegisterEvent("UPDATE_INVENTORY_ALERTS", "UpdateFrame")
	end)
	
	self.frame:SetScript("OnHide", function()
		self:UnregisterEvent("BAG_UPDATE")
		self:UnregisterEvent("BAG_UPDATE_COOLDOWN")
		self:UnregisterEvent("UPDATE_INVENTORY_ALERTS")
	end)
	
end

function OneBag3:OnEnable()
	

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
	
	frame:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
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

function OneBag3:OrganizeFrame()
	if not self.doOrganization then
		return 
	end
	
	local cols, curCol, curRow, justinc = self.db.profile.appearance.cols, 1, 1, false
	
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

	ContainerFrame_Update(self.frame.bags[bag])
end

function OneBag3:UpdateFrame()
	for _, bag in pairs(self.bagIndexes) do
		self:UpdateBag(bag)
	end
end