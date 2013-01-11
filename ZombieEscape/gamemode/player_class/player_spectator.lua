AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "Specator"

--
-- Called serverside only when the player spawns
--
function PLAYER:Spawn()

	self.Player:Spectate( OBS_MODE_ROAMING )
	self.Player:SetMoveType( MOVETYPE_OBSERVER )

end

player_manager.RegisterClass( "player_spectator", PLAYER, "player_ze" )