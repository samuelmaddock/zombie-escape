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

		ent:SetOwner(NULL)
		ent:SetParent(NULL)
		ent:OnDrop(self)

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