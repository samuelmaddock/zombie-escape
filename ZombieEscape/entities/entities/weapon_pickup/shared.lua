if SERVER then
	AddCSLuaFile('shared.lua')
end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = Model("models/weapons/w_pist_elite.mdl")

function ENT:Initialize()
	
	self:SetModel(self.Model)
	
	if SERVER then

		self:SetMoveType(MOVETYPE_NONE)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		
		self:SetTrigger(true)
		self:DrawShadow(false)
		self:SetNotSolid(false)
		self:SetNoDraw(false)
		
		self.Phys = self:GetPhysicsObject()
		if IsValid(self.Phys) then
			self.Phys:Sleep()
		end

	end
	
end

if !SERVER then return end

function ENT:KeyValue( key, value )
	self:StoreOutput( key, value )
end

function ENT:Think()

	local ply = self:GetOwner()

	if !IsValid(ply) then
		if IsValid(self:GetParent()) then
			self:SetParent(NULL)
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

	if self.NextPickup and self.NextPickup > CurTime() then return end
	if IsValid(self:GetOwner()) or !IsValid(ent) or !ent:IsPlayer() then return end
	if !ent:CanPickupEntity() then return end
	
	if IsValid(self.Phys) then
		self.Phys:EnableCollisions(false)
		self.Phys:Sleep()
	end

	self:TriggerOutput( "OnPlayerPickup", ent )
	
	-- Set offset
	local boneId = ent:LookupBone("ValveBiped.Bip01_Pelvis")
	local bonePos, boneAng = ent:GetBonePosition(boneId)
	
	self:SetPos(bonePos)
	self:SetAngles(ent:GetAngles())
	
	self:Fire("setparentattachmentmaintainoffset", "forward", 0)
	self:SetParent(ent)

	ent:SetPickupEntity(self)

end

function ENT:OnDrop()

	self.LastOwner = self:GetOwner()
	self.NextPickup = CurTime() + 0.8

	self:SetOwner()
	self:SetParent()

	self:SetMoveType(MOVETYPE_FLYGRAVITY)
	self:SetGravity(1.0)
	self:SetMoveCollide(MOVECOLLIDE_FLY_BOUNCE)
	self:SetGroundEntity()

	local vThrowPos = self.LastOwner:GetShootPos() - Vector(0,0,12)
	self:SetPos(vThrowPos)

	if IsValid(self.Phys) then
		-- self.Phys:SetVelocity(self.LastOwner:GetForward() * 128)
		self.Phys:ApplyForceCenter(self.LastOwner:GetForward() * 128)
	end

end

function ENT:OnRemove()
	if IsValid(self:GetOwner()) then
		self:GetOwner():DropPickupEntity()
	end
end