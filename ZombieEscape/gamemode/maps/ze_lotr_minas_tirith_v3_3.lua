--[[-------------------------------------------------------------------
		Map Fixes
---------------------------------------------------------------------]]
local function SetupNazgul( ply )

	local oldvel = ply:GetVelocity()

	timer.Simple( 0.3, function()
		if IsValid(ply) then
			ply:SetPos(Vector(-7094.88,2101.93,6916.67))
			ply:SetMoveType(MOVETYPE_FLY)
			ply:SetSpeed(200, 200)
			ply:SetLocalVelocity( oldvel:GetNormal() * 600 )
		end
	end)

	local TimerName = "NazgulTimer" .. ply:EntIndex()

	timer.Create( TimerName, 0.1, 0, function()

		if IsValid(ply) and ply:Alive() and IsValid(ply:GetPickupEntity()) then
			
			-- Easier controls
			local vel = ply:GetVelocity()
			if vel:Length2D() > 600 then
				ply:SetLocalVelocity( vel:GetNormal() * 600 )
			elseif ply:KeyDown( IN_FORWARD ) then
				ply:SetLocalVelocity( ply:EyeAngles():Forward() * 600 )
			end

		else -- player has dropped nazgul knife pickup

			if IsValid(ply) then
				ply:SetMoveType(MOVETYPE_WALK)
				ply:SetLocalVelocity(vector_origin)
				ply:SetSpeed(250, 250)
			end

			-- Don't leave the nazgul laying on the ground
			if IsValid(ply.LastPickupEntity) then
				ply.LastPickupEntity:Remove()
			end

			timer.Destroy( TimerName )

		end

	end )

end

-- Fix movement with nazguls for zombies
GM:AddTrigger(Vector(-7109.56, 2501.3, 6784.13), Vector(-6209.77, 1621.64, 6986.53), function(ply)
	if ply:IsPlayer() then
		SetupNazgul(ply)
	end
end)

hook.Add( "PostCleanUpMap", "RemoveSpeedMod", function()

	-- Remove speedmod entity
	local speedmod = ents.FindByName("speedMod")[1]
	if IsValid(speedmod) then
		speedmod:Remove()
	end

end )