-- TTT Ammo override base

if SERVER then
	AddCSLuaFile()
end

ENT.Type = "anim"

-- Override these values
ENT.AmmoType = "Pistol"
ENT.AmmoAmount = 1
ENT.Model = Model( "models/items/boxsrounds.mdl" )

function ENT:Initialize()

	self:SetModel( self.Model )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_BBOX )

	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	local b = 26
	self:SetCollisionBounds(Vector(-b, -b, -b), Vector(b,b,b))

	if SERVER then
		self:SetTrigger(true)
	end

	self.taken = false

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

end

-- Pseudo-clone of SDK's UTIL_ItemCanBeTouchedByPlayer
-- aims to prevent picking stuff up through fences and stuff
function ENT:PlayerCanPickup(ply)

	if ply == self:GetOwner() then return false end

	local ent = self.Entity
	local phys = ent:GetPhysicsObject()
	local spos = phys:IsValid() and phys:GetPos() or ent:OBBCenter()
	local epos = ply:GetShootPos() -- equiv to EyePos in SDK

	local tr = util.TraceLine({start=spos, endpos=epos, filter={ply, ent}, mask=MASK_SOLID})

	-- can pickup if trace was not stopped
	return tr.Fraction == 1.0

end

function ENT:Touch(ent)

	if SERVER and self.taken != true then

		if IsValid(self) and ent:IsPlayer() and self:PlayerCanPickup(ent) then

			ent:GiveAmmo( self.AmmoAmount, self.AmmoType )

			self:Remove()

			-- just in case remove does not happen soon enough
			self.taken = true

		end

	end

end