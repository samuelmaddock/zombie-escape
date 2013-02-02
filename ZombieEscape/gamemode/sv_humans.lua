CVars.HumanSpeed	= CreateConVar( "ze_human_speed", 250, {FCVAR_REPLICATED}, "Speed at which the humans move in units/sec." )
CVars.Ammo		= CreateConVar( "ze_ammo", 800, {FCVAR_REPLICATED}, "Amount of ammo to give humans." )
CVars.Buyzone 	= CreateConVar( "ze_buyzone", 1, {FCVAR_REPLICATED}, "Whether or not players may purchase weapons only in a buyzone." )

-- GM.AmmoTypes = {"smg1","pistol","357","ar2","buckshot","sniperround"}
GM.AmmoTypes = {"ammo_50AE","ammo_762mm","ammo_556mm","ammo_556mm_box","ammo_338mag","ammo_9mm","ammo_buckshot","ammo_45acp","ammo_357sig","ammo_57mm"}
GM.ValidHumans = {"male14","male18","male12","male17","male13","male10","male16","male15","male11",
	"female10","female11","female12"}