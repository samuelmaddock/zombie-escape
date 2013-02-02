local function CorrectBeam(a, b)
	if(!IsValid(a) or !IsValid(b)) then
		return
	end
	
	local v1, v2 = a:GetPos(), b:GetPos()
	local trace = util.TraceLine({start=v1, endpos=v2})
	
	if trace.StartSolid then
		local npos = v1 + ((v2 - v1) * (trace.FractionLeftSolid + 0.005) )
		a:SetPos(npos)
	end
end

local function CorrectLasers()
	local laser = ents.FindByClass("env_laser")
	for _,v in pairs(laser) do
		local e = v:GetKeyValues()
		
		local name = e["LaserTarget"]
		local endent = ents.FindByName(name)[1]
		
		CorrectBeam(v, endent)
	end
	
	laser = ents.FindByClass("env_beam")
	
	for _,v in pairs(laser) do
		local e = v:GetKeyValues()
		
		local sname = e["LightningStart"]
		local ename = e["LightningEnd"]
		
		local sent = ents.FindByName(sname)[1]
		local eent = ents.FindByName(ename)[1]
		
		CorrectBeam(sent, eent)
	end
end

local SaveEntities = { "func_brush", "env_global" }
local EntitiesToRemove = { "prop_ragdoll", "weapon_*" }
function GM:CleanUpMap()

	hook.Call( "PreCleanUpMap", self )
	
	-- Zombie Escape maps save values in several
	-- entities, commonly used for difficulty levels
	game.CleanUpMap( false, SaveEntities )
	
	-- Remove unwanted entities
	for _, class in pairs( EntitiesToRemove ) do

		for _, ent in pairs( ents.FindByClass(class) ) do

			 -- ents with targetnames are typically important
			if IsValid(ent) and !ent:HasTargetName() and !ent.OnPlayerPickup then
				ent:Remove()
			end

		end

	end

	CorrectLasers()

	hook.Call( "PostCleanUpMap", self )
	
end
hook.Add( "InitPostEntity", "InitMapCleanup", GM.CleanUpMap )