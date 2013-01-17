local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:GetKnockbackMultiplier()
	if self:IsZombie() then
		return self:IsMotherZombie() and CVars.ZMotherKnockback:GetFloat() or CVars.ZKnockback:GetFloat()
	else
		return 0.0 -- shouldn't be affected by knockback if player isn't a zombie
	end
end