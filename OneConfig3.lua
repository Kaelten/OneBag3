
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog   = LibStub("AceConfigDialog-3.0")

local OneCore3 = LibStub('AceAddon-3.0'):GetAddon('OneCore3')
local ModulePrototype = OneCore3.defaultModulePrototype


function ModulePrototype:InitializeConfiguration()
	self.configs = {}
	
	function GetBaseConfig()
		return {
			type = "group",
			name = self.displayName,
			args = {}
		}
	end
	
	baseconfig = GetBaseConfig()
	
	AceConfig:RegisterOptionsTable(self.displayName, baseconfig)
	self.configs.main = AceConfigDialog:AddToBlizOptions(self.displayName)
end

function ModulePrototype:OpenConfig()
	InterfaceOptionsFrame_OpenToCategory(self.configs.main)
end