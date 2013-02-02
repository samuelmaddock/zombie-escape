AddCSLuaFile()
DEFINE_BASECLASS( "player_ze" )

if ( CLIENT ) then

	CreateConVar( "cl_playercolor", "0.24 0.34 0.41", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The value is a Vector - so between 0-1 - not between 0-255" )
	-- CreateConVar( "cl_weaponcolor", "0.30 1.80 2.10", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "The value is a Vector - so between 0-1 - not between 0-255" )

end

local PLAYER = {}

PLAYER.DisplayName			= "ZE Base"

PLAYER.DuckSpeed			= 0.3		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed			= 0.3		-- How fast to go from ducking, to not ducking
PLAYER.JumpPower			= 205		-- How powerful our jump should be
PLAYER.DropWeaponOnDie		= false		-- Do we drop our weapon when we die
PLAYER.TeammateNoCollide 	= true		-- Do we collide with teammates or run straight through them
PLAYER.AvoidPlayers			= false		-- Automatically swerves around other players


--
-- Set up the network table accessors
--
function PLAYER:SetupDataTables()
end

--
-- Called when the class object is created (shared)
--
function PLAYER:Init()

end

--
-- Called serverside only when the player spawns
--
function PLAYER:Spawn()

end

--
-- Called on spawn to give the player their default loadout
--
function PLAYER:Loadout()

end

-- Clientside only
function PLAYER:CalcView( view ) end
function PLAYER:CreateMove( cmd ) end		-- Creates the user command on the client
function PLAYER:ShouldDrawLocal() end		-- Return true if we should draw the local player

-- Shared
function PLAYER:StartMove( cmd, mv ) end	-- Copies from the user command to the move
function PLAYER:Move( mv ) end				-- Runs the move (can run multiple times for the same client)
function PLAYER:FinishMove( mv ) end		-- Copy the results of the move back to the Player

-- Called from timer every second
function PLAYER:Think()

	-- For some reason, some maps strip the player's HEV suit
	if SERVER and self.Player:Alive() and !self.Player:IsSuitEquipped() then
		self.Player:EquipSuit()
		self.Player:GiveWeapons()
	end

end

/*---------------------------------------------------------------------------
	Animations
---------------------------------------------------------------------------*/
function PLAYER:HandlePlayerJumping( velocity )

	if ( self.Player:GetMoveType() == MOVETYPE_NOCLIP ) then
		self.Player.m_bJumping = false;
		return
	end

	-- airwalk more like hl2mp, we airwalk until we have 0 velocity, then it's the jump animation
	-- underwater we're alright we airwalking
	if ( !self.Player.m_bJumping && !self.Player:OnGround() && self.Player:WaterLevel() <= 0 ) then
	
		if ( !self.Player.m_fGroundTime ) then

			self.Player.m_fGroundTime = CurTime()
			
		elseif (CurTime() - self.Player.m_fGroundTime) > 0 && velocity:Length2D() < 0.5 then

			self.Player.m_bJumping = true
			self.Player.m_bFirstJumpFrame = false
			self.Player.m_flJumpStartTime = 0

		end
	end
	
	if self.Player.m_bJumping then
	
		if self.Player.m_bFirstJumpFrame then

			self.Player.m_bFirstJumpFrame = false
			self.Player:AnimRestartMainSequence()

		end
		
		if ( self.Player:WaterLevel() >= 2 ) ||	( (CurTime() - self.Player.m_flJumpStartTime) > 0.2 && self.Player:OnGround() ) then

			self.Player.m_bJumping = false
			self.Player.m_fGroundTime = nil
			self.Player:AnimRestartMainSequence()

		end
		
		if self.Player.m_bJumping then
			self.Player.CalcIdeal = ACT_MP_JUMP
			return true
		end
	end
	
	return false
end

function PLAYER:HandlePlayerDucking( velocity )

	if ( !self.Player:Crouching() ) then return false end

	if ( velocity:Length2D() > 0.5 ) then
		self.Player.CalcIdeal = ACT_MP_CROUCHWALK
	else
		self.Player.CalcIdeal = ACT_MP_CROUCH_IDLE
	end
		
	return true

end

function PLAYER:HandlePlayerNoClipping( velocity )

	if ( self.Player:InVehicle() ) then return end

	if ( self.Player:GetMoveType() != MOVETYPE_NOCLIP ) then 

		if ( self.Player.m_bWasNoclipping ) then

			self.Player.m_bWasNoclipping = nil
			self.Player:AnimResetGestureSlot( GESTURE_SLOT_CUSTOM )
			if ( CLIENT ) then self.Player:SetIK( true ); end

		end

		return

	end

	if ( !self.Player.m_bWasNoclipping ) then

		self.Player:AnimRestartGesture( GESTURE_SLOT_CUSTOM, ACT_GMOD_NOCLIP_LAYER, false )
		if ( CLIENT ) then self.Player:SetIK( false ); end

	end

			
	return true

end

function PLAYER:HandlePlayerVaulting( velocity )

	if ( velocity:Length() < 1000 ) then return end
	if ( self.Player:IsOnGround() ) then return end

	self.Player.CalcIdeal = ACT_MP_SWIM		
	return true

end

function PLAYER:HandlePlayerSwimming( velocity )

	if ( self.Player:WaterLevel() < 2 ) then 
		self.Player.m_bInSwim = false
		return false 
	end
	
	if ( velocity:Length2D() > 10 ) then
		self.Player.CalcIdeal = ACT_MP_SWIM
	else
		self.Player.CalcIdeal = ACT_MP_SWIM_IDLE
	end
		
	self.Player.m_bInSwim = true
	return true
	
end

function PLAYER:HandlePlayerLanding( velocity, WasOnGround ) 

	if ( self.Player:GetMoveType() == MOVETYPE_NOCLIP ) then return end

	if ( self.Player:IsOnGround() && !WasOnGround ) then
		self.Player:AnimRestartGesture( GESTURE_SLOT_JUMP, ACT_LAND, true );
	end

end

function PLAYER:HandlePlayerDriving()

	if self.Player:InVehicle() then
		local pVehicle = self.Player:GetVehicle()
		
		if ( pVehicle.HandleAnimation != nil ) then
		
			local seq = pVehicle:HandleAnimation( self.Player )
			if ( seq != nil ) then
				self.Player.CalcSeqOverride = seq
				return true
			end
			
		else
		
			local class = pVehicle:GetClass()
			
			if ( class == "prop_vehicle_jeep" ) then
				self.Player.CalcSeqOverride = self.Player:LookupSequence( "drive_jeep" )
			elseif ( class == "prop_vehicle_airboat" ) then
				self.Player.CalcSeqOverride = self.Player:LookupSequence( "drive_airboat" )
			elseif ( class == "prop_vehicle_prisoner_pod" && pVehicle:GetModel() == "models/vehicles/prisoner_pod_inner.mdl" ) then
				-- HACK!!
				self.Player.CalcSeqOverride = self.Player:LookupSequence( "drive_pd" )
			else
				self.Player.CalcSeqOverride = self.Player:LookupSequence( "sit_rollercoaster" )
			end
			
			return true
		end
	end
	
	return false
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

--
-- If you don't want the player to grab his ear in your gamemode then
-- just override this.
--
function PLAYER:GrabEarAnimation()	

	self.Player.ChatGestureWeight = self.Player.ChatGestureWeight or 0

	-- Don't show this when we're playing a taunt!
	if ( self.Player:IsPlayingTaunt() ) then return end

	if ( self.Player:IsTyping() ) then
		self.Player.ChatGestureWeight = math.Approach( self.Player.ChatGestureWeight, 1, FrameTime() * 5.0 );
	else
		self.Player.ChatGestureWeight = math.Approach( self.Player.ChatGestureWeight, 0, FrameTime()  * 5.0 );
	end
	
	if ( self.Player.ChatGestureWeight > 0 ) then
	
		self.Player:AnimRestartGesture( GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true )
		self.Player:AnimSetGestureWeight( GESTURE_SLOT_VCD, self.Player.ChatGestureWeight )
		
	end

end

--
-- Moves the mouth when talking on voicecom
--
function PLAYER:MouthMoveAnimation()

	local FlexNum = self.Player:GetFlexNum() - 1
	if ( FlexNum <= 0 ) then return end
	
	for i=0, FlexNum-1 do
	
		local Name = self.Player:GetFlexName( i )

		if ( Name == "jaw_drop" || Name == "right_part" || Name == "left_part" || Name == "right_mouth_drop" || Name == "left_mouth_drop"  ) then

			if ( self.Player:IsSpeaking() ) then
				self.Player:SetFlexWeight( i, math.Clamp( self.Player:VoiceVolume() * 2, 0, 2 ) )
			else
				self.Player:SetFlexWeight( i, 0 )
			end
		end
		
	end
	
end

function PLAYER:CalcMainActivity( velocity )

	self.Player.CalcIdeal = ACT_MP_STAND_IDLE
	self.Player.CalcSeqOverride = -1

	self:HandlePlayerLanding( velocity, self.Player.m_bWasOnGround );
	
	if ( self:HandlePlayerNoClipping( velocity ) ||
		self:HandlePlayerDriving() ||
		self:HandlePlayerVaulting( velocity ) ||
		self:HandlePlayerJumping( velocity ) ||
		self:HandlePlayerDucking( velocity ) ||
		self:HandlePlayerSwimming( velocity ) ) then
		
	else

		local len2d = velocity:Length2D()
		if ( len2d > 150 ) then self.Player.CalcIdeal = ACT_MP_RUN elseif ( len2d > 0.5 ) then self.Player.CalcIdeal = ACT_MP_WALK end

	end
	
	-- a bit of a hack because we're missing ACTs for a couple holdtypes
	local weapon = self.Player:GetActiveWeapon()
	local ht = "pistol"

	if ( IsValid( weapon ) ) then ht = weapon:GetHoldType() end
	
	if ( self.Player.CalcIdeal == ACT_MP_CROUCH_IDLE &&	( ht == "knife" || ht == "melee2" ) ) then
		self.Player.CalcSeqOverride = self.Player:LookupSequence("cidle_" .. ht)
	end

	self.Player.m_bWasOnGround = self.Player:IsOnGround()
	self.Player.m_bWasNoclipping = (self.Player:GetMoveType() == MOVETYPE_NOCLIP)

	return self.Player.CalcIdeal, self.Player.CalcSeqOverride

end

local IdleActivity = ACT_HL2MP_IDLE
local IdleActivityTranslate = {}
	IdleActivityTranslate [ ACT_MP_STAND_IDLE ] 				= IdleActivity
	IdleActivityTranslate [ ACT_MP_WALK ] 						= IdleActivity+1
	IdleActivityTranslate [ ACT_MP_RUN ] 						= IdleActivity+2
	IdleActivityTranslate [ ACT_MP_CROUCH_IDLE ] 				= IdleActivity+3
	IdleActivityTranslate [ ACT_MP_CROUCHWALK ] 				= IdleActivity+4
	IdleActivityTranslate [ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] 	= IdleActivity+5
	IdleActivityTranslate [ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ]	= IdleActivity+5
	IdleActivityTranslate [ ACT_MP_RELOAD_STAND ]		 		= IdleActivity+6
	IdleActivityTranslate [ ACT_MP_RELOAD_CROUCH ]		 		= IdleActivity+6
	IdleActivityTranslate [ ACT_MP_JUMP ] 						= ACT_HL2MP_JUMP_SLAM
	IdleActivityTranslate [ ACT_MP_SWIM_IDLE ] 					= ACT_MP_SWIM_IDLE
	IdleActivityTranslate [ ACT_MP_SWIM ] 						= ACT_MP_SWIM
	IdleActivityTranslate [ ACT_LAND ] 							= ACT_LAND
	
-- it is preferred you return ACT_MP_* in CalcMainActivity, and if you have a specific need to not tranlsate through the weapon do it here
function PLAYER:TranslateActivity( act )

	local act = act
	local newact = self.Player:TranslateWeaponActivity( act )
	
	-- select idle anims if the weapon didn't decide
	if ( act == newact ) then
		return IdleActivityTranslate[ act ]
	end
	
	return newact

end

function PLAYER:DoAnimationEvent( event, data )
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
	
		if self.Player:Crouching() then
			self.Player:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_CROUCH_PRIMARYFIRE, true )
		else
			self.Player:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_STAND_PRIMARYFIRE, true )
		end
		
		return ACT_VM_PRIMARYATTACK
	
	elseif event == PLAYERANIMEVENT_ATTACK_SECONDARY then
	
		-- there is no gesture, so just fire off the VM event
		return ACT_VM_SECONDARYATTACK
		
	elseif event == PLAYERANIMEVENT_RELOAD then
	
		if self.Player:Crouching() then
			self.Player:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_CROUCH, true )
		else
			self.Player:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_STAND, true )
		end
		
		return ACT_INVALID
		
	elseif event == PLAYERANIMEVENT_JUMP then
	
		self.Player.m_bJumping = true
		self.Player.m_bFirstJumpFrame = true
		self.Player.m_flJumpStartTime = CurTime()
		
		self.Player:AnimRestartMainSequence()
		
		return ACT_INVALID
		
	elseif event == PLAYERANIMEVENT_CANCEL_RELOAD then
	
		self.Player:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )
		
		return ACT_INVALID
	end

	return nil
end

player_manager.RegisterClass( "player_ze", PLAYER, "player_default" )