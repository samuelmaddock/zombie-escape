local OverlayMaterial = Material( "sprites/grip" )

local Buttons = {}
local PressedButtons = {}
local ButtonDistance = 256

local pos, pos2d, dist
local function DrawButtonOverlay()

	if !LocalPlayer():Alive() then return end

	surface.SetMaterial( OverlayMaterial )

	-- for _, ent in pairs( Buttons ) do
		-- if IsValid(ent) then

	for _, ent in pairs( ents.FindInSphere( LocalPlayer():GetPos(), ButtonDistance ) ) do
		if IsValid(ent) and ent:GetClass() == "class C_BaseEntity" and
			not ent:GetNetworkedBool("Pressed") then

			pos = ent:GetPos()
			pos2d = pos:ToScreen()
			dist = ( LocalPlayer():GetPos() -  pos ):Length()

			surface.SetDrawColor( 255, 255, 255, (ButtonDistance - dist)/ButtonDistance * 88 )
			surface.DrawTexturedRect( pos2d.x - 64, pos2d.y - 64, 128, 128 )

		end
	end

end
hook.Add( "HUDPaint", "DrawButtonOverlay", DrawButtonOverlay )


net.Receive( "UpdateButtons", function()

	local entities = net.ReadTable()

	local ent
	for _, idx in pairs( entities ) do
		ent = Entity( idx )
		if IsValid(ent) then
			table.insert( Buttons, ent )
		end
	end

	-- print("Got buttons")
	-- PrintTable(Buttons)

	PressedButtons = {}

end )