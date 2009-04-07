local OneCore3 = LibStub('AceAddon-3.0'):GetAddon('OneCore3')            

local PluginPrototype = {}
OneCore3:SetBasePluginPrototype(PluginPrototype)                                                   
                                            
function PluginPrototype:SetupDB(moduleName)
    -- This results in a self.db being an AceDB object keyed on plugin-type name and then on which module it's for currently.
    -- Can be called as many times as wished as it's idempotent.
    local pluginsDB = OneCore3.db:RegisterNamespace('plugins', nil, true)
    local pluginDB = pluginsDB:RegisterNamespace(format('%s-%s', self.pluginType, self.pluginName), nil, true)
    self.db = pluginDB:RegisterNamespace(moduleName, self:GetDatabaseDefaults(), true)
end

function PluginPrototype:GetDatabaseDefaults()
    return nil
end  


-- Defining these methods here since they are definately more related to plugins.
local ModulePrototype = OneCore3.defaultModulePrototype

function ModulePrototype:_prepPlugins(type)
    for pluginName, plugin in OneCore3:IteratePluginsByType(type) do
        plugin:SetupDB(self.moduleName)
    end
end
                                                                                 
function ModulePrototype:IterateActivePluginsByType(type)            
    self:_prepPlugins(type)
    return OneCore3:IterateActivePluginsByType(type)
end
