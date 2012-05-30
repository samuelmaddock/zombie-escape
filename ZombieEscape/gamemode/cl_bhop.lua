--[[---------------------------------------
		Disable Bunny Hopping
-----------------------------------------]]
hook.Add( "CreateMove", "DisableBhop", function( input )
	local ply = LocalPlayer()
	if ply:Alive() && input:KeyDown( IN_JUMP ) && ply.NextJump &&  CurTime() < ply.NextJump then
		--Msg("Disabled jump for player\n")
		input:SetButtons( input:GetButtons() - IN_JUMP )
	end
end )

hook.Add( "OnPlayerHitGround", "SetNextJump", function( ply, bInWater, bOnFloater, flFallSpeed )
	--Msg("Player hit the ground\n")
	ply.NextJump = CurTime() + 0.08
end )