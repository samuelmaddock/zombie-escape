GM.CVars.ZSpeed 		= CreateConVar( "ze_zombie_speed", 250, {FCVAR_REPLICATED}, "Zombie walk and run speed." )
GM.CVars.ZHealthMin 	= CreateConVar( "ze_zhealth_min", 3000, {FCVAR_REPLICATED}, "Minumum health for a zombie to receive." )
GM.CVars.ZHealthMax 	= CreateConVar( "ze_zhealth_max", 3500, {FCVAR_REPLICATED}, "Maximum health for a zombie to receive." )
GM.CVars.ZKnockback		= CreateConVar( "ze_zknockback", '7.0', {FCVAR_REPLICATED}, "Knockback multiplier for zombies." )
GM.CVars.ZMotherKnockback = CreateConVar( "ze_zmotherknockback", '6.0', {FCVAR_REPLICATED}, "Knockback multiplier for mother zombies." )
GM.CVars.ZombieRatio 	= CreateConVar( "ze_zombie_ratio", 7, {FCVAR_REPLICATED}, "Ratio of zombies to spawn." )
GM.CVars.ZHealthRegen   = CreateConVar( "ze_zhealth_regen", 1, {FCVAR_REPLICATED}, "Whether or not zombie health should regenerate." )

function GM:ZombieSpawn( ply )

	local mdl = table.Random(self.ZombieModels)

	 -- Map specific zombie models
	local override = self.PlayerModelOverride[TEAM_ZOMBIES]
	mdl = override and table.Random(override) or mdl
	
	ply:SetModel(mdl)
	ply:SetFOV(110, 3)

	local scale = math.Clamp( 1 - (#team.GetPlayers(TEAM_BOTH) / self.PlayerScale), 0, 1 )
	scale = (scale > 0.7) and 1 or scale -- only take effect with larger amount of players

	local health = self.CVars.ZHealthMin:GetInt() + self.CVars.ZHealthMax:GetInt()*scale
	ply:SetHealth(health)
	ply:SetMaxHealth(health)

	ply:SetSpeed(self.CVars.ZSpeed:GetInt())
	
	ply:Flashlight(false)
	ply:StripWeapons() -- zombies can't use guns, silly!
	ply:Give("zombie_arms")

	ply:ZScream()
	
	ply.NextHealthRegen = CurTime() + 5
	ply.NextMoan = CurTime() + math.random(25,45)

end

GM.PreviousZombies = {}
function GM:RandomInfect()
	
	local ratio = self.CVars.ZombieRatio:GetInt()

	-- Reset previous zombies if number of players is too low
	if team.NumPlayers(TEAM_ZOMBIES) < 1 then
		local NonZombies = math.floor(team.NumPlayers(TEAM_HUMANS) - (team.NumPlayers(TEAM_HUMANS) * (1/ratio)))
		if #self.PreviousZombies > NonZombies then
			Msg("[ZE] Clearing previous zombies, " .. tostring(#self.PreviousZombies) .. ", " .. tostring(NonZombies) .. "\n")
			self.PreviousZombies = {}
		end
	end

	local ply
	
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
		return Msg("[ZE] " .. tostring(Zombies) .. " zombies have been infected.\n")
	else
		if Zombies < 1 then
			return ErrorNoHalt("GM.RandomInfect: Failed to infect a zombie, no players?\n")
		end

		self:RandomInfect()
	end

end


/*---------------------------------------------------------
	Zombie Ignite Logic

	Grenades can ignite zombies
---------------------------------------------------------*/
local function CheckIgnite(ply)

	if ply:IsOnFire() then

		-- Reduced speed has already been set
		if ply._ReducedSpeed then

			-- Player is in the water and should be extinguished
			if ply:WaterLevel() >= 2 then
				ply:Extinguish()
			end

		else -- Zombie has been ignited

			-- Reduce zombie speed to half
			ply._ReducedSpeed = true
			ply:SetSpeed( math.Round(GAMEMODE.CVars.ZSpeed:GetInt() * 0.5) )

		end

	else

		-- Restore default speed
		if ply._ReducedSpeed then
			ply:SetSpeed(GAMEMODE.CVars.ZSpeed:GetInt())
			ply._ReducedSpeed = nil
		end
		
	end

end


/*---------------------------------------------------------
	Zombie Think
		Moan every 25 to 35 seconds,
		Health Regen,
		Weapon check
---------------------------------------------------------*/
hook.Add("Think", "ZombieThink", function()
	for _, ply in pairs(team.GetPlayers(TEAM_ZOMBIES)) do
		if IsValid(ply) && ply:Alive() then

			-- Zombie moan
			if ply.NextMoan and ply.NextMoan < CurTime() then
				ply:ZMoan()
			end
			
			-- Health regeneration
			if GAMEMODE.CVars.ZHealthRegen:GetBool() then
				local health = ply:Health()
				if ply.NextHealthRegen && ply.NextHealthRegen < CurTime() && health < ply:GetMaxHealth() then
					local newhealth = math.Clamp( health + math.random(50, 150), 0, ply:GetMaxHealth() )
					ply:SetHealth( newhealth )
					ply.NextHealthRegen = CurTime() + math.random(2,3)
				end
			end
			
			-- Weapon check
			if !ply:HasWeapon("zombie_arms") then
				ply:Give("zombie_arms")
				ply:SelectWeapon("zombie_arms")
			end

			-- Flashlight should always be disabled
			if ply:FlashlightIsOn() then
				ply:Flashlight(false)
			end

			-- Grenade speed reduction
			CheckIgnite(ply)

		end
	end
end)