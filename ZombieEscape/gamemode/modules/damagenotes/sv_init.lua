util.AddNetworkString( "DamageNotes" )

function OnDamageDelt( ent, dmginfo )
	
	local inflictor = dmginfo:GetInflictor()
	local attacker = dmginfo:GetAttacker()
	local amount = dmginfo:GetDamage()

	if !IsValid(inflictor) or !IsValid(ent) or ent:IsNPC() then return end
	
	-- Send damage display to players
	if ent:IsPlayer() and ent:IsZombie() then

		if inflictor:IsPlayer() and !inflictor:IsZombie() then
			inflictor:EnqueueDamageNote( ent, amount )
		elseif attacker:IsPlayer() and !attacker:IsZombie() then
			attacker:EnqueueDamageNote( ent, amount )
		end

	end
	
end
hook.Add( "EntityTakeDamage", "RelayDamageNote", OnDamageDelt )
hook.Add( "OnDamagedByExplosion", "RelayDamageNoteExplosion", OnDamageDelt )