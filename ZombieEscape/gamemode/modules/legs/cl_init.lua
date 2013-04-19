local cl_legs = CreateConVar( "cl_drawlegs", "1", { FCVAR_ARCHIVE, }, "Enable/Disable the rendering of the legs" )

local Legs = {
	BoneHoldTypes = { -- Can change to whatever you want, I think these two look best
		["none"] = {
			"ValveBiped.Bip01_Head1",
			"ValveBiped.Bip01_Neck1",
			"ValveBiped.Bip01_Spine4",
			"ValveBiped.Bip01_Spine2",
		},
		["default"] = { -- The default bones to be hidden if there is no hold type bones
			"ValveBiped.Bip01_Head1",
			"ValveBiped.Bip01_Neck1",
			"ValveBiped.Bip01_Spine4",
			"ValveBiped.Bip01_Spine2",
			/*"ValveBiped.Bip01_L_Hand",
			"ValveBiped.Bip01_L_Forearm",
			"ValveBiped.Bip01_L_Upperarm",
			"ValveBiped.Bip01_L_Clavicle",
			"ValveBiped.Bip01_R_Hand",
			"ValveBiped.Bip01_R_Forearm",
			"ValveBiped.Bip01_R_Upperarm",
			"ValveBiped.Bip01_R_Clavicle",
			"ValveBiped.Bip01_L_Finger4", "ValveBiped.Bip01_L_Finger41", "ValveBiped.Bip01_L_Finger42",
			"ValveBiped.Bip01_L_Finger3", "ValveBiped.Bip01_L_Finger31", "ValveBiped.Bip01_L_Finger32",
			"ValveBiped.Bip01_L_Finger2", "ValveBiped.Bip01_L_Finger21", "ValveBiped.Bip01_L_Finger22",
			"ValveBiped.Bip01_L_Finger1", "ValveBiped.Bip01_L_Finger11", "ValveBiped.Bip01_L_Finger12",
			"ValveBiped.Bip01_L_Finger0", "ValveBiped.Bip01_L_Finger01", "ValveBiped.Bip01_L_Finger02",
			"ValveBiped.Bip01_R_Finger4", "ValveBiped.Bip01_R_Finger41", "ValveBiped.Bip01_R_Finger42",
			"ValveBiped.Bip01_R_Finger3", "ValveBiped.Bip01_R_Finger31", "ValveBiped.Bip01_R_Finger32",
			"ValveBiped.Bip01_R_Finger2", "ValveBiped.Bip01_R_Finger21", "ValveBiped.Bip01_R_Finger22",
			"ValveBiped.Bip01_R_Finger1", "ValveBiped.Bip01_R_Finger11", "ValveBiped.Bip01_R_Finger12",
			"ValveBiped.Bip01_R_Finger0", "ValveBiped.Bip01_R_Finger01", "ValveBiped.Bip01_R_Finger02"*/
		},
		["vehicle"] = { -- Bones that are deflated while in a vehicle
			"ValveBiped.Bip01_Head1",
			"ValveBiped.Bip01_Neck1",
			"ValveBiped.Bip01_Spine4",
			"ValveBiped.Bip01_Spine2",
		}
	},
}

local _R = debug.getregistry()

_R.Legs = {}
_R.Legs.__index = _R.Legs

local function CreateLegs() -- Creates our legs

	local ent = ClientsideModel( LocalPlayer():GetTranslatedModel(), RENDER_GROUP_OPAQUE_ENTITY )
	ent:SetNoDraw( true ) -- We render the model differently
	ent:ApplyPlayerProperties( LocalPlayer() )

	return setmetatable( {
		Entity = ent,
		NextBreath = CurTime(),
		LastTick = CurTime(),
		LastWeapon = nil,
		LastSeq = nil,
		ScaleFactor = 1,
	}, _R.Legs )

end

function _R.Legs:IsValid()
	return IsValid( self.Entity )
end

