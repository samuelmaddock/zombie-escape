

// Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_grenade.mdl"
SWEP.WorldModel		= "models/weapons/w_grenade.mdl"
SWEP.AnimPrefix		= "Grenade"
SWEP.HoldType		= "grenade"

// Note: This is how it should have worked. The base weapon would set the category
// then all of the children would have inherited that.
// But a lot of SWEPS have based themselves on this base (probably not on purpose)
// So the category name is now defined in all of the child SWEPS.
//SWEP.Category					= "Half-Life 2";
SWEP.m_bFiresUnderwater			= false;
SWEP.m_flNextPrimaryAttack		= CurTime();
SWEP.m_flNextSecondaryAttack	= CurTime();
SWEP.m_flSequenceDuration		= 0.0;

GRENADE_TIMER	= 2.5 //Seconds

GRENADE_PAUSED_NO			= 0
GRENADE_PAUSED_PRIMARY		= 1
GRENADE_PAUSED_SECONDARY	= 2

GRENADE_RADIUS	= 4.0 // inches

GRENADE_DAMAGE_RADIUS = 250.0

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Special1		= Sound( "common/null.wav" )
SWEP.Primary.Sound			= Sound( "common/null.wav" )
SWEP.Primary.Damage			= 150
SWEP.Primary.NumShots		= 1
SWEP.Primary.NumAmmo		= SWEP.Primary.NumShots
SWEP.Primary.Cone			= vector_origin
SWEP.Primary.ClipSize		= -1				// Size of a clip
SWEP.Primary.Delay			= 0.5
SWEP.Primary.DefaultClip	= 1					// Default number of bullets in a clip
SWEP.Primary.Automatic		= false				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "grenade"
SWEP.Primary.AmmoType		= "npc_grenade_frag"

SWEP.Secondary.Sound		= Sound( "common/null.wav" )
SWEP.Secondary.ClipSize		= -1				// Size of a clip
SWEP.Secondary.DefaultClip	= -1				// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
SWEP.Secondary.Ammo			= "None"

FLT_MAX = 3.402823466e+38

/*---------------------------------------------------------
   Name: SWEP:Precache( )
   Desc: Use this function to precache stuff
---------------------------------------------------------*/
function SWEP:Precache()

	self.BaseClass:Precache();

	util.PrecacheSound( "WeaponFrag.Throw" );
	util.PrecacheSound( "WeaponFrag.Roll" );

end

//if ( !CLIENT ) then
//-----------------------------------------------------------------------------
// Purpose:
// Input  : *pEvent -
//			*pOperator -
//-----------------------------------------------------------------------------
function SWEP:Operator_HandleAnimEvent( pEvent, pOperator )

	if ( self.fThrewGrenade ) then
		return;
	end

	local pOwner = self.Owner;
	self.fThrewGrenade = false;

	if( pEvent ) then
		if pEvent == "EVENT_WEAPON_SEQUENCE_FINISHED" then
			self.m_fDrawbackFinished = true;
			return;

		elseif pEvent == "EVENT_WEAPON_THROW" then
			self:ThrowGrenade( pOwner );
			self:DecrementAmmo( pOwner );
			self.fThrewGrenade = true;
			return;

		elseif pEvent == "EVENT_WEAPON_THROW2" then
			self:RollGrenade( pOwner );
			self:DecrementAmmo( pOwner );
			self.fThrewGrenade = true;
			return;

		elseif pEvent == "EVENT_WEAPON_THROW3" then
			self:LobGrenade( pOwner );
			self:DecrementAmmo( pOwner );
			self.fThrewGrenade = true;
			return;

		else
			return;
		end
	end

