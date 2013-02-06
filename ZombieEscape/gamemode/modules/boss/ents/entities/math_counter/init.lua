ENT.Base = "base_point"
ENT.Type = "point"

function ENT:Initialize()
	-- Any better way I should be doing this?
	if !self.m_OutValue then self.m_OutValue = 0 end
	if !self.m_flMin then self.m_flMin = 0 end
	if !self.m_flMax then self.m_flMax = 0 end

	-- Make sure max and min are ordered properly or clamp won't work.
	if self.m_flMin > self.m_flMax then
		flTemp = self.m_flMax
		self.m_flMax = self.m_flMin
		self.m_flMin = flTemp
	end
	
	-- Clamp initial value to within the valid range.
	if ((self.m_flMin != 0) || (self.m_flMax != 0)) then
		flStartValue = math.Clamp(self.m_OutValue, self.m_flMin, self.m_flMax)
		self.m_OutValue = flStartValue
	end
	
	self.m_bHitMin = false
	self.m_bHitMax = false
	
	self.m_bDisabled = false
end

function ENT:KeyValue( key, value )

	-- Set the initial value of the counter.
	if key == "startvalue" then
		self.m_OutValue = tonumber(value)
	elseif key == "min" then
		self.m_flMin = tonumber(value)
	elseif key == "max" then
		self.m_flMax = tonumber(value)
	end

	self:StoreOutput( key, value )

end

function ENT:AcceptInput( name, activator, caller, data )

	name = string.lower(name)

	local outValue = self.m_OutValue
	local min, max = self.m_flMin, self.m_flMax
	
	local flData = tonumber(data)
	
	--[[Msg("MATH COUNTER INPUT:\n")
	Msg("\tSelf: " .. tostring(self) .. "\n")
	Msg("\tName: " .. tostring(name) .. "\n")
	Msg("\tActivator: " .. tostring(activator) .. "\n")
	Msg("\tCaller: " .. tostring(caller) .. "\n")
	Msg("\tData: " .. tostring(data) .. "\n")]]

	if name == "add" then
	
		local fNewValue = outValue + flData
		self:UpdateOutValue(activator, fNewValue)
		
	elseif name == "divide" and flData != 0 then
	
		local fNewValue = outValue / flData
		self:UpdateOutValue(activator, fNewValue)
		
	elseif name == "multiply" then
	
		local fNewValue = outValue * flData
		self:UpdateOutValue(activator, fNewValue)
		
	elseif name == "setvalue" then
	
		self:UpdateOutValue(activator, flData)
		
	elseif name == "setvaluenofire" then
	
		self:UpdateOutValue(activator, flData, true)
		
	elseif name == "subtract" then
	
		local fNewValue = outValue - flData
		self:UpdateOutValue(activator, fNewValue)
		
	elseif name == "sethitmax" then
	
		self.m_flMax = flData
		if ( self.m_flMax < self.m_flMin ) then
			self.m_flMin = self.m_flMax
		end
		self:UpdateOutValue(nil, self.m_OutValue)
		
	elseif name == "sethitmin" then
	
		self.m_flMin = flData
		if ( self.m_flMax < self.m_flMin ) then
			self.m_flMax = self.m_flMin
		end
		self:UpdateOutValue(nil, self.m_OutValue)
		
	elseif name == "getvalue" then
		-- Update outvalue before firing
		for k, v in pairs(self.Outputs.OnGetValue) do
			v.param = self.m_OutValue
		end
		self:TriggerOutput("OnGetValue", activator)
	elseif name == "enable" then
		self.m_bDisabled = false
	elseif name == "disable" then
		self.m_bDisabled = true	
	else
		return false
	end
	
	-- Setup initial value
	if !self.m_InitialValue || self.m_InitialValue < self:GetOutValue() then
		self.m_InitialValue = self:GetOutValue()
	end
	
	-- Update boss values, but don't send clamped min value
	if !self.m_LastValue || self.m_LastValue != self:GetOutValue() then
		hook.Call("MathCounterUpdate", GAMEMODE, self, activator)
	end
	
	self.m_LastValue = self:GetOutValue()
	
	/*if !self.m_InitialValue || self.m_InitialValue < self:GetOutValue() then -- starting health
		self.m_InitialValue = self:GetOutValue()
		hook.Call("MathCounterUpdate", GAMEMODE, self, activator)
	elseif self.m_LastValue < self:GetOutValue() then -- health was added
		self.m_InitialValue = self:GetOutValue()
		hook.Call("MathCounterUpdate", GAMEMODE, self, activator)
	end*/

	return true
	
end

function ENT:UpdateOutValue(pActivator, fNewValue, bNoOutput)
	if( self.m_bDisabled ) then
		ErrorNoHalt("Math Counter " .. self:GetName() .. " ignoring new value because it is disabled\n")
		return
	end

	if ((self.m_flMin != 0) || (self.m_flMax != 0)) then
		-- Fire an output any time we reach or exceed our maximum value.
		if ( fNewValue >= self.m_flMax ) then
			if ( !self.m_bHitMax ) then
				self.m_bHitMax = true
				self:TriggerOutput("OnHitMax", pActivator)
			end
		else
			self.m_bHitMax = false
		end

		-- Fire an output any time we reach or go below our minimum value.
		if ( fNewValue <= self.m_flMin ) then
			if ( !self.m_bHitMin ) then
				hook.Call("MathCounterHitMin", GAMEMODE, self, pActivator)

				self.m_bHitMin = true
				self:TriggerOutput("OnHitMin", pActivator)
			end
		else
			self.m_bHitMin = false
		end

		fNewValue = math.Clamp(fNewValue, self.m_flMin, self.m_flMax)
	end

	self:SetOutValue(fNewValue, pActivator, bNoOutput)
end

function ENT:SetOutValue(fNewValue, pActivator, bNoOutput)
	self.m_OutValue = fNewValue
	if !bNoOutput and self.Outputs and self.Outputs.OutValue then
		self.Outputs.OutValue[1].param = self.m_OutValue
		self:TriggerOutput("OutValue", pActivator)
	end
end

function ENT:GetOutValue()
	return self.m_OutValue
end

function ENT:UpdateTransmitState()
	return TRANSMIT_NEVER
end

/*function ENT:StoreOutput(name, info)
	local rawData = string.Explode(",",info);
	
	local Output = {}
	Output.entities = rawData[1] or ""
	Output.input = rawData[2] or ""
	Output.param = rawData[3] or ""
	Output.delay = tonumber(rawData[4]) or 0
	Output.times = tonumber(rawData[5]) or -1
	
	self.Outputs = self.Outputs or {}
	self.Outputs[name] = self.Outputs[name] or {}
	
	table.insert(self.Outputs[name], 1, Output);
end*/