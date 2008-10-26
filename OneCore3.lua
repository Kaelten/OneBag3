local FrameMetatable = {}

function FrameMetatable:CustomizeFrame(db)
	self:SetScale(db.appearance.scale)
	self:SetAlpha(db.appearance.alpha)
	
	local c = db.colors.background
	self:SetBackdropColor(c.r, c.g, c.b, c.a)
	
	self:SetFrameStrata(self.handler.stratas[db.behavior.strata])
	self:SetClampedToScreen(db.behavior.clamped)
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
			},
			position = {
				parent = "UIParent",
				top = 500,
				left = 300
			},
		},
	},   
}

local plain = {r = .05, g = .05, b = .05}
function ModulePrototype:ColorBorder(slot)
	local bag = slot:GetParent()
	local color = plain
	
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
	
	if self.db.profile.appearance.rarity then
		local hex = (GetContainerItemLink(bag:GetID(), slot:GetID()) or ""):match("(|cff%x%x%x%x%x%x)") 
		
		for k, v in ipairs(ITEM_QUALITY_COLORS) do
			if hex == v.hex then
				if k ~= 1 or self.db.profile.appearance.white then
					color = v
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

-- OneCore!
OneCore3 = LibStub("AceAddon-3.0"):NewAddon("OneCore3", "AceEvent-3.0")
OneCore3:SetDefaultModulePrototype(ModulePrototype)
OneCore3:SetDefaultModuleLibraries("AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")

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
	frame:SetScript("OnDragStart", function()
		if not this.handler.db.profile.behavior.locked then
            frame:StartMoving()
            frame.isMoving = true
            
            for _, slot in pairs(frame.slots) do
				slot:EnableMouse(false)
			end
        end
	end)
	
	frame:SetScript("OnDragStop", function()
		frame:StopMovingOrSizing()
        if frame.isMoving then
            frame.handler.db.profile.position = frame:GetPosition()
            for _, slot in pairs(frame.slots) do
				slot:EnableMouse(true)
			end
        end
        this.isMoving = false
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
