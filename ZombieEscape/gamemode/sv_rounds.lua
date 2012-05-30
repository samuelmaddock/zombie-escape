GM.CVars.ZSpawnMin			= CreateConVar( "ze_ztimer_min", 10, {FCVAR_REPLICATED}, "Minimum time from the start of the round until picking the mother zombie(s)." )
GM.CVars.ZSpawnMax 			= CreateConVar( "ze_ztimer_max", 25, {FCVAR_REPLICATED}, "Maximum time from the start of the round until picking the mother zombie(s)." )

GM.CVars.MaxRounds			= CreateConVar( "ze_max_rounds", 8, {FCVAR_REPLICATED}, "Maximum amount of rounds played prior to map switch" )

GM.WaitingTime		= 10
GM.IntermissionTime = 15
GM.InfectingTime	= 10

GM.PlayerScale = math.Clamp( MaxPlayers(), 50, math.max(MaxPlayers(),50) ) -- amount of players

GM.Round = 0
GM.RoundCanEnd = true

function GM:GetRound()
	return self.Round and self.Round or 1
end

function GM:GetMaxRounds()
	return (self.CVars and self.CVars.MaxRounds) and self.CVars.MaxRounds:GetInt() or 6
end

function GM:GetMinZSpawnTime()
	return (self.CVars and self.CVars.ZSpawnMin) and self.CVars.ZSpawnMin:GetInt() or 10
end

function GM:GetMaxZSpawnTime()
	return (self.CVars and self.CVars.ZSpawnMax) and self.CVars.ZSpawnMax:GetInt() or 25
end

function GM:RoundChecks(CallBack)
	timer.Simple(0.25, self.DeathCheck, self)
	timer.Simple(0.5, self.RoundRestart, self)
	if CallBack then
		timer.Simple(0.51, CallBack)
	end
end

function GM:ShouldStartRound()

	if self.RoundCanEnd and #player.GetAll() >= 2 then

		-- Check if no one is alive on either team
		if !team.IsAlive(TEAM_HUMANS) or !team.IsAlive(TEAM_ZOMBIES) then
			return true
		end

	end

	return false

end

function GM:DeathCheck()

	if self.Restarting then return end

	local bRestart = false
	local WinnerTeam

	local bHumansAlive = team.IsAlive(TEAM_HUMANS)
	local bZombiesAlive = team.IsAlive(TEAM_ZOMBIES)

	if !bHumansAlive and bZombiesAlive then -- Zombies win
		bRestart = true
		WinnerTeam = TEAM_ZOMBIES
	elseif bHumansAlive and !bZombiesAlive then -- Humans win
		bRestart = true
		WinnerTeam = TEAM_HUMANS
	elseif !self.ServerStarted and !bHumansAlive and !bZombiesAlive then -- All players died before round start
		bRestart = true
		self.RoundCanEnd = true
	end

	if bRestart then

		local callback = function()

			if WinnerTeam then
				self:SendWinner(WinnerTeam,false)
				gamemode.Call("OnTeamWin", WinnerTeam)
			end

		end

		self:RoundRestart(callback)

	end

end

GM.Restarting = false
function GM:RoundRestart(CallBack)

	if self.Restarting then
		return -1
	end

	if !self.ForceRestart and !self:ShouldStartRound() then
		return -2
	end
	
	self.Restarting = true
	self.ForceRestart = false
	self.RoundEndTime = false
	
	if CallBack then
		CallBack()
	end
	
	if self:GetRound() >= self:GetMaxRounds() then

		gamemode.Call("ChangeMap")

	else

		local Time = 5
		if self.ServerStarted then
			self.ServerStarted = false
			Time = 15
		end

		timer.Simple(Time, self.RoundStart, self)

		self:SendMapMessage("A new round will begin in "..tostring(Time).." seconds")

	end
	
	return true

end

function GM:AFKCheck()
	-- Check current position vs spawn position
	for _, ply in pairs(team.GetPlayers(TEAM_HUMANS)) do
		if IsValid(ply) and ply.SpawnInfo then
			if math.floor(ply.SpawnInfo.pos:Length()) == math.floor(ply:GetPos():Length()) then
				ply:GoTeam(TEAM_ZOMBIES)
				ply:SendMessage("You have been infected for being AFK")
			end
		end
	end
	self:RoundChecks()
end


function GM:RoundStart()

	if !self.Restarting then return end
	
	self.RoundCanEnd = false
	self.RoundTime = CurTime()
	self.InfectionStarted = false
	self.Round = self:GetRound() + 1

	if self:GetRound() == self:GetMaxRounds() then
		self:SendMapMessage("This is the final round")
	end

	self:CleanUpMap()
	
	-- Spawn all non-spectators as humans
	for _, ply in pairs(player.GetAll()) do
		if IsValid(ply) then
			ply:GoTeam(TEAM_HUMANS)
		end
	end
	
	gamemode.Call("OnRoundChange")
	
	self:SendWinner(-1,true) -- Reset winner
	
	self.Restarting = false
	self.RoundStarted = CurTime()
	
	local scale = math.Clamp( 1 - (team.NumPlayers(TEAM_BOTH) / self.PlayerScale), 0, 1 )
	scale = (scale > 0.7) and 1 or scale -- only take effect with larger amount of players

	local Time = self:GetMinZSpawnTime() + math.abs(self:GetMaxZSpawnTime()-self:GetMinZSpawnTime())*scale
	Time = (self:GetRound() == 1) and Time + 3 or Time -- additional time for players selecting their weapons
	
	-- Random infect
	timer.Simple(Time, function()
		math.randomseed(os.time())
		self:RandomInfect()
		self.InfectionStarted = true
	end)

	-- Simple AFK check
	timer.Destroy("HumanAFKCheck")
	timer.Create("HumanAFKCheck", 60, 1, self.AFKCheck, self)
	
end

function GM:SendWinner( TeamId, bReset )
	umsg.Start("WinningTeam")
		umsg.Char(TeamId)
		umsg.Bool(bReset)
	umsg.End()
end