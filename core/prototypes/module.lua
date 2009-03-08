local OneCore3 = LibStub('AceAddon-3.0'):GetAddon('OneCore3')   

local ModulePrototype = {
    colWidth = 39,
    rowHeight = 39,
    topBorder = 2,
    bottomBorder = 24,
    rightBorder = 5,
    leftBorder = 8,
    
    stratas = {
        "LOW",
        "MEDIUM",
        "HIGH",
        "DIALOG",
        "FULLSCREEN",
        "FULLSCREEN_DIALOG",
        "TOOLTIP",
    },
    
    defaults = {
		profile = {
			colors = {
				mouseover = {r = 0, g = .7, b = 1, a = 1},
				ammo = {r = 1, g = 1, b = 0, a = 1},
				soul = {r = .5, g = .5, b = 1, a = 1}, 
				profession = {r = 1, g = 0, b = 1, a = 1},
				background = {r = 0, g = 0, b = 0, a = .45},
			},
			show = {
				['*'] = true
			},
			appearance = {
				cols = 10,
				scale = 1,
				alpha = 1,
				glow = false,
				rarity = true,
				white = false,
			},
			behavior = {
				strata = 2,
				locked = false,
				clamped = true,
				bagbreak = false,
				valign = 1,
				bagorder = 1,
			},
			position = {
				parent = "UIParent",
				top = 500,
				left = 300
			},
			plugins = {},
		},
	},   
}

local colorCache = {}
local plain = {r = .05, g = .05, b = .05}
function ModulePrototype:ColorBorder(slot, fcolor)
	local bag = slot:GetParent()
	local color = fcolor or plain
	
	if not slot.border then
		-- Thanks to oglow for this method
		local border = slot:CreateTexture(nil, "OVERLAY")
		border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
		border:SetBlendMode("ADD")
        border:SetAlpha(.5)
		
		border:SetPoint('CENTER', slot, 'CENTER', 0, 1)
		border:SetWidth(slot:GetWidth() * 2 - 5)
		border:SetHeight(slot:GetHeight() * 2 - 5)
		slot.border = border
	end
	
	local bcolor = nil
	if not fcolor and bag.type then
		if bag:IsAmmoBag() then
			bcolor = self.db.profile.colors.ammo
		elseif bag:IsSoulBag() then
			bcolor = self.db.profile.colors.soul
		elseif bag:IsProfessionBag() then
			bcolor = self.db.profile.colors.profession
		end
		
		if bcolor then color = bcolor end
	end
	
	if self.db.profile.appearance.rarity and not fcolor and not bcolor then
		local link = GetContainerItemLink(bag:GetID(), slot:GetID())
		if link then
			local rarity = select(3, GetItemInfo(link))
			if rarity and (rarity > 1 or self.db.profile.appearance.lowlevel) then
				-- going with this method as it should never produce a point where I don't have a color to work with.
				color = colorCache[rarity]
				if not color then
					local r, g, b, hex = GetItemQualityColor(rarity)
					color = {r=r, g=g, b=b}
					colorCache[rarity] = color --caching to prevent me from generating dozens of tables per pass
				end
			end
		end
	end
	
	local texture = slot:GetNormalTexture()		
	if self.db.profile.appearance.glow and color ~= plain then
		texture:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        texture:SetBlendMode("ADD")
        texture:SetAlpha(.8)
        texture:SetPoint("CENTER", slot, "CENTER", 0, 1)

		slot.border:Hide()
		slot.glowing = true
	elseif slot.glowing then
		texture:SetTexture("Interface\\Buttons\\UI-Quickslot2")
		texture:SetBlendMode("BLEND")
        texture:SetPoint("CENTER", slot, "CENTER", 0, 0)
		texture:SetAlpha(1)
		texture:SetVertexColor(1, 1, 1)
		
		slot.border:Show()
		slot.glowing = false
	end
	
	local target = slot.glowing and texture or slot.border
	target:SetVertexColor(color.r, color.g, color.b)
end

function ModulePrototype:HighlightBagSlots(bagid)
	if not self.frame.bags[bagid] then
		return
	end
	
	local color = self.db.profile.colors.mouseover 
	
	for slotid = 1, self.frame.bags[bagid].size do
		self:ColorBorder(self.frame.slots[('%s:%s'):format(bagid, slotid)], color)
	end
end

function ModulePrototype:UnhighlightBagSlots(bagid)
	if not self.frame.bags[bagid] then
		return
	end
	
	for slotid = 1, self.frame.bags[bagid].size do
		self:ColorBorder(self.frame.slots[('%s:%s'):format(bagid, slotid)])
	end
end

function ModulePrototype:GetBag(parent, id)
	local bag = CreateFrame("Frame", parent:GetName().."Bag"..id, parent)
	bag:SetID(id)
	
	bag.meta = {}
	bag.slots = {}
	bag.handler = self
	
	for k, v in pairs(OneCore3.BagMetatable) do
		bag[k] = v
	end
	
	return bag
end

function ModulePrototype:GetButton(parent, id)
	local bagID = parent:GetID()
	local buttonType = "ContainerFrameItemButtonTemplate"
	
	if bagID == -1 then
		buttonType = "BankItemButtonGenericTemplate"
	end
	
	local button = CreateFrame("Button", parent:GetName().."Item"..id, parent, buttonType)
	
	button:SetID(id)
	button:SetFrameLevel(parent:GetParent():GetFrameLevel()+20)
	
	button.meta = {}
	button.handler = self
	
	parent.slots[id] = button
	
	for k, v in pairs(OneCore3.SlotMetatable) do
		button[k] = v
	end
	
	return button
end

function ModulePrototype:BuildFrame()
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

function ModulePrototype:OrganizeFrame(force)
	if (not self.doOrganization and not force) or not self.frame.slots then
		return 
	end
	
	local cols, curCol, curRow, maxCol, justinc = self.db.profile.appearance.cols, 1, 1, 0, false
	
	for slotkey, slot in pairs(self.frame.slots) do
		slot:Hide()
	end
	
	for slotkey, slot in pairs(self:GetButtonOrder()) do
		if type(slot) == 'string' or slot:ShouldShow() then
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
	end
	
	if not justinc then curRow = curRow + 1 end
	self.frame:SetHeight(curRow * self.rowHeight + self.bottomBorder + self.topBorder) 
	self.frame:SetWidth(maxCol * self.colWidth + self.leftBorder + self.rightBorder)
	
	self.doOrganization = false
end

function ModulePrototype:UpdateBag(bag)
	if not self.frame.bags or not self.frame.bags[bag] then
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

function ModulePrototype:GetSlot(bagid, slotid)
	key = ('%s:%s'):format(bagid, slotid)
	return self.frame.slots[key]
end

function ModulePrototype:UpdateFrame()
	for _, bag in pairs(self.bagIndexes) do
		self:UpdateBag(bag)
	end
end

function ModulePrototype:GetButtonOrder()
	return self.activePlugins[OneCore3.SortPlugin]:GetButtonOrder()
end

OneCore3:SetDefaultModulePrototype(ModulePrototype)
