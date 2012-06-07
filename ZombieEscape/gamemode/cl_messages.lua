/*---------------------------------------------------------
	draw.Rectangle
---------------------------------------------------------*/
local sin,cos,rad = math.sin,math.cos,math.rad // makes things a bit faster

function draw.Rectangle( x, y, w, h, col, tex )

	surface.SetDrawColor(col)
	
	if tex then
		surface.SetTexture(tex)
		surface.DrawTexturedRect(x,y,w,h)
	else
		surface.DrawRect(x,y,w,h)
	end
	
end

/*---------------------------------------------------------
	Throws a Hint sent from the map to the screen
	Entity: point_servercommand
---------------------------------------------------------*/
surface.CreateFont( "Segoe UI", 24, 400, true, false, "HUDMessages" )

local MapMessages = {}
local colBar
local colBarDark = Color(100,100,100,255)

function CleanupMM()
	MapMessages = {}
end
net.Receive("RoundChange", CleanupMM)

function GM:MapMessages()

	for k, v in pairs( MapMessages ) do
		
		local H = ScrH() / 1024
		local x = v.x - 75 * H
		local y = v.y - 300 * H
		
		if ( !v.w ) then
		
			surface.SetFont( "HUDMessages" )
			v.w, v.h = surface.GetTextSize( v.text )
		
		end
		
		local w = v.w
		local h = v.h

		draw.Rectangle( x - w + 8, y - 8, w + h, h, Color( 30, 30, 30, v.a ) )
		draw.SimpleText( v.text, "HUDMessages", x + h - 4, y - 8, Color(255,255,255,v.a), TEXT_ALIGN_RIGHT )
		
		-- Timer
		local wTime = math.Clamp( ((v.time + v.len - SysTime()) / v.len) * (w+h), 0, w+h )
		local xTime = (x - w + 8) + (w + h - wTime)	-- Timer bar drains to the right
		draw.Rectangle( x -w + 8, (y - 8) + h, w + h, 2, colBarDark )
		draw.Rectangle( xTime, (y - 8) + h, wTime, 2, team.GetColor(LocalPlayer():Team()) )
		
		local ideal_y = ScrH() - (#MapMessages - k) * (h + 6)
		local ideal_x = ScrW()
		
		local timeleft = v.len - (SysTime() - v.time)
		
		-- Cartoon style about to go thing
		if ( timeleft < 0.8  ) then
			ideal_x = ScrW() - 50
		end
		 
		-- Gone!
		if ( timeleft < 0.5  ) then
		
			ideal_x = ScrW() + (w+h) * 2
		
		end
		
		local spd = RealFrameTime() * 15
		
		v.y = v.y + v.vely * spd
		v.x = v.x + v.velx * spd
		
		local dist = ideal_y - v.y
		v.vely = v.vely + dist * spd * 1
		if (math.abs(dist) < 2 && math.abs(v.vely) < 0.1) then v.vely = 0 end
		local dist = ideal_x - v.x
		v.velx = v.velx + dist * spd * 1
		if (math.abs(dist) < 2 && math.abs(v.velx) < 0.1) then v.velx = 0 end
		
		-- Friction.. kind of FPS independant.
		v.velx = v.velx * (0.95 - RealFrameTime() * 8 )
		v.vely = v.vely * (0.95 - RealFrameTime() * 8 )
		
		if ( v.len - (SysTime() - v.time) ) < 0 then table.remove( MapMessages, k ) end

	end

end

local function MapMessageParser(str)
	local mapmess = string.lower(str)
	local seconds = {"seconds", "second", "secs", "sec", "s"}
	local minutes = {"minutes", "minute", "mins", "min", "m"}
	local parsed = nil
	for k,v in pairs(seconds) do
		if string.find(mapmess, '%d+%s' .. v) != nil then
			parsed = string.sub(mapmess, string.find(mapmess, '%d+%s*' .. v))
		end
	end
	if parsed == nil then
		for k,v in pairs(minutes) do
			if string.find(mapmess, '%d+%s' .. v) != nil then
				parsed = string.sub(mapmess, string.find(mapmess, '%d+%s*' .. v))
			end
		end
	end
	if parsed == nil then
		return 5
	else
		return string.sub(parsed, string.find(parsed, '%d+'))
	end
end

function AddMapMessage()
	local msg	= {}
	msg.text	= net.ReadString()
	msg.time 	= SysTime()
	msg.len		= MapMessageParser(msg.text)
	msg.velx	= -5
	msg.vely	= 0
	msg.x		= ScrW() + 200
	msg.y		= ScrH()
	msg.a		= 200
	table.insert( MapMessages, msg )
	
	Msg( "[ZE] " .. msg.text .. "\n" )
end
net.Receive( "MapMessage", AddMapMessage )