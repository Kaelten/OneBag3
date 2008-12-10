
-- BAGTYPE_QUIVER = Quiver + Ammo
local BAGTYPE_QUIVER = 0x0001 + 0x0002 
-- BAGTYPE_SOUL = Soul Bags
local BAGTYPE_SOUL = 0x004
-- BAGTYPE_PROFESSION = Leather + Inscription + Herb + Enchanting + Engineering + Gem + Mining
local BAGTYPE_PROFESSION = 0x0008 + 0x0010 + 0x0020 + 0x0040 + 0x0080 + 0x0200 + 0x0400 

local BagMetatable = {}

function BagMetatable:IsAmmoBag()
	if not self.type or self.type == 0 then return false end
	return bit.band(self.type, BAGTYPE_QUIVER) > 0
end

function BagMetatable:IsSoulBag()
	if not self.type or self.type == 0 then return false end
	return bit.band(self.type, BAGTYPE_SOUL) > 0
end

function BagMetatable:IsProfessionBag()
	if not self.type or self.type == 0 then return false end
	return bit.band(self.type, BAGTYPE_PROFESSION) > 0
end

local SlotMetatable = {}

function SlotMetatable:ShouldShow()
	local bag = self:GetParent()
	
	if bag:IsAmmoBag() and not self.handler.db.profile.show.ammo then 
		return false 
	end
	
	if bag:IsSoulBag() and not self.handler.db.profile.show.soul then 
		return false 
	end
	
	if bag:IsProfessionBag() and not self.handler.db.profile.show.profession then 
		return false 
	end
	
	return self.handler.db.profile.show[bag:GetID()]
end

local FrameMetatable = {}

function FrameMetatable:CustomizeFrame(db)
	self:SetScale(db.appearance.scale)
	self:SetAlpha(db.appearance.alpha)
	
	local c = db.colors.background
	self:SetBackdropColor(c.r, c.g, c.b, c.a)
	
	self:SetFrameStrata(self.handler.stratas[db.behavior.strata])
	self:SetClampedToScreen(db.behavior.clamped)
	
	if self.sidebar then
		self.sidebar:CustomizeFrame(db)
	end
	
	if self.slots then
		for _, slot in pairs(self.slots) do
			slot:SetFrameStrata(self.handler.stratas[db.behavior.strata])
		end
	end
end

function FrameMetatable:SetSize(width, height)
	self:SetWidth(width)
	self:SetHeight(height)
end

function FrameMetatable:SetPosition(position)
	self:ClearAllPoints()
	self:SetPoint(position.attachAt or "TOPLEFT", getglobal(position.parent), position.attachTo or "BOTTOMLEFT", position.left, position.top)
end

function FrameMetatable:GetPosition()
	return {
		top = self:GetTop(),
		left = self:GetLeft(),
		parent = self:GetParent():GetName(),
	}
end

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

function ModulePrototype:GetBagButton(bag, parent)
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

function ModulePrototype:GetBag(parent, id)
	local bag = CreateFrame("Frame", parent:GetName().."Bag"..id, parent)
	bag:SetID(id)
	
	bag.meta = {}
	bag.slots = {}
	bag.handler = self
	
	for k, v in pairs(BagMetatable) do
		bag[k] = v
	end
	
	return bag
end

function ModulePrototype:GetButton(parent, id)
	local button = CreateFrame("Button", parent:GetName().."Item"..id, parent, "ContainerFrameItemButtonTemplate")
	
	button:SetID(id)
	button:SetFrameLevel(parent:GetParent():GetFrameLevel()+20)
	
	button.meta = {}
	button.handler = self
	
	parent.slots[id] = button
	
	for k, v in pairs(SlotMetatable) do
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

-- OneCore!
local AceAddon = LibStub("AceAddon-3.0")
OneCore3 = AceAddon:NewAddon("OneCore3", "AceEvent-3.0", "AceHook-3.0")
OneCore3:SetDefaultModulePrototype(ModulePrototype)
OneCore3:SetDefaultModuleLibraries("AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")


function OneCore3:OnInitialize()
	-- This doubles as a LoD manager and as a way to block the game's bank window from showing up
	self:RawHook("BankFrame_OnEvent", function(...)
	 	if not self.bankLoaded then
			LoadAddOn("OneBank3")
			self.bankLoaded = true
		end
		
        local module = self:GetModule("OneBank3", true)
		if not module or not module:IsEnabled() then
			self.hooks.BankFrame_OnEvent(...)
		end
	end, true)
end


