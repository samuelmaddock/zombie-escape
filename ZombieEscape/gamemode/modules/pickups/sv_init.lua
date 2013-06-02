/*---------------------------------------------------------
	Replace common CS:S weapons with pickup weapon

	Some ZE maps include player pickups which make use
	of weapons, which are unnecessary (ie. providing an
	additional weapon and ammo).
---------------------------------------------------------*/
/*local pickups = { "weapon_deagle", "weapon_elite","weapon_glock" }
function GM:SetupEntityFixes()

	-- Replace weapons with pickup entities
	for _, weapon in pairs(pickups) do

		weapons.Remove(weapon) -- make sure it's only a sent

		local swep = scripted_ents.Get("weapon_pickup")
		scripted_ents.Register(swep,weapon,true)

		scripted_ents.Alias(weapon, "weapon_pickup")

	end

end*/

hook.Add( "Initialize", "SetupPickupEntities", function()

	for _, weapon in pairs( { "weapon_knife" } ) do
		scripted_ents.Alias( weapon, "weapon_deagle" )
	end

end )

/*---------------------------------------------------------
	Key Value Fixes
---------------------------------------------------------*/
hook.Add( "EntityKeyValue", "MarkPickupEntities", function(ent, key, value)
	
	-- Mark pickup function weapons to not be removed
	if key == "OnPlayerPickup" then
		ent.OnPlayerPickup = value
	end

end )

concommand.Add( "ze_dropentity", function(ply,cmd,args)

	if !IsValid(ply) then return end
	
	ply:DropPickupEntity()

end )