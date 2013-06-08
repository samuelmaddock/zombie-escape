CVars.ZSpeed 		= CreateConVar( "ze_zombie_speed", 250, {FCVAR_REPLICATED}, "Zombie walk and run speed." )
CVars.ZHealthMin 	= CreateConVar( "ze_zhealth_min", 3000, {FCVAR_REPLICATED}, "Minumum health for a zombie to receive." )
CVars.ZHealthMax 	= CreateConVar( "ze_zhealth_max", 7500, {FCVAR_REPLICATED}, "Maximum health for a zombie to receive." )
CVars.ZKnockback		= CreateConVar( "ze_zknockback", '3.2', {FCVAR_REPLICATED}, "Knockback multiplier for zombies." )
CVars.ZMotherKnockback = CreateConVar( "ze_zmotherknockback", '2.3', {FCVAR_REPLICATED}, "Knockback multiplier for mother zombies." )
CVars.ZombieRatio 	= CreateConVar( "ze_zombie_ratio", 7, {FCVAR_REPLICATED}, "Ratio of zombies to spawn." )
CVars.ZHealthRegen   = CreateConVar( "ze_zhealth_regen", 1, {FCVAR_REPLICATED}, "Whether or not zombie health should regenerate." )
CVars.DebugNoInfect = CreateConVar( "ze_debug_noinfect", 0, FCVAR_NONE, "Disable the ability for zombies to infect humans." )

GM.PreviousZombies = {}

function GM:RandomInfect()

	local ratio = CVars.ZombieRatio:GetInt()

	-- Reset previous zombies if number of players is too low
	if team.NumPlayers(TEAM_ZOMBIES) < 1 then
		local NonZombies = math.floor(team.NumPlayers(TEAM_HUMANS) - (team.NumPlayers(TEAM_HUMANS) * (1/ratio)))
		if #self.PreviousZombies > NonZombies then
			MsgZE("Clearing previous zombies, " .. tostring(#self.PreviousZombies) .. ", " .. tostring(NonZombies))
			self.PreviousZombies = {}
		end
	end

	local ply
	
	math.randomseed( os.time() * #player.GetAll() / game.MaxPlayers() * self:GetRound() / self:GetMaxRounds() )
	
	-- Get random player to infect
	local Players = team.GetPlayers(TEAM_HUMANS)
	for _, pl in RandomPairs(Players) do
		if IsValid(pl) && !table.HasValue(self.PreviousZombies, pl) then
			ply = pl
			break
		end
	end

	if !IsValid(ply) then
		ply = Players[1]
	end
	
	if IsValid(ply) then

		ply:Zombify()
		ply:Spawn()
		ply.bMotherZombie = true

		-- Notify players of infection
		timer.Simple(0.1, function()
			if IsValid(ply) then
				umsg.Start( "PlayerKilledSelf" )
					umsg.Entity( ply )
				umsg.End()
			end
		end)

	end

	-- Infect until ratio is satisfied
	local Zombies = team.NumPlayers(TEAM_ZOMBIES)

	if Zombies * ratio > team.NumPlayers(TEAM_HUMANS) then
		self.PreviousZombies = team.GetPlayers(TEAM_ZOMBIES)
		MsgZE(tostring(Zombies) .. " zombies have been infected.")
		return
	else
		if Zombies < 1 then
			return ErrorNoHalt("GM.RandomInfect: Failed to infect a zombie, no players?\n")
		end

		self:RandomInfect()
	end

end


/*---------------------------------------------------------
	Infection process, zombie hurts human, etc.
---------------------------------------------------------*/
function GM:PlayerShouldTakeDamage( ply, attacker, inflictor )
	
	if !IsValid(attacker) then return true end

	if attacker:IsPlayer() and ply != attacker then
		
		-- Friendly fire is disabled
		if ply:Team() == attacker:Team() then
			return false
		end
		
		-- Human attacked by zombie
		if ply:IsHuman() and attacker:IsZombie() then
		
			-- Hacky fix for zombie infection via post-start-round grenade
			if attacker.GrenadeOwner then
				return false
			end
		
			-- Debug disabled infections
			if IsDebugMode() and CVars.DebugNoInfect:GetBool() then
				return false
			end

			attacker:SetHealth( attacker:Health() + ply:Health() ) -- zombies receive victim's health
			
			ply:Zombify()
			
			-- Inform players of infection
			umsg.Start( "PlayerKilledByPlayer" )
				umsg.Entity( ply )
				umsg.String( "zombie_arms" )
				umsg.Entity( attacker )
			umsg.End()
			
			hook.Call( "OnInfected", self, ply, attacker )

			return false
			
		elseif ply:IsZombie() and attacker:IsHuman() then -- Zombie attacked by human
		
			-- 8% chance a zombie will emit pain upon taking damage
			if math.random() < 0.08 then
				ply:EmitRandomSound(self.ZombiePain)
			end
		
		end
		
	end
	
	-- Friendly entity owner detection, etc.
	if !attacker:IsPlayer() then
		local owner = attacker:GetOwner()
		if IsValid(owner) and owner:IsPlayer() and ply:Team() == owner:Team() then
			return false
		end
	end
	
	-- Props shouldn't hurt the player
	if string.find(attacker:GetClass(), "^prop_") then
		return false
	end
	
	return true

end

/*---------------------------------------------------------
	Prevents zombies infecting via grenades
---------------------------------------------------------*/
hook.Add( "EntityTakeDamage", "RelayDamage", function( ent, dmginfo )
	
	local inflictor = dmginfo:GetInflictor()
	local attacker = dmginfo:GetAttacker()
	local amount = dmginfo:GetDamage()

	if !IsValid(ent) or !IsValid(inflictor) or ent:IsNPC() then return end
	
	if ent:IsPlayer() then

		-- Damage delt to player by grenade
		if IsValid(attacker) and inflictor:GetClass() == "npc_grenade_frag" then

			-- fix for zombies throwing grenade prior to infection
			if attacker:IsPlayer() then
				inflictor:SetOwner(attacker)
				attacker.GrenadeOwner = true
			end

			-- Human has grenaded a zombie
			local dmgblast = bit.band(DMG_BLAST, dmginfo:GetDamageType()) != 0
			local owner = attacker:GetOwner()
			if ent:IsZombie() and dmgblast and IsValid(owner) and owner:IsPlayer() and !owner:IsZombie() then
				ent:Ignite( math.random(3, 5), 0 )
				hook.Call( "OnZombieIgnited", GAMEMODE, ent, owner )
			end

		else
			attacker.GrenadeOwner = nil
		end

	end
	
end )

/*---------------------------------------------------------
	Zombies should not pickup any weapons
---------------------------------------------------------*/
function GM:PlayerCanPickupWeapon( ply, weapon )

	if !IsValid(ply) or !IsValid(weapon) then return false end
	if GetConVar( "sv_cheats" ):GetBool() then return true end

	local bZombieArms = (weapon:GetClass() == "zombie_arms")
	if ply:IsZombie() then
		if bZombieArms then return true end
		return false
	else
		if bZombieArms then return false end
	end
	
	return true

end