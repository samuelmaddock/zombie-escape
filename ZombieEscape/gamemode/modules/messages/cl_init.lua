/*---------------------------------------------------------
	Throws a Hint sent from the map to the screen
	Entity: point_servercommand
---------------------------------------------------------*/
surface.CreateFont( "HUDMessages", { font = "Segoe UI", size = 24, weight = 400, antialias = true } )

local MapMessages = {}
local colBar
local colBarDark = Color(100,100,100,255)

local function ClearMessages()
	MapMessages = {}
end
hook.Add( "OnReceivedWinningTeam", "ClearMessages", ClearMessages )

function DrawMapMessages()

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
hook.Add( "HUDPaint", "MapMessages", DrawMapMessages )

local function ParseMessageDuration(str)
	local mapmess = string.lower(str)
	local seconds = {"seconds", "second", "secs", "sec", "s"}
	local minutes = {"minutes", "minute", "mins", "min", "m"}
	local parsed = nil

	for k,v in pairs(seconds) do
		if string.find(mapmess, '%d+%s' .. v) != nil then
			parsed = string.sub(mapmess, string.find(mapmess, '%d+%s*' .. v))
		end
	end

	if !parsed then
		for k,v in pairs(minutes) do
			if string.find(mapmess, '%d+%s' .. v) != nil then
				parsed = string.sub(mapmess, string.find(mapmess, '%d+%s*' .. v))
			end
		end
	end

	return parsed and string.sub(parsed, string.find(parsed, '%d+')) or 10
end

function AddMapMessage()

	local timescale = GetConVarNumber("host_timescale")
	timescale = ( game.GetTimeScale() > 1 ) and game.GetTimeScale() or timescale

	local msg	= {}
	msg.text	= net.ReadString()
	msg.time 	= SysTime() / timescale
	msg.len		= ParseMessageDuration(msg.text)
	msg.velx	= -5
	msg.vely	= 0
	msg.x		= ScrW() + 200
	msg.y		= ScrH()
	msg.a		= 200
	table.insert( MapMessages, msg )
	
	if !game.SinglePlayer() then
		MsgZE(msg.text)
	end

end
net.Receive( "MapMessage", AddMapMessage )