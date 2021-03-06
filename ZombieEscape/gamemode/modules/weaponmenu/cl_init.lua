--[[---------------------------------------------
		Controls to open menu
-----------------------------------------------]]
control.Add( KEY_B, function( enabled, held )

	if held then return end
	
	if enabled then
		
		net.Start( "RequestWeaponMenu" )
		net.SendToServer()

	end

end )


--[[---------------------------------------------
		Menu Helpers
-----------------------------------------------]]
function GM:OpenWeaponSelection()

	if !self.Weapons then
		self:LoadWeapons()
	end

	if ValidPanel(self.WeaponMenu) then
		self.WeaponMenu:Remove()
	end

	self.bSelectingWeapons = true

	self.WeaponMenu = vgui.Create("WeaponSelection")

end

function GM:HideWeaponSelection()

	if ValidPanel(self.WeaponMenu) then
		self.WeaponMenu:Remove()
	end

	self.bSelectingWeapons = nil

end

function GM:ReceivedWeapon(type)

	if !ValidPanel(self.WeaponMenu) then return end

	if type == WEAPON_PRIMARY then
		self.WeaponMenu:SetupWeapons(WEAPON_SECONDARY)
	elseif type == WEAPON_SECONDARY then
		self:HideWeaponSelection()
	end

end


--[[---------------------------------------------
		User Message Hooks
-----------------------------------------------]]
net.Receive("SelectWeapons", function()
	GAMEMODE:OpenWeaponSelection()
end)

net.Receive("CloseWeaponSelection", function()
	GAMEMODE:HideWeaponSelection()
end)

net.Receive("ReceiveWeapon", function()
	local type = net.ReadUInt(2)
	if !type then return end
	GAMEMODE:ReceivedWeapon(type)
end)

net.Receive("WeaponsData", function()
	GAMEMODE.Weapons = net.ReadTable()
end)


--[[---------------------------------------------
		Weapon Selection VGUI
-----------------------------------------------]]
surface.CreateFont( "WeaponMenuText", { font = "Segoe UI", size = 20, weight = 400, antialias = true } )

local PANEL = {}

function PANEL:Init()

	self:ParentToHUD()

	self.Title = "Select A Weapon"
	self.padding = 8
	
	self:SetupWeapons(WEAPON_PRIMARY)
	
end

function PANEL:SetupWeapons(type)
	
	self.WeaponList = {}

	surface.SetFont("WeaponMenuText")

	local w, h = 94, 0
	for k, weapon in ipairs(GAMEMODE:GetWeaponsByType(type)) do

		weapon.Slot = k

		local ent = weapons.Get(weapon.class)
		weapon.Name = (ent and ent.PrintName) and tostring(ent.PrintName) or "Unknown"

		local w2, h2 = surface.GetTextSize(weapon.Name)

		w = (w2 and w2 > w) and w2 or w
		h = (h2 and h2 > h) and h2 or h


		self.WeaponList[k] = weapon

	end

	local count = #self.WeaponList
	self.WeaponList[count+1] = {
		Slot = count+1,
		Name = "Cancel"
	}

	self.tw = w -- text width
	self.th = h -- text height

	self:PerformLayout()

end

function PANEL:OnSelectWeapon(slot)

	if self.LastPress and self.LastPress + 0.3 > RealTime() then return end
	self.LastPress = RealTime()

	local weapon = self.WeaponList[slot]
	if !weapon then return end
	
	if weapon.Name == "Cancel" then
		GAMEMODE:HideWeaponSelection()
		return
	end

	RunConsoleCommand("ze_selectweapon", weapon.class)

end

function PANEL:PerformLayout()

	local w = self.tw + (self.padding * 2) + 20
	local h = (self.padding + self.th) * (#self.WeaponList+1) + self.padding

	self:SetPos(20, ScrH()/2 - h/2)
	self:SetSize(w,h)
	
end

function PANEL:Paint( w, h )

	-- Background
	draw.RoundedBoxEx( 4, 0, 0, w, h, Color(0,0,0,180), true, true, true, true )

	draw.SimpleText("Select A Weapon", "WeaponMenuText", self.padding, self.padding + 2, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.SimpleText("Select A Weapon", "WeaponMenuText", self.padding, self.padding, team.GetColor(LocalPlayer():Team()), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	local x, y, text
	for k, v in pairs(self.WeaponList) do

		-- Weapon Name
		x = self.padding
		y = self.padding + (self.padding + self.th) * (k)
		text = tostring(v.Slot) .. ". " .. v.Name
		draw.SimpleText(text, "WeaponMenuText", x, y+2, Color(0,0,0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(text, "WeaponMenuText", x, y, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	end

end

function PANEL:Think()

	if !LocalPlayer():Alive() or !LocalPlayer():IsHuman() then
		GAMEMODE:HideWeaponSelection()
	end

	-- Get input without requesting focus
	for key = 2, 9 do
		if input.IsKeyDown(key) then
			self:OnSelectWeapon(key-1)
		end
	end

end

vgui.Register( "WeaponSelection", PANEL, "DPanel" )