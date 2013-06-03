AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "Specator"

--
-- Called serverside only when the player spawns
--
function PLAYER:Spawn()

	hook.Call( "PlayerSpawnAsSpectator", GAMEMODE, self.Player )

end

player_manager.RegisterClass( "player_spectator", PLAYER, "player_ze" )