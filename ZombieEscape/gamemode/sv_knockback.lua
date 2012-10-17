/*---------------------------------------------------------
	Zombie Knockback effects
---------------------------------------------------------*/

/*
	GAMEMODE.Multipliers

	Multipliers affect the amount of force applied to zombies
	upon bullet impact
*/
-- GM.DmgFilter = DMG_BULLET | DMG_CLUB | DMG_ALWAYSGIB | DMG_BLAST
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
	local bPassesDmgFilter = bit.band(dmginfo:GetDamageType(), self.DmgFilter) == dmginfo:GetDamageType()
	local inflictor = dmginfo:GetInflictor()
	if IsValid(ply) && ply:IsPlayer() && IsValid(inflictor) && inflictor:IsPlayer() && ply:IsZombie() && bPassesDmgFilter then
	
		-- Store some info for GM.PlayerHurt
		ply.OldVelocity = ply:GetVelocity()
		
		local weap = inflictor:GetActiveWeapon()
		if IsValid(weap) then
			ply.LastDmg = { hitgroup, weap:GetClass(), inflictor:GetPos() }
		else
			ply.LastDmg = { hitgroup, "nil", inflictor:GetPos() }
		end
		
		-- Hack to disable default pushback effects
		ply:SetMoveType(MOVETYPE_NONE)
		
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
		local hitgroupMult = self.Multipliers.Hitgroups[ply.LastDmg[1]]
		hitgroupMult = hitgroupMult && hitgroupMult || 1.0

		local weapMult = self.Multipliers.Weapons[ply.LastDmg[2]]
		weapMult = weapMult and weapMult or 1.0
		
		ply.KnockbackMultiplier = ply.KnockbackMultiplier and ply.KnockbackMultiplier or 1.0

		-- Knockback effects = (multiplier * weapon multiplier * hitgroup multiplier) * damage delt
		local knockback = (ply.KnockbackMultiplier * weapMult * hitgroupMult) * healthtaken

		-- Apply force
		local startvec = ply.LastDmg[3]
		local endvec = ply:GetPos()
		local vec = (endvec - startvec):GetNormal() * knockback
		
		ply:SetLocalVelocity(ply.OldVelocity + vec)
		ply.LastDmg = nil
		
	end
	
	return ply, attacker, healthleft, healthtaken
	
end
