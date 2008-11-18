
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog   = LibStub("AceConfigDialog-3.0")

local OneCore3 = LibStub('AceAddon-3.0'):GetAddon('OneCore3')
local ModulePrototype = OneCore3.defaultModulePrototype

local L = LibStub("AceLocale-3.0"):GetLocale("OneCore3")

function ModulePrototype:InitializeConfiguration()
	self.configs = {}
	
	function GetBaseConfig()
		return {
			type = "group",
			name = self.displayName,
			args = {
				general = {
					type = "group",
					name = self.displayName,
					args = {
						desc1 = {
							type = "description",
							name = L["Overview Description"]:format(self.displayName),
							order = 1,
						},
						heading = {
							type = "group",
							order = 2,
							name = L["Core Options"],
							inline = true,
							args = {
								desc1 = {
									type = "description",
									name = L["Description of Cols"],
									order = 1
								},
								cols = {
									order = 5, 
									type = "range",
									name = L["Number of Columns"],
									desc = "Sets the maximum number of columns to use",
									min = 1, max = 30, step = 1,
									get = function(info)
										return self.db.profile.appearance.cols
									end,
									set = function(info, cols)
										self.db.profile.appearance.cols = cols
										self:OrganizeFrame(true)
									end	
								},
								desc2 = {
									type = "description",
									name = L["Description of Scale and Alpha"],
									order = 10
								},
								scale = {
									order = 15,
									type = "range",
									name = "UI Scale",
									min = 0.5,
									max = 3,
									step = 0.05,
									get = function(info)
										return self.db.profile.appearance.scale
									end,
									set = function(info, scale)
										self.db.profile.appearance.scale = scale
										self.frame:CustomizeFrame(self.db.profile)
									end,
								},
								alpha = {
									order = 20,
									type = "range",
									name = "Frame Alpha",
									min = 0,
									max = 1,
									step = 0.05,
									get = function(info)
										return self.db.profile.appearance.alpha
									end,
									set = function(info, alpha)
										self.db.profile.appearance.alpha = alpha
										self.frame:CustomizeFrame(self.db.profile)
									end,
								},
								desc3 = {
									order = 25,
									type = "description",
									name = L["Description of Colors"],
								},
								background = { 
					                order = 30, 
					                type = "color", 
					                name = "Background",
					 				desc = "Sets the background color of your bag.",
									get = function(info) 
										local color = self.db.profile.colors.background
										return color.r, color.g, color.b, color.a
									end,
									set = function(info, r, g, b, a)
										self.db.profile.colors.background = {r = r, g = g, b = b, a = a}
										self.frame:CustomizeFrame(self.db.profile)
									end,
									hasAlpha = true,
					            },
								mouseover = { 
					                order = 35, 
					                type = "color", 
					                name = "Mouseover",
					 				desc = "Sets the border color of highlighted slots when you mouse over a bag.",
									get = function(info) 
										local color = self.db.profile.colors.mouseover
										return color.r, color.g, color.b, color.a
									end,
									set = function(info, r, g, b, a)
										self.db.profile.colors.mouseover = {r = r, g = g, b = b, a = a}
									end
					            },
							}
						},
						desc2 = {
							type = "description",
							name = L["Overview Closing"]:format(self.displayName),
							order = 10,
						},
					}
				}
			}
		}
	end
	
	baseconfig = GetBaseConfig()
	
	AceConfig:RegisterOptionsTable(self.displayName, baseconfig)
	self.configs.main = AceConfigDialog:AddToBlizOptions(self.displayName, nil, nil, 'general')
end

function ModulePrototype:OpenConfig()
	InterfaceOptionsFrame_OpenToCategory(self.configs.main)
end