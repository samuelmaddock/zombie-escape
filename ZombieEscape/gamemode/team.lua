module( 'team' )

function IsAlive( id )
	
	for _, ply in pairs(team.GetPlayers(id)) do
		if IsValid(ply) and ply:Alive() then
			return true
		end
	end

	return false

end

local GetPlayersOld = GetPlayers
function GetPlayers( teamId )

	if !teamId then return end

	if type(teamId) == 'table' then

		local players = {}

		for _, id in pairs(teamId) do
			table.Merge( players, GetPlayersOld(id) )
		end

		return players

	else
		return GetPlayersOld(teamId)
	end

end

local NumPlayersOld = NumPlayers
function NumPlayers( teamId )

	if !teamId then return end

	if type(teamId) == 'table' then

		local count = 0

		for _, id in pairs(teamId) do
			count = count + NumPlayersOld(id)
		end

		return count

	else
		return NumPlayersOld(teamId)
	end

end