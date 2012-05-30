GM.CVars.HumanSpeed	= CreateConVar( "ze_human_speed", 250, {FCVAR_REPLICATED}, "Speed at which the humans move in units/sec." )
GM.CVars.Ammo		= CreateConVar( "ze_ammo", 800, {FCVAR_REPLICATED}, "Amount of ammo to give humans." )
GM.CVars.Buyzone 	= CreateConVar( "ze_buyzone", 1, {FCVAR_REPLICATED}, "Whether or not players may purchase weapons only in a buyzone." )

GM.AmmoTypes = {"smg1","pistol","357","ar2","buckshot","sniperround"}
GM.ValidHumans = {"male14","male18","male12","male17","male13","male10","male16","male15","male11",
	"female8","female9","female10","female11","female12","female7"}

function GM:HumanSpawn( ply )

	if !IsValid(ply) then return end

	ply:SetSpeed(self.CVars.HumanSpeed:GetInt())

	-- Set player to random citizen model
	local mdl = player_manager.TranslatePlayerModel( table.Random(self.ValidHumans) )
	ply:SetModel(mdl)

	-- Give basic weapons
	for _, weapon in pairs(self:GetWeaponsByType(WEAPON_ADDON)) do
		ply:Give(weapon.class)
	end

	ply:SelectWeapon("weapon_crowbar")
	
	-- Give ammo
	ply:ResetAmmo()

	-- Display weapons menu on first spawn
	if !ply.Weapons then

		ply:WeaponMenu()

	else

		ply:SendMessage("Press F3 at spawn to open the weapon selection menu")

		-- Give selected weapons
		timer.Simple(0.1, function()
			for type, weapon in pairs(ply.Weapons) do
				ply:Give(weapon)
			end
			ply:SelectWeapon(ply.Weapons[WEAPON_PRIMARY])
		end)

	end

end