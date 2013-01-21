local PlayerMeta = FindMetaTable( "Player" )
if !PlayerMeta then return end

local TimerDelay = 0.15 -- delay to allow damage to accumulate and prevent networking congestion

function PlayerMeta:EnqueueDamageNote( ent, amount )

	-- Ignore damage too small
	if amount < 1 then return end

	-- Setup damage notes table
	if !self.DamageNotes then
		self.DamageNotes = {}
	end

	-- Sum total damage delt
	local dmg = self.DamageNotes[ent]
	self.DamageNotes[ent] = dmg and (dmg + amount) or amount

	-- Check timer
	local TimerName = "DamageNote" .. ent:EntIndex()
	local TimerFunc = function()

		if !IsValid(self) or !IsValid(ent) then return end

		local totaldmg = self.DamageNotes[ent]
		local offset = Vector( math.random(-8,8), math.random(-8,8), math.random(-8,8) )

		net.Start("DamageNotes")
			net.WriteFloat( math.Round(totaldmg) )
			net.WriteVector( ent:GetPos() + offset )
		net.Send(self)

		self.DamageNotes[ent] = nil

		timer.Destroy( TimerName )

	end

	if !timer.Exists( TimerName ) then
		timer.Create( TimerName, TimerDelay, 1, TimerFunc )
	end

end