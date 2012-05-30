--[[-------------------------------------------------------------------
		Map Fixes
---------------------------------------------------------------------]]
hook.Add("OnRoundChange", "RenderviewFix", function()
	-- Renderview fix
	local camera = ents.FindByClass("point_camera")[1]
	if IsValid(camera) then
		camera:SetAngles(Angle(-70,128,230))
	end
end)