
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
									step = 0.01,
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
									step = 0.01,
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
				},
				frame = {
					type = "group",
					name = L["Frame Options"],
					args = {
						frame = {
							type = "group",
							name = L["Frame Behavior"],
							inline = true,
							order = 1,
							args = {
								description = {
									order = 1,
									type = "description",
									name = L["Frame Behavior Description"],
								},
								locked = {
									order = 5,
									type = "toggle",
									name = "Lock Frame",
									desc = "Toggles if the frame is movable or not",
									get = function(info)
										return self.db.profile.behavior.locked
									end,
									set = function(info, value)
										self.db.profile.behavior.locked = value
									end
								},
								clamped = {
									order = 10,
									type = "toggle",
									name = "Clamp to Screen",
									desc = "Toggles if you can drag the frame off screen.",
									get = function(info)
										return self.db.profile.behavior.clamped
									end,
									set = function(info, value)
										self.db.profile.behavior.clamped = value
										self.frame:CustomizeFrame(self.db.profile)
									end
								},
								strata = {
									order = 15, 
									type = "range",
									name = "Frame Strata",
									min = 1,
									max = 5,
									step = 1,
									get = function(info)
										return self.db.profile.behavior.strata
									end,
									set = function(info, value)
										self.db.profile.behavior.strata = value
										self.frame:CustomizeFrame(self.db.profile)
									end	
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
								scale = {
									order = 25,
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
								
							},
						},
						bag = {
							type = "group",
							name = L["Bag Behavior"],
							order = 2,
							inline = true,
							args = {
								description = {
									order = 1,
									type = 'description',
									name = L["Bag Behavior Description"]:format(self.displayName),
								},
								bagbreak = {
									order = 20,
									type = "toggle",
									name = "Bag Break",
									desc = "Forces a row break to happen at the end of each bag.",
									get = function(info)
										return self.db.profile.behavior.bagbreak
									end,
									set = function(info, value)
										self.db.profile.behavior.bagbreak = value
										self:OrganizeFrame(true)
									end
								},
								cols = {
									order = 25, 
									type = "range",
									name = "Number of Columns",
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
								valign = {
									order = 30,
									type = 'select',
									name = 'Vertical Alignment',
									values = {'Top', 'Bottom'},
									style = 'radio',
									get = function(info)
										return self.db.profile.behavior.valign
									end,
									set = function(info, value)
										self.db.profile.behavior.valign = value
										self:OrganizeFrame(true)
									end
								},
								bagorder = {
									order = 35,
									type = 'select',
									name = "Bag Order",
									desc = "Controls the order which the bags are shown.",
									values = {'Normal', 'Backwards'},
									style = 'radio',
									get = function(info)
										return self.db.profile.behavior.bagorder
									end,
									set = function(info, value)
										self.db.profile.behavior.bagorder = value
										self:OrganizeFrame(true)
									end
								},
							}
						}
					}
				},
				colors = {
					type = "group",
					name = L["Color Options"],
					args = {
						general = {
							type = "group",
							order = 1, 
							inline = true,
							name = L["General"],
							args = {
								background = { 
					                order = 5, 
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
					                order = 10, 
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
								glow = {
									order = 15,
									type = "toggle",
									name = "Use Glow Borders",
									desc = L["Glow Borders are a little brighter and 'shinier' than the default ones."],
									get = function(info)
										return self.db.profile.appearance.glow
									end,
									set = function(info, value)
										self.db.profile.appearance.glow = value
										self:UpdateFrame()
									end,
								},
							}
						},
						item = {
							type = "group",
							order = 2,
							inline = true,
							name = L["Item Centric"],
							args = {
								rarity = {
									order = 10,
									type = "toggle",
									name = "Use Rarity Borders",
									desc = "Toggles if a slot's border should be highlighted based on an items rarity.",
									get = function(info)
										return self.db.profile.appearance.rarity
									end,
									set = function(info, value)
										self.db.profile.appearance.rarity = value
										self:UpdateFrame()
									end,
								},
								lowlevel = {
									order = 15,
									type = "toggle",
									name = "Color Low Level Items",
									desc = "Toggles if you want to color white and grey item's borders as well.",
									get = function(info)
										return self.db.profile.appearance.lowlevel
									end,
									set = function(info, value)
										self.db.profile.appearance.lowlevel = value
										self:UpdateFrame()
									end,
								},
							}
						},
						bag = {
							type = "group",
							order = 3,
							inline = true,
							name = L["Bag Centric"],
							args = {
								ammo = { 
					                order = 5, 
					                type = "color", 
					                name = "Ammo Bags",
					 				desc = "Sets the border color of ammo bag slots.",
									get = function(info) 
										local color = self.db.profile.colors.ammo
										return color.r, color.g, color.b, color.a
									end,
									set = function(info, r, g, b, a)
										self.db.profile.colors.ammo = {r = r, g = g, b = b, a = a}
										self:UpdateFrame()
									end
					            },
								soul = { 
					                order = 10, 
					                type = "color", 
					                name = "Soul Bags",
					 				desc = "Sets the border color of soul bag slots.",
									get = function(info) 
										local color = self.db.profile.colors.soul
										return color.r, color.g, color.b, color.a
									end,
									set = function(info, r, g, b, a)
										self.db.profile.colors.soul = {r = r, g = g, b = b, a = a}
										self:UpdateFrame()
									end
					            },
								profession = { 
					                order = 15, 
					                type = "color", 
					                name = "Profession Bags",
					 				desc = "Sets the border color of profession bag slots.",
									get = function(info) 
										local color = self.db.profile.colors.profession
										return color.r, color.g, color.b, color.a
									end,
									set = function(info, r, g, b, a)
										self.db.profile.colors.profession = {r = r, g = g, b = b, a = a}
										self:UpdateFrame()
									end
					            },
							}
						},
					}
				},
				showbags = {
					type = "group",
					name = L["Bag Visibility"],
					args = {
						description = {
							type = 'description',
							name = 'These options allow you to stop certain bags from displaying.',
							order = 1
						},
						type = {
							type = "group",
							name = L["Type Based Filters"],
							order = 1,
							inline = true,
							args = {
								ammo = {
									order = 15,
									type = "toggle",
									name = "Ammo Bags & Quivers",
									desc = "Toggles the display of ammo bags and quivers.",
									get = function(info)
										return self.db.profile.show.ammo
									end,
									set = function(info, value)
										self.db.profile.show.ammo = value
										self:OrganizeFrame(true)
									end
								},
								soul = {
									order = 10,
									type = "toggle",
									name = "Soul Bags",
									desc = "Toggles the display of soul bags.",
									get = function(info)
										return self.db.profile.show.soul
									end,
									set = function(info, value)
										self.db.profile.show.soul = value
										self:OrganizeFrame(true)
									end
								},
								profession = {
									order = 5,
									type = "toggle",
									name = "Profession Bags",
									desc = "Toggles the display of profession bags.",
									get = function(info)
										return self.db.profile.show.profession
									end,
									set = function(info, value)
										self.db.profile.show.profession = value
										self:OrganizeFrame(true)
									end
								},
							}
						}
					},
				},
				plugins = {
					type = "group",
					name = "Plugins",
					args = {
					}
				},
			}
		}
	end
	
	baseconfig = GetBaseConfig()
	
	--Setup Plugin Groups
	for pluginType, heading in pairs(self.core.pluginOptionsGroups) do 
		local values = {}
		for pluginName, plugin in pairs(self.core.plugins[pluginType]) do
			values[pluginName] = ("%s: %s"):format(plugin.displayName or plugin.name, plugin.description)
		end
		
		local pluginGroup = {
			type = "multiselect", 
			name = heading,
			values = values,
			order = pluginType / 256 + 1,
			get = function(info, pluginName) 
				return self.db.profile.plugins[pluginType] == pluginName
			end,
			set = function(info, pluginName, state)
				if state then
					self.db.profile.plugins[pluginType] = pluginName
					self:EnablePlugins(pluginType, pluginName)
					self:OrganizeFrame(true)
				end
			end,
		}
		
		baseconfig.args.plugins.args[self.core.pluginTypeNames[pluginType]] = pluginGroup
	end
	
	if self.LoadCustomConfig then
		self:LoadCustomConfig(baseconfig)
	end
	
	AceConfig:RegisterOptionsTable(self.displayName, baseconfig)
	self.configs.main = AceConfigDialog:AddToBlizOptions(self.displayName, nil, nil, 'general')
	self.configs.frame = AceConfigDialog:AddToBlizOptions(self.displayName, "Frame Options", self.displayName, 'frame')
	self.configs.colors = AceConfigDialog:AddToBlizOptions(self.displayName, "Color Options", self.displayName, 'colors')
	self.configs.showbags = AceConfigDialog:AddToBlizOptions(self.displayName, "Bag Visibility", self.displayName, 'showbags')
	self.configs.plugins = AceConfigDialog:AddToBlizOptions(self.displayName, "Plugins", self.displayName, 'plugins')
end

function ModulePrototype:OpenConfig()
	InterfaceOptionsFrame_OpenToCategory(self.configs.showbags)
	InterfaceOptionsFrame_OpenToCategory(self.configs.main)
end