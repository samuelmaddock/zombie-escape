AddCSLuaFile("animations.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile('shared.lua')
AddCSLuaFile("sh_load.lua")
AddCSLuaFile('sh_meta.lua')

include('shared.lua')
include('sv_humans.lua')
include('sv_resources.lua')

GM.PlayerModelOverride = {}

CVars.ZSpawnLateJoin		= CreateConVar( "ze_zspawn_latejoin", 1, {FCVAR_REPLICATED}, "Allow late joining as zombie." )
CVars.ZSpawnTimeLimit 	= CreateConVar( "ze_zspawn_timelimit", 120, {FCVAR_REPLICATED}, "Time from the start of the round to allow late zombie spawning." )

function GM:Initialize()
	self.BaseClass.Initialize( self )
	RunConsoleCommand("sv_playerpickupallowed",0) -- this should never be enabled
end

function GM:PlayerInitialSpawn( ply )

	self.BaseClass.PlayerInitialSpawn( self, ply )

	ply:GoTeam( TEAM_SPECTATOR )

	if self:HasRoundStarted() then
		ply:SendMessage( "Press F3 to begin playing as a zombie." )
	end

end

function GM:PlayerSpawn( ply )

	self.BaseClass.PlayerSpawn( self, ply )

	if !ply:IsSpectator() then
		ply:UnSpectate()
	end

	player_manager.OnPlayerSpawn( ply )
	player_manager.RunClass( ply, "Spawn" )

end

function GM:PlayerSwitchFlashlight(ply)
	return ply:Alive() and ply:IsHuman()
end

function GM:ShowSpare1(ply)

	if !IsValid(ply) then return end

	if !table.HasValue(TEAM_BOTH, ply:Team()) then -- Spectator
	
		self:PlayerRequestJoin(ply)
		
	else

		if ply:IsHuman() and !ply.IsInBuyzone then
			ply:SendMessage("You must be in a buyzone to select weapons")
		end
		
	end
	
end

function GM:PlayerRequestJoin(ply)

	local numply = #player.GetAll()
	if numply >= 2 and !self.Restarting then

		local bLateJoin = CVars.ZSpawnLateJoin:GetBool()
		local bWithinTimeLimit = self.RoundStarted and ( self.RoundStarted + CVars.ZSpawnTimeLimit:GetInt() ) > CurTime() -- player may spawn as zombie prior to timelimit
		
		if !self.InfectionStarted then -- pre-infection

			ply:GoTeam(TEAM_HUMANS)

		else -- post-infection

			if team.IsAlive(TEAM_ZOMBIES) and ( bLateJoin or bWithinTimeLimit ) then

				ply:GoTeam(TEAM_ZOMBIES)

			else

				ply:GoTeam(TEAM_SPECTATOR)
				ply:SendMessage("You will start playing next round!")

			end

		end
		
	else
	
		ply:GoTeam(TEAM_SPECTATOR)
		ply:SendMessage("You will start playing next round!")
		
	end

end

function GM:PlayerCanHearPlayersVoice( ply1, ply2 )
	return IsValid(ply1) and IsValid(ply2) and (ply1:Team() != ply2:Team())
end

/*---------------------------------------------------------
	DoPlayerDeath
---------------------------------------------------------*/
function GM:DoPlayerDeath( ply, attacker, dmginfo )

	self.BaseClass.DoPlayerDeath( self, ply, attacker, dmginfo )

	-- Humans should drop their weapons upon death
	local weapon = ply:GetActiveWeapon()
	if ply:IsHuman() and IsValid(weapon) then
		ply:DropWeapon(weapon)
	end

	ply:CreateRagdoll()
	
	if IsValid(attacker) and attacker:IsPlayer() then

		if ply == attacker then -- suicide

			attacker:AddFrags(-1)

		elseif ply:Team() != attacker:Team() then -- pvp kill

			-- should only be human killed zombie
			if attacker:IsZombie() then
				ErrorNoHalt("ERROR: Zombie killed player! " .. tostring(ply) .. ", " .. tostring(attacker))
			end

			attacker:AddFrags(1)
			ply:EmitRandomSound(self.ZombieDeath)

			hook.Call( "OnHumanKilledZombie", self, ply, attacker )

		end

	end
	
	-- Prevent respawning
	if self.RoundStarted then
		ply.DiedOnRound = self:GetRound()
	end
	
	ply:GoTeam( TEAM_SPECTATOR, true )

end

/*---------------------------------------------------------
	Suicide is disabled
---------------------------------------------------------*/
function GM:CanPlayerSuicide(ply)

	if GetConVar("sv_cheats"):GetBool() then
		return true
	end

	return ply:IsHuman() or ( ply:IsZombie() and !ply:IsMotherZombie() )

end

/*---------------------------------------------------------
	Player must be alive and a human or zombie
	to use buttons, etc.
---------------------------------------------------------*/
function GM:PlayerUse(ply, ent)
	return ply:Alive() and (ply:IsHuman() or ply:IsZombie())
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerNoClip( player, bool )
   Desc: Player pressed the noclip key, return true if
		  the player is allowed to noclip, false to block
-----------------------------------------------------------]]
function GM:PlayerNoClip( pl, on )

	-- Allow noclip if we're in single player
	if game.SinglePlayer() then return true end
	if GetConVar("sv_cheats"):GetBool() then return true end
	
	-- Allow base gamemode to decide
	if !self.BaseClass.PlayerNoClip( self, pl, on ) then
		return false
	end
	
	return false
	
end

/*---------------------------------------------------------
	Include Map Lua Files
---------------------------------------------------------*/
local mapLua = string.format("maps/%s.lua", game.GetMap())
if file.Exists( string.format("gamemodes/%s/gamemode/" .. mapLua, GM.FolderName), "GAME" ) then
	Msg("Including map lua file\n")
	include(mapLua)
end