function OneCore3:BuildFrame(basename, moneyType)
	local frame = self:BuildBaseFrame(basename)
	
	frame.title = self:BuildFontString(frame)
	frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -14)
	
	frame.info = self:BuildFontString(frame, {r=1, g=1, b=0}, 11)
	frame.info:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 8)
	
	frame.moneyframe = self:BuildSmallMoneyFrame("MoneyFrame", frame, moneyType)
	frame.moneyframe:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 5, 7)
	
	-- Default Behaviors
	tinsert(UISpecialFrames, frame:GetName())
	frame:SetScript("OnDragStart", function(self)
		if not self.handler.db.profile.behavior.locked then
            frame:StartMoving()
            frame.isMoving = true
            
            for _, slot in pairs(frame.slots) do
				slot:EnableMouse(false)
			end
        end
	end)
	
	frame:SetScript("OnDragStop", function()
		frame:StopMovingOrSizing(self)
        if frame.isMoving then
            frame.handler.db.profile.position = frame:GetPosition()
            for _, slot in pairs(frame.slots) do
				slot:EnableMouse(true)
			end
        end
        self.isMoving = false
	end)
	
	local sidebarButton = CreateFrame('CheckButton', nil, frame)
	sidebarButton:SetHeight(30)
	sidebarButton:SetWidth(32)
	
	sidebarButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, -7)
	sidebarButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
	sidebarButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
	sidebarButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	
	sidebarButton:SetScript("OnClick", function()
		if sidebarButton:GetChecked() then
			sidebarButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
			frame.sidebar:Show()
		else
			sidebarButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
			frame.sidebar:Hide()
		end
	end)
	
	frame.sidebarButton = sidebarButton
	
	local name = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	name:SetJustifyH("LEFT")
	name:SetPoint("LEFT", sidebarButton, "RIGHT", 5, 1)
	frame.name = name
	
	local closeButton = CreateFrame('Button', nil, frame, "UIPanelCloseButton")
	closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
	frame.closeButton = closeButton
	
	local configButton = CreateFrame('Button', nil, frame, "UIPanelButtonTemplate")
	configButton:SetHeight(20)
	configButton:SetWidth(65)
	
	configButton:SetText("Config")
	configButton:SetPoint("RIGHT", closeButton, "LEFT", 0, 0)
	
	configButton:SetScript("OnClick", function()
		frame.handler:OpenConfig()
	end)
	
	return frame
end

function OneCore3:BuildSideBar(basename, frame)
	local sidebar = self:BuildBaseFrame(basename)
	
	sidebar:SetSize(60, 223)
	sidebar:SetPosition({top=0, left=0, parent=frame:GetName(), attachAt="TOPRIGHT", attachTo="TOPLEFT"})
	
	return sidebar
end

function OneCore3:BuildBaseFrame(basename)
	
	local frame = CreateFrame('Frame', basename, UIParent)
	
	for k, v in pairs(FrameMetatable) do
		frame[k] = v
	end
	
	frame:SetToplevel(true)
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	
	frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
        insets = {left = 5, right = 5, top = 5, bottom = 5},
    })
		
	return frame
end

function OneCore3:BuildFontString(frame, color, size)
	local c = color or {r=1, g=1, b=1}
	local fontstring = frame:CreateFontString(nil, "OVERLAY")
    
    fontstring:SetWidth(365)
    fontstring:SetHeight(15)

    fontstring:SetShadowOffset(.8, -.8)
    fontstring:SetShadowColor(0, 0, 0, .5)
    fontstring:SetTextColor(c.r, c.g, c.b)

    fontstring:SetJustifyH("LEFT")
    fontstring:SetFont("Fonts\\FRIZQT__.TTF", size or 13)
    
    return fontstring
end

function OneCore3:BuildSmallMoneyFrame(name, parent, type)
	local moneyframe = CreateFrame("Frame", parent:GetName()..name, parent, "SmallMoneyFrameTemplate")

	SmallMoneyFrame_OnLoad(moneyframe, type)
		
	return moneyframe
end

function OneCore3:BuildEditBox(name, parent)
	editbox = CreateFrame("EditBox", name, parent)
	editbox:SetFontObject(ChatFontNormal)
	editbox:SetTextInsets(5,5,3,3)
	editbox:SetMaxLetters(256)
	editbox:SetHeight(26)
	editbox:SetWidth(150)
	editbox:SetAutoFocus(false)
	
	editbox:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 3, right = 3, top = 3, bottom = 3 }
	})
	editbox:SetBackdropColor(0, 0, 0, .55)
	editbox:SetBackdropBorderColor(0.4, 0.4, 0.4)
	
	editbox:SetScript("OnEscapePressed", function() 
		editbox:ClearFocus() 
		if editbox.OnEscape then
			editbox:OnEscape()
		end
	end)
	
	return editbox
end

-- Plugin Harness
local PluginMetatable = { 
	displayName = 'Unknown',
	description = 'This plugin may be able to do all sorts of impossible things! ... Or Not!',
}

