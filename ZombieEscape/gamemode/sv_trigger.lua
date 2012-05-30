GM.Triggers = {}
GM.Triggers.Config = {}
GM.Triggers.Entities = {}

function GM:AddTrigger( vMin, vMax, Function )

	if !vMin or !vMax then return end

	local trigger = {
		min = vMin,
		max = vMax,
		f = Function
	}

	table.insert(self.Triggers.Config, trigger)

end

function GM:CreateTriggers()

	self.Triggers.Entities = {}

	for _, v in pairs(self.Triggers.Config) do
		local ent = ents.Create("trigger_ze")
		ent:Setup(v.min,v.max,v.f)
		table.insert(self.Triggers.Entities, ent)
	end

end