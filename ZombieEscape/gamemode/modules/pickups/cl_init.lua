hook.Add( "PlayerBindPress", "BindDropEntity", function( ply, bind, pressed )

	if bind == "+menu_context" and pressed then
		LocalPlayer():ConCommand( "ze_dropentity" )
		return true
	end

end )