function _R.Legs:ShouldDraw()
	return	cl_legs:GetBool() and
			self:IsValid() and
			LocalPlayer():Alive() and
			GetViewEntity() == LocalPlayer() and
			!LocalPlayer():ShouldDrawLocalPlayer() and
			!LocalPlayer():GetObserverTarget() and
			!LocalPlayer().ShouldDisableLegs
end

function _R.Legs:UpdateAnimation( groundSpeed )

	if self:IsValid() then

		if LocalPlayer():GetActiveWeapon() != self.LastWeapon then  -- Player switched weapons, change the bones for new weapon
			self.LastWeapon = LocalPlayer():GetActiveWeapon()
			self:OnSwitchedWeapon( self.LastWeapon )
		end

		if self.Entity:GetModel() != LocalPlayer():GetTranslatedModel() then -- Player changed model without spawning?
			self.Entity:SetModel( LocalPlayer():GetTranslatedModel() )
		end

		self.Entity:SetMaterial( LocalPlayer():GetMaterial() )
		self.Entity:SetSkin( LocalPlayer():GetSkin() )

		local vel = LocalPlayer():GetVelocity():Length2D()

		local playRate = 1

		if vel > 0.5 then -- Taken from the SDK, gets the proper play back rate
			if groundSpeed < 0.001 then
				playRate = 0.01
			else
				playRate = vel / groundSpeed
				playRate = math.Clamp( playRate, 0.01, 10 )
			end
		end

		self.Entity:SetPlaybackRate( playRate ) -- Change the rate of playback. This is for when you walk faster/slower

		self.Entity:FrameAdvance( CurTime() - self.LastTick ) -- Advance the amount of frames we need
		self.LastTick = CurTime()

		local seq = LocalPlayer():GetSequence()

		if self.LastSeq != seq then
			self.LastSeq = seq
			self.Entity:ResetSequence( seq ) -- If the player changes sequences, change the legs too
		end

		local breathScale = .5

		if self.NextBreath <= CurTime() then -- Only update every cycle, should stop MOST of the jittering
			self.NextBreath = CurTime() + 1.95 / breathScale
			self.Entity:SetPoseParameter( "breathing", breathScale )
		end

		self.Entity:SetPoseParameter( "move_x", ( LocalPlayer():GetPoseParameter( "move_x" ) * 2 ) - 1 ) -- Translate the walk x direction
		self.Entity:SetPoseParameter( "move_y", ( LocalPlayer():GetPoseParameter( "move_y" ) * 2 ) - 1 ) -- Translate the walk y direction
		self.Entity:SetPoseParameter( "move_yaw", ( LocalPlayer():GetPoseParameter( "move_yaw" ) * 360 ) - 180 ) -- Translate the walk direction
		self.Entity:SetPoseParameter( "body_yaw", ( LocalPlayer():GetPoseParameter( "body_yaw" ) * 180 ) - 90 ) -- Translate the body yaw
		self.Entity:SetPoseParameter( "spine_yaw",( LocalPlayer():GetPoseParameter( "spine_yaw" ) * 180 ) - 90 ) -- Translate the spine yaw

		if LocalPlayer():InVehicle() then
			//self.Entity:SetColor( color_transparent )
			self.Entity:SetPoseParameter( "vehicle_steer", ( LocalPlayer():GetVehicle():GetPoseParameter( "vehicle_steer" ) * 2 ) - 1 ) -- Translate the vehicle steering
		end

	end

end

vector_down = vector_up * -1
local renderPos, renderAng, scale, biaisAngle, radAngle, eyePos, eyeAng, col, modelScale

