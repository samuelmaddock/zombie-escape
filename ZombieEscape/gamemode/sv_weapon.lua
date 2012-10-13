util.AddNetworkString("ReceiveWeapon")

function GM:OnRequestWeapon(ply, class)

	if !ply:Alive() or !ply:IsHuman() or !ply:CanBuyWeapons() then return end

	local weapon = self:GetWeaponByClass(class)
	if !weapon then return end

	if !ply.Weapons then
		ply.Weapons = {}
	end

	-- Select a primary weapon before secondary
	if weapon.type == WEAPON_SECONDARY and !ply.Weapons[WEAPON_PRIMARY] then
		return
	end

	-- Strip previous weapon selection
	if ply.Weapons[weapon.type] then
		ply:StripWeapon(ply.Weapons[weapon.type])
	end

	-- Give requested weapon
	ply:StripWeapon(weapon.class)
	ply:Give(weapon.class)

	ply:ResetAmmo()

	-- Select new weapon
	ply:SelectWeapon(weapon.class)

	-- Save new weapon
	ply.Weapons[weapon.type] = weapon.class

	net.Start("ReceiveWeapon")
		-- 3 weapon types, 0x?? (0, 1, 2, 3)
		net.WriteUInt(weapon.type, 2)
	net.Send(ply)

end

concommand.Add("ze_selectweapon", function(ply,cmd,args)

	local class = args[1]
	if !IsValid(ply) or !class then return end

	GAMEMODE:OnRequestWeapon(ply, class)

end)