local RETHROW_DELAY	= self.Primary.Delay
	if( self.fThrewGrenade ) then
		self.Weapon:SetNextPrimaryFire( CurTime() + RETHROW_DELAY );
		self.Weapon:SetNextSecondaryFire( CurTime() + RETHROW_DELAY );
		self.m_flNextPrimaryAttack	= CurTime() + RETHROW_DELAY;
		self.m_flNextSecondaryAttack	= CurTime() + RETHROW_DELAY;
		self.m_flTimeWeaponIdle = FLT_MAX; //NOTE: This is set once the animation has finished up!
	end

end

//end

/*---------------------------------------------------------
   Name: SWEP:Initialize( )
   Desc: Called when the weapon is first loaded
---------------------------------------------------------*/
function SWEP:Initialize()

	if ( SERVER ) then
		self:SetNPCMinBurst( 0 )
		self:SetNPCMaxBurst( 0 )
		self:SetNPCFireRate( self.Primary.Delay )
	end

	self:SetWeaponHoldType( self.HoldType )

end


/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack( )
   Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	// Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end

	if ( self.m_bRedraw ) then
		return;
	end

	local pOwner  = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	local pPlayer = self.Owner;

	if ( !pPlayer ) then
		return;
	end

	if ( self.m_bIsUnderwater && !self.m_bFiresUnderwater ) then
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.2 );

		return;
	end

	// Note that this is a primary attack and prepare the grenade attack to pause.
	self.m_AttackPaused = GRENADE_PAUSED_PRIMARY;
	self.Weapon:SendWeaponAnim( ACT_VM_PULLBACK_HIGH );
	self.m_flSequenceDuration = CurTime() + self.Weapon:SequenceDuration();

	// Put both of these off indefinitely. We do not know how long
	// the player will hold the grenade.
	self.Weapon:SetNextPrimaryFire( FLT_MAX );
	self.m_flTimeWeaponIdle = FLT_MAX;
	self.m_flNextPrimaryAttack = FLT_MAX;

end


/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack( )
   Desc: +attack2 has been pressed
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	// Make sure we can shoot first
	if ( !self:CanSecondaryAttack() ) then return end

	if ( self.m_bRedraw ) then
		return;
	end

	if ( self:Ammo1() <= 0 ) then
		return;
	end

	local pOwner  = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	local pPlayer = self.Owner;

	if ( pPlayer == NULL ) then
		return;
	end

	if ( self.m_bIsUnderwater && !self.m_bFiresUnderwater ) then
		self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 );

		return;
	end

	// Note that this is a secondary attack and prepare the grenade attack to pause.
	self.m_AttackPaused = GRENADE_PAUSED_SECONDARY;
	self.Weapon:SendWeaponAnim( ACT_VM_PULLBACK_LOW );
	self.m_flSequenceDuration = CurTime() + self.Weapon:SequenceDuration();

	// Don't let weapon idle interfere in the middle of a throw!
	self.Weapon:SetNextSecondaryFire( FLT_MAX );
	self.m_flTimeWeaponIdle = FLT_MAX;
	self.m_flNextSecondaryAttack	= FLT_MAX;

end

//-----------------------------------------------------------------------------
// Purpose:
// Input  : *pOwner -
//-----------------------------------------------------------------------------
function SWEP:DecrementAmmo( pOwner )

	pOwner:RemoveAmmo( self.Primary.NumAmmo, self.Primary.Ammo );

end

/*---------------------------------------------------------
   Name: SWEP:Reload( )
   Desc: Reload is being pressed
---------------------------------------------------------*/
function SWEP:Reload()

	if ( self:Ammo1() <= 0 ) then
		return false;
	end

	if ( ( self.m_bRedraw ) && ( self.m_flNextPrimaryAttack <= CurTime() ) && ( self.m_flNextSecondaryAttack <= CurTime() ) ) then
		//Redraw the weapon
		self.Weapon:SendWeaponAnim( ACT_VM_DRAW );

		//Update our times
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Weapon:SequenceDuration() );
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );
		self.m_flNextPrimaryAttack	= CurTime() + self.Weapon:SequenceDuration();
		self.m_flNextSecondaryAttack	= CurTime() + self.Weapon:SequenceDuration();
		self.m_flTimeWeaponIdle = CurTime() + self.Weapon:SequenceDuration();

		//Mark this as done
		self.m_bRedraw = false;
	end

	return true;

