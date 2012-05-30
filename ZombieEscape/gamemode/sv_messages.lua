/*---------------------------------------------------------
	Sent from point_servercommand entities
---------------------------------------------------------*/
function GM:SendMapMessage(str)

	if self:ShouldIgnoreMessage(string.lower(str)) then return end

	Msg("[ZE] "..tostring(str).."\n")

	umsg.Start("MapMessage")
		umsg.String(str)
	umsg.End()

end

-- Messages may be found by enabling 'developer 2'
-- in SP or browsing a bsp's entity lump
GM.MessagesToIgnore = {}
function GM:IgnoreMessages(tbl)
	for _, msg in pairs(tbl) do
		table.insert(self.MessagesToIgnore, string.lower(msg))
	end
end

function GM:ShouldIgnoreMessage(str)
	for _, v in pairs(self.MessagesToIgnore) do
		if string.find(str,v) then
			return true
		end
	end
	return false
end