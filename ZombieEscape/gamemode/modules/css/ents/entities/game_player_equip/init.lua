ENT.Base = "base_point"
ENT.Type = "point"

local SF_PLAYEREQUIP_USEONLY = 1
local MAX_EQUIP = 32

function ENT:Initialize()
	self.m_UseOnly = self.m_UseOnly or false
end

function ENT:AcceptInput(name, activator, caller, data)

	name = string.lower(name)

	if name == "use" then
		self:Use( activator, caller, SIMPLE_USE, data or 0 )
	end

	return true
	
end

local KVIgnore = {'origin','targetname','classname','hammerid'}
function ENT:KeyValue( key, value )
	
	if table.HasValue(KVIgnore,key) then return false end

	if key == "spawnflags" then

		local flags = tonumber(value)
		if flags and flags == SF_PLAYEREQUIP_USEONLY then
			self.m_UseOnly = true
		end

		return true
		
	end

	if !self.BaseClass.KeyValue(self,key,value) then
		
		if !self.m_weapons then
			self.m_weapons = {}
		end

		self.m_weapons[key] = math.max( 1, tonumber(value) or 1 )

		return true

	end

	return false

end

function ENT:Touch( pOther )

	if self.m_UseOnly then return end

	self:EquipPlayer( pOther )

end

function ENT:EquipPlayer( pEntity )

	if !IsValid(pEntity) or !pEntity:IsPlayer() then return end

	for item, count in pairs(self.m_weapons) do
		for i = 1, count do
			pEntity:Give( item )
		end
	end

end

function ENT:Use( activator, caller, type, value )
	self:EquipPlayer( activator )
end