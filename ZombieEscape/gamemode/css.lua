/*-------------------------------------------------
	Counter-Strike: Source Rules
	Recreated from the source code
-------------------------------------------------*/

local EntityMeta = FindMetaTable("Entity")
local PlayerMeta = FindMetaTable("Player")

/*-------------------------------------------------
	Ammo Types
	cs_gamerules.cpp
-------------------------------------------------*/

game.AddAmmoType({
	name = "ammo_50AE",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2400,
	minsplash = 10,
	maxsplash = 14
})
game.AddAmmoType({
	name = "ammo_762mm",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2400,
	minsplash = 10,
	maxsplash = 14
})
game.AddAmmoType({
	name = "ammo_556mm",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2400,
	minsplash = 10,
	maxsplash = 14
})
game.AddAmmoType({
	name = "ammo_556mm_box",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2400,
	minsplash = 10,
	maxsplash = 14
})
game.AddAmmoType({
	name = "ammo_338mag",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2800,
	minsplash = 12,
	maxsplash = 16
})
game.AddAmmoType({
	name = "ammo_9mm",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 5,
	maxsplash = 10
})
game.AddAmmoType({
	name = "ammo_buckshot",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 600,
	minsplash = 3,
	maxsplash = 6
})
game.AddAmmoType({
	name = "ammo_45acp",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2100,
	minsplash = 6,
	maxsplash = 10
})
game.AddAmmoType({
	name = "ammo_357sig",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 4,
	maxsplash = 8
})
game.AddAmmoType({
	name = "ammo_57mm",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 4,
	maxsplash = 8
})

/*-------------------------------------------------
	Bullet
-------------------------------------------------*/

function util.ImpactTrace( tr, iDamageType, pCustomImpactName )
	local ent = tr.Entity

	if tr.HitSky then
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

-- For some reason, impact effects are wrong
local HitDecals = {
	[MAT_METAL] = MAT_CONCRETE,
	[MAT_CONCRETE] = MAT_METAL
}
function EntityMeta:ImpactTrace( tr, iDamageType, pCustomImpactName )

	local data = EffectData()
	data:SetOrigin(tr.HitPos)
	data:SetStart(tr.StartPos)
	data:SetDamageType(iDamageType)
	data:SetHitBox(tr.HitBox)

	-- Msg("MAT IMPACT " .. tr.MatType .. "\n")
	local fixedmat = HitDecals[tr.MatType] and HitDecals[tr.MatType] or tr.MatType
	data:SetSurfaceProp(fixedmat)

	if !pCustomImpactName then
		util.Effect( "Impact", data, true, true )
	else
		util.Effect( pCustomImpactName, data, true, true )
	end

end

local function GetBulletTypeParameters( iBulletType )

	local fPenetrationPower, flPenetrationDistance

	if iBulletType == "ammo_50AE" then
		fPenetrationPower = 30
		flPenetrationDistance = 1000
	elseif iBulletType == "ammo_762mm" then
		fPenetrationPower = 39
		flPenetrationDistance = 5000
	elseif iBulletType == "ammo_556mm" or iBulletType == "ammo_556mm_box" then
		fPenetrationPower = 35
		flPenetrationDistance = 4000
	elseif iBulletType == "ammo_338mag"then
		fPenetrationPower = 45
		flPenetrationDistance = 8000
	elseif iBulletType == "ammo_9mm"then
		fPenetrationPower = 21
		flPenetrationDistance = 800
	elseif iBulletType == "ammo_buckshot"then
		fPenetrationPower = 0
		flPenetrationDistance = 0
	elseif iBulletType == "ammo_45acp"then
		fPenetrationPower = 15
		flPenetrationDistance = 500
	elseif iBulletType == "ammo_357sig"then
		fPenetrationPower = 25
		flPenetrationDistance = 800
	elseif iBulletType == "ammo_57mm"then
		fPenetrationPower = 30
		flPenetrationDistance = 2000
	else
		fPenetrationPower = 0
		flPenetrationDistance = 0
	end

	return fPenetrationPower, flPenetrationDistance

end

