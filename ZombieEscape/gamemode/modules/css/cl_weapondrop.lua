hook.Add( "PlayerBindPress", "BindDropWeapon", function( ply, bind, pressed )

	if bind == "+menu_context" and pressed then
		LocalPlayer():ConCommand( "ze_dropweapon" )
		return true
	end

end )