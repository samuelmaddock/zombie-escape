ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Initialize()

	self.Entity:SetMoveType(MOVETYPE_NONE)
	
	self.Entity:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self.Entity:SetColor(255, 255, 255, 0)
	
	local RVec = Vector() * 64
	self.Entity:PhysicsInitBox(-RVec, RVec)
	self.Entity:SetCollisionBounds(-RVec, RVec)
	
	self.Entity:SetTrigger(true)
	self.Entity:DrawShadow(false)
	self.Entity:SetNotSolid(true)
	self.Entity:SetNoDraw(true)
	
	self.Phys = self.Entity:GetPhysicsObject()
	if(self.Phys and self.Phys:IsValid()) then
		self.Phys:Sleep()
		self.Phys:EnableCollisions(false)
	end
	
end

function ENT:KeyValue( key, value )
	self:StoreOutput( key, value )
end

function ENT:Think()

	local ply = self:GetOwner()

	if !IsValid(ply) then
		if IsValid(self:GetParent()) then
			self:SetParent(nil)
		end
		return
	end

	if !ply:Alive() then
		ply:DropPickupEntity()
	end

	-- Drop if teams have changed
	if ply:Team() != self.TeamOnPickup then
		ply:DropPickupEntity()
	end

end

function ENT:Use(ent)
	if !IsValid(self:GetOwner()) or ent != self:GetOwner() then return false end
	return true
end

function ENT:StartTouch( ent )

	if IsValid(self:GetOwner()) or !IsValid(ent) or !ent:IsPlayer() or
		!ent:CanPickupEntity() or (self.LastOwner == ent and self.LastDrop + 3 > CurTime()) then return end
	
	self:TriggerOutput( "OnPlayerPickup", ent )
	
	-- Set offset
	local boneId = ent:LookupBone("ValveBiped.Bip01_Pelvis")
	local bonePos, boneAng = ent:GetBonePosition(boneId)
	
	self.Entity:SetPos(bonePos)
	self.Entity:SetAngles(ent:GetAngles())
	
	self.Entity:Fire("setparentattachmentmaintainoffset", "forward", 0)
	self.Entity:SetParent(ent)
	
	for _, v in pairs(self:GetChildren()) do
		v:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	end

	ent:SetPickupEntity(self)

end

function ENT:OnDrop(ply)

	self.LastOwner = ply
	self.LastDrop = CurTime()

	/*self:SetMoveType(MOVETYPE_VPHYSICS)
	self.Phys:Wake()
	self.Phys:EnableCollisions(true)

	self:SetLocalVelocity(ply:GetVelocity())*/


end

function ENT:OnRemove()
	if IsValid(self:GetOwner()) then
		self:GetOwner():DropPickupEntity()
	end
end