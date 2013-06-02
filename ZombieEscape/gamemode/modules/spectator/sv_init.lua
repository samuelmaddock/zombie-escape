--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnAsSpectator( )
   Desc: Player spawns as a spectator
-----------------------------------------------------------]]
function GM:PlayerSpawnAsSpectator( ply )

    ply:StripWeapons()
    
    if ply:Team() == TEAM_UNASSIGNED then
        ply:Spectate( OBS_MODE_FIXED )
        return
    end

    ply:SetTeam( TEAM_SPECTATOR )
    ply:Spectate( OBS_MODE_ROAMING )

end
