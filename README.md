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
Although it's suggested to keep these settings at their default, you may change them if you feel necessary.
* ze_max_rounds <number> "Maximum amount of rounds played prior to map switch"
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
* ze_zknockback <float> "Knockback multiplier for zombies."
* ze_zmotherknockback <float> "Knockback multiplier for mother zombies."
* ze_propknockback <float> "Force multiplier for props when shot."


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


#### Installation ####
Place the 'ZombieEscape' folder inside 'garrysmod/gamemodes'


#### Maps ####
Additional maps can be found on [gamebanana.com](http://gamebanana.com/csszm/maps/cats/2471)
Also be sure to check out any CS:S Zombie Escape servers for any popular maps.


#### Links ####
* [Facepunch thread](http://www.facepunch.com/showthread.php?t=1187359)
* [Zombie Escape Wiki](http://zombieescape.wikia.com/wiki/Zombie_Escape_Wiki) (for CS:S)
* [Maps](http://gamebanana.com/csszm/maps/cats/2471)