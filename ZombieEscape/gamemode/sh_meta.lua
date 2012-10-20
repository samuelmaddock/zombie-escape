local EntityMeta = FindMetaTable("Entity")

function EntityMeta:HasTargetName()
	return self:GetName() != ""
end

function EntityMeta:EmitRandomSound(SoundTable)
	if !SoundTable or type(SoundTable) != 'table' or #SoundTable < 1 then return end
	self:EmitSound( table.Random(SoundTable) )
end

function EntityMeta:GetChildren()
	local tbl = {}
	for _, ent in pairs(ents.GetAll()) do
		if IsValid(ent) and IsValid(ent:GetParent()) and ent:GetParent() == self then
			table.insert(tbl, ent)
		end
	end
	return tbl
end

function EntityMeta:IsPressed()
	local value = self:GetSaveTable()["m_toggle_state"]
	return value and value == 0
end

local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:IsSpectator()
	return self:Team() == TEAM_SPECTATOR
end

function PlayerMeta:IsHuman()
	return self:Team() == TEAM_HUMANS
end

function PlayerMeta:IsZombie()
	return self:Team() == TEAM_ZOMBIES
end

if SERVER then

	util.AddNetworkString("SelectWeapons")
	util.AddNetworkString("CloseWeaponSelection")

	function PlayerMeta:Zombify()
		
		-- Zombies shouldn't be holding ZE map/weapon pickups
		local pickup = self:GetPickupEntity()
		if IsValid(pickup) then
			pickup:Remove()
		end
		
		self.bMotherZombie = false
		self:GoTeam(TEAM_ZOMBIES, true) -- respawning causes stuck issues
		GAMEMODE:ZombieSpawn(self)
		
		GAMEMODE:RoundChecks() -- check for winner

	end

	function PlayerMeta:ZScream()
		self:EmitSound( GAMEMODE.ZombieScream )
		self.LastScream = CurTime()
	end

	function PlayerMeta:ZMoan()
		self:EmitRandomSound(GAMEMODE.ZombieMoan)
		self.NextMoan = CurTime() + math.random(30,90)
	end

	function PlayerMeta:IsMotherZombie()
		return self:IsZombie() and self.bMotherZombie
	end

	function PlayerMeta:GoTeam(teamId, bNoRespawn)

		if !teamId then return end
		
		if self:Team() != teamId then
			self:SetTeam(teamId)
		end

		if !bNoRespawn then

			if IsValid(self:GetPickupEntity()) then
				self:DropPickupEntity()
			end

			self:Spawn()

			timer.Simple(3, function()
				if IsValid(self) then
					self.SpawnInfo = { pos = self:GetPos() }
				end
			end)
			
		end

	end

	function PlayerMeta:ResetAmmo()

		self:StripAmmo()

		local ammo = GAMEMODE.CVars.Ammo:GetInt()
		for _, type in pairs(GAMEMODE.AmmoTypes) do
			self:GiveAmmo(ammo, type, true)
		end

		local prevweap = self:GetActiveWeapon()

		self:GiveAmmo(1,"Grenade",true) -- give grenade

		-- Grenade automatically selects weapon_frag
		if IsValid(prevweap) then
			self:SelectWeapon(prevweap:GetClass())
		end
		
	end

	function PlayerMeta:CanBuyWeapons()
		return self:IsHuman() and ( ( !self.Weapons or !self.Weapons[1] or !self.Weapons[2] ) or
			self.IsInBuyzone or !GAMEMODE.CVars.Buyzone:GetBool() )
	end

	function PlayerMeta:WeaponMenu()
		net.Start("SelectWeapons")
		net.Send(self)
	end

	function PlayerMeta:CloseWeaponMenu()
		net.Start("CloseWeaponSelection")
		net.Send(self)
	end

	function PlayerMeta:SetSpeed(speed, crouchSpeed)
		self:SetWalkSpeed(speed)
		self:SetRunSpeed(speed)

		if crouchSpeed then
			self:SetCrouchedWalkSpeed(crouchSpeed)
		end
	end

	function PlayerMeta:SendMessage(str)
		if !str then return end
		net.Start("MapMessage")
			net.WriteString(str)
		net.Send(self)
	end

	function PlayerMeta:CanPickupEntity()
		return self:IsHuman() and !IsValid(self.PickupEntity)
	end

	function PlayerMeta:GetPickupEntity()
		return self.PickupEntity
	end

	function PlayerMeta:SetPickupEntity(ent)
		self.PickupEntity = ent
		ent.TeamOnPickup = self:Team()
		ent:SetOwner(self)
	end

	function PlayerMeta:DropPickupEntity()

		local ent = self:GetPickupEntity()
		if !IsValid(ent) then return end

		ent:OnDrop()

		self.PickupEntity = nil

	end

	function PlayerMeta:GetKnockbackMultiplier()
		if self:IsZombie() then
			return self:IsMotherZombie() and GAMEMODE.CVars.ZMotherKnockback:GetFloat() or GAMEMODE.CVars.ZKnockback:GetFloat()
		else
			return 0.0 -- shouldn't be affected by knockback if player isn't a zombie
		end
	end

