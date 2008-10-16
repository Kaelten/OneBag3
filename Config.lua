
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

local function frameOnClose()
	AceGUI:Release(frame)
	frame = nil
end

local function OnClick(widget, event, value)
	AceConfigDialog:Open(value, widget)
end

local function AddColorConfigs(configs)
	return {
		type = "group",
		args = {
			desc = { 
                order = 1, 
                type = "description", 
                name = "hi" .. "\n", 
            },
	  	}
	}
end

tables = AddColorConfigs()
AceConfig:RegisterOptionsTable(MODNAME, tables)

configs = {
	{
		value = MODNAME,
		text = "Color",
	}

}

local function Open()
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
end

--Open()