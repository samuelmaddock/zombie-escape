/*---------------------------------------------------------
	Player Transparency
		Distance opacity opacity
		Thanks to Jetboom for the code (Zombie Survival)
---------------------------------------------------------*/
CVars.PlayerOpacity = CreateClientConVar( "ze_playeropacity", 1, true, false )
CVars.PlayerOpacityDistance = CreateClientConVar( "ze_playeropacity_dist", 80, true, false )

local undomodelblend = false
local undozombievision = false
local matWhite = Material("models/debug/debugwhite")

function GM:PrePlayerDraw( ply )

	if !IsValid(LocalPlayer()) then return end
	if !CVars.PlayerOpacity:GetBool() then return end

	if LocalPlayer():Team() == ply:Team() then

		local radius = CVars.PlayerOpacityDistance:GetInt() or 80
		if radius > 0 then

			local eyepos = EyePos()
			local dist = ply:NearestPoint(eyepos):Distance(eyepos)

			if dist < radius then

				local blend = math.max((dist / radius) ^ 1.4, 0.04)
				render.SetBlend(blend)

				if blend < 0.4 then
					render.ModelMaterialOverride(matWhite)
					render.SetColorModulation(0.2, 0.2, 0.2)
				end

				undomodelblend = true

			end

		end
	end

end

function GM:PostPlayerDraw( ply )

	if undomodelblend then

		render.SetBlend(1)
		render.ModelMaterialOverride()
		render.SetColorModulation(1, 1, 1)

		undomodelblend = false

	end

end