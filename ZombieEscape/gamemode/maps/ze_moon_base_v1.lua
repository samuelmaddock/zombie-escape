--[[-------------------------------------------------------------------
		Map Settings
---------------------------------------------------------------------]]
GM.PlayerModelOverride = {
	[TEAM_HUMANS] = {
		Model("models/player/spacesuit.mdl")
	}
}

GM:IgnoreMessages({
	"your sound"
})

--[[-------------------------------------------------------------------
		Map Fixes
---------------------------------------------------------------------]]
hook.Add( "PostCleanUpMap", "RemoveWaterSplashes", function()

	for _, v in pairs( ents.FindByName("volume_*") ) do
		if IsValid(v) then
			v:Remove()
		end
	end

end )