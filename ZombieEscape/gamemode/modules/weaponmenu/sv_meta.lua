local PlayerMeta = FindMetaTable("Player")

util.AddNetworkString("SelectWeapons")
util.AddNetworkString("CloseWeaponSelection")

function PlayerMeta:CanBuyWeapons()
	return self:IsHuman() and (
		( !self.Weapons or !self.Weapons[1] or !self.Weapons[2] ) or
		self.IsInBuyzone or !CVars.Buyzone:GetBool() )
end

function PlayerMeta:WeaponMenu()
	net.Start("SelectWeapons")
	net.Send(self)
end

function PlayerMeta:CloseWeaponMenu()
	net.Start("CloseWeaponSelection")
	net.Send(self)
end

function PlayerMeta:GiveWeapons()

	hook.Call( "PlayerLoadout", GAMEMODE, self )

	if !self.Weapons then return end
	
	for id, class in pairs(self.Weapons) do
		GAMEMODE:OnRequestWeapon(self, class, true)
	end

end

function PlayerMeta:GetWeaponTier(tier)
	for _, v in pairs( self:GetWeapons() or {} ) do
		if self.Weapons[tier] == v:GetClass() then
			return v
		end
	end
end

function PlayerMeta:SelectPrimaryWeapon()
	local weapon = self:GetWeaponTier(WEAPON_PRIMARY)
	if IsValid(weapon) then
		self:SelectWeapon( weapon:GetClass() )
	end
end

function PlayerMeta:SelectSecondaryWeapon()
	local weapon = self:GetWeaponTier(WEAPON_SECONDARY)
	if IsValid(weapon) then
		self:SelectWeapon( weapon:GetClass() )
	end
end

function PlayerMeta:GetPrimaryWeapon()
	return self:GetWeaponTier(WEAPON_PRIMARY)
end

function PlayerMeta:GetSecondaryWeapon()
	return self:GetWeaponTier(WEAPON_SECONDARY)
end

function PlayerMeta:HasWeaponTier(tier)
	return IsValid( self:GetWeaponTier(tier) )
end

function PlayerMeta:HasPrimaryWeapon()
	return self:HasWeaponTier(WEAPON_PRIMARY)
end

function PlayerMeta:HasSecondaryWeapon()
	return self:HasWeaponTier(WEAPON_SECONDARY)
end

function PlayerMeta:HasAddonWeapon()
	return self:HasWeaponTier(WEAPON_ADDON)
end