local function GetMaterialParameters( mat )

	local flPenetrationModifier, flDamageModifier

	if mat == MAT_METAL then
		flPenetrationModifier = 0.5
		flDamageModifier = 0.3
	elseif mat == MAT_DIRT then
		flPenetrationModifier = 0.5
		flDamageModifier = 0.3
	elseif mat == MAT_CONCRETE then
		flPenetrationModifier = 0.4
		flDamageModifier = 0.25
	elseif mat == MAT_GRATE then
		flPenetrationModifier = 1.0
		flDamageModifier = 0.99
	elseif mat == MAT_VENT then
		flPenetrationModifier = 0.5
		flDamageModifier = 0.45
	elseif mat == MAT_TILE then
		flPenetrationModifier = 0.65
		flDamageModifier = 0.3
	elseif mat == MAT_COMPUTER then
		flPenetrationModifier = 0.4
		flDamageModifier = 0.45
	elseif mat == MAT_WOOD then
		flPenetrationModifier = 1.0
		flDamageModifier = 0.6
	else
		flPenetrationModifier = 1.0
		flDamageModifier = 0.5
	end
	
	return flPenetrationModifier, flDamageModifier

end

local function TraceToExit( trace )
	local flDistance = 0
	local last = trace.vecStart
	local vecEnd

	while flDistance <= trace.flMaxDistance do
		flDistance = flDistance + trace.flStepSize
		vecEnd = trace.vecStart + flDistance * trace.dir

		if bit.band(util.PointContents(vecEnd), MASK_SOLID) == 0 then
			return vecEnd
		end
	end

	return false
end

function PlayerMeta:FireBullets( bullet )

	bullet.Attacker = bullet.Attacker and bullet.Attacker or self

	math.randomseed(CurTime())
	local x, y

	for i = 1, bullet.Num do

		
		x = math.Rand(-0.5, 0.5) + math.Rand(-0.5, 0.5)
		y = math.Rand(-0.5, 0.5) + math.Rand(-0.5, 0.5)

		self:FireCSBullet(
			bullet.Src,
			bullet.Dir,
			bullet.Spread,
			6000,
			2,
			bullet.Damage,
			1.0,
			bullet.Attacker,
			true,
			x,
			y
		)

		if bullet.Callback then
			bullet.Callback()
		end

	end

end

