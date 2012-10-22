--[[-------------------------------------------------------------------
		Boss Entities
---------------------------------------------------------------------]]
GM:AddBoss("Helicopter", "Helicopter", "Helicopter_health")	-- Normal
GM:AddBoss("Power Core", "Power_core", "math_counter")		-- Hard

--[[-------------------------------------------------------------------
		Map Fixes
---------------------------------------------------------------------]]
-- func_breakable doesn't seem to want to break, let's fix that
GM:AddTrigger(Vector(4182.42,-1532.14,542.98), Vector(4697.26,-1816.9,588.33), function(ent)
	if string.match(ent:GetClass(), "grenade") then
		local owner = IsValid(ent:GetOwner()) and ent:GetOwner() or game.GetWorld()
		timer.Simple(1.9, function()
			for _, ent in pairs( ents.FindInSphere(Vector(4442.17,-1517.92,550.27), 128) ) do
				if IsValid(ent) and ent:GetClass() == "func_breakable" then
					ent:TakeDamage(1, owner, owner)
				end
			end
		end)
	end
end, true)