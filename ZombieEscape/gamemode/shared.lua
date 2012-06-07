GM.Name     = "Zombie Escape"
GM.Author   = "Samuel 'samm5506' Maddock"
GM.Website  = "http://samuelmaddock.com/"

DeriveGamemode('base')

include('sh_meta.lua')
include('sh_resources.lua')
include('sh_weapon.lua')
include('team.lua')
include('weapons.lua')

GM.CVars = {}

TEAM_ZOMBIES = 2
TEAM_HUMANS = 3

TEAM_BOTH = {TEAM_ZOMBIES, TEAM_HUMANS}

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

function GM:ShouldCollide( ent1, ent2 )

	if IsValid(ent1) and IsValid(ent2) and ent1:IsPlayer() and ent2:IsPlayer() and ent1:Team() == ent2:Team() then
		return false
	end

	return true

end