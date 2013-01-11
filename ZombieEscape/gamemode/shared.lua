GM.Name     = "Zombie Escape"
GM.Author   = "Samuel 'samm5506' Maddock"
GM.Website  = "http://samuelmaddock.com/"

DeriveGamemode('base')

include('player_class/player_ze.lua')
include('player_class/player_human.lua')
include('player_class/player_zombie.lua')
include('player_class/player_spectator.lua')
include('animations.lua')
include('sh_meta.lua')
include('sh_resources.lua')
include('sh_weapon.lua')
include('team.lua')
include('weapons.lua')
include('css.lua')

GM.CVars = {}
GM.CVars.BossDebug = CreateConVar( "ze_boss_debug", 0, {FCVAR_REPLICATED}, "Debug mode for finding boss entities." )

TEAM_SPECTATOR = 1
TEAM_ZOMBIES = 2
TEAM_HUMANS = 3

TEAM_BOTH = { TEAM_ZOMBIES, TEAM_HUMANS }

function GM:CreateTeams()
	
	team.SetUp(TEAM_HUMANS, "Humans", Color(42,190,235,255) )
	team.SetUp(TEAM_ZOMBIES, "Zombies", Color(0,180,0,255))

	if self.SwapSpawns then
		team.SetSpawnPoint(TEAM_HUMANS, "info_player_terrorist")
		team.SetSpawnPoint(TEAM_ZOMBIES, "info_player_counterterrorist")
	else
		team.SetSpawnPoint(TEAM_HUMANS, "info_player_counterterrorist")
		team.SetSpawnPoint(TEAM_ZOMBIES, "info_player_terrorist")
	end

end