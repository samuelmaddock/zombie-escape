if SERVER then
	AddCSLuaFile( "shared.lua" )
end

if CLIENT then
	SWEP.PrintName	= "Dual Elites"			
	SWEP.Author			= "Counter-Strike"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 3
	SWEP.IconLetter	= "s"
	SWEP.ViewModelFlip = false
	
	killicon.AddFont( "weapon_elite", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )
end

SWEP.HoldType			= "duel"
SWEP.Base				= "weapon_cs_base"
SWEP.Category			= "Counter-Strike"

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= Model("models/weapons/v_pist_elite.mdl")
SWEP.WorldModel			= Model("models/weapons/w_pist_elite.mdl")

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Sound			= Sound( "Weapon_Elite.Single" )
SWEP.Primary.Recoil			= 1.2
SWEP.Primary.Damage			= 15
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.04
SWEP.Primary.ClipSize		= 15
SWEP.Primary.Delay			= 0.15
SWEP.Primary.DefaultClip	= 15
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"

SWEP.Secondary.Sound			= Sound( "Weapon_Elite.Single" )
SWEP.Secondary.Recoil			= 1.2
SWEP.Secondary.Damage			= 15
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0.04
SWEP.Secondary.ClipSize		= 15
SWEP.Secondary.Delay			= 0.15
SWEP.Secondary.DefaultClip	= 15
SWEP.Secondary.Automatic		= false
SWEP.Secondary.Ammo			= "pistol"

SWEP.IronSightsPos 		= nil

function SWEP:Initialize()

	if ( SERVER ) then
		self:SetNPCMinBurst( 30 )
		self:SetNPCMaxBurst( 30 )
		self:SetNPCFireRate( 0.01 )
	end
	
	self:SetWeaponHoldType( self.HoldType )
	self.Weapon:SetNetworkedBool( "Ironsights", false )
	
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if ( !self:CanPrimaryAttack() ) then return end
	
	// Play shoot sound
	self.Weapon:EmitSound( self.Primary.Sound )
	
	// Shoot the bullet
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone, true )
	
	// Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	
	// In singleplayer this function doesn't get called on the client, so we use a networked float
	// to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	// send the float.
	if ( (SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
	
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	
	if ( !self:CanSecondaryAttack() ) then return end
	
	// Play shoot sound
	self.Weapon:EmitSound( self.Secondary.Sound )
	
	// Shoot the bullet
	self:CSShootBullet( self.Secondary.Damage, self.Secondary.Recoil, self.Secondary.NumShots, self.Secondary.Cone, false )
	
	// Remove 1 bullet from our clip
	self:TakeSecondaryAmmo( 1 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Secondary.Recoil, math.Rand(-0.1,0.1) *self.Secondary.Recoil, 0 ) )
	
	// In singleplayer this function doesn't get called on the client, so we use a networked float
	// to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	// send the float.
	if ( (SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
	
end

/*---------------------------------------------------------
   Name: SWEP:CSShootBullet( )
---------------------------------------------------------*/
function SWEP:CSShootBullet( dmg, recoil, numbul, cone, bPrimary )

	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01

	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()			// Source
	bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
	bullet.Spread 	= Vector( cone, cone, 0 )			// Aim Cone
	bullet.Tracer	= 4									// Show a tracer on every x bullets 
	bullet.Force	= 5									// Amount of force to give to phys objects
	bullet.Damage	= dmg
	
	self.Owner:FireBullets( bullet )
	if bPrimary then
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	else
		self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	end
	self.Owner:MuzzleFlash()								// Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				// 3rd Person Animation
	
	if ( self.Owner:IsNPC() ) then return end
	
	// CUSTOM RECOIL !
	if ( (SinglePlayer() && SERVER) || ( !SinglePlayer() && CLIENT && IsFirstTimePredicted() ) ) then
	
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self.Owner:SetEyeAngles( eyeang )
	
	end

end