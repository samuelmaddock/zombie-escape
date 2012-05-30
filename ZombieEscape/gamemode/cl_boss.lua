/*---------------------------------------------------------
	Boss Health
---------------------------------------------------------*/
GM.BossEntities = {}
GM.LastBossUpdate = RealTime()

surface.CreateFont( "Impact", 24, 400, true, false, "BossFont" )
local gradientUp = surface.GetTextureID("VGUI/gradient_up")
local maxBarHealth = 100
local deltaVelocity = 0.08 -- [0-1]
local bw = 12 -- bar segment width
local padding = 2
local colGreen = Color( 129, 215, 30, 255 )
local colDarkGreen = Color( 50, 83, 35, 255 )
local colDarkRed = Color( 132, 43, 24, 255 )
local curPercent = nil
function GM:BossHealth()
	for k, boss in pairs(self.BossEntities) do

		if !IsValid(boss.Ent) or boss.Health <= 0 then self.BossEntities[k] = nil return end
		if (LocalPlayer():GetPos() - boss.Ent:GetPos()):Length() > 4096 then return end

		-- Let's do some calculations first
		maxBarHealth = (boss.MaxHealth > 1000) and 1000 or 100
		local name = boss.Name and boss.Name or "BOSS"
		local totalHealthBars = math.ceil(boss.MaxHealth / maxBarHealth)
		local curHealthBar = math.floor(boss.Health / maxBarHealth)
		local percent = (boss.Health - curHealthBar*maxBarHealth) / maxBarHealth
		curPercent = !curPercent and 1 or math.Approach(curPercent, percent, math.abs(curPercent-percent)*0.08)

		local x, y = ScrW()/2, 80
		local w, h = ScrW()/3, 20

		-- Boss name
		surface.SetFont("BossFont")
		local tw, th = surface.GetTextSize(name)
		local x3, y3 = x-(w/2), y + h - padding*2
		local w3, h3 = tw + padding*4, th + padding
		draw.RoundedBox( 4, x3, y3, w3, h3, Color( 0, 0, 0, 255 ) )
		draw.SimpleText(name, "BossFont", x3 + padding*2, y3 + padding, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		
		-- Boss health bar segments
		local rw, rh = (bw + padding)*totalHealthBars + padding, th + padding
		local x4, y4 = x+(w/2)-rw, y + h - padding*2
		draw.RoundedBox( 4, x4, y4, rw, rh, Color( 0, 0, 0, 255 ) )

		for i=0,totalHealthBars-1 do
			local col = (i<curHealthBar) and colGreen or colDarkGreen
			draw.RoundedBox( 4, x4 + (bw + padding)*i + padding, y4 + padding*3, bw, bw + padding*2, col )
		end

		-- Health bar background
		draw.RoundedBox( 4, x-(w/2), y, w, h, Color( 0, 0, 0, 255 ) )

		-- Boss health bar
		local x2, y2 = x-(w/2) + padding, y + padding
		local w2, h2 = w - padding*2, h - padding*2
		draw.RoundedBox( 4, x2, y2, w2, h2, colDarkGreen ) -- dark green background
		draw.RoundedBox( 0, x2, y2, w*curPercent - padding*2, h2, colGreen )

		surface.SetDrawColor(0,0,0,100)
		surface.SetTexture(gradientUp)
		surface.DrawTexturedRect( x2, y2, w2, h2 )

	end
end

function RecieveBossSpawn( um )

	local index = um:ReadShort()
	local name = um:ReadString()
	
	local boss = GAMEMODE.BossEntities[index]
	if !boss then
		GAMEMODE.BossEntities[index] = {}
		boss = GAMEMODE.BossEntities[index]
		boss.Ent = Entity(index)
		boss.Name = string.upper(name)
		boss.bSpawned = true

		Msg(name .. " boss has spawned.\n")
	end


end
usermessage.Hook( "BossSpawn", RecieveBossSpawn )

function RecieveBossUpdate( um )

	local index = um:ReadShort()
	local health, maxhealth = um:ReadShort(), um:ReadShort()
	
	local boss = GAMEMODE.BossEntities[index]
	if !boss then
		--Msg("Received boss update for non-existant boss.\n")
		GAMEMODE.BossEntities[index] = {}
		boss = GAMEMODE.BossEntities[index]
		boss.Ent = Entity(index)
	end
	
	boss.Health = health
	boss.MaxHealth = maxhealth
	--Msg("BOSS UPDATE " .. tostring(GAMEMODE.BossEntities[index].Ent) .. "\t" .. health .. "\t" .. boss.MaxHealth .. "\n")

	GAMEMODE.LastBossUpdate = RealTime()

end
usermessage.Hook( "BossTakeDamage", RecieveBossUpdate )

function RecieveBossDefeated( um )

	local index = um:ReadShort()
		
	if !GAMEMODE.BossEntities[index] then
		--Msg("Warning: Received boss death for non-existant boss!\n")
	else
		--Msg("BOSS DEATH " .. tostring(GAMEMODE.BossEntities[index].Ent) .. "\n")
		GAMEMODE.BossEntities[index] = nil
	end
	
end
usermessage.Hook( "BossDefeated", RecieveBossDefeated )