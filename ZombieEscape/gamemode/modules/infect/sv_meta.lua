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