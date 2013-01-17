local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:CanPickupEntity()
	return self:IsHuman() and !IsValid(self.PickupEntity)
end

function PlayerMeta:GetPickupEntity()
	return self.PickupEntity
end

function PlayerMeta:SetPickupEntity(ent)
	self.PickupEntity = ent
	ent.TeamOnPickup = self:Team()
	ent:SetOwner(self)
end

function PlayerMeta:DropPickupEntity()

	local ent = self:GetPickupEntity()
	if !IsValid(ent) then return end

	ent:OnDrop()

	self:AnimRestartGesture( GESTURE_SLOT_CUSTOM, ACT_GMOD_GESTURE_ITEM_DROP, true )

	self.PickupEntity = nil

end