--[[-------------------------------------------------------------------
		Map Fixes
---------------------------------------------------------------------]]
hook.Add("OnRoundChange", "RemoveWaterSplashes", function()
	-- Displace laser damage
	for _, v in pairs( ents.FindByName("laserdamage") ) do
		if IsValid(v) then
			if !v.OriginalPos then v.OriginalPos = v:GetPos() end
			v:SetPos(v.OriginalPos + Vector(0,0,8))
		end
	end
end )