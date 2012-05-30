--[[-------------------------------------------------------------------
		Nuke
---------------------------------------------------------------------]]
hook.Add("PlayerUse", "LaunchNuke", function(ply, ent)
	if !ply:IsZombie() && ent:GetName() == "button995" && !ent:IsPressed() then
		gamemode.Call("OnNukeLaunched", ply)
	end
end)

--[[-------------------------------------------------------------------
		Map Fixes
---------------------------------------------------------------------]]
GM:IgnoreMessages({
	"MAP FIXED BY 5UNZ"
})