AddCSLuaFile()

local PLAYER = {}

PLAYER.DisplayName			= "Zombie"

--
-- Called serverside only when the player spawns
--
function PLAYER:Spawn()

	self.Player:RemoveAllItems()

	local mdl = table.Random(GAMEMODE.ZombieModels)

	 -- Map specific zombie models
	local override = GAMEMODE.PlayerModelOverride[TEAM_ZOMBIES]
	mdl = override and table.Random(override) or mdl
	
	self.Player:SetModel(mdl)
	self.Player:SetFOV(110, 3)

	local scale = math.Clamp( 1 - (#team.GetPlayers(TEAM_BOTH) / GAMEMODE.PlayerScale), 0, 1 )
	scale = (scale > 0.7) and 1 or scale -- only take effect with larger amount of players

	local MinHealth = CVars.ZHealthMin:GetInt()
	local MaxHealth = ( CVars.ZHealthMax:GetInt() - MinHealth ) * scale
	local health = MaxHealth + MinHealth
	self.Player:SetHealth(health)
	self.Player:SetMaxHealth(health)

	self.Player:SetSpeed( CVars.ZSpeed:GetInt() )
	
	self.Player:Flashlight(false)
	self.Player:StripWeapons() -- zombies can't use guns, silly!
	self.Player:Give("zombie_arms")

	self.Player:ZScream()
	
	self.Player.NextHealthRegen = CurTime() + 5
	self.Player.NextMoan = CurTime() + math.random(25,45)

end

--
-- Called on spawn to give the player their default loadout
--
function PLAYER:Loadout()

	self.Player:RemoveAllAmmo()
	self.Player:SwitchToDefaultWeapon()

end

function PLAYER:Think()

	local ply = self.Player

	if SERVER and ply:Alive() then

		-- Zombie moan
		if ply.NextMoan and ply.NextMoan < CurTime() then
			ply:ZMoan()
		end
		
		-- Health regeneration
		if CVars.ZHealthRegen:GetBool() then
			local health = ply:Health()
			if ply.NextHealthRegen && ply.NextHealthRegen < CurTime() && health < ply:GetMaxHealth() then
				local newhealth = math.Clamp( health + math.random(50, 150), 0, ply:GetMaxHealth() )
				ply:SetHealth( newhealth )
				ply.NextHealthRegen = CurTime() + math.random(2,3)
			end
		end
		
		-- Weapon check
		if !ply:HasWeapon("zombie_arms") then
			ply:Give("zombie_arms")
			ply:SelectWeapon("zombie_arms")
		end

		-- Flashlight should always be disabled
		if ply:FlashlightIsOn() then
			ply:Flashlight(false)
		end

		-- Grenade speed reduction
		ply:CheckIgnite()

	end

end

--[[---------------------------------------------------------
   Name: gamemode:UpdateAnimation( )
   Desc: Animation updates (pose params etc) should be done here
-----------------------------------------------------------]]
function PLAYER:UpdateAnimation( velocity, maxseqgroundspeed )	

	local len = velocity:Length()
	local movement = 1.0
	
	if ( len > 0.2 ) then
			movement =  ( len / maxseqgroundspeed )
	end
	
	rate = math.min( movement, 2 )

	-- if we're under water we want to constantly be swimming..
	if ( self.Player:WaterLevel() >= 2 ) then
		rate = math.max( rate, 0.5 )
	elseif ( !self.Player:IsOnGround() && len >= 1000 ) then 
		rate = 0.1;
	end
	
	local weapon = self.Player:GetActiveWeapon()

	self.Player:SetPlaybackRate( rate )
	
	if ( self.Player:InVehicle() ) then

		local Vehicle =  self.Player:GetVehicle()
		
		-- We only need to do this clientside..
		if ( CLIENT ) then
			--
			-- This is used for the 'rollercoaster' arms
			--
			local Velocity = Vehicle:GetVelocity()
			local fwd = Vehicle:GetUp()                       
			local dp = fwd:Dot( Vector(0,0,1) )
			local dp2 = fwd:Dot( Velocity )

			self.Player:SetPoseParameter( "vertical_velocity", (dp<0 and dp or 0)+dp2*0.005 ) 

			-- Pass the vehicles steer param down to the player
			local steer = Vehicle:GetPoseParameter( "vehicle_steer" )
			steer = steer * 2 - 1 -- convert from 0..1 to -1..1
			self.Player:SetPoseParameter( "vehicle_steer", steer  ) 
		end
		
	end
	
	if ( CLIENT ) then
		self:GrabEarAnimation()
		self:MouthMoveAnimation()
	end
	
end

function PLAYER:CalcMainActivity( velocity )

	self.Player.CalcIdeal = ACT_MP_STAND_IDLE
	self.Player.CalcSeqOverride = self.Player:LookupSequence( "zombie_idle" )

	local len2d = velocity:Length2D()
	if ( len2d > 200 ) then
		self.Player.CalcSeqOverride = self.Player:LookupSequence( "zombie_run" )
	elseif ( len2d > 0.5 ) then
		self.Player.CalcSeqOverride = self.Player:LookupSequence( "zombie_walk_03" )
	end

	return self.Player.CalcIdeal, self.Player.CalcSeqOverride

end

function PLAYER:DoAnimationEvent( event, data )

	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
	
		self.Player:AnimRestartGesture( GESTURE_SLOT_CUSTOM, ACT_GMOD_GESTURE_RANGE_ZOMBIE, true )

		return ACT_VM_PRIMARYATTACK
	
	elseif event == PLAYERANIMEVENT_ATTACK_SECONDARY then
	
		-- there is no gesture, so just fire off the VM event
		return ACT_VM_SECONDARYATTACK
		
	elseif event == PLAYERANIMEVENT_JUMP then
	
		self.Player.m_bJumping = true
		self.Player.m_bFirstJumpFrame = true
		self.Player.m_flJumpStartTime = CurTime()
		
		self.Player:AnimRestartMainSequence()
		
		return ACT_INVALID

	elseif event >= PLAYERANIMEVENT_FLINCH_CHEST and event <= PLAYERANIMEVENT_FLINCH_RIGHTLEG then

		self.Player:AnimRestartGesture( GESTURE_SLOT_FLINCH, ACT_FLINCH_PHYSICS, true )

		return ACT_INVALID

	end

	return nil

end

player_manager.RegisterClass( "player_zombie", PLAYER, "player_ze" )