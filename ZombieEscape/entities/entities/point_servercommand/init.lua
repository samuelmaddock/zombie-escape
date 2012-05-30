ENT.Base = "base_point"
ENT.Type = "point"

local cmdignore = {
	"mp_roundtime",
	"mp_freezetime",
	"mp_flashlight",
	"mat_color_correction",
	"zombie_delete_dropped_weapons"
}
local function IgnoreCommand( data )

	for _, v in pairs(cmdignore) do
		if string.find(data,v) then
			return true
		end
	end

	return false
	
end

local function FixCommand(data)

	if string.find(data,"zr_infect_spawntime_min") then
		data = string.gsub(data, "zr_infect_spawntime_min", "zombie_timer_min")
	elseif string.find(data,"zr_infect_spawntime_max") then
		data = string.gsub(data, "zr_infect_spawntime_max", "zombie_timer_max")
	end

	return data

end

local function removeChars(str)

	local chars = { ' ', '*', '-', '=', '>', '<' }
	
	// Remove unnecessary characters
	for _, char in pairs(chars) do
		str = string.TrimRight(str, char)
		str = string.Trim(str, char)
		str = string.TrimLeft(str, char)
	end

	str = string.TrimRight(str,'.') // Remove period
	
	return str
	
end

function ENT:AcceptInput(name, act, caller, data)

    if caller:IsPlayer() || IgnoreCommand(data) then return end
	
    if name == "Command" then
	
		if string.find(string.lower(data), "say") then
			data = string.gsub(data, "say ", "")
			data = string.gsub(data, "SAY ", "")
			data = removeChars(data)

			GAMEMODE:SendMapMessage(data)
		else
			data = FixCommand(data)

			Msg(tostring(self) .. " ran '" .. data .. "'\n")
			game.ConsoleCommand(data.."\n")
		end
		
    end
	
end