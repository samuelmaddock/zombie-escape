include('shared.lua')

--[[---------------------------------------
		HUD
-----------------------------------------]]
CVars.ZombieFOV = CreateClientConVar( "ze_zfov", 110, true, false )
CVars.Vignette = CreateClientConVar( "ze_vignette", 1, true, false )

-- Because vignettes make everything look nicer
local VignetteMat = Material("ze/vignette")
function GM:HUDPaintBackground()

	self.BaseClass.HUDPaintBackground( self )

	if CVars.Vignette:GetBool() then
		surface.SetDrawColor(0,0,0,200)
		surface.SetMaterial(VignetteMat)
		surface.DrawTexturedRect(0,0,ScrW(),ScrH())
	end

end

/*---------------------------------------------------------
	HUDShouldDraw
	Determine whether to draw parts of HUD
---------------------------------------------------------*/

GM.ZEHideHUD = {}
GM.ZEHideHUD[ "CHudCrosshair" ] = true
GM.ZEHideHUD[ "CHudZoom" ] 		= true

GM.ZEShowHUD = {}
GM.ZEShowHUD[ "CHudGMod" ] 	= true
GM.ZEShowHUD[ "CHudChat" ] 	= true

function GM:HUDShouldDraw(name)

	-- Hide certain HUD elements
	if self.ZEHideHUD[ name ] then
		return false
	end

	-- Don't draw too much over the win overlays
	if WinningTeam != nil and !self.ZEShowHUD[ name ] then
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

	return self.BaseClass.HUDShouldDraw( self, name )

end

function GM:PlayerBindPress( ply, bind, pressed )

	self.BaseClass.PlayerBindPress( self, ply, bind, pressed )

	if ( bind == "+menu" && pressed ) then
		LocalPlayer():ConCommand( "lastinv" )
		return true
	end

	return false

end

--[[---------------------------------------------------------
   Name: gamemode:HUDPaint( )
   Desc: Use this section to paint your HUD
-----------------------------------------------------------]]
function GM:HUDDrawTargetID()
	return false
end