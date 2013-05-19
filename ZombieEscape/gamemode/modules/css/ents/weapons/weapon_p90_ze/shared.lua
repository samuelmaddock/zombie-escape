if SERVER then

	AddCSLuaFile()
	
else

	SWEP.PrintName			= "P90"			
	SWEP.Author				= "Counter-Strike"
	SWEP.Slot				= 3
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "m"
	
	killicon.AddFont( "weapon_p90", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
	
end

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Counter-Strike"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/cstrike/c_smg_p90.mdl"
SWEP.WorldModel			= "models/weapons/w_smg_p90.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "Weapon_P90.Single" )
SWEP.Primary.Recoil			= 0.098
SWEP.Primary.Damage			= 30
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.032
SWEP.Primary.ClipSize		= 50
SWEP.Primary.Delay			= 0.07
SWEP.Primary.DefaultClip	= 90
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ammo_57mm"