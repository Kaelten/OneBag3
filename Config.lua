
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


--[[
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

local function GetAppearanceOptions(addon)
	--[[
	appearance = {
		cols = 10,
		scale = 1,
		alpha = 1,
		glow = false,
		rarity = true,
	},
	]]
	
	
	return {
		type = "group", 
		args = {
			layout = {
				order = 1,
				type = "header",
				name = "Layout Options"
			},
			cols = {
				order = 2, 
				type = "range",
				name = "Number of Columns",
				min = 1,
				max = 30,
				step = 1,
				get = function(info)
					return addon.db.profile.appearance.cols
				end,
				set = function(info, cols)
					addon.db.profile.appearance.cols = cols
					addon:OrganizeFrame(true)
				end	
			},
			appearance = {
				order = 10,
				type = "header",
				name = "Appearance Options"
			},
			scale = {
				order = 11,
				type = "range",
				name = "UI Scale",
				min = 0.5,
				max = 3,
				step = 0.1,
				get = function(info)
					return addon.db.profile.appearance.scale
				end,
				set = function(info, scale)
					addon.db.profile.appearance.scale = scale
					addon.frame:CustomizeFrame(addon.db.profile)
				end,
				
			}
			
		}
	}

end

local function GetColorOptions(addon)
	--[[colors = {
		mouseover = {r = 0, g = .7, b = 1},
		ammo = {r = 1, g = 1, b = 0},
		soul = {r = .5, g = .5, b = 1}, 
		profession = {r = 1, g = 0, b = 1},
		background = {r = 0, g = 0, b = 0, a = .45},
	},]]

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
tables = GetAppearanceOptions(addon)
AceConfig:RegisterOptionsTable(MODNAME .. '2', tables)

configs = {
	--[[{
		value = MODNAME,
		text = "Color Options",
	},]]
	{
		value = MODNAME .. '2',
		text = "Appearance & Layout"
	}

}


local function frameOnClose()
	AceGUI:Release(frame)
	frame = nil
end

local function OnClick(widget, event, value)
	AceConfigDialog:Open(value, widget)
end

function addon:OpenConfig()
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
	AceConfigDialog:Open(MODNAME .. '2', select)
end
