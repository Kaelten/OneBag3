
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

]]

local function GetAppearanceOptions(addon)
	return {
		type = "group", 
		args = {
			layout = {
				order = 1,
				type = "header",
				name = "Layout Options"
			},
			locked = {
				order = 2,
				type = "toggle",
				name = "Lock Frame",
				get = function(info)
					return addon.db.profile.behavior.locked
				end,
				set = function(info, value)
					addon.db.profile.behavior.locked = value
				end
			},
			clamped = {
				order = 3,
				type = "toggle",
				name = "Clamp to Screen",
				get = function(info)
					return addon.db.profile.behavior.clamped
				end,
				set = function(info, value)
					addon.db.profile.behavior.clamped = value
					addon.frame:CustomizeFrame(addon.db.profile)
				end
			},
			bagbreak = {
				order = 4,
				type = "toggle",
				name = "Bag Break",
				desc = "Forces a rowbreak to happen at the end of each bag.",
				get = function(info)
					return addon.db.profile.behavior.bagbreak
				end,
				set = function(info, value)
					addon.db.profile.behavior.bagbreak = value
					addon:OrganizeFrame(true)
				end
			},
			cols = {
				order = 5, 
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
			strata = {
				order = 6, 
				type = "range",
				name = "Frame Strata",
				min = 1,
				max = 5,
				step = 1,
				get = function(info)
					return addon.db.profile.behavior.strata
				end,
				set = function(info, value)
					addon.db.profile.behavior.strata = value
					addon.frame:CustomizeFrame(addon.db.profile)
				end	
			},
			
			appearance = {
				order = 10,
				type = "header",
				name = "Appearance Options",
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
			},
			alpha = {
				order = 12,
				type = "range",
				name = "Frame Alpha",
				min = 0,
				max = 1,
				step = 0.05,
				get = function(info)
					return addon.db.profile.appearance.alpha
				end,
				set = function(info, alpha)
					addon.db.profile.appearance.alpha = alpha
					addon.frame:CustomizeFrame(addon.db.profile)
				end,
			},
			border = {
				order = 20,
				type = "header",
				name = "Border Options",
			},
			glow = {
				order = 21,
				type = "toggle",
				name = "Use Glow Borders",
				get = function(info)
					return addon.db.profile.appearance.glow
				end,
				set = function(info, value)
					addon.db.profile.appearance.glow = value
					addon:UpdateFrame()
				end,
			},
			rarity = {
				order = 22,
				type = "toggle",
				name = "Use Rarity Borders",
				get = function(info)
					return addon.db.profile.appearance.rarity
				end,
				set = function(info, value)
					addon.db.profile.appearance.rarity = value
					addon:UpdateFrame()
				end,
			},
			white = {
				order = 23,
				type = "toggle",
				name = "Color White Item",
				get = function(info)
					return addon.db.profile.appearance.white
				end,
				set = function(info, value)
					addon.db.profile.appearance.white = value
					addon:UpdateFrame()
				end,
			},
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
