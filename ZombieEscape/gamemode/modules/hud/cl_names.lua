surface.CreateFont( "3D2DName", { font = "Bebas", size = 135, weight = 600 } )

local function DrawName( ply, opacityScale )

	if !IsValid(ply) or !ply:Alive() then return end
	
	local pos = ply:GetPos() + Vector( 0, 0, 60 )
	local ang = LocalPlayer():EyeAngles()
	
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )
	
	local dist = LocalPlayer():GetPos():Distance( ply:GetPos() )
	if ( dist >= 1200 ) then return end -- no need to draw anything if the player is far away
	
	local name = "  " .. string.upper( ply:GetName() )
	local col = team.GetColor( ply:Team() )
	col.a = math.Clamp( 310.526 - ( 0.394737 * dist ), 0, 200 ) * ( opacityScale or 1 )

	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.15 )

		render.OverrideDepthEnable(false, true)

		draw.SimpleText( name, "3D2DName", 50, 0, col )
		
		render.OverrideDepthEnable(false, false)

	cam.End3D2D()

end

local HUDTargets = {}
local fadeTime = 2
hook.Add( "PostDrawTranslucentRenderables", "DrawPlayerNames", function()

	for ply, time in pairs(HUDTargets) do

		if time < RealTime() then
			HUDTargets[ply] = nil
			continue
		end

		-- Fade over time
		DrawName( ply, 0.11 * ((time - RealTime()) / fadeTime) )

	end

	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	if (!trace.HitNonWorld) then return end
	
	-- Keep track of recently targetted players
	if trace.Entity:IsPlayer() then
		HUDTargets[trace.Entity] = RealTime() + fadeTime
	elseif trace.Entity:IsVehicle() and
		IsValid(trace.Entity:GetOwner()) and
		trace.Entity:GetOwner():IsPlayer() then
		HUDTargets[trace.Entity:GetOwner()] = RealTime() + fadeTime
	end
	
end )