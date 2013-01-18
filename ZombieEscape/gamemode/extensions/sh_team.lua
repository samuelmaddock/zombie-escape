function team.IsAlive( id )
	
	for _, ply in pairs(team.GetPlayers(id)) do
		if IsValid(ply) and ply:Alive() then
			return true
		end
	end

	return false

end

local GetPlayersOld = team.GetPlayers
function team.GetPlayers( teamId )

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

local NumPlayersOld = team.NumPlayers
function team.NumPlayers( teamId )

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