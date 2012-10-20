--[[---------------------------------------
		Disable Bunny Hopping
-----------------------------------------]]
hook.Add( "CreateMove", "DisableBhop", function( input )
	if !LocalPlayer():Alive() or !LocalPlayer().NextJump then return end
	if LocalPlayer().NextJump < CurTime() then return end
	if input:KeyDown( IN_JUMP ) then
		input:SetButtons( input:GetButtons() - IN_JUMP )
	end
end )

hook.Add( "OnPlayerHitGround", "SetNextJump", function( ply, bInWater, bOnFloater, flFallSpeed )
	ply.NextJump = CurTime() + 0.08
end )