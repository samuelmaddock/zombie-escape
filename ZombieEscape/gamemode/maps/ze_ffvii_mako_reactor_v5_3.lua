--[[-------------------------------------------------------------------
		Boss Entities
---------------------------------------------------------------------]]
GM:AddBoss("Guard Scorpion", "monstruo", "Monstruo_Breakable") -- Red Scorpian
GM:AddBoss("Bahamut", "bahamut", "bahamut_vida") -- Bahamut, dragon thing

--[[-------------------------------------------------------------------
		Map Fixes
---------------------------------------------------------------------]]
-- Prevent humans from jumping down yellow panels before boss starts
GM:AddTrigger(Vector(-7250,9597,-5241), Vector(-7124,9411,-4650), function(ply)
	if ply:IsPlayer() then
		ply:SetPos(Vector(-7479,9047,-4733))
		ply:SetEyeAngles(Angle(0,180,0))
	end
end)

-- Yellow ledges near reactor floor ladder
GM:AddTrigger(Vector(-9972,8600,-5272), Vector(-10099,8454,-4364), function(ply)
	if ply:IsPlayer() then
		ply:SetPos(Vector(-10011,8887,-4733))
		ply:SetEyeAngles(Angle(0,180,0))
	end
end)