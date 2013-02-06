local WeaponMeta = FindMetaTable('Weapon')

function WeaponMeta:Equip( ply )

	self:SetAbsVelocity( vector_origin )
	self:SetTrigger( false )
	self:FollowEntity( ply )
	self:SetOwner( ply )

	self:RemoveEffects( EF_ITEM_BLINK )

	if !CLIENT and m_pConstraint != NULL then
		-- remove constraints
	end

	self:SetNextPrimaryFire( CurTime() )
	self:SetNextSecondaryFire( CurTime() )

	-- SetTouch, SetThink NULL

	if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
		self:SetModel( self.ViewModel or "models/error.mdl" )
	else
		-- Make the weapon ready as soon as any NPC picks it up.
		self:SetNextPrimaryFire( CurTime() )
		self:SetNextSecondaryFire( CurTime() )
		self:SetModel( self.Model )
	end

end


local EntityMeta = FindMetaTable('Entity')

function EntityMeta:FollowEntity( ent, bBoneMerge )

	if IsValid( ent ) then
		self:SetParent( ent )
		self:SetMoveType( MOVETYPE_NONE )

		if bBoneMerge then
			self:AddEffects( EF_BONEMERGE )
		end

		self:SetSolid( false ) -- AddSolidFlags( FSOLID_NOT_SOLID )
		self:SetLocalPos( vector_origin )
		self:SetLocalAngles( Angle(0,0,0) )
	else
		self:StopFollowingEntity()
	end

end

function EntityMeta:StopFollowingEntity()

	if !self:IsFollowingEntity() then
		return
	end

	self:SetParent( NULL )
	self:RemoveEffects( EF_BONEMERGE )
	self:SetSolid( true ) -- RemoveSolidFlags( FSOLID_NOT_SOLID )
	self:SetMoveType( MOVETYPE_NONE )
	self:CollisionRulesChanged()

end

function EntityMeta:IsFollowingEntity()
	return self:IsEffectActive( EF_BONEMERGE ) and
		self:GetMoveType() == MOVETYPE_NONE and
		self:GetMoveParent()
end

function EntityMeta:GetFollowedEntity()
	if !self:IsFollowingEntity() then
		return
	end
	return self:GetMoveParent()
end

function EntityMeta:CollisionRulesChanged()
	local cg = self:GetCollisionGroup()
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetCollisionGroup(cg) -- HACK
end