/*-------------------------------------------------
	Ammo Types
	cs_gamerules.cpp
-------------------------------------------------*/

if CLIENT then
	language.Add( "ammo_50AE_ammo",			"50AE Ammo" )
	language.Add( "ammo_762mm_ammo",		"762mm Ammo" )
	language.Add( "ammo_556mm_ammo",		"556mm Ammo" )
	language.Add( "ammo_556mm_box_ammo", 	"556mm Box Ammo" )
	language.Add( "ammo_338mag_ammo", 		"338MAG Ammo" )
	language.Add( "ammo_9mm_ammo", 			"9mm Ammo" )
	language.Add( "ammo_buckshot_ammo", 	"Buckshot Ammo" )
	language.Add( "ammo_45acp_ammo", 		"45ACP Ammo" )
	language.Add( "ammo_357sig_ammo", 		"357SIG Ammo" )
	language.Add( "ammo_57mm_ammo", 		"57mm Ammo" )
end

local CSAmmoDef = {
	{
		name = "ammo_50AE",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 2400,
		minsplash = 10,
		maxsplash = 14,
		buysize = 7
	},
	{
		name = "ammo_762mm",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 2400,
		minsplash = 10,
		maxsplash = 14,
		buysize = 30
	},
	{
		name = "ammo_556mm_box",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 2400,
		minsplash = 10,
		maxsplash = 14,
		buysize = 30
	},
	{
		name = "ammo_556mm",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 2400,
		minsplash = 10,
		maxsplash = 14,
		buysize = 30
	},
	{
		name = "ammo_338mag",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 2800,
		minsplash = 12,
		maxsplash = 16,
		buysize = 10
	},
	{
		name = "ammo_9mm",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 2000,
		minsplash = 5,
		maxsplash = 10,
		buysize = 30
	},
	{
		name = "ammo_buckshot",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 600,
		minsplash = 3,
		maxsplash = 6,
		buysize = 8
	},
	{
		name = "ammo_45acp",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 2100,
		minsplash = 6,
		maxsplash = 10,
		buysize = 25
	},
	{
		name = "ammo_357sig",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 2000,
		minsplash = 4,
		maxsplash = 8,
		buysize = 13
	},
	{
		name = "ammo_57mm",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 2000,
		minsplash = 4,
		maxsplash = 8,
		buysize = 50
	}
}

for _, ammo in pairs( CSAmmoDef ) do

	-- Add ammo definitions
	game.AddAmmoType( ammo )

	-- Create ammo entities
	scripted_ents.Register( {
		Base = "item_ammo_css",
		AmmoType = ammo.name,
		AmmoAmount = ammo.buysize
	}, ammo.name )

end