end


/*---------------------------------------------------------
   Name: SWEP:Think( )
   Desc: Called every frame
---------------------------------------------------------*/
function SWEP:Think()

	if ((self.fThrewGrenade && CurTime() > self.Primary.Delay)) then
		self.fThrewGrenade = false;

		//Update our times
		self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay );
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay );
		self.m_flNextPrimaryAttack = CurTime() + self.Primary.Delay;
		self.m_flNextSecondaryAttack = CurTime() + self.Primary.Delay;
		self.m_flTimeWeaponIdle = CurTime() + self.Primary.Delay;
	end

	if ((self.m_flSequenceDuration > CurTime())) then
		self:Operator_HandleAnimEvent( "EVENT_WEAPON_SEQUENCE_FINISHED" );
		self.m_flSequenceDuration = CurTime();
	end

	if( self.m_fDrawbackFinished ) then
		local pOwner = self.Owner;

		if (pOwner) then
			if( self.m_AttackPaused ) then
			if self.m_AttackPaused == GRENADE_PAUSED_PRIMARY then
				if( !(pOwner:KeyDown( IN_ATTACK )) ) then
					self.Weapon:SendWeaponAnim( ACT_VM_THROW );
					self:Operator_HandleAnimEvent( "EVENT_WEAPON_THROW" );

					//Tony; fire the sequence
					self.m_fDrawbackFinished = false;
				end
				return;

			elseif self.m_AttackPaused == GRENADE_PAUSED_SECONDARY then
				if( !(pOwner:KeyDown( IN_ATTACK2 )) ) then
					//See if we're ducking
					if ( pOwner:KeyDown( IN_DUCK ) ) then
						//Send the weapon animation
						self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK );
						self:Operator_HandleAnimEvent( "EVENT_WEAPON_THROW2" );
					else
						//Send the weapon animation
						self.Weapon:SendWeaponAnim( ACT_VM_HAULBACK );
						self:Operator_HandleAnimEvent( "EVENT_WEAPON_THROW3" );
					end

					self.m_fDrawbackFinished = false;
				end
				return;

			else
				return;
			end
			end
		end
	end

	local pPlayer = self.Owner;

	if ( !pPlayer ) then
		return;
	end

	if ( pPlayer:WaterLevel() >= 3 ) then
		self.m_bIsUnderwater = true;
	else
		self.m_bIsUnderwater = false;
	end

	if ( self.m_bRedraw ) then
		self:Reload();
	end

end


/*---------------------------------------------------------
   Name: SWEP:Deploy( )
   Desc: Whip it out
---------------------------------------------------------*/
function SWEP:Deploy()

	self.m_bRedraw = false;
	self.m_fDrawbackFinished = false;

	if self:CanPrimaryAttack() then
		self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
		self:SetDeploySpeed( self.Weapon:SequenceDuration() )
	else
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	end
	
	self:SetNextPrimaryFire(CurTime())
	self:SetNextSecondaryFire(CurTime())

	return true

end


	// check a throw from vecSrc.  If not valid, move the position back along the line to vecEye
function SWEP:CheckThrowPosition( pPlayer, vecEye, vecSrc )

	local tr;

	tr = {}
	tr.start = vecEye
	tr.endpos = vecSrc
	tr.mins = -Vector(GRENADE_RADIUS+2,GRENADE_RADIUS+2,GRENADE_RADIUS+2)
	tr.maxs = Vector(GRENADE_RADIUS+2,GRENADE_RADIUS+2,GRENADE_RADIUS+2)
	tr.mask = MASK_PLAYERSOLID
	tr.filter = pPlayer
	tr.collision = pPlayer:GetCollisionGroup()
	local trace = util.TraceHull( tr );

	if ( trace.Hit ) then
		vecSrc = tr.endpos;
	end

	return vecSrc

