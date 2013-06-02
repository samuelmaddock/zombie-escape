-- Taken from Sassilization

local function SetupNotice( class, str )
	class = string.Trim(string.lower(class))
	language.Add(class, str)
	killicon.AddAlias(class, "default")
end

SetupNotice( "worldspawn", "The World" )

SetupNotice( "func_door", "Door" )
SetupNotice( "func_rotating", "Rotating Death Spinner" )
SetupNotice( "func_door_rotating", "Rotating Death Spinner" )

SetupNotice( "func_movelinear", "Moving Platform" )
SetupNotice( "func_breakable", "Spotaneously Combusted" )

SetupNotice( "trigger_hurt", "Mystic Force" )
SetupNotice( "point_hurt", "Mystic Force" )

SetupNotice( "env_fire", "Fire" )
SetupNotice( "env_beam", "Beam of Death" )
SetupNotice( "env_explosion", "Explosion" )
SetupNotice( "env_laser", "Laser of Death" )
SetupNotice( "prop_combine_ball", "Balls of Combine" )

SetupNotice( "func_physbox", "Deadly Physbox" )
SetupNotice( "prop_physics_override", "Deadly Prop" )
SetupNotice( "prop_physics_respawnable", "Deadly Prop" )
SetupNotice( "prop_physics_multiplayer", "Deadly Prop" )
SetupNotice( "func_physbox_multiplayer", "Deadly Physbox" )

SetupNotice( "trigger_waterydeath", "Leeches" )
SetupNotice( "trigger_physics_trap", "A TRAP!" )
SetupNotice( "point_tesla", "Painful Tesla" )