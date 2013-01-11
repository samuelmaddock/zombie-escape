--[[-------------------------------------------------------------------
		Nuke
---------------------------------------------------------------------]]
hook.Add("PlayerUse", "LaunchNuke", function(ply, ent)
	if !ply:IsZombie() && ent:GetName() == "button995" && !ent:IsPressed() then
		hook.Call( "OnNukeLaunched", GAMEMODE, ply )
	end
end)

--[[-------------------------------------------------------------------
		Map Fixes
---------------------------------------------------------------------]]
GM:IgnoreMessages({
	"MAP FIXED BY 5UNZ"
})