ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Initialize()
end

function ENT:Setup(Min, Max, Function, bRemoveOnTouch)

	self.Entity:SetMoveType(MOVETYPE_NONE)
	
	self.Entity:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self.Entity:SetColor(255, 255, 255, 0)
	self.Entity:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.Entity:DrawShadow(false)
	self.Entity:SetNotSolid(true)
	self.Entity:SetNoDraw(true)

	local bbox = (Max - Min) / 2 -- determine actual boundaries from world vectors
	self.Entity:SetPos(Min + bbox) -- set pos to midpoint of bbox
	
	self.Entity:PhysicsInitBox(-bbox, bbox)
	self.Entity:SetCollisionBounds(-bbox, bbox)
	
	self.Entity:SetTrigger(true)
	
	self.Phys = self.Entity:GetPhysicsObject()
	if IsValid(self.Phys) then
		self.Phys:Sleep()
		self.Phys:EnableCollisions(false)
	end

	self.bRemoveOnTouch = bRemoveOnTouch
	self.OnTouch = Function

end

function ENT:StartTouch(ent)

	if IsValid(ent) and self.OnTouch then

		local bSuccess, err = pcall(self.OnTouch, ent)

		if !bSuccess then
			ErrorNoHalt("TRIGGER ERROR: "..tostring(err).."\n")
		end

		if self.bRemoveOnTouch then
			self:Remove()
		end

	end

end
