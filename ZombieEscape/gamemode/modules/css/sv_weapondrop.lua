local Undroppable = {
	weapon_crowbar = true
}

local function DropActiveWeapon( ply, cmd, args )

	-- Only humans can drop weapons
	if not ( IsValid(ply) and ply:IsHuman() ) then return end

	-- Get out currently selected weapon
	local weap = ply:GetActiveWeapon()
	if not IsValid(weap) then return end

	-- Ignore attempt to drop weapon if it's marked as undroppable
	local class = weap:GetClass()
	if Undroppable[class] then return end

	-- Switch to weapon based on type
	local weap2
	if ply:GetPrimaryWeapon() == weap and ply:HasSecondaryWeapon() then
		weap2 = ply:GetSecondaryWeapon()
	elseif ply:GetSecondaryWeapon() == weap and ply:HasPrimaryWeapon() then
		weap2 = ply:GetPrimaryWeapon()
	else
		if ply:HasPrimaryWeapon() then
			weap2 = ply:GetPrimaryWeapon()
		elseif ply:HasSecondaryWeapon() then
			weap2 = ply:GetSecondaryWeapon()
		else
			for _, v in pairs( ply:GetWeapons() or {} ) do
				if v:GetClass() != class then
					weap2 = v
					break
				end
			end
		end
	end

	-- The player should always have a second valid weapon, but just in case..
	if not IsValid(weap2) then return end

	-- Select our other weapon
	ply:SelectWeapon( weap2:GetClass() )

	-- Drop the weapon we wanted to
	ply:DropWeapon( weap )

	-- Stupid fix for weapon not appearing after drop
	-- if not weap2:IsWeaponVisible() and weap2:IsScripted() then
	-- 	weap2:RemoveEffects( EF_NODRAW )
	-- 	weap2:Deploy()
	-- end


end
concommand.Add( "ze_dropweapon", DropActiveWeapon )