function PluginMetatable:GetDBNamespace(db, namespace, defaults)
	if db.children and db.children[namespace] then
		return db.children[namespace]
	end
	
	return db:RegisterNamespace('SimpleSortDB', defaults)
end

local lastUsedPluginKey = 0x0000
function OneCore3:NewPluginType(typeName, defaultPlugin, optionsHeading)
	if not self.plugins then
		self.plugins = {}
		self.defaultPlugins = {}
		self.pluginTypeNames = {}	
		self.pluginOptionsGroups = {}
	end
	
	local pluginTypeKey = lastUsedPluginKey + 0x0100
	lastUsedPluginKey = pluginTypeKey
	
	if not self.plugins[pluginTypeKey] then
		self.plugins[pluginTypeKey] = {}
	end
	
	self.defaultPlugins[pluginTypeKey] = defaultPlugin
	self.pluginTypeNames[pluginTypeKey] = typeName
	self.pluginOptionsGroups[pluginTypeKey] = optionsHeading
	self[typeName] = pluginTypeKey
		
	ModulePrototype['Get'..typeName] = function(self, name) 
		return self:GetPlugin(pluginTypeKey, name) 
	end

end

local tostringPattern = "%s: %s"
local function plugintostring( self ) 
	return tostringPattern:format(self.pluginTypeNames[pluginType], self.name)
end 
OneCore3:NewPluginType('SortPlugin', 'simple', 'Sorting')

-- Styled after NewModule/NewAddon from AceAddon.
function OneCore3:NewPlugin(pluginType, name, displayName, ...)
	if not self.plugins[pluginType] then
		error("Usage: NewPlugin(pluginType, name, displayName, [lib, lib, lib, ...]): 'pluginType' - Invalid value.", 2)
	end
	
	if type(name) ~= "string" then 
		error(("Usage: NewPlugin(pluginType, name, displayName, [lib, lib, lib, ...]): 'name' - string expected got '%s'."):format(type(name)), 2) 
	end

	if type(displayName) ~= "string" then 
		error(("Usage: NewPlugin(pluginType, name, displayName, [lib, lib, lib, ...]): 'displayName' - string expected got '%s'."):format(type(displayName)), 2) 
	end

	if self.plugins[pluginType][name] then
		error(("Usage: NewPlugin(pluginType, name, displayName, [lib, lib, lib, ...]): 'name' - Plugin '%s' already exists."):format(name), 2)
	end
	
	local plugin = {}
	plugin.name = name
	plugin.type = pluginType
	plugin.displayName = displayName
	
	local pluginmeta = {}
	pluginmeta.__tostring = plugintostring
	pluginmeta.__index = PluginMetatable
	setmetatable(plugin, pluginmeta)

	AceAddon:EmbedLibraries(plugin, ...)
	
	self.plugins[pluginType][name] = plugin
	return plugin
end

function ModulePrototype:GetPlugin(pluginType, name)
	if not self.core.plugins[pluginType] then
		error("Usage: GetPlugin(pluginType, [name]): 'pluginType' - valid pluginType constant expected.", 2)
	end
	
	name = name or self.db.profile.plugins[pluginType]

	local plugin = self.core.plugins[pluginType][name]
	if not plugin then
		name = self.core.defaultPlugins[pluginType]
		plugin = self.core.plugins[pluginType][name]
		
		if not plugin then
			error(("Usage: GetPlugin(pluginType, [name]): the default plugin for type %s does not exist."):format(self.core.pluginTypeNames[pluginType]), 2)
		end
		
		self.db.profile.plugins[pluginType] = name
	end
	
	return plugin
end

function ModulePrototype:EnablePlugin(pluginType, pluginName, defaultPluginName)
	if not self.activePlugins then
		self.activePlugins = {}
	end
	
	local oldPlugin = self.activePlugins[pluginType]
	if oldPlugin and oldPluginName == (pluginName or defaultPluginName) then
		return
	end
	
	if oldPlugin then
		if oldPlugin.UnloadCustomConfig then
			oldPlugin:UnloadCustomConfig(self.configs.base)
		end
		
		if oldPlugin.OnDestruction then
			oldPlugin:OnDestruction()
		end
	end
	
	local newPlugin = self:GetPlugin(pluginType, pluginName or defaultPluginName)	
	
	-- this is a hack to give each addon it's own copy of the plugin.
	local plugin = setmetatable({}, {__index = newPlugin})
	
	if plugin.OnInitialize then 
		plugin:OnInitialize(self)
	end
	
	if plugin.LoadCustomConfig then
		plugin:LoadCustomConfig(self.configs.base)
	end
	
	self.activePlugins[pluginType] = plugin
end

function ModulePrototype:EnablePlugins()
	for pluginType, defaultPluginName in pairs(self.core.defaultPlugins) do
		self:EnablePlugin(pluginType, self.db.profile.plugins[pluginType], defaultPluginName)
	end
end
