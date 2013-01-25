WinningTeam = nil

/*---------------------------------------------------------
	Humans Win
---------------------------------------------------------*/
local starOverlay = surface.GetTextureID("ze/staroverlay")
local humansWin = surface.GetTextureID("ze/humanswin") -- text
local hw, hh = surface.GetTextureSize(humansWin)
local function DrawHumansWin()

	surface.SetTexture(starOverlay)
	surface.DrawTexturedRect(0,0,ScrH(),ScrH())

	local w, h = math.floor(hw*scale), math.floor(hh*scale)
	local x, y = ScrW()/2 - w/2, math.floor(60*scale)
	surface.SetTexture(humansWin)
	surface.DrawTexturedRect(x,y,w,h)

end

/*---------------------------------------------------------
	Zombies Win
---------------------------------------------------------*/
local bloodOverlay = surface.GetTextureID("ze/bloodoverlay")
local zombieHand = surface.GetTextureID("ze/zombiehand")
local handw, handh = surface.GetTextureSize(zombieHand)
local zombiesWin = surface.GetTextureID("ze/zombieswin") -- text
local zw, zh = surface.GetTextureSize(zombiesWin)
local function DrawZombiesWin()

	surface.SetTexture(bloodOverlay)
	surface.DrawTexturedRect(0,0,ScrW(),ScrH())

	local w, h = math.floor(handw*scale), math.floor(handh*scale)
	local x, y = ScrW() - w - 128, ScrH() - h
	surface.SetTexture(zombieHand)
	surface.DrawTexturedRect(x,y,w,h)

	local w, h = math.floor(zw*scale), math.floor(zh*scale)
	local x, y = ScrW()/2 - w/2, math.floor(100*scale)
	surface.SetTexture(zombiesWin)
	surface.DrawTexturedRect(x,y,w,h)

end

/*---------------------------------------------------------
	Winning Team Overlay
---------------------------------------------------------*/
local scale, fade
local grungeOverlay = surface.GetTextureID("ze/grungeoverlay")
function DrawWinningOverlay()

	if WinningTeam == nil then
		fade = nil
		return
	end

	if fade == nil then
		fade = RealTime()
	end

	scale = math.Clamp(ScrH()/640,0,1.4)

	local fadeamount = math.Clamp( (RealTime()-fade) / 2, 0, 1)
	surface.SetDrawColor(255,255,255,255*fadeamount)

	if WinningTeam == TEAM_HUMANS then
		DrawHumansWin()
	elseif WinningTeam == TEAM_ZOMBIES then
		DrawZombiesWin()
	end

	surface.SetTexture(grungeOverlay)
	surface.DrawTexturedRect(0,0,ScrW(),ScrH())

end
hook.Add( "HUDPaint", "WinningOverlays", DrawWinningOverlay )


net.Receive("WinningTeam", function(um)

	local winner = net.ReadUInt(2)
	local bReset = tobool(net.ReadBit())

	WinningTeam = !bReset and tonumber(winner) or nil

end)