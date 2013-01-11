--[[-------------------------------------------------------------------
		Nuke
---------------------------------------------------------------------]]
hook.Add("PlayerUse", "LaunchNukeAchievement", function(ply, ent)
	if !ply:IsZombie() && ent:GetName() == "nukebutton" && !ent:IsPressed() then
		hook.Call( "OnNukeLaunched", GAMEMODE, ply )
	end
end)