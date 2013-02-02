AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "Human"
PLAYER.StartArmor			= 100

--
-- Called serverside only when the player spawns
--
function PLAYER:Spawn()

	/*-- Set player color
	local col = self.Player:GetInfo( "cl_playercolor" )
	self.Player:SetPlayerColor( Vector( col ) )*/

	self.Player:RemoveAllItems()

	self.Player:SetSpeed( CVars.HumanSpeed:GetInt() )

	-- Set player to random citizen model
	local mdl = player_manager.TranslatePlayerModel( table.Random(GAMEMODE.ValidHumans) )
	self.Player:SetModel(mdl)

	-- Display weapons menu on first spawn
	if !self.Player.Weapons then
		self.Player:WeaponMenu()
	else

		-- Give selected weapons
		timer.Simple(0.1, function()

			for type, weapon in pairs(self.Player.Weapons) do
				self.Player:Give(weapon)
			end

			self.Player:SelectWeapon(self.Player.Weapons[WEAPON_PRIMARY])
			self.Player:SendMessage("Press B at spawn to open the weapon selection menu")

		end)

	end

end

--
-- Called on spawn to give the player their default loadout
--
function PLAYER:Loadout()

	self.Player:RemoveAllAmmo()
	self.Player:SwitchToDefaultWeapon()

	-- Give basic weapons
	for _, weapon in pairs( GAMEMODE:GetWeaponsByType(WEAPON_ADDON) ) do
		self.Player:Give(weapon.class)
	end

	self.Player:SelectWeapon("weapon_crowbar")
	
	-- Give ammo
	self.Player:ResetAmmo()

end

player_manager.RegisterClass( "player_human", PLAYER, "player_ze" )