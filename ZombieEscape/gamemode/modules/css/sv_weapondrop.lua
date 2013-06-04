local function DropActiveWeapon( ply, cmd, args )

	if not ( IsValid(ply) and ply:IsHuman() ) then return end

	local weap = ply:GetActiveWeapon()
	if not IsValid(weap) then return end
	if weap:GetClass() == "weapon_crowbar" then return end

	ply:DropWeapon( weap )

	weap = ply:GetActiveWeapon()
	if not IsValid(weap) then return end
	
	-- Stupid fix for weapon not appearing after drop
	if not weap:IsWeaponVisible() and weap:IsScripted() then
		weap:RemoveEffects( EF_NODRAW )
		weap:Deploy()
	end

end
concommand.Add( "ze_dropweapon", DropActiveWeapon )