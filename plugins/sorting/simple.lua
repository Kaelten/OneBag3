local SimpleSort = OneCore3:NewPlugin(OneCore3.SortPlugin, 'simple', 'Simple')

SimpleSort.description = 'Very simple sort, just puts the slot in order.  This is the default sort.'

function SimpleSort:OnInitialize(module)
	local defaults = {
		profile = {
			behavior = {
				bagbreak = false,
				valign = 1,
				bagorder = 1,
			},
		},
	}

	self.module = module
	self.db = self:GetDBNamespace(module.db, 'SimpleSortDB', defaults)	
	
	if self.module:IsBagOpen() then
		self.module:UpdateFrame()
	end
end

function SimpleSort:LoadCustomConfig(baseconfig)
	self.baseconfig = baseconfig
	
	baseconfig.args.frame.args.bag.plugins['SimpleSort'] = {
		bagbreak = {
			order = 2,
			type = "toggle",
			name = "Bag Break",
			desc = "Forces a row break to happen at the end of each bag.",
			get = function(info)
				return self.db.profile.behavior.bagbreak
			end,
			set = function(info, value)
				self.db.profile.behavior.bagbreak = value
				self.module:OrganizeFrame(true)
			end
		},
		valign = {
			order = 11,
			type = 'select',
			name = 'Vertical Alignment',
			values = {'Top', 'Bottom'},
			style = 'radio',
			get = function(info)
				return self.db.profile.behavior.valign
			end,
			set = function(info, value)
				self.db.profile.behavior.valign = value
				self.module:OrganizeFrame(true)
			end
		},
		bagorder = {
			order = 12,
			type = 'select',
			name = "Bag Order",
			desc = "Controls the order which the bags are shown.",
			values = {'Normal', 'Backwards'},
			style = 'radio',
			get = function(info)
				return self.db.profile.behavior.bagorder
			end,
			set = function(info, value)
				self.db.profile.behavior.bagorder = value
				self.module:OrganizeFrame(true)
			end
		},
		
	}
end

function SimpleSort:UnloadCustomConfig()
	if self.baseconfig then
		self.baseconfig.args.frame.args.bag.plugins['SimpleSort'] = nil
	end
end

function SimpleSort:GetButtonOrder()
	local slots = {}
	local moudle = self.module
	
	if self.db.profile.behavior.bagorder == 2 then
		start, stop, step = #moudle.bagIndexes, 1, -1
	else
		start, stop, step = 1, #moudle.bagIndexes, 1
	end

	for i=start, stop, step do
		bagid = moudle.bagIndexes[i]

		for slotid = 1, moudle.frame.bags[bagid].size do
			table.insert(slots,  moudle.frame.slots[('%s:%s'):format(bagid, slotid)])
		end	
		
		if self.db.profile.behavior.bagbreak then
			table.insert(slots, "NEWLINE")
		end
	end
	
	if self.db.profile.behavior.valign == 2 and not self.db.profile.behavior.bagbreak then
		local totalSlots, cols = #slots, moudle.db.profile.appearance.cols
		local leftover = math.fmod(totalSlots, cols)
		local spaces = leftover > 0 and cols - leftover or 0
		for i=1, spaces do
			table.insert(slots, 1, "BLANK")
		end
	end
	
	return slots
end
