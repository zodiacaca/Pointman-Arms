
include('shared.lua')
include('cl_hud.lua')
include('cl_flashlight.lua')

SWEP.Slot				= 2
SWEP.SlotPos			= 10
SWEP.DrawWeaponInfoBox = false
SWEP.BounceWeaponIcon	= false		-- it's a serious weapon, don't bounce it
SWEP.DrawAmmo			= true		-- being overwritten by SWEP:HUDShouldDraw
SWEP.DrawCrosshair		= true		-- being overwritten by SWEP:DoDrawCrosshair

SWEP.RenderGroup 		= RENDERGROUP_OPAQUE

-- Override this in your SWEP to set the icon in the weapon selection
SWEP.WepSelectIcon		= surface.GetTextureID( "weapons/swep" )

-- This is the corner of the speech bubble
SWEP.SpeechBubbleLid	= surface.GetTextureID( "gui/speech_lid" )

SWEP.VMViewOffset = Vector(0, 0, 0)
SWEP.VMViewDelta = Angle(0, 0, 0)

SWEP.DelayVMPos = Vector(0, 0, 0)
SWEP.DelayVMAng = Angle(0, 0, 0)
SWEP.LastVMPos = Vector(0, 0, 0)
SWEP.LastVMAng = Angle(0, 0, 0)


--[[---------------------------------------------------------
	Initialize
-----------------------------------------------------------]]
function SWEP:Initialize()
end

--[[---------------------------------------------------------
	Deploy
-----------------------------------------------------------]]
function SWEP:CreateClientModels()

	if self.Owner:IsPlayer() then

		-- shadow
		if not IsValid(ptm_cModel["Shadow"]) then

			ptm_cModel["Shadow"] = ClientsideModel(self.Owner:GetModel(), RENDERGROUP_OPAQUE)

			local mats = ptm_cModel["Shadow"]:GetMaterials()
			for k, v in pairs(mats) do
				ptm_cModel["Shadow"]:SetSubMaterial( k - 1, "effects/pointman_transparent" )
			end

		end

		-- body
		if not IsValid(ptm_cModel["Body"]) then

			ptm_cModel["Body"] = ClientsideModel(self.Owner:GetModel(), RENDERGROUP_OPAQUE)
			ptm_cModel["Body"]:DrawShadow(false)
			ptm_cModel["Body"]:SetNoDraw(true)

		end

		-- mask
		if not IsValid(ptm_cModel["Mask"]) then

			ptm_cModel["Mask"] = ClientsideModel("models/weapons/v_ptm_gasmask.mdl", RENDERGROUP_VIEWMODEL)
			ptm_cModel["Mask"]:DrawShadow(false)
			ptm_cModel["Mask"]:SetNoDraw(true)

		end
		
		-- ghost
		if not IsValid(ptm_cModel["Ghost"]) and GetConVar("PointmanToggleGlobal"):GetBool() then

			ptm_cModel["Ghost"] = ClientsideModel(self.Owner:GetViewModel():GetModel(), RENDERGROUP_VIEWMODEL)
			ptm_cModel["Ghost"]:ResetSequence(ACT_VM_DRAW)

		end

	end

end

--[[---------------------------------------------------------
	Remove Client Models
-----------------------------------------------------------]]
function SWEP:RemoveClientModels()

	for k, v in pairs(ptm_cModel) do

		if IsValid(v) then

			v:Remove()

		end

	end

end

--[[---------------------------------------------------------
	Infomation
-----------------------------------------------------------]]
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
end

function SWEP:PrintWeaponInfo( x, y, alpha )
end

--[[---------------------------------------------------------
	Aim Info
-----------------------------------------------------------]]
function SWEP:SendAimInfo()

	if util.NetworkStringToID( "pointman_aimpos"..self.Owner:EntIndex() ) != 0 then

		local position, angles = self.Owner:GetViewModel():GetAttachment(1).Pos, self.Owner:GetViewModel():GetAttachment(1).Ang

		self.AimPos = position
		self.AimAng = angles

		if self.Owner:ShouldDrawLocalPlayer() then
			net.Start("pointman_aimpos"..self.Owner:EntIndex())
				net.WriteVector(self.Weapon:GetAttachment(1).Pos)
				net.WriteAngle(self.Weapon:GetAttachment(1).Ang)
				net.WriteBool(self.Owner:ShouldDrawLocalPlayer())
				net.WriteFloat(self.PeekOffset)
				net.WriteFloat(self.Stamina)
			net.SendToServer()
		else
			net.Start("pointman_aimpos"..self.Owner:EntIndex())
				net.WriteVector(position)
				net.WriteAngle(angles)
				net.WriteBool(self.Owner:ShouldDrawLocalPlayer())
				net.WriteFloat(self.PeekOffset)
				net.WriteFloat(self.Stamina)
			net.SendToServer()
		end

	end

