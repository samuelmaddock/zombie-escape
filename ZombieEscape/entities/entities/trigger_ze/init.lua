ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Initialize()

	self.Entity:SetMoveType(MOVETYPE_NONE)
	
	self.Entity:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self.Entity:SetColor(255, 255, 255, 0)
	self.Entity:DrawShadow(false)
	self.Entity:SetNotSolid(true)
	self.Entity:SetNoDraw(true)

end

function ENT:Setup(Min, Max, Function)

	local bbox = (Max - Min) / 2 -- determine actual boundaries from world vectors
	self.Entity:SetPos(self.Entity:GetPos() + bbox) -- set pos to midpoint of bbox
	
	self.Entity:PhysicsInitBox(-bbox, bbox)
	self.Entity:SetCollisionBounds(-bbox, bbox)
	
	self.Entity:SetTrigger(true)
	
	self.Phys = self.Entity:GetPhysicsObject()
	if IsValid(self.Phys) then
		self.Phys:Sleep()
		self.Phys:EnableCollisions(false)
	end
	
	self.OnTouch = Function

end

function ENT:StartTouch(ent)

	if ValidEntity(ent) or !ent:IsPlayer() or !ent:Alive() then return end

	if self.OnTouch then
		self.OnTouch()
	end

end
