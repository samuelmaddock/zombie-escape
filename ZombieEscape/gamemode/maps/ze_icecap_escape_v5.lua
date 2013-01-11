--[[-------------------------------------------------------------------
		Nuke
---------------------------------------------------------------------]]
hook.Add("PlayerUse", "LaunchNuke", function(ply, ent)
	if !ply:IsZombie() && ent.bNukeBtn && !ent:IsPressed() then
		hook.Call( "OnNukeLaunched", GAMEMODE, ply )
	end
end)

-- Specify which entity is the nuke button since there is no targetname on the func_button
hook.Add("EntityKeyValue", "SpecifyNukeButton", function(ent, k, v)
	if ent:GetClass() == "func_button" && k == "OnPressed" && v == "Com,Command,say ***Nuke in 10secs.***,0,1" then
		ent.bNukeBtn = true
	end
end)

--[[-------------------------------------------------------------------
		Map Fixes
---------------------------------------------------------------------]]
hook.Add("OnRoundChange", "RemoveBugsSecrets", function()

	-- Remove orange secrets
	/*local buttons = ents.FindByName("Orange*")
	for _, v in pairs(buttons) do
		if IsValid(v) then
			v:Remove()
		end
	end
	
	-- Remove skybox teleports
	local buttons = ents.FindByName("SkyBox*")
	for _, v in pairs(buttons) do
		if IsValid(v) then
			v:Remove()
		end
	end*/

	for _, v in pairs(ents.FindInSphere(Vector(-2528,-4576,369), 64)) do
		if string.find(v:GetClass(),"info_player") then
			v:Remove()
		end
	end

end)