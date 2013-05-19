if SERVER then

	AddCSLuaFile()

else

	SWEP.PrintName			= "Deagle"			
	SWEP.Author				= "Counter-Strike"

	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "f"
	
	killicon.AddFont( "weapon_deagle", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end

SWEP.HoldType			= "pistol"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Counter-Strike"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel			= "models/weapons/w_pist_deagle.mdl"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "Weapon_Deagle.Single" )
SWEP.Primary.Recoil			= 2.5
SWEP.Primary.Damage			= 60
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.ClipSize		= 8
SWEP.Primary.Delay			= 0.3
SWEP.Primary.DefaultClip	= 48
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "ammo_50AE"