
local SimpleSort = OneCore3:NewPlugin(OneCore3.SortPlugin, 'simple')

function SimpleSort:GetButtonOrder()
	slots = {}
	
	if self.db.profile.behavior.bagorder == 2 then
		start, stop, step = #self.bagIndexes, 1, -1
	else
		start, stop, step = 1, #self.bagIndexes, 1
	end

	for i=start, stop, step do
		bagid = self.bagIndexes[i]

		for slotid = 1, self.frame.bags[bagid].size do
			table.insert(slots,  self.frame.slots[('%s:%s'):format(bagid, slotid)])
		end	
		
		if self.db.profile.behavior.bagbreak then
			table.insert(slots, "NEWLINE")
		end
	end
	
	if self.db.profile.behavior.valign == 2 and not self.db.profile.behavior.bagbreak then
		local totalSlots, cols = #slots, self.db.profile.appearance.cols
		local leftover = math.fmod(totalSlots, cols)
		local spaces = leftover > 0 and cols - leftover or 0
		for i=1, spaces do
			table.insert(slots, 1, "BLANK")
		end
	end
	
	return slots
end
