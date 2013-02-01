local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:Zombify()
	
	-- Zombies shouldn't be holding ZE map/weapon pickups
	local pickup = self:GetPickupEntity()
	if IsValid(pickup) then
		pickup:Remove()
	end
	
	self.bMotherZombie = false
	self:GoTeam(TEAM_ZOMBIES, true) -- respawning causes stuck issues
	
	GAMEMODE:RoundChecks() -- check for winner

end

function PlayerMeta:ZScream()
	self:EmitSound( GAMEMODE.ZombieScream )
	self.LastScream = CurTime()
end

function PlayerMeta:ZMoan()
	self:EmitRandomSound(GAMEMODE.ZombieMoan)
	self.NextMoan = CurTime() + math.random(30,90)
end

function PlayerMeta:IsMotherZombie()
	return self:IsZombie() and self.bMotherZombie
end

function PlayerMeta:CheckIgnite()

	if self:IsOnFire() then

		-- Reduced speed has already been set
		if self._ReducedSpeed then

			-- Player is in the water and should be extinguished
			if self:WaterLevel() >= 2 then
				self:Extinguish()
			end

		else -- Zombie has been ignited

			-- Reduce zombie speed to half
			self._ReducedSpeed = true
			self:SetSpeed( math.Round(CVars.ZSpeed:GetInt() * 0.5) )

		end

	else

		-- Restore default speed
		if self._ReducedSpeed then
			self:SetSpeed(CVars.ZSpeed:GetInt())
			self._ReducedSpeed = nil
		end
		
	end

end