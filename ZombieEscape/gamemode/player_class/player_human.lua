AddCSLuaFile()
DEFINE_BASECLASS( "player_default" )

if ( CLIENT ) then

	CreateConVar( "cl_playercolor", "0.24 0.34 0.41", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The value is a Vector - so between 0-1 - not between 0-255" )
	-- CreateConVar( "cl_weaponcolor", "0.30 1.80 2.10", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The value is a Vector - so between 0-1 - not between 0-255" )

end

local PLAYER = {}

PLAYER.DisplayName			= "Human"

PLAYER.WalkSpeed 			= 200		-- How fast to move when not running
PLAYER.RunSpeed				= 300		-- How fast to move when running
PLAYER.CrouchedWalkSpeed 	= 0.2		-- Multiply move speed by this when crouching
PLAYER.DuckSpeed			= 0.3		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed			= 0.3		-- How fast to go from ducking, to not ducking
PLAYER.JumpPower			= 200		-- How powerful our jump should be
PLAYER.CanUseFlashlight     = true		-- Can we use the flashlight
PLAYER.MaxHealth			= 100		-- Max health we can have
PLAYER.StartHealth			= 100		-- How much health we start with
PLAYER.StartArmor			= 0			-- How much armour we start with
PLAYER.DropWeaponOnDie		= false		-- Do we drop our weapon when we die
PLAYER.TeammateNoCollide 	= true		-- Do we collide with teammates or run straight through them
PLAYER.AvoidPlayers			= true		-- Automatically swerves around other players


--
-- Set up the network table accessors
--
function PLAYER:SetupDataTables()
	self.Player:DTVar("Int", 0, "Location")
end

--
-- Called when the class object is created (shared)
--
function PLAYER:Init()

end

--
-- Called serverside only when the player spawns
--
function PLAYER:Spawn()

	-- Set player color
	local col = self.Player:GetInfo( "cl_playercolor" )
	self.Player:SetPlayerColor( Vector( col ) )

	self.Player:SetSpeed(self.CVars.HumanSpeed:GetInt())

	-- Set player to random citizen model
	local mdl = player_manager.TranslatePlayerModel( table.Random(self.ValidHumans) )
	self.Player:SetModel(mdl)

	-- Give basic weapons
	for _, weapon in pairs(self:GetWeaponsByType(WEAPON_ADDON)) do
		self.Player:Give(weapon.class)
	end

	self.Player:SelectWeapon("weapon_crowbar")
	
	-- Give ammo
	self.Player:ResetAmmo()

	-- Display weapons menu on first spawn
	if !self.Player.Weapons then

		self.Player:WeaponMenu()

	else

		self.Player:SendMessage("Press F3 at spawn to open the weapon selection menu")

		-- Give selected weapons
		timer.Simple(0.1, function()
			for type, weapon in pairs(self.Player.Weapons) do
				self.Player:Give(weapon)
			end
			self.Player:SelectWeapon(self.Player.Weapons[WEAPON_PRIMARY])
		end)

	end

end

--
-- Called on spawn to give the player their default loadout
--
function PLAYER:Loadout()

	self.Player:RemoveAllAmmo()

	if game.SinglePlayer() then
		-- self.Player:Give( "weapon_physgun" )
	end

	self.Player:SwitchToDefaultWeapon()

end

player_manager.RegisterClass( "player_human", PLAYER, nil )