end

function SWEP:DropPrimedFragGrenade( pPlayer, pGrenade )

	local pWeaponFrag = pGrenade;

	if ( pWeaponFrag ) then
		self:ThrowGrenade( pPlayer );
		self:DecrementAmmo( pPlayer );
	end

end

//-----------------------------------------------------------------------------
// Purpose:
// Input  : *pPlayer -
//-----------------------------------------------------------------------------
function SWEP:ThrowGrenade( pPlayer )

	if ( self.m_bRedraw ) then
		return;
	end

if ( !CLIENT ) then
	local	vecEye = pPlayer:EyePos();
	local	vForward, vRight;

	vForward = pPlayer:GetForward();
	vRight = pPlayer:GetRight();
	local vecSrc = vecEye + vForward * 18.0 + vRight * 8.0;
	vecSrc = self:CheckThrowPosition( pPlayer, vecEye, vecSrc );
//	vForward.x = vForward.x + 0.1;
//	vForward.y = vForward.y + 0.1;

	local vecThrow;
	vecThrow = pPlayer:GetVelocity();
	vecThrow = vecThrow + vForward * 1200;
	local pGrenade = ents.Create( self.Primary.AmmoType );
	pGrenade:SetPos( vecSrc );
	pGrenade:SetAngles( Angle( 0, 0, 0 ) );
	pGrenade:SetOwner( pPlayer );
	pGrenade:Fire( "SetTimer", GRENADE_TIMER );
	pGrenade:Spawn()
	pGrenade:GetPhysicsObject():SetVelocity( vecThrow );
	pGrenade:GetPhysicsObject():AddAngleVelocity( Vector(600,math.random(-1200,1200),0) );

	if ( pGrenade ) then
		if ( pPlayer && !pPlayer:Alive() ) then
			vecThrow = pPlayer:GetVelocity();

			local pPhysicsObject = pGrenade:GetPhysicsObject();
			if ( pPhysicsObject ) then
				vecThrow = pPhysicsObject:SetVelocity();
			end
		end

		pGrenade.m_flDamage = self.Primary.Damage;
		pGrenade.m_DmgRadius = GRENADE_DAMAGE_RADIUS;
	end
end

	self.m_bRedraw = true;

	self.Weapon:EmitSound( self.Primary.Sound );

	// player "shoot" animation
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

end

//-----------------------------------------------------------------------------
// Purpose:
// Input  : *pPlayer -
//-----------------------------------------------------------------------------
function SWEP:LobGrenade( pPlayer )

	if ( self.m_bRedraw ) then
		return;
	end

if ( !CLIENT ) then
	local	vecEye = pPlayer:EyePos();
	local	vForward, vRight;

	vForward = pPlayer:GetForward();
	vRight = pPlayer:GetRight();
	local vecSrc = vecEye + vForward * 18.0 + vRight * 8.0 + Vector( 0, 0, -8 );
	vecSrc = self:CheckThrowPosition( pPlayer, vecEye, vecSrc );

	local vecThrow;
	vecThrow = pPlayer:GetVelocity();
	vecThrow = vecThrow + vForward * 350 + Vector( 0, 0, 50 );
	local pGrenade = ents.Create( self.Primary.AmmoType );
	pGrenade:SetPos( vecSrc );
	pGrenade:SetAngles( Angle( 0, 0, 0 ) );
	pGrenade:SetOwner( pPlayer );
	pGrenade:Fire( "SetTimer", GRENADE_TIMER );
	pGrenade:Spawn()
	pGrenade:GetPhysicsObject():SetVelocity( vecThrow );
	pGrenade:GetPhysicsObject():AddAngleVelocity( Vector(200,math.random(-600,600),0) );

	if ( pGrenade ) then
		pGrenade.m_flDamage = self.Primary.Damage;
		pGrenade.m_DmgRadius = GRENADE_DAMAGE_RADIUS;
	end
