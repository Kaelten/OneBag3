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
	for pluginType, defaultPluginName in pairs(self.defaultPlugins) do
		self:EnablePlugin(pluginType, self.db.profile.plugins[pluginType], defaultPluginName)
	end
end
