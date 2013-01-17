local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:SendMessage(str)
	if !str then return end
	net.Start("MapMessage")
		net.WriteString(str)
	net.Send(self)
end