end

function SWEP:GetAimInfo()		-- read by attachments

	local ent = self.Owner:GetViewModel()
	-- local bone = ent:LookupBone("wpn_body")

	-- if (!bone) then return end

	-- local m = ent:GetBoneMatrix(bone)
	-- local pos, dir
	-- if m then
		-- pos, dir = m:GetTranslation(), m:GetForward() * 1
	-- end

	local pos = ent:GetAttachment(1).Pos
	local ang = ent:GetAttachment(1).Ang
	local dir = ang:Forward()

	return pos, dir

end

--[[---------------------------------------------------------
	View Model
-----------------------------------------------------------]]
function SWEP:ViewModelDrawn()

	-- mask
	if self.Weapon:GetNWBool("Gasmask") and IsValid(ptm_cModel["Mask"]) then

		cam.IgnoreZ(true)

			ptm_cModel["Mask"]:SetPos(self.FixedPos - self.Owner:EyeAngles():Forward() * 2.65 - self.Owner:EyeAngles():Up() * 0.25)
			ptm_cModel["Mask"]:SetAngles(self.Owner:EyeAngles())

			-- local settings = {
				-- model = "models/weapons/v_ptm_gasmask.mdl",
				-- pos = self.Owner:EyePos() - self.Owner:EyeAngles():Forward() * 2.65 - self.Owner:EyeAngles():Up() * 0.25,
				-- angle = self.Owner:EyeAngles()
				-- }
			-- render.Model( settings, ptm_cModel["Mask"] )

			ptm_cModel["Mask"]:DrawModel()

	end
	
	-- ghost
	if IsValid(ptm_cModel["Ghost"]) then
	
		ptm_cModel["Ghost"]:SetPos(self.Owner:EyePos())
		ptm_cModel["Ghost"]:SetAngles(self.Owner:EyeAngles())
		
	end

end

local curSeq = 0
local lastFrame = 0

function SWEP:UpdateClientShadow()

	if IsValid(ptm_cModel["Shadow"]) and IsValid(ptm_cModel["Body"]) then

		local ang = self.Owner:EyeAngles()
		ang.x = 0			-- control the model doesn't need angle x
		local dir = ang:Forward()
		ptm_cModel["Shadow"]:SetPos(self.Owner:GetPos() - dir * 16)
		-- ptm_cModel["Shadow"]:SetPos(self.Owner:GetPos() + dir * 128)
		ptm_cModel["Shadow"]:SetAngles(ang)
		
		-- walk animation playback speed depends on the speed
		local rate = 1
		if self.Owner:KeyDown(IN_SPEED) then
			rate = 2
		elseif self.Owner:KeyDown(IN_WALK) then
			rate = 1
		else
			rate = 1.5
		end

		local sequence = self.Owner:GetSequence()
		local vm = self.Owner:GetViewModel()
		if vm:GetSequenceActivityName(vm:GetSequence()) == "ACT_VM_RELOAD" then
			sequence = ptm_cModel["Shadow"]:LookupSequence("reloadpistol")			-- can't set layer on client model, quite buggy though
			rate = 0.5
		end
		ptm_cModel["Shadow"]:SetPlaybackRate(rate)
		ptm_cModel["Body"]:SetPlaybackRate(rate)
		if sequence != curSeq then
			ptm_cModel["Shadow"]:ResetSequence(sequence)
			ptm_cModel["Body"]:ResetSequence(sequence)
			curSeq = sequence
			lastFrame = CurTime()
		end
		ptm_cModel["Shadow"]:FrameAdvance(CurTime() - lastFrame)			-- seems number doesn't matter
		ptm_cModel["Body"]:FrameAdvance(CurTime() - lastFrame)

		-- make the model walk
		ptm_cModel["Shadow"]:SetPoseParameter("move_x", self.Owner:GetPoseParameter("move_x") * 2 - 1)		-- parameter is 0.5 to 1
		ptm_cModel["Shadow"]:SetPoseParameter("move_y", self.Owner:GetPoseParameter("move_y") * 2 - 1)
		ptm_cModel["Body"]:SetPoseParameter("move_x", self.Owner:GetPoseParameter("move_x") * 2 - 1)
		ptm_cModel["Body"]:SetPoseParameter("move_y", self.Owner:GetPoseParameter("move_y") * 2 - 1)
		-- model aim pose
		local mul = 30		-- use a simply multiply to control them
		-- local spinePitch = self.Owner:GetPoseParameter("spine_pitch") * 2 - 1
		-- ptm_cModel["Shadow"]:SetPoseParameter("spine_pitch", spinePitch * mul)
		local spineYaw = self.Owner:GetPoseParameter("spine_yaw") * 2 - 1
		ptm_cModel["Shadow"]:SetPoseParameter("spine_yaw", spineYaw * mul)
		ptm_cModel["Body"]:SetPoseParameter("spine_yaw", spineYaw * mul)
		local aimPitch = self.Owner:GetPoseParameter("aim_pitch") * 2 - 1
		ptm_cModel["Shadow"]:SetPoseParameter("aim_pitch", aimPitch * mul * math.Clamp(self.Owner:EyeAngles().x / 30, 1, 3) * 2)		-- flashlight
		local aimYaw = self.Owner:GetPoseParameter("aim_yaw") * 2 - 1
		ptm_cModel["Shadow"]:SetPoseParameter("aim_yaw", aimYaw * mul)
		ptm_cModel["Body"]:SetPoseParameter("aim_yaw", aimYaw * mul)

	end

