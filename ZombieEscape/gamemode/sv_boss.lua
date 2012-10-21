util.AddNetworkString("BossSpawn")
util.AddNetworkString("BossTakeDamage")
util.AddNetworkString("BossDefeated")

/*---------------------------------------------------------
	Boss Object
---------------------------------------------------------*/
BOSS_MATH		= 1
BOSS_PHYSBOX	= 2

local BOSS = {}

function BOSS:Setup(name, modelEnt, counterEnt)

	local boss = {}
	
	setmetatable( boss, self )
	self.__index = self
	
	boss.Name = name
	boss.Type = -1
	boss.KilledOnRound = -1
	boss.Entities = {}

	boss.Targets = {}
	boss.Targets.Model = modelEnt
	boss.Targets.Counter = counterEnt
	
	return boss
	
end

function BOSS:IsValid()
	return IsValid( self:GetCounter() ) and
		IsValid( self:GetClientModel() ) and
		-- self:MaxHealth() > 10 and
		self.KilledOnRound != GAMEMODE:GetRound()
end

function BOSS:HasCounter(ent)
	return self.Targets.Counter == ent:GetName()
end

function BOSS:Health()
	if self:GetType() == BOSS_MATH then
		return IsValid(self.Entities.Counter) and self.Entities.Counter:GetOutValue() or -1
	elseif self:GetType() == BOSS_PHYSBOX then
		if !IsValid(self.Entities.Counter) then return -1 end

		-- Update max health
		local health = self.Entities.Counter:Health()
		if !self._MaxHealth or health > self._MaxHealth then
			self._MaxHealth = health
		end

		return health
	end
end

function BOSS:MaxHealth()
	if self:GetType() == BOSS_MATH then
		return IsValid(self.Entities.Counter) and self.Entities.Counter.m_InitialValue or -1
	elseif self:GetType() == BOSS_PHYSBOX then
		return IsValid(self.Entities.Counter) and self._MaxHealth or self:Health()
	end
end

function BOSS:GetType()
	return self.Type
end

function BOSS:GetCounterTarget()
	return self.Targets.Counter
end

function BOSS:GetModelTarget()
	return self.Targets.Model
end

function BOSS:GetName()
	return self.Name
end

function BOSS:GetCounter()

	if !IsValid(self.Entities.Counter) then

		for _, v in pairs(ents.FindByName(self.Targets.Counter)) do
			if IsValid(v) and v:GetName() == self.Targets.Counter then
				if v:GetClass() == "math_counter" then
					self.Type = BOSS_MATH
				elseif v:GetClass() == "func_physbox_multiplayer" then
					self.Type = BOSS_PHYSBOX
				else
					continue -- not what we want
				end

				self.Entities.Counter = v
				break
			end
		end

	end

	return self.Entities.Counter
	
end

function BOSS:GetClientModel()
	
	if !IsValid(self.Entities.Model) then

		for _, v in pairs(ents.FindByName(self.Targets.Model)) do
			if IsValid(v) and v:GetName() == self.Targets.Model then
				self.Entities.Model = v
			end
		end

	end

	return self.Entities.Model
	
end


/*---------------------------------------------------------
	Bosses
---------------------------------------------------------*/
GM.Bosses = {}
GM.ValidBossEntities = { "math_counter", "func_physbox_multiplayer" }
-- AddBoss( name, model entity, math counter )
function GM:AddBoss(name, propEnt, healthEnt)

	local boss = BOSS:Setup(name,propEnt,healthEnt)
	table.insert(self.Bosses, boss)

end

-- return boss table
function GM:GetBoss(ent)

	if self.CVars.BossDebug:GetInt() == 2 then
		Msg("REQUESTING BOSS\n")
		Msg(ent)
		Msg("\n")
	end

	if !table.HasValue(self.ValidBossEntities, ent:GetClass()) then
		return
	end

	if self.CVars.BossDebug:GetInt() == 1 then
		Msg("REQUESTING BOSS\n")
		Msg(ent)
		Msg("\n")
	end

	for _, boss in pairs(self.Bosses) do
		if boss:HasCounter(ent) then
			if self.CVars.BossDebug:GetInt() > 0 then
				Msg("FOUND BOSS\n")
				Msg(boss)
				Msg("\n")
			end
			return boss
		end
	end
	
	return nil

end


/*---------------------------------------------------------
	Boss Updates
---------------------------------------------------------*/
function GM:BossDamageTaken(ent, activator)

	if !IsValid(ent) then return end
	if self.NextBossUpdate && self.NextBossUpdate > CurTime() then return end -- prevent umsg spam

	local boss = self:GetBoss(ent)
	if boss then
		
		if !boss:IsValid() then return end

		if !boss.bInitialized then

			net.Start("BossSpawn")
				net.WriteFloat( boss:GetClientModel():EntIndex() )
				net.WriteString( boss:GetName() )
			net.Broadcast()

			boss.bInitialized = true

		end

		net.Start("BossTakeDamage")
			net.WriteFloat( boss:GetClientModel():EntIndex() )
			net.WriteFloat( boss:Health() )
			net.WriteFloat( boss:MaxHealth() )
		net.Broadcast()
		
		if self.CVars.BossDebug:GetInt() > 0 then
			Msg("BOSS TAKE DAMAGE:\n")
			Msg("\tMath: " .. tostring(boss:GetCounter()) .. "\n")
			Msg("\tProp: " .. tostring(boss:GetClientModel()) .. "\n")
			Msg("\tActivator: " .. tostring(activator) .. "\n")
		end

		self.NextBossUpdate = CurTime() + 0.15

	end

end

function GM:BossDeath(ent, activator)

	if !IsValid(ent) then return end

	local boss = self:GetBoss(ent)
	if boss then
		
		if !boss:IsValid() or !boss.bInitialized then return end

		net.Start("BossDefeated")
			net.WriteFloat( boss:GetClientModel():EntIndex() )
		net.Broadcast()

		boss.bInitialized = false
		boss.KilledOnRound = GAMEMODE:GetRound()

		if self.CVars.BossDebug:GetInt() > 0 then
			Msg("BOSS DEFEATED:\n")
			Msg("\tMath: " .. tostring(boss:GetCounter()) .. "\n")
			Msg("\tProp: " .. tostring(boss:GetClientModel()) .. "\n")
			Msg("\tActivator: " .. tostring(activator) .. "\n")
		end

		gamemode.Call("OnBossDefeated", boss, activator)

	end

end

function GM:MathCounterUpdate(ent, activator)
	self:BossDamageTaken(ent, activator)
end

function GM:MathCounterHitMin(ent, activator)
	self:BossDeath(ent, activator)
end

-- Physbox boss handling
hook.Add("EntityTakeDamage", "PhysboxTakeDamage", function( ent, dmginfo )
	GAMEMODE:BossDamageTaken(ent, dmginfo:GetAttacker())
end)

hook.Add("EntityRemoved", "PhysboxRemoved", function(ent)
	GAMEMODE:BossDeath(ent, nil)
end)