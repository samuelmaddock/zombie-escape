--[[-------------------------------------------------------------------
		Nuke
---------------------------------------------------------------------]]
hook.Add("PlayerUse", "LaunchNukeAchievement", function(ply, ent)
	if !ply:IsZombie() && ent:GetName() == "nukebutton" && !ent:IsPressed() then
		gamemode.Call("OnNukeLaunched", ply)
	end
end)