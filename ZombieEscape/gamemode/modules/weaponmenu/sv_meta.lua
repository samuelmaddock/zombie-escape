local PlayerMeta = FindMetaTable("Player")

util.AddNetworkString("SelectWeapons")
util.AddNetworkString("CloseWeaponSelection")

function PlayerMeta:CanBuyWeapons()
	return self:IsHuman() and ( ( !self.Weapons or !self.Weapons[1] or !self.Weapons[2] ) or
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