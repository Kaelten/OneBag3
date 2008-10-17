
local MODNAME           = "OneBag3" 

local addon             = OneBag3
 
--local L                 = LibStub("AceLocale-3.0"):GetLocale(MODNAME) 

local AceGUI 			= LibStub("AceGUI-3.0") 
local AceConfig         = LibStub("AceConfig-3.0") 
local AceConfigDialog   = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0") 

local frame, select
local status = {}
local configs = {}

local function frameOnClose()
	AceGUI:Release(frame)
	frame = nil
end

local function OnClick(widget, event, value)
	AceConfigDialog:Open(value, widget)
end

--[[colors = {
	mouseover = {r = 0, g = .7, b = 1},
	ammo = {r = 1, g = 1, b = 0},
	soul = {r = .5, g = .5, b = 1}, 
	profession = {r = 1, g = 0, b = 1},
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
},]]

local function GetColorOptions(addon)
	return {
		type = "group",
		args = {
			heading1 = {
				order = 1,
				type = "header",
				name = "Slot Border Colors"
			},
			mouseover = { 
                order = 2, 
                type = "color", 
                name = "Mouseover",
 				desc = "Sets the border color of highlighted slots when you mouse over a bag.",
				get = function(info) 
					local color = addon.db.profile.colors.mouseover
					return color.r, color.g, color.b, color.a
				end,
				set = function(info, r, g, b, a)
					addon.db.profile.colors.mouseover = {r = r, g = g, b = b, a = a}
				end
            },
	  	}
	}
end

tables = GetColorOptions(addon)
AceConfig:RegisterOptionsTable(MODNAME, tables)

configs = {
	{
		value = MODNAME,
		text = "Color Options",
	}

}

local function Open()
	if not frame then
		frame = AceGUI:Create("Frame")
		frame:ReleaseChildren()
		frame:SetTitle("OneBag3")
		frame:SetLayout("FILL")
		frame:SetCallback("OnClose", frameOnClose)

		select = AceGUI:Create("TreeGroup")
		select:SetTree(configs)
		select:SetCallback("OnClick", OnClick)
		frame:AddChild(select)
	end
	frame:Show()
end

Open()