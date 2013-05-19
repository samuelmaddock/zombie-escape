util.AddNetworkString( "UpdateButtons" )

local function UpdateButtons()

	timer.Simple( 1, function()

		local buttons = {}

		for _, ent in pairs( ents.FindByClass( "func_button" ) ) do
			if IsValid(ent) then
				table.insert( buttons, ent:EntIndex() )
			end
		end

		net.Start( "UpdateButtons" )
			net.WriteTable( buttons )
		net.Broadcast()

	end )

end
hook.Add( "OnRoundChange", "UpdateButtons", UpdateButtons )

local function ButtonUse( ply, ent )

	if !IsValid(ply) then return end
	if !IsValid(ent) or ent:GetClass() != "func_button" then return end
	if ent:IsPressed() then return end

	ent:SetNetworkedBool( "Pressed", true )

end
hook.Add( "PlayerUse", "ButtonUse", ButtonUse )