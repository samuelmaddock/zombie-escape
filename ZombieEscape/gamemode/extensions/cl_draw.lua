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