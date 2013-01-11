function GM:UpdateAnimation( ply, velocity, maxseqgroundspeed )
	player_manager.RunClass( ply, "UpdateAnimation", velocity, maxseqgroundspeed )
end

function GM:CalcMainActivity( ply, velocity )
	return player_manager.RunClass( ply, "CalcMainActivity", velocity )
end

function GM:TranslateActivity( ply, act )
	return player_manager.RunClass( ply, "TranslateActivity", act )
end

function GM:DoAnimationEvent( ply, event, data )
	return player_manager.RunClass( ply, "DoAnimationEvent", event, data )
end