function _R.Legs:Render()

	if self:ShouldDraw() then -- Should the legs be visible this frame?

		eyeAng = LocalPlayer():EyeAngles()
		modelScale = LocalPlayer():GetModelScale()
		renderPos = LocalPlayer():GetPos()
		renderAng = eyeAng

		if renderAng.p < 60 then return end // why draw when they're not looking????
		
		if LocalPlayer():InVehicle() then -- The player is in a vehicle, so we use the vehicles angles, not the LocalPlayer

			renderAng = LocalPlayer():GetVehicle():GetAngles()
			renderAng:RotateAroundAxis( renderAng:Up(), 90 ) -- Fix it
			self.ScaleFactor = modelScale

		else -- This calculates the offset behind the player, adjust the -22 if you want to move it

			self.ScaleFactor = ( modelScale / 2 ) / 1

			biaisAngle = eyeAng
			renderAng = Angle( 0, biaisAngle.y, 0 )

			radAngle = math.rad( biaisAngle.y )
			renderPos.x = renderPos.x + math.cos( radAngle ) * -16
			renderPos.y = renderPos.y + math.sin( radAngle ) * -16
			 
			if LocalPlayer():GetGroundEntity() == NULL then

				renderPos.z = renderPos.z + 8 * self.ScaleFactor -- Crappy jump fix
				if LocalPlayer():KeyDown( IN_DUCK ) then -- Crappy duck fix
					renderPos.z = renderPos.z - 28 * self.ScaleFactor
				end

			end

			// Scale fix
			renderPos.z = renderPos.z + 60 * self.ScaleFactor

		end
		 
		col = LocalPlayer():GetColor()
		eyePos = EyePos()

		local bEnabled = render.EnableClipping( true )
			render.PushCustomClipPlane( vector_down, vector_down:Dot( eyePos ) ) -- Clip the model so if we look up we should never see any part of the legs model
				render.SetColorModulation( col.r / 255, col.g / 255, col.b / 255 ) -- Render the color correctly
					render.SetBlend( col.a / 255 )
						render.SetLightingOrigin( eyePos )
						hook.Call( "PreLegsDraw", GAMEMODE, self.Entity )
							self.Entity:SetRenderOrigin( renderPos )
							self.Entity:SetRenderAngles( renderAng )
							self.Entity:SetupBones()

							if self.Entity:GetModelScale() != self.ScaleFactor then
								self.Entity:SetModelScale( self.ScaleFactor, 0 )
							end

							self.Entity:DrawModel()
						hook.Call( "PostLegsDraw", GAMEMODE, self.Entity )
					render.SetBlend( 1 )
				render.SetColorModulation( 1, 1, 1 )
			render.PopCustomClipPlane()
		render.EnableClipping( bEnabled )

	end

end

function _R.Legs:OnSwitchedWeapon( weap ) -- Different bones will be visible for different hold types

	if IsValid( self.Entity ) then

		local holdType = "none"
	
		if IsValid( weap ) then
			holdType = weap:GetHoldType()
		end

		-- Reset all bones
		for i = 0, self.Entity:GetBoneCount() do
			self.Entity:ManipulateBoneScale( i, Vector(1,1,1) )
			self.Entity:ManipulateBonePosition( i, vector_origin )
		end

		-- Remove bones from being seen
		local bonesToRemove = {
			"ValveBiped.Bip01_Head1"
		}
		
		if !LocalPlayer():InVehicle() then
			bonesToRemove = Legs.BoneHoldTypes[ holdType ] or Legs.BoneHoldTypes[ "default" ]
		else
			bonesToRemove = Legs.BoneHoldTypes[ "vehicle" ]
		end
		
		for _, v in pairs( bonesToRemove ) do -- Loop through desired bones
			local id = self.Entity:LookupBone( v )
			if id then
				self.Entity:ManipulateBoneScale( id, vector_origin )
				self.Entity:ManipulateBonePosition( id, Vector( -5, -10, 0 ) )
			end
		end

	end

end
 
hook.Add( "UpdateAnimation", "Legs:UpdateAnimation", function( ply, vel, groundSpeed )

	if ply == LocalPlayer() then
		if IsValid( ply.Legs ) then
			ply.Legs:UpdateAnimation( groundSpeed ) -- Called every frame. Pass the ground speed for later use
		else
			ply.Legs = CreateLegs() -- No legs, create them. Should only be called once
		end
	end

end )

hook.Add( "PostDrawTranslucentRenderables", "Legs:Render", function()

	if LocalPlayer().Legs then
		LocalPlayer().Legs:Render()
	end

end )