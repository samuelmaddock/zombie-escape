util.AddNetworkString( "DamageNotes" )

hook.Add( "EntityTakeDamage", "RelayDamage", function( ent, dmginfo )
	
	local inflictor = dmginfo:GetInflictor()
	local attacker = dmginfo:GetAttacker()
	local amount = dmginfo:GetDamage()

	if !IsValid(ent) or !IsValid(inflictor) or ent:IsNPC() then return end
	
	if ent:IsPlayer() then

		-- Send damage display to players
		if inflictor:IsPlayer() and !inflictor:IsZombie() and ( !inflictor.LastDamageNote or inflictor.LastDamageNote < CurTime() ) and ent:IsZombie() then

			local offset = Vector( math.random(-8,8), math.random(-8,8), math.random(-8,8) )
			net.Start("DamageNotes")
				net.WriteFloat(math.Round(amount))
				net.WriteVector(ent:GetPos() + offset)
			net.Send(inflictor)
			
			inflictor.LastDamageNote = CurTime() + 0.15 -- prevent spamming of damage notes

		end

	end
	
end )