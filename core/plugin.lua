local ModulePrototype = OneCore3.defaultModulePrototype
local AceAddon = LibStub("AceAddon-3.0")

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

local lastUsedPluginKey = 0x0000
function OneCore3:NewPluginType(typeName, defaultPlugin, optionsHeading)
	if not self.plugins then
		self.plugins = {}
		self.defaultPlugins = {}
		self.pluginTypeNames = {}	
		self.pluginOptionsGroups = {}
	end
	
	local pluginTypeKey = lastUsedPluginKey + 0x0100
	lastUsedPluginKey = pluginTypeKey
	
	if not self.plugins[pluginTypeKey] then
		self.plugins[pluginTypeKey] = {}
	end
	
	self.defaultPlugins[pluginTypeKey] = defaultPlugin
	self.pluginTypeNames[pluginTypeKey] = typeName
	self.pluginOptionsGroups[pluginTypeKey] = optionsHeading
	self[typeName] = pluginTypeKey
		
	ModulePrototype['Get'..typeName] = function(self, name) 
		return self:GetPlugin(pluginTypeKey, name) 
	end

end

local tostringPattern = "%s: %s"
local function plugintostring( self ) 
	return tostringPattern:format(self.pluginTypeNames[pluginType], self.name)
end 
OneCore3:NewPluginType('SortPlugin', 'simple', 'Sorting')

-- Styled after NewModule/NewAddon from AceAddon.
function OneCore3:NewPlugin(pluginType, name, displayName, ...)
	if not self.plugins[pluginType] then
		error("Usage: NewPlugin(pluginType, name, displayName, [lib, lib, lib, ...]): 'pluginType' - Invalid value.", 2)
	end
	
	if type(name) ~= "string" then 
		error(("Usage: NewPlugin(pluginType, name, displayName, [lib, lib, lib, ...]): 'name' - string expected got '%s'."):format(type(name)), 2) 
	end

	if type(displayName) ~= "string" then 
		error(("Usage: NewPlugin(pluginType, name, displayName, [lib, lib, lib, ...]): 'displayName' - string expected got '%s'."):format(type(displayName)), 2) 
	end

	if self.plugins[pluginType][name] then
		error(("Usage: NewPlugin(pluginType, name, displayName, [lib, lib, lib, ...]): 'name' - Plugin '%s' already exists."):format(name), 2)
	end
	
	local plugin = {}
	plugin.name = name
	plugin.type = pluginType
	plugin.displayName = displayName
	
	local pluginmeta = {}
	pluginmeta.__tostring = plugintostring
	pluginmeta.__index = PluginMetatable
	setmetatable(plugin, pluginmeta)

	AceAddon:EmbedLibraries(plugin, ...)
	
	self.plugins[pluginType][name] = plugin
	return plugin
end

function ModulePrototype:GetPlugin(pluginType, name)
	if not self.core.plugins[pluginType] then
		error("Usage: GetPlugin(pluginType, [name]): 'pluginType' - valid pluginType constant expected.", 2)
	end
	
	name = name or self.db.profile.plugins[pluginType]

	local plugin = self.core.plugins[pluginType][name]
	if not plugin then
		name = self.core.defaultPlugins[pluginType]
		plugin = self.core.plugins[pluginType][name]
		
		if not plugin then
			error(("Usage: GetPlugin(pluginType, [name]): the default plugin for type %s does not exist."):format(self.core.pluginTypeNames[pluginType]), 2)
		end
		
		self.db.profile.plugins[pluginType] = name
	end
	
	return plugin
end

function ModulePrototype:EnablePlugin(pluginType, pluginName, defaultPluginName)
	if not self.activePlugins then
		self.activePlugins = {}
	end
	
	local oldPlugin = self.activePlugins[pluginType]
	if oldPlugin and oldPluginName == (pluginName or defaultPluginName) then
		return
	end
	
	if oldPlugin then
		if oldPlugin.UnloadCustomConfig then
			oldPlugin:UnloadCustomConfig(self.configs.base)
		end
		
		if oldPlugin.OnDestruction then
			oldPlugin:OnDestruction()
		end
	end
	
	local newPlugin = self:GetPlugin(pluginType, pluginName or defaultPluginName)	
	
	-- this is a hack to give each addon it's own copy of the plugin.
	local plugin = setmetatable({}, {__index = newPlugin})
	
	if plugin.OnInitialize then 
		plugin:OnInitialize(self)
	end
	
	if plugin.LoadCustomConfig then
		plugin:LoadCustomConfig(self.configs.base)
	end
	
	self.activePlugins[pluginType] = plugin
end

function ModulePrototype:EnablePlugins()
	for pluginType, defaultPluginName in pairs(self.core.defaultPlugins) do
		self:EnablePlugin(pluginType, self.db.profile.plugins[pluginType], defaultPluginName)
	end
end
