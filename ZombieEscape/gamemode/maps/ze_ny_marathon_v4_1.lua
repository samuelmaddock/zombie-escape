--[[-------------------------------------------------------------------
		Map Fixes
---------------------------------------------------------------------]]
local IndexPattern = "modelindex %d+"
local function FixModelIndexes(ent, key, value)

	if key == "OnPlayerPickup" and string.match( value, IndexPattern ) then

		local rawData = string.Explode(",",value);
		local param = rawData[3] or ""
		param = string.Explode(" ",param)
		rawData[3] = string.format( "%s %s", param[1], tonumber(param[2]) - 1 )

		return table.concat( rawData, "," )

	end

end
hook.Add( "EntityKeyValue", "ModelIndexFix", FixModelIndexes )