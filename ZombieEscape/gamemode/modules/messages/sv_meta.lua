local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:SendMessage(str)

	if !str then return end

	-- Prevent spam
	if self.LastMessage and self.LastMessage.message == str and CurTime() - self.LastMessage.time < 0.1 then
		return
	end

	net.Start("MapMessage")
		net.WriteString(str)
	net.Send(self)

	if !self.LastMessage then self.LastMessage = {} end

	self.LastMessage.time = CurTime()
	self.LastMessage.message = str

end