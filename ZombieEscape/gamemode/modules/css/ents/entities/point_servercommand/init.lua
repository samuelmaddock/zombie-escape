ENT.Base = "base_point"
ENT.Type = "point"

local cmdignore = {
	"mp_roundtime",
	"mp_freezetime",
	"mp_flashlight",
	"mat_color_correction",
	"zombie_delete_dropped_weapons",
	"sv_pushaway_force",
	"sv_pushaway_clientside"
}

local fixcmd = {}
fixcmd["zr_infect_spawntime_min"] = "ze_ztimer_min"
fixcmd["zr_infect_spawntime_max"] = "ze_ztimer_max"
fixcmd["zombie_timer_min"] = "ze_ztimer_min"
fixcmd["zombie_timer_max"] = "ze_ztimer_max"
fixcmd["zombie_health_min"] = "ze_zhealth_min"
fixcmd["zombie_health_max"] = "ze_zhealth_max"

local function IgnoreCommand( data )

	for _, v in pairs(cmdignore) do
		if string.find(data,v) then
			return true
		end
	end

	return false
	
end

local function FixCommand(data)

	for k, v in pairs(fixcmd) do
		if string.find(data,k) then
			data = string.gsub(data,k,v)
		end
	end

	return data

end

local function removeChars(str)

	local chars = { ' ', '*', '-', '=', '>', '<' }
	
	str = string.gsub(str,'*','') -- '*' is the worst offender

	-- Remove unnecessary characters
	for _, char in pairs(chars) do
		str = string.TrimRight(str, char)
		str = string.Trim(str, char)
		str = string.TrimLeft(str, char)
	end

	str = string.TrimRight(str,'.') -- Remove period
	
	return str
	
end

local function fixMessage(str, activator)

	str = removeChars(str)
	str = string.gsub(str, "say ", "")
	str = string.gsub(str, "SAY ", "")

	if IsValid(activator) and activator:IsPlayer() and
		string.find(string.lower(str), "player") then
		str = string.gsub(str, "A player", activator:Name()) -- mako reactor
		str = string.gsub(str, "Player", activator:Name())
		str = string.gsub(str, "PLAYER", activator:Name())
	end

	return str

end

function ENT:AcceptInput(name, activator, caller, data)

    if caller:IsPlayer() || IgnoreCommand(data) then return false end
	
    name = string.lower(name)

    if name == "command" then
	
		if string.find(string.lower(data), "say") then

			GAMEMODE:SendMapMessage( fixMessage(data, activator) )

		else

			data = FixCommand(data)

			Msg(tostring(self) .. " ran '" .. data .. "'\n")
			game.ConsoleCommand(data.."\n")

		end
		
    end

	return true
	
end