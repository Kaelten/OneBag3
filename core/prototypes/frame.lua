
local FrameMetatable = {}

function FrameMetatable:CustomizeFrame(db)
	self:SetScale(db.appearance.scale)
	self:SetAlpha(db.appearance.alpha)
	
	local c = db.colors.background
	self:SetBackdropColor(c.r, c.g, c.b, c.a)
	
	self:SetFrameStrata(self.handler.stratas[db.behavior.strata])
	self:SetClampedToScreen(db.behavior.clamped)
	
	if self.sidebar then
		self.sidebar:CustomizeFrame(db)
	end
	
	if self.purchase then
		self.purchase:CustomizeFrame(db)
	end
	
	if self.slots then
		for _, slot in pairs(self.slots) do
			slot:SetFrameStrata(self.handler.stratas[db.behavior.strata])
		end
	end
end

function FrameMetatable:SetSize(width, height)
	self:SetWidth(width)
	self:SetHeight(height)
end

function FrameMetatable:SetPosition(position)
	self:ClearAllPoints()
	self:SetPoint(position.attachAt or "TOPLEFT", getglobal(position.parent), position.attachTo or "BOTTOMLEFT", position.left, position.top)
end

function FrameMetatable:GetPosition()
	return {
		top = self:GetTop(),
		left = self:GetLeft(),
		parent = self:GetParent():GetName(),
	}
end

OneCore3.FrameMetatable = FrameMetatable