end

	self.Weapon:EmitSound( self.Secondary.Sound );

	// player "shoot" animation
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	self.m_bRedraw = true;

end

//-----------------------------------------------------------------------------
// Purpose:
// Input  : *pPlayer -
//-----------------------------------------------------------------------------
function SWEP:RollGrenade( pPlayer )

	if ( self.m_bRedraw ) then
		return;
	end

if ( !CLIENT ) then
	// BUGBUG: Hardcoded grenade width of 4 - better not change the model :)
	local vecSrc;
	vecSrc = pPlayer:GetPos();
	vecSrc.z = vecSrc.z + GRENADE_RADIUS;

	local vecFacing = pPlayer:GetAimVector( );
	// no up/down direction
	vecFacing.z = 0;
	vecFacing = VectorNormalize( vecFacing );
	local tr;
	tr = {};
	tr.start = vecSrc;
	tr.endpos = vecSrc - Vector(0,0,16);
	tr.mask = MASK_PLAYERSOLID;
	tr.filter = pPlayer;
	tr.collision = COLLISION_GROUP_NONE;
	tr = util.TraceLine( tr );
	if ( tr.Fraction != 1.0 ) then
		// compute forward vec parallel to floor plane and roll grenade along that
		local tangent;
		tangent = CrossProduct( vecFacing, tr.HitNormal );
		vecFacing = CrossProduct( tr.HitNormal, tangent );
	end
	vecSrc = vecSrc + (vecFacing * 18.0);
	vecSrc = self:CheckThrowPosition( pPlayer, pPlayer:GetPos(), vecSrc );

	local vecThrow;
	vecThrow = pPlayer:GetVelocity();
	vecThrow = vecThrow + vecFacing * 700;
	// put it on its side
	local orientation = Angle(0,pPlayer:GetLocalAngles().y,-90);
	// roll it
	local rotSpeed = Vector(0,0,720);
	local pGrenade = ents.Create( self.Primary.AmmoType );
	pGrenade:SetPos( vecSrc );
	pGrenade:SetAngles( orientation );
	pGrenade:SetOwner( pPlayer );
	pGrenade:Fire( "SetTimer", GRENADE_TIMER );
	pGrenade:Spawn();
	pGrenade:GetPhysicsObject():SetVelocity( vecThrow );
	pGrenade:GetPhysicsObject():AddAngleVelocity( rotSpeed );

	if ( pGrenade ) then
		pGrenade.m_flDamage = self.Primary.Damage;
		pGrenade.m_DmgRadius = GRENADE_DAMAGE_RADIUS;
	end

end

	self.Weapon:EmitSound( self.Primary.Special1 );

	// player "shoot" animation
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	self.m_bRedraw = true;

end

/*---------------------------------------------------------
   Name: SWEP:CanPrimaryAttack( )
   Desc: Helper function for checking for no ammo
---------------------------------------------------------*/
function SWEP:CanPrimaryAttack()
	return self.Owner.GetAmmoCount and self.Owner:GetAmmoCount("Grenade") > 0
end


/*---------------------------------------------------------
   Name: SWEP:CanSecondaryAttack( )
   Desc: Helper function for checking for no ammo
---------------------------------------------------------*/
function SWEP:CanSecondaryAttack()
	return self:CanPrimaryAttack()
end


/*---------------------------------------------------------
   Name: SetDeploySpeed
   Desc: Sets the weapon deploy speed.
		 This value needs to match on client and server.
---------------------------------------------------------*/
function SWEP:SetDeploySpeed( speed )

	self.m_WeaponDeploySpeed = tonumber( speed )

	self.Weapon:SetNextPrimaryFire( CurTime() + speed )
	self.Weapon:SetNextSecondaryFire( CurTime() + speed )

end
