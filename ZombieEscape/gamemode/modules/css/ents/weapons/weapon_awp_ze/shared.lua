if SERVER then

	AddCSLuaFile()

else

	SWEP.PrintName			= "AWP"
	SWEP.Author				= "Counter-Strike"

	SWEP.Slot				= 3
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "n"

	killicon.AddFont( "weapon_awp_ze", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end

SWEP.HoldType			= "ar2"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Counter-Strike"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.WorldModel			= "models/weapons/w_snip_awp.mdl"

SWEP.Weight				= 30
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "Weapon_Awp.Single" )
SWEP.Primary.Recoil			= 8.5
SWEP.Primary.Damage			= 115
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.01
SWEP.Primary.ClipSize		= 10
SWEP.Primary.Delay			= 1.4
SWEP.Primary.DefaultClip	= 48
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "ammo_338mag"

SWEP.Zoom = {}
SWEP.Zoom.Level = 2

function SWEP:CanSecondaryAttack()
	return true
end