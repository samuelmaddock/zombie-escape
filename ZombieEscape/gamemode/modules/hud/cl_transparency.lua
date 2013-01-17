/*---------------------------------------------------------
	Player Transparency
		Distance opacity opacity
---------------------------------------------------------*/
CVars.PlayerOpacity = CreateClientConVar( "ze_playeropacity", 1, true, false )

local function HideWeapon(ply, percent)
	local weapon = ply:GetActiveWeapon()
	if IsValid(weapon) then
		weapon:SetColor(Color(255,255,255,255*percent))
	end
end

local function HidePlayer(ply, percent)
	ply:SetColor(Color(255,255,255,255*percent))
	HideWeapon(ply,percent)
end

local bHide = false
local min, max = 35, 100
hook.Add("Think", "HideTeamPlayers", function()

	bHide = CVars.PlayerOpacity:GetBool()

	-- Player transparency
	for _, ply in pairs( team.GetPlayers(TEAM_BOTH) ) do

		-- Ignore invalid players and local player
		if !IsValid(ply) or ply == LocalPlayer() then
			continue
		end

		-- Apply distance based transparency to team players
		if ply:Team() == LocalPlayer():Team() then

			local dist = ( ply:GetPos() - LocalPlayer():GetPos() ):Length()

			if bHide and dist < min then
				HidePlayer(ply,0)
			elseif bHide and dist > min and dist < max then
				HidePlayer(ply, math.Clamp((dist-min)/max,0,1))
			else
				HidePlayer(ply,1)
			end

			if ply:IsZombie() then
				HideWeapon(ply,0)
			end

		else
			-- Non-friendly players should be completely opaque
			HidePlayer(ply,1)
		end

	end

end)