end

local function TraceToExit( trace )
	local flDistance = 0
	local last = trace.vecStart
	local vecEnd

	while flDistance <= trace.flMaxDistance do
		flDistance = flDistance + trace.flStepSize
		vecEnd = trace.vecStart + flDistance * trace.dir

		if bit.band(util.PointContents(vecEnd), MASK_SOLID) == MASK_SOLID then
			return vecEnd
		end
	end

	return false
end

function PlayerMeta:FireBullets( bullet )

	-- Not sure if these are correct
	local flDistance = 6000
	local flRangeModifier = 1.0
	local iPenetration = 2
	local bDoEffects = CLIENT

	local fCurrentDamage = bullet.Damage
	local flCurrentDistance = 0.0

	local vecDirShooting = bullet.Dir
	local vecRight = bullet.Dir
	local vecUp = bullet.Dir

	local weap = self:GetActiveWeapon()
	if !IsValid(weap) then return end

	local flPenetrationPower = weap.PenetrationPower
	local flPenetrationDistance = weap.PenetrationDistance
	local flDamageModifier = 0.5
	local flPenetrationModifier = 1.0

	math.randomseed(CurTime())
	local x = math.Rand(-0.5, 0.5) + math.Rand(-0.5, 0.5)
	local y = math.Rand(-0.5, 0.5) + math.Rand(-0.5, 0.5)

	local vecDir = vecDirShooting +
		x * bullet.Spread * vecRight +
		y * bullet.Spread * vecUp

	vecDir = vecDir:GetNormal()

	local bFirstHit = true

	local lastPlayerHit

	while fCurrentDamage > 0 do
		local vecEnd = bullet.Src + vecDir * flDistance

		local tr = util.TraceLine({
			start = bullet.Src,
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

		if SERVER then
			-- create bullet_impact
		end

		local iEnterMaterial = tr.MatType

		local hitGrate = bit.band(iEnterMaterial, MAT_GRATE) == MAT_GRATE

		if hitGrate then
			flPenetrationModifier = 1.0
			flDamageModifier = 0.99
			Msg("BULLET: HIT GRATE\n")
		end

		flCurrentDistance = flCurrentDistance + tr.Fraction * flDistance
		fCurrentDamage = fCurrentDamage * math.pow(flRangeModifier, (flCurrentDistance / 500))

		if flCurrentDistance > flPenetrationDistance and iPenetration > 0 then
			iPenetration = 0
		end

		if SERVER then
			-- bullet impact sound
		end

		local iDamageType = bit.bor(DMG_BULLET, DMG_NEVERGIB)

		if bDoEffects then
			if bit.band(util.PointContents(tr.HitPos), bit.bor(CONTENTS_WATER,CONTENTS_SLIME)) != 0 then
				Msg("BULLET: Hit water\n")
				local waterTrace = util.TraceLine({
					start = bullet.Src,
					endpos = tr.HitPos,
					filter = self,
					mask = bit.bor(MASK_SHOT,CONTENTS_WATER,CONTENTS_SLIME)
				})

				if waterTrace.Hit then
					local data = EffectData()
					data:SetOrigin(waterTrace.HitPos)
					data:SetNormal(waterTrace.HitNormal)
					data:SetScale(math.Rand(8,12))

					if bit.band(waterTrace.MatType, MAT_SLOSH) != 0 then
						data:SetFlags(0x1) -- FX_WATER_IN_SLIME
					end

					util.Effect( "gunshotsplash", data )
					Msg("BULLET: Splashed\n")
				end
			else
				Msg("BULLET: Hit solid\n")
				if !tr.HitNonWorld and !tr.HitSky and !tr.HitNoDraw then
					Msg("BULLET: Hit non-nodraw surface\n")
					local ent = tr.Entity
					if IsValid(ent) and !(ent:IsPlayer() and ent:Team() == LocalPlayer():Team()) then
						Msg("BULLET: Hit non-team-player\n")
						util.ImpactTrace(tr, iDamageType)
					end
				end
			end
		end

		if SERVER then
			local dmginfo = DamageInfo()
			dmginfo:SetAttacker(self)
			dmginfo:SetInflictor(self)
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
			util.ImpactTrace(tr, iDamageType)
		end

		flPenetrationPower = flPenetrationPower - flTraceDistance / flPenetrationModifier
		flCurrentDistance = flCurrentDistance + flTraceDistance

		bullet.Src = exitTr.HitPos
		flDistance = (flDistance - flCurrentDistance) * 0.5

		fCurrentDamage = fCurrentDamage * flDamageModifier

		iPenetration = iPenetration - 1
	end

end