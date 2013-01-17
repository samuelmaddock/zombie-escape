
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
include( "ai_translations.lua" )

SWEP.Weight				= 1			// Decides whether we should switch from/to this
SWEP.AutoSwitchTo		= true		// Auto switch to if we pick it up
SWEP.AutoSwitchFrom		= true		// Auto switch from if you pick up a better weapon

/*---------------------------------------------------------
   Name: OnDrop
   Desc: Weapon was dropped
---------------------------------------------------------*/
function SWEP:OnDrop()

	local pOwner  = self.Owner;

	if ( pOwner == NULL ) then
		return;
	end

	if ( pOwner:KeyDown( IN_ATTACK ) || pOwner:KeyDown( IN_ATTACK2 ) ) then
		self:DropPrimedFragGrenade( pOwner, self.Weapon )
	end

end
