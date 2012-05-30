Zombie Escape
=============

Zombie Escape is a popular gamemode for Counter-Strike: Source, now available for Garry's Mod. Players initially spawn as humans, and after a short amount of time, an infection outbreaks. The humans must escape the infection by reaching the end of the map, otherwise the zombies will succeed. Humans are able to 'push' zombies back with their bullets. Each weapon has their own stats, which affects the amount of push.


#### Features ####

* Map messages sent to the HUD (instead of chat)
* Zombie damage display
* Zombie knockback/push system
* Bosses display health bars
* Zombie arms weapon
* Simple weapon selection menu
* Win screen overlays (Thanks to Snoipa)
* Configurable settings
* Automated map changing after max rounds
* Decreased zombie health and infection time with larger amount of players
* Disabled Bunny Hop (Only in GMod Beta)


#### Settings ####
* ze_max_rounds <number> "Maximum amount of rounds played prior to map switch"
Although it's suggested to keep these settings at their default, you may change them if you feel necessary.
* ze_ztimer_min <seconds> "Minimum time from the start of the round until picking the mother zombie(s)."
* ze_ztimer_max <seconds> "Maximum time from the start of the round until picking the mother zombie(s)."
* ze_zhealth_min <number>
* ze_zhealth_max <number>
* ze_ammo <number> "Amount of ammo to give humans."
* ze_buyzone <0/1> "Whether or not players may purchase weapons only in a buyzone."
* ze_human_speed <number>
* ze_zombie_speed <number>
* ze_zombie_ratio <number>
* ze_zspawn_latejoin <0/1> "Allow late joining as zombie."
* ze_zspawn_timelimit <seconds> "Time from the start of the round to allow late zombie spawning."


#### Developer Support ####
* Custom human weapons may be added by editing the 'weapons.txt' file.
* Map fixes may be added to 'gamemode/maps/mapname.lua'
* A selection of hooks are made available for developers looking to implement custom rewards or other features

* OnRoundChange()
* OnChangeMap( String nextmap )
* OnTeamWin( Integer teamId )
* OnInfected( Player ply, Player attacker )
* OnNukeLaunched( Player ply )
* OnBossDefeated( Table boss, Player attacker ) see sv_boss.lua


#### Map Patching ####
Included with the gamemode is a custom tool, which I originally created for Sassilization, for patching Zombie Escape maps, found under 'ZombieEscape/content/MapPatcher.exe' (Your anti-virus may tell you that it is malware, but I assure you, it is not). Unfortunately, a number of maps for the gamemode feature bugs only found present in Garry's Mod. A certain grated material is handled differently, bullets go through it in Garry's Mod, but not in Counter-Strike: Source. The tool provides instructions for correcting this by clicking the 'Help' link. Technical details: The tool parses the brush lump of a map and removes the CONTENTS_GRATE attribute from any surface with that attribute. More details can be found ([here](https://developer.valvesoftware.com/wiki/Source_BSP_File_Format#Brush_and_brushside).


#### Downloads ####
([Pre-patched Map Pack](http://www.solidfiles.com/d/47922cc034/) 555MB Torrent


#### Installation ####

Place the 'ZombieEscape' folder inside 'garrysmod/gamemodes'


#### Links ####

Facepunch thread
[pending]

Zombie Escape Wiki (for CS:S)
http://zombieescape.wikia.com/wiki/Zombie_Escape_Wiki