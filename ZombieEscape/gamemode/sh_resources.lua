GM.ZombieScream = Sound("npc/fast_zombie/fz_scream1.wav")

GM.ZombieMoan = {
	Sound("npc/zombie/zombie_voice_idle1.wav"),
	Sound("npc/zombie/zombie_voice_idle2.wav"),
	Sound("npc/zombie/zombie_voice_idle3.wav"),
	Sound("npc/zombie/zombie_voice_idle4.wav"),
	Sound("npc/zombie/zombie_voice_idle5.wav"),
	Sound("npc/zombie/zombie_voice_idle6.wav"),
	Sound("npc/zombie/zombie_voice_idle7.wav"),
	Sound("npc/zombie/zombie_voice_idle8.wav"),
	Sound("npc/zombie/zombie_voice_idle9.wav"),
	Sound("npc/zombie/zombie_voice_idle10.wav"),
	Sound("npc/zombie/zombie_voice_idle11.wav"),
	Sound("npc/zombie/zombie_voice_idle12.wav"),
	Sound("npc/zombie/zombie_voice_idle13.wav"),
	Sound("npc/zombie/zombie_voice_idle14.wav")
}

GM.ZombiePain = {
	Sound("npc/zombie/zombie_pain1.wav"),
	Sound("npc/zombie/zombie_pain2.wav"),
	Sound("npc/zombie/zombie_pain3.wav"),
	Sound("npc/zombie/zombie_pain4.wav"),
	Sound("npc/zombie/zombie_pain5.wav"),
	Sound("npc/zombie/zombie_pain6.wav"),
}

GM.ZombieDeath = {
	Sound("npc/zombie/zombie_die1.wav"),
	Sound("npc/zombie/zombie_die2.wav"),
	Sound("npc/zombie/zombie_die3.wav")
}

GM.ZombieModels = {
	Model("models/player/zombie_classic.mdl"),
	Model("models/player/corpse1.mdl"),
	Model("models/player/zombie_fast.mdl")
}

if SERVER then

	resource.AddFile("materials/ze/bloodoverlay.vmt")
	resource.AddFile("materials/ze/grungeoverlay.vmt")
	resource.AddFile("materials/ze/humanswin.vmt")
	resource.AddFile("materials/ze/staroverlay.vmt")
	resource.AddFile("materials/ze/zombiehand.vmt")
	resource.AddFile("materials/ze/zombieswin.vmt")
	resource.AddFile("materials/ze/vignette.vmt")

	resource.AddFile("materials/models/weapons/v_zombiearms/zombie_classic_sheet.vmt")
	resource.AddFile("models/weapons/v_zombiearms.mdl")

	resource.AddFile("materials/models/player/aliendrone_v3/drone_arms.vmt")
	resource.AddFile("materials/models/player/aliendrone_v3/drone_head.vmt")
	resource.AddFile("materials/models/player/aliendrone_v3/drone_legs.vmt")
	resource.AddFile("materials/models/player/aliendrone_v3/drone_torso.vmt")
	resource.AddFile("materials/models/player/aliendrone_v3/slow_alien_blood.vmt")
	resource.AddFile("materials/models/player/aliendrone_v3/slow_alien_gebiss.vmt")
	resource.AddFile("materials/models/player/aliendrone_v3/slow_alien_schwanz.vmt")
	resource.AddFile("models/player/aliendrone.mdl")

	resource.AddFile("materials/models/player/spacesuit/glove_d.vmt")
	resource.AddFile("materials/models/player/spacesuit/helmet_d.vmt")
	resource.AddFile("materials/models/player/spacesuit/outfitm_d.vmt")
	resource.AddFile("models/player/spacesuit.mdl")

	resource.AddFile("resource/fonts/segoeui.ttf")
	
end