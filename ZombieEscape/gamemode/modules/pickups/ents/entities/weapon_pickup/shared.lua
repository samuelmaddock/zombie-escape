if SERVER then
	AddCSLuaFile()
end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.WorldModel = Model("models/weapons/w_knife_t.mdl")
ENT.ViewModel = Model("models/weapons/v_knife_t.mdl")
-- ENT.Model = Model("models/dav0r/hoverball.mdl")
ENT.Material = Material("models/props_combine/portalball001_sheet.vmt")

function ENT:Initialize()
	
	self:SetModel( self.WorldModel )
	
	if SERVER then

		self:SetMaterial( self.Material )

		self:SetCustomCollisionCheck(true)

		-- self:PhysicsInit(SOLID_BBOX)
		self:PhysicsInitBox( Vector(-16,-16,-16), Vector(16,16,16) )
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetMoveType(MOVETYPE_VPHYSICS)

		self:SetTrigger(true)
		self:DrawShadow(false)
		self:SetNotSolid(false)
		self:SetNoDraw(false)

		self:SetGravity(1.0)
		
		self.Phys = self:GetPhysicsObject()
		/*if IsValid(self.Phys) then
			self.Phys:EnableGravity( false )
			self.Phys:Sleep()
		end*/

	end
	
end

if SERVER then

	function ENT:KeyValue( key, value )
		self:StoreOutput( key, value )
	end

	function ENT:Think()

		local ply = self:GetOwner()

		if IsValid(ply) then

			-- Drop if player is dead or teams have changed
			if !ply:Alive() or ply:Team() != self.TeamOnPickup then
				ply:DropPickupEntity()
			end

		else

			if IsValid(self:GetParent()) then
				self:SetParent(NULL)
			end

		end

	end

	function ENT:Use(ent)
		if !IsValid(self:GetOwner()) or ent != self:GetOwner() then return false end
		return true
	end

	function ENT:StartTouch( ent )

		-- Check pickup delay
		if self.NextPickup and self.NextPickup > CurTime() then return end

		-- Make sure we don't already have an owner and that the entity is a player
		if IsValid(self:GetOwner()) or !IsValid(ent) or !ent:IsPlayer() then return end

		-- Check if the player can pickup an entity
		if !ent:CanPickupEntity() then return end
		
		-- Reset properties
		-- self:SetNoDraw(true)

		-- Disable gravity and collisions
		if IsValid(self.Phys) then
			self.Phys:EnableCollisions( false )
			self.Phys:EnableGravity( false )
		end

		self:TriggerOutput( "OnPlayerPickup", ent )
		
		/*-- Set offset
		local boneId = ent:LookupBone("ValveBiped.Bip01_Pelvis")
		local bonePos, boneAng = ent:GetBonePosition(boneId)
		
		self:SetPos( ent:GetPos() + Vector(0,0,32) )
		self:SetAngles( ent:GetAngles() )

		self:FollowBone( ent, boneId )
		self:SetLocalPos( Vector( 0, 0, 0 ) )
		self:SetLocalAngles( Angle( 0, 0, 0 ) )*/

		/*self:SetPos( ent:GetPos() + Vector( 0, 0, 36 ) ) -- half of player hull height
		self:SetAngles( ent:GetAngles() )

		self:FollowBone( ent, 0 )*/

		-- self:FollowEntity( ent, true )
		self:Equip( ent )

		ent:SetPickupEntity(self)

	end 

	function ENT:Equip( ply )

		self:SetAbsVelocity( vector_origin )
		-- self:SetTrigger( false )
		self:FollowEntity( ply )
		self:SetOwner( ply )

		self:RemoveEffects( EF_ITEM_BLINK )

		local boneId = ply:LookupBone("ValveBiped.Bip01_Pelvis")
		local bonePos, boneAng = ply:GetBonePosition(boneId)
		
		local offset = boneAng:Right():GetNormal() * 32

		self:SetPos( bonePos - offset )
		self:SetAngles( boneAng )

		self:FollowBone( ply, 1 )

	end

	function ENT:OnDrop()

		self.LastOwner = self:GetOwner()
		self.NextPickup = CurTime() + 0.8

		-- Reset properties
		self:StopFollowingEntity()
		self:SetMoveType( MOVETYPE_VPHYSICS )
		-- self:SetNoDraw( false )

		-- Set position
		local vThrowPos = self.LastOwner:GetShootPos() - Vector(0,0,12)
		self:SetPos( vThrowPos )
		self:SetAngles( self.LastOwner:GetAngles() )

		-- Wake physics
		/*if IsValid(self.Phys) then
			self.Phys:EnableCollisions( true )
			self.Phys:EnableGravity( true )
			self.Phys:Wake()

			-- Apply Velocity
			local EyeAng = self.LastOwner:EyeAngles()
			EyeAng = Angle( EyeAng.p, EyeAng.y, 0 )
			self.Phys:SetVelocity( EyeAng:Forward() * 400 )
		end*/

	end

	function ENT:OnRemove()

		if IsValid(self:GetOwner()) then
			self:GetOwner():DropPickupEntity()
		end

	end

end