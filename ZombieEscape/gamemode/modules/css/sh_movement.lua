-- Movement ended up being too laggy. So, I'm removing it for now.
if true then return end

local STAMINA_MAX = 100
local STAMINA_COST_JUMP = 25
local STAMINA_COST_FALL = 20
local STAMINA_RECOVER_RATE = 19
local CS_WALK_SPEED = 100

local function ReduceTimers( ply )

	local frame_msec = 1000 * FrameTime()

	-- Reduce stamina value over time
	if ply:GetStamina() > 0 then
		ply:SetStamina( ply:GetStamina() - frame_msec )

		if ply:GetStamina() < 0 then
			ply:SetStamina( 0 )
		end
	end

end

local lastJump = 0
local function CheckJumpButton( ply, mv )

	-- Check for first instance of new jump
	if ply.m_flJumpStartTime and (CurTime() - ply.m_flJumpStartTime) < 0.2 and lastJump != ply.m_flJumpStartTime then

		-- Modify velocity if stamina is higher than zero (recently jumped)
		if ply:GetStamina() > 0 then
			local flRatio = ( STAMINA_MAX - ( ( ply:GetStamina()  / 1000.0 ) * STAMINA_RECOVER_RATE ) ) / STAMINA_MAX
			local vel = mv:GetVelocity()
			vel.z = vel.z * flRatio
			mv:SetVelocity( vel )
		end

		ply:SetStamina( (STAMINA_COST_JUMP / STAMINA_RECOVER_RATE) * 1000 )

		lastJump = ply.m_flJumpStartTime

	end

end

local ground, world
local lastnull = 0
local function CSSMove( ply, mv )

	if ply:Alive() then

		ReduceTimers( ply )
		CheckJumpButton( ply, mv )

		ground = ply:GetGroundEntity()
		world = SERVER and game.GetWorld() or Entity(0)

		if ply:OnGround() and (IsValid(ground) or ground == world) then

			-- Server seems to report both null and valid when not on the ground
			if SERVER and CurTime() - lastnull < 0.01 then
				return
			end

			-- CSS speed reduction from landing on ground
			if ply:GetVelocityModifier() < 1.0 then
				ply:SetVelocityModifier( ply:GetVelocityModifier() + FrameTime() / 3.0 )
			elseif ply:GetVelocityModifier() > 1.0 then
				ply:SetVelocityModifier( 1.0 )
			end

			if ply:GetStamina() > 0 then
				local flRatio = ( STAMINA_MAX - ( ( ply:GetStamina() / 1000.0 ) * STAMINA_RECOVER_RATE ) ) / STAMINA_MAX
			
				local flReferenceFrametime = 1.0 / 70.0
				local flFrametimeRatio = FrameTime() / flReferenceFrametime

				flRatio = math.pow( flRatio, flFrametimeRatio )

				local vel = mv:GetVelocity()
				vel.x = vel.x * flRatio
				vel.y = vel.y * flRatio
				mv:SetVelocity( vel )
			end

		else
			lastnull = CurTime()
		end

		mv:SetMaxSpeed( mv:GetMaxSpeed() * ply:GetVelocityModifier() )

	end

end
hook.Add( "Move", "CSSMove", CSSMove )

if SERVER then

	hook.Add( "OnPlayerHitGround", "VelocityModify", function( ply, bInWater, bOnFloater, flFallSpeed )
		if ply:GetAbsVelocity():Length() < 300 then
			ply:SetVelocityModifier( 0.65 )
		else
			ply:SetVelocityModifier( 0.5 )
		end
	end )

	hook.Add( "PlayerSpawn", "CSSVarSet", function( ply )

		ply:SetVelocityModifier( 1.0 )
		ply:SetStamina( 0.0 )

	end )

end