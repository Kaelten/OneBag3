
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

	self:EnablePlugins()	
	self:InitializeConfiguration()
--	self:OpenConfig()
	
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

-- Custom Configuration
function OneBag3:LoadCustomConfig(baseconfig)
	local bagvisibility = {
		type = "group",
		name = "Specific Bag Filters",
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
	
	for id, text in pairs(names) do
		bagvisibility.args[tostring(id)] = {
			order = 5 * id + 5,
			type = "toggle",
			name = text,
			desc = ("Toggles the display of your %s."):format(text),
			get = function(info)
				return self.db.profile.show[id]
			end,
			set = function(info, value)
				self.db.profile.show[id] = value
				self:OrganizeFrame(true)
			end
		}
	end
	
	baseconfig.args.showbags.args.bag = bagvisibility
end

-- Hooks handlers
function OneBag3:IsBagOpen(bag)
	if type(bag) == "number" and (bag < 0 or bag > 4) then
		return
	end
	
	return self.isOpened and bag or nil
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

--Custom Button Getter
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
