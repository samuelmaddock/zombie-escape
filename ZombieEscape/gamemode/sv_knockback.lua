GM.CVars.PropKnockback = CreateConVar( "ze_propForceMultiplier", '2.0', {FCVAR_REPLICATED}, "Force multiplier for props when shot." )

/*---------------------------------------------------------
	Zombie Knockback effects
---------------------------------------------------------*/

/*
	GAMEMODE.Multipliers

	Multipliers affect the amount of force applied to zombies
	upon bullet impact
*/
GM.DmgFilter = bit.bor(DMG_BULLET, DMG_CLUB, DMG_ALWAYSGIB, DMG_BLAST)
GM.Multipliers = {

	Hitgroups = {
		[HITGROUP_GENERIC]		= 1.0,
		[HITGROUP_HEAD]			= 1.2,
		[HITGROUP_CHEST]		= 1.0,
		[HITGROUP_STOMACH]		= 1.0,
		[HITGROUP_LEFTARM]		= 0.9,
		[HITGROUP_RIGHTARM]		= 0.9,
		[HITGROUP_LEFTLEG]		= 0.9,
		[HITGROUP_RIGHTLEG]		= 0.9,
		[HITGROUP_GEAR]			= 1.0,
	},

	-- See sv_weapons.lua
	Weapons = {}

}

/*---------------------------------------------------------
	Zombie Knockback effects
---------------------------------------------------------*/

local FlinchEvent = {
	[HITGROUP_HEAD] = PLAYERANIMEVENT_FLINCH_HEAD,
	[HITGROUP_CHEST] = PLAYERANIMEVENT_FLINCH_CHEST,
	[HITGROUP_LEFTARM] = PLAYERANIMEVENT_FLINCH_LEFTARM,
	[HITGROUP_LEFTLEG] = PLAYERANIMEVENT_FLINCH_LEFTLEG,
	[HITGROUP_RIGHTARM] = PLAYERANIMEVENT_FLINCH_RIGHTARM,
	[HITGROUP_RIGHTLEG] = PLAYERANIMEVENT_FLINCH_RIGHTLEG,
}

/*
	First hook called before taking damage
*/
function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )

	-- More damage if we're shot in the head
	 if hitgroup == HITGROUP_HEAD then
	 
		dmginfo:ScaleDamage( 2 )
	 
	 end
	 
	-- Less damage if we're shot in the arms or legs
	if ( hitgroup == HITGROUP_LEFTARM ||
		 hitgroup == HITGROUP_RIGHTARM || 
		 hitgroup == HITGROUP_LEFTLEG ||
		 hitgroup == HITGROUP_RIGHTLEG ||
		 hitgroup == HITGROUP_GEAR ) then
	 
		dmginfo:ScaleDamage( 0.25 )
	 
	 end

	-- Zombie Knockback implementation
	local bPassesDmgFilter = bit.band(dmginfo:GetDamageType(), self.DmgFilter) != 0
	local inflictor = dmginfo:GetInflictor()

	if IsValid(ply) && ply:IsPlayer() && IsValid(inflictor) && inflictor:IsPlayer() && ply:IsZombie() && bPassesDmgFilter then
	
		-- Store some info for GM.PlayerHurt
		ply.OldVelocity = ply:GetVelocity()
		
		ply.LastDmg = {}
		ply.LastDmg.Hitgroup = hitgroup
		ply.LastDmg.Pos = inflictor:GetPos()

		local weap = inflictor:GetActiveWeapon()
		if IsValid(weap) then
			ply.LastDmg.Weapon = weap:GetClass()
		end
		
		-- Hack to disable default pushback effects
		ply:SetMoveType(MOVETYPE_NONE)

		-- Pushback animations
		self:DoAnimationEvent( ply, FlinchEvent[hitgroup] or PLAYERANIMEVENT_FLINCH_CHEST, 0 )

	else
		ply.LastDmg = nil
	end
	
	return ply, hitgroup, dmginfo
	
end


/*
	Called after damage is taken
*/
function GM:PlayerHurt( ply, attacker, healthleft, healthtaken )

	if IsValid(ply) && ply:IsPlayer() && ply:IsZombie() && ply.LastDmg then
	
		-- Reset movetype
		ply:SetMoveType(MOVETYPE_WALK)

		-- Get multipliers
		local hitgroupMult = self.Multipliers.Hitgroups[ ply.LastDmg.Hitgroup ] or 1.0
		local weapMult = self.Multipliers.Weapons[ ply.LastDmg.Weapon ] or 1.0

		-- Knockback effects = (multiplier * weapon multiplier * hitgroup multiplier) * damage delt
		local knockback = (ply:GetKnockbackMultiplier() * weapMult * hitgroupMult) * healthtaken

		-- Apply force
		local startvec = ply.LastDmg.Pos
		local endvec = ply:GetPos()
		local vec = (endvec - startvec):GetNormal() * knockback
		
		ply:SetLocalVelocity(ply.OldVelocity + vec)
		ply.LastDmg = nil
		
	end
	
	return ply, attacker, healthleft, healthtaken
	
end

/*---------------------------------------------------------
	PropPhysics Knockback effects
---------------------------------------------------------*/

/*
	Apply physics to props when shot
*/
function GM:PropPhysicsKnockback(ent, dmginfo)

	local inflictor = dmginfo:GetInflictor()
	local attacker = dmginfo:GetAttacker()
	local amount = dmginfo:GetDamage()

	if ent:IsNPC() then return end --Check that the entity is of the type we are looking for

	--Calculate the force multiplier to apply
	local weapMult = GAMEMODE.Multipliers.Weapons[weap]
	weapMult = weapMult and weapMult or 1.0

	local forceMultiplier = GAMEMODE.CVars.PropKnockback:GetFloat() * weapMult

	--Store the velocity of the hit and the velocity of the object before hit
	local hitVel = dmginfo:GetDamageForce()
	local hitLoc = dmginfo:GetDamagePosition()
	--local objectVelOld = ent:GetVelocity()

	--Calculate the force to apply to the object
	--local objectVel = objectVelOld + (forceMultiplier * hitVel)
	local objectVel = forceMultiplier * hitVel

	--Apply the force to the physics object of the entity
	local physobj = ent:GetPhysicsObject()
	if IsValid(physobj) then
		physobj:ApplyForceOffset(objectVel, hitLoc)
	end

end