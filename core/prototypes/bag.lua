local OneCore3 = LibStub('AceAddon-3.0'):GetAddon('OneCore3')   

-- BAGTYPE_QUIVER = Quiver + Ammo
local BAGTYPE_QUIVER = 0x0001 + 0x0002 
-- BAGTYPE_SOUL = Soul Bags
local BAGTYPE_SOUL = 0x004
-- BAGTYPE_PROFESSION = Leather + Inscription + Herb + Enchanting + Engineering + Gem + Mining
local BAGTYPE_PROFESSION = 0x0008 + 0x0010 + 0x0020 + 0x0040 + 0x0080 + 0x0200 + 0x0400 

local BagMetatable = {}

function BagMetatable:IsAmmoBag()
	if not self.type or self.type == 0 then return false end
	return bit.band(self.type, BAGTYPE_QUIVER) > 0
end

function BagMetatable:IsSoulBag()
	if not self.type or self.type == 0 then return false end
	return bit.band(self.type, BAGTYPE_SOUL) > 0
end

function BagMetatable:IsProfessionBag()
	if not self.type or self.type == 0 then return false end
	return bit.band(self.type, BAGTYPE_PROFESSION) > 0
end

OneCore3.BagMetatable = BagMetatable
