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

TEAM_SPECTATOR = 1
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

	-- Players of opposite teams shouldn't collide
	if ent1:IsPlayer() and ent2:IsPlayer() and ent1:Team() == ent2:Team() then
		return false
	end

	-- CS:S Collision Rules
	local collisionGroup0 = ent1:GetCollisionGroup()
	local collisionGroup1 = ent2:GetCollisionGroup()

	if collisionGroup0 > collisionGroup1 then
		local old = collisionGroup0
		collisionGroup0 = collisionGroup1
		collisionGroup1 = old
	end

	if collisionGroup0 == COLLISION_GROUP_PLAYER_MOVEMENT and 
		collisionGroup1 == COLLISION_GROUP_WEAPON then
		return false
	end

	if (collisionGroup0 == COLLISION_GROUP_PLAYER or collisionGroup0 == COLLISION_GROUP_PLAYER_MOVEMENT) and
		collisionGroup1 == COLLISION_GROUP_PUSHAWAY then
		return false
	end

	if collisionGroup0 == COLLISION_GROUP_DEBRIS and collisionGroup1 == COLLISION_GROUP_PUSHAWAY then
		return true
	end

	return self.BaseClass:ShouldCollide( ent1, ent2 )

end


local EntityMeta = FindMetaTable( "Entity" )
if !EntityMeta then return end

function ImpactTrace2( traceHit, pPlayer )

	if ( traceHit.MatType == MAT_GRATE ) then
		return
	end

	local vecSrc		= traceHit.StartPos;
	local vecDirection	= traceHit.Normal;

	if ( pPlayer && pPlayer:IsPlayer() ) then
		vecSrc			= pPlayer:GetShootPos()
		vecDirection	= pPlayer:GetAimVector()
	else
		pPlayer			= game.GetWorld()
	end

	local info			= {}
	info.Src			= vecSrc
	info.Dir			= vecDirection
	info.Num			= 1
	info.Damage			= 0
	info.Force			= 0
	info.Tracer			= 0

	return EntityMeta:FireBullets( pPlayer, info )

end

function util.ImpactTrace( tr, iDamageType, pCustomImpactName )
	local ent = tr.Entity

	if !IsValid(ent) or tr.HitSky then
		return
	end

	if tr.Fraction == 1.0 then
		return
	end

	if tr.HitNoDraw then
		return
	end

	ent:ImpactTrace(tr, iDamageType)
end

function EntityMeta:ImpactTrace( tr, iDamageType, pCustomImpactName )

	local ent = tr.Entity

	local data = EffectData()
	data:SetOrigin(tr.HitPos)
	data:SetStart(tr.StartPos)
	data:SetSurfaceProp(tr.MatType)
	data:SetDamageType(iDamageType)
	data:SetHitBox(tr.HitBox)

	if !pCustomImpactName then
		util.Effect( "Impact", data, true, true )
	else
		util.Effect( pCustomImpactName, data, true, true )
	end

end