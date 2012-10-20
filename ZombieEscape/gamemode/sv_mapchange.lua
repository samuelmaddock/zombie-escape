GM.MapList = {}

local function LoadMaps()

	GAMEMODE.MapList = {}

	for _, v in pairs( file.Find( "maps/*.bsp", "GAME" ) ) do

        local name = string.gsub( v, ".bsp", "" )
        local lowername = string.lower( v )
        
        if string.find( lowername, "^ze_" ) then
            table.insert(GAMEMODE.MapList,name)
        end

	end

end

function GM:ChangeMap()

	LoadMaps()

	local map

	if self.MapList then

		-- Remove current map from list
		if #self.MapList > 1 then
			local key = table.KeyFromValue(self.MapList, game.GetMap())
			if key and self.MapList[key] then
				table.remove(self.MapList,key)
			end
		end

		map = table.Random(self.MapList)

	end

	if map then

		gamemode.Call("OnChangeMap", map)

		self:SendMapMessage("Changing map to '"..tostring(map).."' in 10 seconds")

		timer.Simple(10, function()
			RunConsoleCommand("changelevel", map)
		end)
		
	else
		Error("Can't change levels, no valid maps found!\n")
	end

end