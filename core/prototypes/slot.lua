local SlotMetatable = {}

function SlotMetatable:ShouldShow()
	local bag = self:GetParent()
	
	if bag:IsAmmoBag() and not self.handler.db.profile.show.ammo then 
		return false 
	end
	
	if bag:IsSoulBag() and not self.handler.db.profile.show.soul then 
		return false 
	end
	
	if bag:IsProfessionBag() and not self.handler.db.profile.show.profession then 
		return false 
	end
	
	return self.handler.db.profile.show[bag:GetID()]
end

OneCore3.SlotMetatable = SlotMetatable
