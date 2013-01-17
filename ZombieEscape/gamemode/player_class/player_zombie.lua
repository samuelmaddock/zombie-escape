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

	local health = CVars.ZHealthMin:GetInt() + CVars.ZHealthMax:GetInt()*scale
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