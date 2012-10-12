include('shared.lua')

include('cl_bhop.lua')
include('cl_weapon.lua')
include('cl_zvision.lua')

include('cl_boss.lua')
include('cl_damage.lua')
include('cl_messages.lua')
include('cl_overlay.lua')

--[[---------------------------------------
		HUD
-----------------------------------------]]
GM.CVars.PlayerOpacity = CreateClientConVar( "ze_playeropacity", 1, true, false )
GM.CVars.ZombieFOV = CreateClientConVar( "ze_zfov", 110, true, false )

function GM:HUDPaint()
	self.BaseClass.HUDPaint(self)
	self:WinningOverlay()
	self:MapMessages()
	self:DamageNotes()
	self:BossHealth()
end

-- Because vignettes make everything look nicer	
local VignetteMat = Material("ze/vignette")
function GM:HUDPaintBackground()
	surface.SetDrawColor(0,0,0,200)
	surface.SetMaterial(VignetteMat)
	surface.DrawTexturedRect(0,0,ScrW(),ScrH())
end

/*---------------------------------------------------------
	HUDShouldDraw
	Determine whether to draw parts of HUD
---------------------------------------------------------*/
GM.HideHUD = { "CHudCrosshair" }
GM.ShowHUD = { "CHudGMod", "CHudChat" }
function GM:HUDShouldDraw(name)

	-- Hide certain HUD elements
	if table.HasValue(self.HideHUD, name) then
		return false
	end

	-- Don't draw too much over the win overlays
	if self.WinningTeam != nil and !table.HasValue(self.ShowHUD,name) then
		return false
	end

	-- Sanity check
	if !LocalPlayer().IsZombie or !LocalPlayer().IsSpectator then
		return true
	end

	-- Hide parts of HUD for zombies and during weapon selection
	if ( !LocalPlayer():IsHuman() or self.bSelectingWeapons ) and name == "CHudWeaponSelection" then
		return false
	end
	
	return true

end

/*---------------------------------------------------------
	CalcView
		Firstperson on death
---------------------------------------------------------*/
function GM:CalcView( ply, origin, angle, fov )

	fov = LocalPlayer():IsZombie() and self.CVars.ZombieFOV:GetInt() or fov

	local ragdoll = ply:GetRagdollEntity() 
	if IsValid( ragdoll ) then
		local att = ragdoll:GetAttachment( ragdoll:LookupAttachment("eyes") ) 
 		return self.BaseClass:CalcView( ply, att.Pos, att.Ang, fov ) 
 	end

	return self.BaseClass:CalcView( ply, origin, angle, fov )
end

/*---------------------------------------------------------
	Player Transparency
		Distance opacity opacity
---------------------------------------------------------*/
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

	bHide = GAMEMODE.CVars.PlayerOpacity:GetBool()

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