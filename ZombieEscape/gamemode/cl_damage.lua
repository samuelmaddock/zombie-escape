/*---------------------------------------------------------
	DamageNotes displays the amount of damage done
	to enemies above their heads
---------------------------------------------------------*/
surface.CreateFont( "Impact", 32, 400, true, false, "ImpactHud" )
surface.CreateFont( "Impact", 32, 400, true, false, "ImpactHudShadow", false, false, 4 )

DamageNotes = {}

local fadetime = 3
function GM:DamageNotes()
	for k, v in pairs(DamageNotes) do
		local scrpos = v.Pos:ToScreen()
		local percent = math.Clamp((v.Time - RealTime())/fadetime, 0, 1)
		local c = Color(210, 0, 0, 255*percent) -- gradually fade
		local y = scrpos.y + 60*percent -- gradually rise
		
		draw.SimpleText(v.Amount, "ImpactHudShadow", scrpos.x, y, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(v.Amount, "ImpactHud", scrpos.x, y, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		
		if percent == 0 then table.remove(DamageNotes, k) end
	end
end

function AddDamageNote()
	local note = {}
	note.Amount 	= net.ReadFloat()
	note.Pos 		= net.ReadVector() + Vector( 0, 0, 65 )
	note.Time 		= RealTime() + fadetime
	table.insert(DamageNotes, note)
end
net.Receive( "DamageNotes", AddDamageNote )