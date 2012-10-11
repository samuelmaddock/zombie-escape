GM.CVars.ZSpeed = CreateConVar( "ze_zombie_speed", 250, {FCVAR_REPLICATED}, "" )
GM.CVars.ZHealthMin = CreateConVar( "ze_zhealth_min", 3200, {FCVAR_REPLICATED}, "" )
GM.CVars.ZHealthMax = CreateConVar( "ze_zhealth_max", 4300, {FCVAR_REPLICATED}, "" )
GM.CVars.ZombieRatio = CreateConVar( "ze_zombie_ratio", 7, {FCVAR_REPLICATED}, "" )

function GM:ZombieSpawn( ply )

	local mdl = table.Random(self.ZombieModels)

	 -- Map specific zombie models
	local override = self.PlayerModelOverride[TEAM_ZOMBIES]
	mdl = override and table.Random(override) or mdl
	
	ply:SetModel(mdl)
	ply:SetFOV(110)

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
	ply.KnockbackMultiplier = 4.0

end

function GM:RandomInfect()
	
	local ply
	
	-- Get random player to infect
	local Players = team.GetPlayers(TEAM_HUMANS)
	for _, pl in RandomPairs(Players) do
		if IsValid(pl) then
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
		--ply.KnockbackMultiplier = 3.6 -- Mother zombies are more resistent to knockback affects
		--ply:SendMessage("You've been randomly selected to be infected")

		-- Notify players of infection
		timer.Simple(0.1, function()
			if IsValid(ply) then
				umsg.Start( "PlayerKilledSelf" )
					umsg.Entity( ply )
				umsg.End()
			end
		end)

	end

	-- Max of 5 mother zombies, 1:7 zombies ratio
	local Zombies = team.NumPlayers(TEAM_ZOMBIES)
	local ratio = self.CVars.ZombieRatio:GetInt()
	if Zombies * ratio > team.NumPlayers(TEAM_HUMANS) then
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
		ply:SetSpeed(GAMEMODE.CVars.ZSpeed:GetInt())
		ply._ReducedSpeed = false
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
			local health = ply:Health()
			if ply.NextHealthRegen < CurTime() && health < ply:GetMaxHealth() then
				local newhealth = math.Clamp( health + math.random(50, 150), 0, ply:GetMaxHealth() )
				ply:SetHealth( newhealth )
				ply.NextHealthRegen = CurTime() + math.random(2,3)
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

			CheckIgnite(ply)

		end
	end
end)