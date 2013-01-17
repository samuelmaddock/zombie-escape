/*---------------------------------------------------------
	Falling Damage
---------------------------------------------------------*/
local CS_PLAYER_FATAL_FALL_SPEED = 1100	// approx 60 feet
local CS_PLAYER_MAX_SAFE_FALL_SPEED = 580		// approx 20 feet
local CS_DAMAGE_FOR_FALL_SPEED = (100 / ( CS_PLAYER_FATAL_FALL_SPEED - CS_PLAYER_MAX_SAFE_FALL_SPEED )) // damage per unit per second. 
function GM:GetFallDamage(ply, speed)
	speed = speed - CS_PLAYER_MAX_SAFE_FALL_SPEED
	return speed * CS_DAMAGE_FOR_FALL_SPEED * 1.25
end

/*---------------------------------------------------------
	Replace common CS:S weapons with pickup weapon

	Some ZE maps include player pickups which make use
	of weapons, which are unnecessary (ie. providing an
	additional weapon and ammo).
---------------------------------------------------------*/

local remove = {
	"weapon_awp", "weapon_m3", "weapon_m249",
	"weapon_p228", "weapon_usp", "weapon_p90",
	"weapon_mp5navy", "weapon_ump45", "weapon_xm1014",
	"weapon_sg550", "weapon_g3sg1", "info_ladder"
}

hook.Add( "Initialize", "InitWeaponFixes", function()

	-- Create useless entities for unwanted entities
	for _, entity in pairs(remove) do
		scripted_ents.Register({Type="point"}, entity, true)
	end

end )