local cl_legs = CreateConVar( "cl_legs", "1", { FCVAR_ARCHIVE, }, "Enable/Disable the rendering of the legs" )
local cl_legs_vehicle = CreateConVar( "cl_legs_vehicle", "0", { FCVAR_ARCHIVE, }, "Enable/Disable the rendering of the legs in a vehicle" )

local Legs = {
	FixedModelNames = { -- Broken model path = key, fixed model path = value
		["models/humans/group01/female_06.mdl"] = "models/player/group01/female_06.mdl",
		["models/humans/group01/female_01.mdl"] = "models/player/group01/female_01.mdl",
		["models/alyx.mdl"] = "models/player/alyx.mdl",
		["models/humans/group01/female_07.mdl"] = "models/player/group01/female_07.mdl",
		["models/charple01.mdl"] = "models/player/charple01.mdl",
		["models/humans/group01/female_04.mdl"] = "models/player/group01/female_04.mdl",
		["models/humans/group03/female_06.mdl"] = "models/player/group03/female_06.mdl",
		["models/gasmask.mdl"] = "models/player/gasmask.mdl",
		["models/humans/group01/female_02.mdl"] = "models/player/group01/female_02.mdl",
		["models/gman_high.mdl"] = "models/player/gman_high.mdl",
		["models/humans/group03/male_07.mdl"] = "models/player/group03/male_07.mdl",
		["models/humans/group03/female_03.mdl"] = "models/player/group03/female_03.mdl",
		["models/police.mdl"] = "models/player/police.mdl",
		["models/breen.mdl"] = "models/player/breen.mdl",
		["models/humans/group01/male_01.mdl"] = "models/player/group01/male_01.mdl",
		["models/zombie_soldier.mdl"] = "models/player/zombie_soldier.mdl",
		["models/humans/group01/male_03.mdl"] = "models/player/group01/male_03.mdl",
		["models/humans/group03/female_04.mdl"] = "models/player/group03/female_04.mdl",
		["models/humans/group01/male_02.mdl"] = "models/player/group01/male_02.mdl",
		["models/kleiner.mdl"] = "models/player/kleiner.mdl",
		["models/humans/group03/female_01.mdl"] = "models/player/group03/female_01.mdl",
		["models/humans/group01/male_09.mdl"] = "models/player/group01/male_09.mdl",
		["models/humans/group03/male_04.mdl"] = "models/player/group03/male_04.mdl",
		["models/player/urban.mbl"] = "models/player/urban.mdl", -- It fucking returns the file type wrong as "mbl" D:
		["models/humans/group03/male_01.mdl"] = "models/player/group03/male_01.mdl",
		["models/mossman.mdl"] = "models/player/mossman.mdl",
		["models/humans/group01/male_06.mdl"] = "models/player/group01/male_06.mdl",
		["models/humans/group03/female_02.mdl"] = "models/player/group03/female_02.mdl",
		["models/humans/group01/male_07.mdl"] = "models/player/group01/male_07.mdl",
		["models/humans/group01/female_03.mdl"] = "models/player/group01/female_03.mdl",
		["models/humans/group01/male_08.mdl"] = "models/player/group01/male_08.mdl",
		["models/humans/group01/male_04.mdl"] = "models/player/group01/male_04.mdl",
		["models/humans/group03/female_07.mdl"] = "models/player/group03/female_07.mdl",
		["models/humans/group03/male_02.mdl"] = "models/player/group03/male_02.mdl",
		["models/humans/group03/male_06.mdl"] = "models/player/group03/male_06.mdl",
		["models/barney.mdl"] = "models/player/barney.mdl",
		["models/humans/group03/male_03.mdl"] = "models/player/group03/male_03.mdl",
		["models/humans/group03/male_05.mdl"] = "models/player/group03/male_05.mdl",
		["models/odessa.mdl"] = "models/player/odessa.mdl",
		["models/humans/group03/male_09.mdl"] = "models/player/group03/male_09.mdl",
		["models/humans/group01/male_05.mdl"] = "models/player/group01/male_05.mdl",
		["models/humans/group03/male_08.mdl"] = "models/player/group03/male_08.mdl",
		--Thanks Jvs
		["models/monk.mdl"] = "models/player/monk.mdl",
		["models/eli.mdl"] = "models/player/eli.mdl",
	},
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
			"ValveBiped.Bip01_L_Hand",
			"ValveBiped.Bip01_L_Forearm",
			"ValveBiped.Bip01_L_Upperarm",
			"ValveBiped.Bip01_L_Clavicle",
			"ValveBiped.Bip01_R_Hand",
			"ValveBiped.Bip01_R_Forearm",
			"ValveBiped.Bip01_R_Upperarm",
			"ValveBiped.Bip01_R_Clavicle",
			"ValveBiped.Bip01_L_Finger4",
			"ValveBiped.Bip01_L_Finger41",
			"ValveBiped.Bip01_L_Finger42",
			"ValveBiped.Bip01_L_Finger3",
			"ValveBiped.Bip01_L_Finger31",
			"ValveBiped.Bip01_L_Finger32",
			"ValveBiped.Bip01_L_Finger2",
			"ValveBiped.Bip01_L_Finger21",
			"ValveBiped.Bip01_L_Finger22",
			"ValveBiped.Bip01_L_Finger1",
			"ValveBiped.Bip01_L_Finger11",
			"ValveBiped.Bip01_L_Finger12",
			"ValveBiped.Bip01_L_Finger0",
			"ValveBiped.Bip01_L_Finger01",
			"ValveBiped.Bip01_L_Finger02",
			"ValveBiped.Bip01_R_Finger4",
			"ValveBiped.Bip01_R_Finger41",
			"ValveBiped.Bip01_R_Finger42",
			"ValveBiped.Bip01_R_Finger3",
			"ValveBiped.Bip01_R_Finger31",
			"ValveBiped.Bip01_R_Finger32",
			"ValveBiped.Bip01_R_Finger2",
			"ValveBiped.Bip01_R_Finger21",
			"ValveBiped.Bip01_R_Finger22",
			"ValveBiped.Bip01_R_Finger1",
			"ValveBiped.Bip01_R_Finger11",
			"ValveBiped.Bip01_R_Finger12",
			"ValveBiped.Bip01_R_Finger0",
			"ValveBiped.Bip01_R_Finger01",
			"ValveBiped.Bip01_R_Finger02"
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

function _R.Player:GetFixedModel() -- For some reason, the client returns the original HL2 version model of the player, not the player model.. Weird right? Only applies to the default player models.
	local mdl = self:GetModel()
	return Legs.FixedModelNames[ mdl ] or mdl
end

_R.Legs = {}
_R.Legs.__index = _R.Legs

local function CreateLegs() -- Creates our legs
	local ent = ClientsideModel( LocalPlayer():GetFixedModel(), RENDER_GROUP_OPAQUE_ENTITY )
	ent:SetNoDraw( true ) -- We render the model differently
	ent:SetSkin( LocalPlayer():GetSkin() )
	ent:SetMaterial( LocalPlayer():GetMaterial() )
	ent.GetPlayerColor = function() return LocalPlayer():GetPlayerColor() end -- Tanks to samm5506 from the Elevator: Source team

	return setmetatable( {
		Entity = ent,
		NextBreath = CurTime(),
		LastTick = CurTime(),
		LastWeapon = nil,
		LastSeq = nil,
	}, _R.Legs )
end

function _R.Legs:IsValid()
	return IsValid( self.Entity )
end

function _R.Legs:ShouldDraw()
	return	cl_legs:GetBool() and
			self:IsValid() and
			LocalPlayer():Alive() and
			( LocalPlayer():InVehicle() and cl_legs_vehicle:GetBool() or !LocalPlayer():InVehicle() ) and
			GetViewEntity() == LocalPlayer() and
			!LocalPlayer():ShouldDrawLocalPlayer() and
			!LocalPlayer():GetObserverTarget() and
			!LocalPlayer().ShouldDisableLegs
end

function _R.Legs:UpdateAnimation( groundSpeed )
	if !self:IsValid() then
		return
	end
	
	if LocalPlayer():GetActiveWeapon() != self.LastWeapon then  -- Player switched weapons, change the bones for new weapon
		self.LastWeapon = LocalPlayer():GetActiveWeapon()
		self:OnSwitchedWeapon( self.LastWeapon )
	end

	if self.Entity:GetModel() != LocalPlayer():GetFixedModel() then -- Player changed model without spawning?
		self.Entity:SetModel( LocalPlayer():GetFixedModel() )
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

	local breathScale = sharpeye and sharpeye.GetStamina and math.Clamp( math.floor( sharpeye.GetStamina() * 5 * 10 ) / 10, 0.5, 5 ) or 0.5 -- More compatability for sharpeye. This changes the models breathing paramaters to go off of sharpeyes stamina system

	if self.NextBreath <= CurTime() then -- Only update every cycle, should stop MOST of the jittering
		self.NextBreath = CurTime() + 1.95 / breathScale
		self.Entity:SetPoseParameter( "breathing", breathScale )
	end

	-- Tanks to samm5506 from the Elevator: Source team for updating to the new pose paramaters
	self.Entity:SetPoseParameter( "move_x", ( LocalPlayer():GetPoseParameter( "move_x" ) * 2 ) - 1 ) -- Translate the walk x direction
	self.Entity:SetPoseParameter( "move_y", ( LocalPlayer():GetPoseParameter( "move_y" ) * 2 ) - 1 ) -- Translate the walk y direction
	self.Entity:SetPoseParameter( "move_yaw", ( LocalPlayer():GetPoseParameter( "move_yaw" ) * 360 ) - 180 ) -- Translate the walk direction
	self.Entity:SetPoseParameter( "body_yaw", ( LocalPlayer():GetPoseParameter( "body_yaw" ) * 180 ) - 90 ) -- Translate the body yaw
	self.Entity:SetPoseParameter( "spine_yaw",( LocalPlayer():GetPoseParameter( "spine_yaw" ) * 180 ) - 90 ) -- Translate the spine yaw

	if LocalPlayer():InVehicle() then
		self.Entity:SetColor( color_transparent )
		self.Entity:SetPoseParameter( "vehicle_steer", ( LocalPlayer():GetVehicle():GetPoseParameter( "vehicle_steer" ) * 2 ) - 1 ) -- Translate the vehicle steering
	end
end

vector_down = vector_up * -1

function _R.Legs:Render()
	if !self:ShouldDraw() then -- Should the legs be visible this frame?
		return
	end
	 
	local renderPos = LocalPlayer():GetPos()
	local renderAng = LocalPlayer():EyeAngles()
	
	if LocalPlayer():InVehicle() then -- The player is in a vehicle, so we use the vehicles angles, not the LocalPlayer
		renderAng = LocalPlayer():GetVehicle():GetAngles()
		renderAng:RotateAroundAxis( renderAng:Up(), 90 ) -- Fix it
	else -- This calculates the offset behind the player, adjust the -22 if you want to move it
		local biaisAngle = sharpeye_focus and sharpeye_focus.GetBiaisViewAngles and sharpeye_focus:GetBiaisViewAngles() or LocalPlayer():EyeAngles()
		renderAng = Angle( 0, biaisAngle.y, 0 )
		local radAngle = math.rad( biaisAngle.y )
		renderPos.x = renderPos.x + math.cos( radAngle ) * -22
		renderPos.y = renderPos.y + math.sin( radAngle ) * -22
		 
		if LocalPlayer():GetGroundEntity() == NULL then
			renderPos.z = renderPos.z + 8 -- Crappy jump fix
			if LocalPlayer():KeyDown( IN_DUCK ) then -- Crappy duck fix
				renderPos.z = renderPos.z - 28
			end
		end
	end
	 
	local col = LocalPlayer():GetColor()
	
	local bEnabled = render.EnableClipping( true )
		render.PushCustomClipPlane( vector_down, vector_down:Dot( EyePos() ) ) -- Clip the model so if we look up we should never see any part of the legs model
			render.SetColorModulation( col.r / 255, col.g / 255, col.b / 255 ) -- Render the color correctly
				render.SetBlend( col.a / 255 )
					hook.Call( "PreLegsDraw", GAMEMODE, self.Entity )
						self.Entity:SetRenderOrigin( renderPos )
						self.Entity:SetRenderAngles( renderAng )
						self.Entity:SetupBones()
						self.Entity:DrawModel()
					hook.Call( "PostLegsDraw", GAMEMODE, self.Entity )
				render.SetBlend( 1 )
			render.SetColorModulation( 1, 1, 1 )
		render.PopCustomClipPlane()
	render.EnableClipping( bEnabled )
end

function _R.Legs:OnSwitchedWeapon( weap ) -- Different bones will be visible for different hold types
	if !self:IsValid() then
		return
	end
	
	local holdType = "none"

	if IsValid( weap ) then
		holdType = weap:GetHoldType()
	end
	
	-- Tanks to samm5506 from the Elevator: Source team for making this hack to fix the bone scaling issues in GMod13

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
 
hook.Add( "UpdateAnimation", "Legs:UpdateAnimation", function( ply, vel, groundSpeed )
    if ply != LocalPlayer() then
		return
	end
	
	if IsValid( ply.Legs ) then
		ply.Legs:UpdateAnimation( groundSpeed ) -- Called every frame. Pass the ground speed for later use
	else
		ply.Legs = CreateLegs() -- No legs, create them. Should only be called once
	end
end )

hook.Add( "PostDrawTranslucentRenderables", "Legs:Render", function()
	if !LocalPlayer().Legs then
		return
	end
	
	LocalPlayer().Legs:Render()
end )