function PlayerMeta:FireCSBullet(
	vecSrc,			// shooting postion
	shootAngles,	//shooting angle
	vecSpread,		// spread vector
	flDistance,		// max distance 
	iPenetration,	// how many obstacles can be penetrated
	iDamage,		// base damage
	flRangeModifier,	// damage range modifier
	pevAttacker,		// shooter
	bDoEffects,
	x,
	y
	)

	local fCurrentDamage = iDamage
	local flCurrentDistance = 0.0

	local vecDirShooting = shootAngles
	local vecRight = shootAngles:Angle():Right()
	local vecUp = shootAngles:Angle():Up()

	local weap = self:GetActiveWeapon()
	if !IsValid(weap) then return end

	local iBulletType = weap.Primary.Ammo

	local flDamageModifier = 0.5
	local flPenetrationModifier = 1.0

	local flPenetrationPower, flPenetrationDistance = GetBulletTypeParameters(iBulletType)

	local vecDir = vecDirShooting +
		x * vecSpread * vecRight +
		y * vecSpread * vecUp

	vecDir = vecDir:GetNormal()

	local bFirstHit = true

	local lastPlayerHit

	while fCurrentDamage > 0 do
		local vecEnd = vecSrc + vecDir * flDistance

		local tr = util.TraceLine({
			start = vecSrc,
			endpos = vecEnd,
			filter = { self, lastPlayerHit },
			mask = bit.bor(CONTENTS_HITBOX,MASK_SOLID,CONTENTS_DEBRIS)
		})

		-- ClipTraceToPlayers?

		lastPlayerHit = tr.Entity

		if tr.Fraction == 1.0 then
			break -- we didn't hit anything, stop tracing shoot
		end

		bFirstHit = false

		local iEnterMaterial = tr.MatType

		flPenetrationModifier, flDamageModifier = GetMaterialParameters(iEnterMaterial)

		local hitGrate = bit.band(iEnterMaterial, MAT_GRATE) == MAT_GRATE

		if hitGrate then
			flPenetrationModifier = 1.0
			flDamageModifier = 0.99
		end

		flCurrentDistance = flCurrentDistance + tr.Fraction * flDistance
		fCurrentDamage = fCurrentDamage * math.pow(flRangeModifier, (flCurrentDistance / 500))

		if flCurrentDistance > flPenetrationDistance and iPenetration > 0 then
			iPenetration = 0
		end

		local iDamageType = bit.bor(DMG_BULLET, DMG_NEVERGIB)

		if bDoEffects then
			if bit.band(util.PointContents(tr.HitPos), bit.bor(CONTENTS_WATER,CONTENTS_SLIME)) != 0 then
				local waterTrace = util.TraceLine({
					start = vecSrc,
					endpos = tr.HitPos,
					filter = self,
					mask = bit.bor(MASK_SHOT,CONTENTS_WATER,CONTENTS_SLIME)
				})

				if waterTrace.Hit then
					local data = EffectData()
					data:SetOrigin(waterTrace.HitPos)
					data:SetNormal(waterTrace.HitNormal)
					data:SetScale(math.Rand(8,12))

					-- if bit.band(waterTrace.MatType, MAT_SLOSH) != 0 then
					-- 	data:SetFlags(0x1) -- FX_WATER_IN_SLIME
					-- end

					util.Effect( "gunshotsplash", data, true, true )
				end
			else
				if !tr.HitSky and !tr.HitNoDraw then
					local ent = tr.Entity
					if !(IsValid(ent) and ent:IsPlayer() and ent:Team() == LocalPlayer():Team()) then
						util.ImpactTrace(tr, iDamageType)
					end
				end
			end
		end

		if SERVER then
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker(pevAttacker)
			dmginfo:SetInflictor(pevAttacker)
			dmginfo:SetDamage(fCurrentDamage)
			dmginfo:SetDamageType(iDamageType)

			dmginfo:SetDamagePosition(tr.HitPos)
			local vecForce = vecDir:GetNormal()
			-- vecForce = vecForce * 1 -- Ammo Damage Force
			vecForce = vecForce * GetConVar("phys_pushscale"):GetFloat()
			-- vecForce = vecForce * 1 -- scale
			dmginfo:SetDamageForce(vecForce)

			tr.Entity:DispatchTraceAttack(dmginfo, tr.StartPos, tr. HitPos, vecDir)

			-- TODO: TraceAttackToTriggers
		end

		if iPenetration == 0 and !hitGrate then
			break
		end

		if iPenetration < 0 then
			break;
		end

		local penetrationEnd = TraceToExit({
			vecStart = tr.HitPos,
			dir = vecDir,
			flStepSize = 24,
			flMaxDistance = 128
		})

		if !penetrationEnd then
			break
		end
		
		local exitTr = util.TraceLine({
			start = penetrationEnd,
			endpos = tr.HitPos,
			mask = bit.bor(CONTENTS_HITBOX,MASK_SOLID,CONTENTS_DEBRIS)
		})

		if exitTr.Entity != tr.Entity and IsValid(exitTr.Entity) then
			exitTr = util.TraceLine({
				start = penetrationEnd,
				endpos = tr.HitPos,
				filter = exitTr.Entity,
				mask = bit.bor(CONTENTS_HITBOX,MASK_SOLID,CONTENTS_DEBRIS)
			})
		end

		local iExitMaterial = exitTr.MatType

		hitGrate = hitGrate and bit.band(iExitMaterial, MAT_GRATE) == MAT_GRATE

		if iEnterMaterial == iExitMaterial then
			if iExitMaterial == MAT_WOOD or
				iExitMaterial == MAT_METAL then
				flPenetrationModifier = flPenetrationModifier * 2
			end
		end

		local flTraceDistance = (exitTr.HitPos - tr.HitPos):Length()

		if flTraceDistance > ( flPenetrationPower * flPenetrationModifier ) then
			break
		end

		if bDoEffects then
			util.ImpactTrace(exitTr, iDamageType)
		end

		flPenetrationPower = flPenetrationPower - flTraceDistance / flPenetrationModifier
		flCurrentDistance = flCurrentDistance + flTraceDistance

		vecSrc = exitTr.HitPos
		flDistance = (flDistance - flCurrentDistance) * 0.5

		fCurrentDamage = fCurrentDamage * flDamageModifier

		iPenetration = iPenetration - 1
	end

end

/*-------------------------------------------------
	Collision Rules
-------------------------------------------------*/

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