--[[---------------------------------------
		Zombie Vision
-----------------------------------------]]
local delay
local tab = {}
	tab["$pp_colour_addr"] 			= 0
	tab["$pp_colour_addg"] 			= 0
	tab["$pp_colour_addb"] 			= 0
	tab["$pp_colour_brightness"] 	= 0
	tab["$pp_colour_contrast"] 		= 1
	tab["$pp_colour_colour"] 		= 1
	tab["$pp_colour_mulr"] 			= 0
	tab["$pp_colour_mulg"] 			= 0
	tab["$pp_colour_mulb"] 			= 0

function ZombieVision()

	if !LocalPlayer():IsZombie() and delay then
		delay = nil
		return
	end

	if GAMEMODE.bZombieLight then
		local dlight = DynamicLight( LocalPlayer():EntIndex() )
		if dlight then
			dlight.r = color_white.r
			dlight.g = color_white.r
			dlight.b = color_white.r
			dlight.Brightness = 0.5
			dlight.Size = 512
			dlight.Decay = 512
			dlight.Pos = LocalPlayer():GetShootPos()
			dlight.DieTime = CurTime() + 0.1
		end
	end

	delay = delay and math.Approach(delay, 1, 0.003) or 0
	tab[ "$pp_colour_colour" ] = 1 - (0.5 * delay)

	DrawColorModify( tab )

end
hook.Add( "RenderScreenspaceEffects", "ZombieVisionEffects", ZombieVision )

function ToggleLight(ply, bind, pressed)
	if !LocalPlayer():Alive() or !LocalPlayer():IsZombie() then return end
	if string.find(bind, "impulse 100") then
		if GAMEMODE.bZombieLight then
			LocalPlayer():EmitSound('HL2Player.FlashLightOff')
			GAMEMODE.bZombieLight = false
		else
			LocalPlayer():EmitSound('HL2Player.FlashLightOn')
			GAMEMODE.bZombieLight = true
		end
	end
end
hook.Add( "PlayerBindPress", "ToggleZombieLight", ToggleLight )