end

function SWEP:PreDrawViewModel(vm, wep, ply)

	-- body
	if IsValid(ptm_cModel["Body"]) then
	
		if self.Owner:GetForward() == Vector(1, 0, 0) then return end
	
		local normal = Vector(0, 0, -1)
		
		local len = math.Clamp(self.Owner:GetAbsVelocity():Length() / 100, 0, 1)
		
		local ang = self.Owner:GetForward():Angle()
		ang.x = 0
		local dir = ang:Forward()

		render.EnableClipping( true )
			render.PushCustomClipPlane( normal, -self.Owner:EyePos().z + 8 )
			-- ang:RotateAroundAxis(self.Owner:GetUp(),180)
				local settings = {
					model = self.Owner:GetModel(),
					pos = self.Owner:GetPos() - dir * (9 + len * 2) + self.Owner:GetRight() * (4 - len * 1),
					-- pos = self.Owner:GetPos() + dir * 128 + self.Owner:GetRight() * (4 - len * 1),
					angle = ang
					}
				render.Model( settings, ptm_cModel["Body"] )
				
				local spine1 = ptm_cModel["Body"]:LookupBone("ValveBiped.Bip01_Spine1")
				ptm_cModel["Body"]:ManipulateBoneAngles( spine1, Angle(0, -30 * len, 0) )
				local r_upperarm = ptm_cModel["Body"]:LookupBone("ValveBiped.Bip01_R_UpperArm")
				ptm_cModel["Body"]:ManipulateBoneAngles( r_upperarm, Angle(0, -120, 0) )
				local l_upperarm = ptm_cModel["Body"]:LookupBone("ValveBiped.Bip01_L_UpperArm")
				ptm_cModel["Body"]:ManipulateBoneAngles( l_upperarm, Angle(0, 0, 0) )		-- bug?
				
				ptm_cModel["Body"]:DrawModel()

			render.PopCustomClipPlane()
		render.EnableClipping( false )

	end

	-- shadow
	self:UpdateClientShadow()

end

function SWEP:PostDrawViewModel(vm, wep, ply)
end

--[[---------------------------------------------------------
	World Model
-----------------------------------------------------------]]
function SWEP:DrawWorldModel()
	self.Weapon:DrawModel()
end

function SWEP:DrawWorldModelTranslucent()
end

--[[---------------------------------------------------------
	Events
-----------------------------------------------------------]]
function SWEP:PlayCrackSound(str)

	local subStr = string.Explode( " ", str, false )

	sound.Play(subStr[1], Vector(tonumber(subStr[3]), tonumber(subStr[4]), tonumber(subStr[5])), tonumber(subStr[2]), math.Rand(95,105) * GetConVarNumber("host_timescale"))

end

function SWEP:FireAnimationEvent( pos, ang, event, options )
	-- no need to change the events
end

function SWEP:OnRemove()
end

--[[---------------------------------------------------------
	Translate FOV
-----------------------------------------------------------]]
local lastFOV = 0

function SWEP:TranslateFOV( oriFOV )

	local FT = FrameTime()

	local fov

	if self.dt.StateLower == POINTMAN_ST_AIM then
		fov = Lerp(FT * 1.4, lastFOV, 7)
	else
		fov = Lerp(FT * 1.4, lastFOV, 0)
	end
	lastFOV = fov

	return oriFOV - fov

end

--[[---------------------------------------------------------
	Sensitivity
-----------------------------------------------------------]]
function SWEP:AdjustMouseSensitivity()

	if self.dt.StateLower == POINTMAN_ST_AIM then
		return 0.8
	else
		return 1
	end

end

--[[---------------------------------------------------------
	Transform
-----------------------------------------------------------]]
function SWEP:GetViewModelPosition(pos, ang)
end

