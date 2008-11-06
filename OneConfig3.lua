
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
						desc = {
							type = "description",
							name = L["Description"]:format(self.displayName),
							order = 1,
						},
						cols = {
							order = 20, 
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