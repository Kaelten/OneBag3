local OneCore3 = LibStub('AceAddon-3.0'):GetAddon('OneCore3')   

-- Plugin Harness
local PluginMetatable = { 
	displayName = 'Unknown',
	description = 'This plugin may be able to do all sorts of impossible things! ... Or Not!',
}

function PluginMetatable:GetDBNamespace(db, namespace, defaults)
	if db.children and db.children[namespace] then
		return db.children[namespace]
	end
	
	return db:RegisterNamespace(namespace, defaults)
end

OneCore3.PluginMetatable = PluginMetatable