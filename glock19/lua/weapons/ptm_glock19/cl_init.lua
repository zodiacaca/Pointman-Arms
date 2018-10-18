
include('shared.lua')

SWEP.Slot				= 1
SWEP.SlotPos			= 10
SWEP.DrawWeaponInfoBox = false
SWEP.BounceWeaponIcon	= false		-- it's a serious weapon, don't bounce it
SWEP.DrawAmmo			= true		-- being overwritten by SWEP:HUDShouldDraw
SWEP.DrawCrosshair		= true		-- being overwritten by SWEP:DoDrawCrosshair

SWEP.WepSelectIcon		= surface.GetTextureID( "vgui/hud/ptm_glock19" )
SWEP.IconText = "Glock 19"			-- shown in the weapon selection box


function SWEP:UpdateHands()

	/*2*/
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	-- // what below influence the first person experience secondary, constantly, hand model // --
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	local vm = ply:GetViewModel()
	local mats = vm:GetMaterials()
	local data = GetConVarNumber("PointmanVMHands")
	local index = nil
	for k, v in pairs(mats) do
		if string.find( v, "glove", 1, false ) then
			index = k
		end
	end

	if index then
		if data == 0 then
			vm:SetSubMaterial( index - 1, nil )
		elseif data == 1 then
			vm:SetSubMaterial( index - 1, "models/weapons/ptm/hands/glove_green" )
		elseif data == 2 then
			vm:SetSubMaterial( index - 1, "models/weapons/ptm/hands/glove_white" )
		else
			vm:SetSubMaterial( index - 1, "models/weapons/ptm/hands/glove_black" )
		end
	end

end

function SWEP:DrawWeaponSelection(x, y, wide, tall, alpha)

	draw.SimpleText(self.IconText, HudSelectionText, x + wide / 2, y + tall / 2, Color(255, 210, 0, alpha), TEXT_ALIGN_CENTER)

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
	ang:RotateAroundAxis(ang:Up(), -0.05)		-- fix numbers
	ang:RotateAroundAxis(ang:Right(), -0.35)
	local dir = ang:Forward()

	return pos, dir

end

SWEP.DeltaData = Angle(0, 0, 0)
SWEP.AngleDelta = Angle(0, 0, 0)
local delayDelta = Angle(0, 0, 0)
SWEP.RotateSpeed = Angle(0, 0, 0)
local pEyeAngles = Angle(0, 0, 0)
local pDelta = Angle(0, 0, 0)

function SWEP:processSwayDelta()

	local FT = FrameTime()
	local ea = self.Owner:EyeAngles()
	local delta = Angle(self:ConvertAngle(ea.x - pEyeAngles.x), self:ConvertAngle(ea.y - pEyeAngles.y), 0)

	self.RotateSpeed.y = self:ConvertAngle(delta.y - pDelta.y)

	delayDelta = LerpAngle(math.Clamp(FT * 8, 0, 1), delayDelta, self.RotateSpeed)
	delayDelta.y = math.Clamp(delayDelta.y, -5, 5)

	self.AngleDelta = LerpAngle(math.Clamp(FT * 7.2, 0, 1), self.AngleDelta, delta)
	self.AngleDelta = self.AngleDelta + delayDelta * 1.3
	self.AngleDelta.y = math.Clamp(self.AngleDelta.y, -15, 15)

	pDelta = delta
	pEyeAngles.x = ea.x
	pEyeAngles.y = ea.y

end

local old_pos = Vector(0, 0, 0)
SWEP.Side = 0
SWEP.Transverse = 0

function SWEP:applySway(posAlt)

	local FT = FrameTime()
	local pos = self.Owner:EyePos()
	local ang = self.Owner:EyeAngles()
	if math.abs(pos.z - old_pos.z) > 0.005 then pos = posAlt end

	self.Side = self.Owner:GetVelocity():GetNormal():Dot(ang:Right():GetNormal())
	if !(self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT)) then
		self.Side = 0
	end
	self.Transverse = self:LerpLocal(6 * FT, self.Transverse, self.Side)

	ang:RotateAroundAxis(ang:Up(), self.AngleDelta.y * -0.8)

	ang:RotateAroundAxis(ang:Forward(), self.AngleDelta.y * 0.2)
	ang:RotateAroundAxis(ang:Forward(), self.Transverse * 2.3)

	if self.Weapon:GetNWBool("Gasmask") then
		pos = pos + (self.AngleDelta.y * 0.032 + self.Transverse * 0.3) * ang:Right()
	else
		pos = pos + (self.AngleDelta.y * 0.064 + self.Transverse * 0.3) * ang:Right()
	end

	pos = pos + (self.AngleDelta.x * 0.28) * ang:Up()

	old_pos = pos

	return pos, ang

end

local pVel_z = 0

local oldFraction = 0
local lastFraction = 0
local c_mul = 1

local bob_half = 0

SWEP.CurBobPos = Vector(0, 0, 0)
SWEP.CurBobAng = Vector(0, 0, 0)

SWEP.RunTime = 0
SWEP.FirstStep = CurTime()

local i_mul = 1

function SWEP:applyBob(pos, ang)

	local FT = FrameTime()
	local BobPos, BobAng = Vector(0, 0, 0), Angle(0, 0, 0)

	local stm = math.Clamp(self:GetStamina(), 1, 1.2)

	local len = self.Owner:GetAbsVelocity():Length()
	local rs = self.Owner:GetRunSpeed()

	local mul = 1.9
	if self.Owner:Crouching() then
		mul = 30
	end
	local power = self.Owner:KeyDown(IN_WALK) and math.Clamp(len / rs * 3, 0, 0.8) or math.Clamp(len / rs * 3, 0, 1)
	local base, add = 4.1, 2
	if !self.Owner:KeyDown(IN_WALK) then
		base, add = 2.95, 4
	end
	local mulit_b = 1
	local delay = 0
	if self.dt.StateLower == POINTMAN_ST_LOW then
		base, add = 4, 1
		power = len / rs * 8
		if self.Owner:KeyDown(IN_SPEED) then
			power = len/300
			base, add = 1.2, 8
			mulit_b = 1.2
			delay = -0.2
		end
	end

	self.RunTime = game.SinglePlayer() and self.RunTime + FT * (base + add) or self.RunTime + FT * (base + add) / 2
	local sin = math.sin(self.RunTime + delay) * power
	local cos = math.cos(self.RunTime + delay) * power
	local tan = math.atan(cos * sin)
	if !self.Owner:KeyDown(IN_WALK) or self.Owner:KeyDown(IN_SPEED) or self.Owner:Crouching() then
		bob_half = 0
	else
		bob_half = Lerp(0.2 * FT, bob_half, math.abs(math.sin(math.sin(self.RunTime + delay))) - 0.6) * power
	end

	BobAng.x = BobAng.x - tan * 4.2 * power * mul / mulit_b * stm
	BobAng.y = BobAng.y + sin * 1.8 * power * mul * mulit_b * stm
	BobAng.z = BobAng.z - cos * 0.9 * power * mul * mulit_b * stm
	if self.Side == 0 then
		BobPos.x = BobPos.x + sin * 0.1 * power * mul / mulit_b * stm
	end
	BobPos.y = BobPos.y - cos * 0.1 * power * mul / mulit_b * stm
	if !self.Owner:KeyDown(IN_WALK) or self.Owner:Crouching() or self.Owner:KeyDown(IN_SPEED) then
		BobPos.z = BobPos.z - bob_half * 0 * power * mul / mulit_b * stm
	else
		BobPos.z = BobPos.z + bob_half * 62 * power * mul / mulit_b * stm
	end

	self.CurBobPos = self:LerpVectorLocal(FT * 14, self.CurBobPos, BobPos)
	self.CurBobAng = self:LerpVectorLocal(FT * 14, self.CurBobAng, BobAng)

	ang:RotateAroundAxis(ang:Right(), self.CurBobAng.x)
	ang:RotateAroundAxis(ang:Up(), self.CurBobAng.y)
	ang:RotateAroundAxis(ang:Forward(), self.CurBobAng.z)

	pos = pos + self.CurBobPos.x * ang:Forward()
	pos = pos + self.CurBobPos.y * ang:Right()
	self.VMViewOffset.y = self.CurBobPos.y
	pos = pos + self.CurBobPos.z * ang:Up()

	return pos, ang

end

local peekOffsetMultiY = 0
local peekOffsetMultiZ = 0
local peekDeltaMulti = 0

function SWEP:PeekTransform(pos, ang, FT)

	if self.dt.StateLower == POINTMAN_ST_AIM then
		if self.PeekOffset < 0 then
			peekDeltaMulti = Lerp(8 * FT, peekDeltaMulti, 0.1)
			peekOffsetMultiY = Lerp(8 * FT, peekOffsetMultiY, 0)
			peekOffsetMultiZ = Lerp(8 * FT, peekOffsetMultiZ, 0)
		else
			peekDeltaMulti = Lerp(8 * FT, peekDeltaMulti, 0.5)
			peekOffsetMultiY = Lerp(8 * FT, peekOffsetMultiY, 0)
			peekOffsetMultiZ = Lerp(8 * FT, peekOffsetMultiZ, 0)
		end
	else
		peekDeltaMulti = Lerp(8 * FT, peekDeltaMulti, 0)
		local mul = self.PeekOffset < 0 and -0.06 or -0.03
		peekOffsetMultiY = Lerp(8 * FT, peekOffsetMultiY, mul)
		peekOffsetMultiZ = Lerp(8 * FT, peekOffsetMultiZ, 0.01)
	end

	ang:RotateAroundAxis(ang:Forward(), -self.PeekOffset * peekDeltaMulti)
	pos = pos - ang:Right() * self.PeekOffset * peekOffsetMultiY
	pos = pos - ang:Up() * self.PeekOffset * peekOffsetMultiZ

	return pos, ang

end

local oldEyePos = Vector(0, 0, 0)
local oldPlyPos = Vector(0, 0, 0)

function SWEP:GetViewModelPosition(pos, ang)

	self.BobScale = 0
	self.SwayScale = 0

	if not IsValid(self.Weapon) then return end
	if not IsValid(self.Owner) then return end

	local moveOffset = self.Owner:GetPos() - oldPlyPos
	oldPlyPos = self.Owner:GetPos()

	self.FixedPos = pos

	local close, direction, fraction, hitpos = self:CloseSight()

	local FT = FrameTime()

	/*1*/
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	-- // what below influence the first person experience majorly, based on action, VM sway // --
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	self.VMDataPos = pos
	self:processSwayDelta()
	pos, ang = self:applySway(pos)
	self.VMDataPos = pos - self.VMDataPos
	self.VMDataAng = ang
	/*1*/
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	-- // what below influence the first person experience majorly, constantly, VM bob // --
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	if self.Owner:OnGround() then
		pos, ang = self:applyBob(pos, ang)
	end

	/*1*/
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- ---
	-- // what below influence the first person experience majorly, based on action, peek // --
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- ---
	-- peek
	pos, ang = self:PeekTransform(pos, ang, FT)

	-- manipulateJoint
	local eye_pos = self.Owner:EyePos()
	if math.abs(eye_pos.z - oldEyePos.z) > 0.005 and self.FixedPos then
		eye_pos = self.FixedPos
	end
	self.VMViewOffset.z = pos.z - eye_pos.z
	oldEyePos = eye_pos
	self.VMViewDelta = ang - self.Owner:EyeAngles()

	/*1*/
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	-- // what below influence the first person experience majorly, based on action, VM transform // --
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	-- close
	if math.abs(fraction - oldFraction) > 0.1 * FT then
		fraction = Lerp(9 * FT, oldFraction, fraction)
		-- if close and (fraction - oldFraction != 0) then print("a") end
	-- else
		-- if close and (fraction - oldFraction != 0) then print("b") end
	end
	oldFraction = fraction

	local offset, ang_y, ang_x
	if self.Weapon:GetNWFloat("Suppressor") == 1 then
		offset = self.CloseOffsetEx
		ang_y = self.CloseAngleYEx
		ang_x = self.CloseAngleXEx
	else
		offset = self.CloseOffset
		ang_y = self.CloseAngleY
		ang_x = self.CloseAngleX
	end

	if close then
		pos = pos - direction * fraction * offset
		ang:RotateAroundAxis(ang:Up(), ang_y * fraction)
		ang:RotateAroundAxis(ang:Right(), ang_x * fraction)
		lastFraction = fraction
		c_mul = 1
	else
		c_mul = Lerp(9 * FT, c_mul, 0)
		pos = pos - direction * lastFraction * offset * c_mul
		ang:RotateAroundAxis(ang:Up(), ang_y * lastFraction * c_mul)
		ang:RotateAroundAxis(ang:Right(), ang_x * lastFraction * c_mul)
		oldFraction = lastFraction * c_mul
	end

	ang:RotateAroundAxis(ang:Right(), self.CurrentAng.x)
	ang:RotateAroundAxis(ang:Up(), self.CurrentAng.y)
	ang:RotateAroundAxis(ang:Forward(), self.CurrentAng.z)

	pos = pos + self.CurrentPos.x * ang:Forward()
	pos = pos + self.CurrentPos.y * ang:Right()
	pos = pos + self.CurrentPos.z * ang:Up()

	/*1*/
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	-- // what below influence the first person experience majorly, based on action, VM sway // --
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	-- VM sway global
	self.VMDataAng = ang - self.VMDataAng
	self.DelayVMPos = LerpVector(8 * FT, self.DelayVMPos, pos - self.VMDataPos - self.LastVMPos - moveOffset)
	local clampPos = 0.1
	self.DelayVMPos = self:ClampVector(self.DelayVMPos, clampPos, clampPos, clampPos)
	self.DelayVMAng = LerpAngle(8 * FT, self.DelayVMAng, self.VMDataAng - self.LastVMAng + (self.ViewDataAng or Angle(0, 0, 0)))
	local clampAng = 1
	self.DelayVMAng = self:ClampAngle(self.DelayVMAng, clampAng, clampAng, clampAng)
	self.DelayVMAng = self:ConvertAngles(self.DelayVMAng)
	self.LastVMPos = pos - self.VMDataPos
	self.LastVMAng = self.VMDataAng

	-- sequence matters
	local x, y = 1.72, -16
	pos = pos + ang:Forward() * y
	pos = pos + ang:Right() * x
	if self.dt.StateLower != POINTMAN_ST_AIM then
		ang:RotateAroundAxis(ang:Right(), -0.03)
	end

	/*3*/
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	-- // what below influence the first person experience insignificantly, based on action, jump // --
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
	-- jump
	local vel_z = self.Owner:GetVelocity().z
	vel_z = self:LerpLocal(0.15, pVel_z, vel_z)
	pVel_z = vel_z
	ang:RotateAroundAxis(ang:Right(), vel_z * -0.02)

	-- lock angle x
	if ang.x > 45 then
		ang.x = ang.x - (self.Owner:EyeAngles().x - 45) * 0.2
	end

	return pos + self.DelayVMPos, ang + self.DelayVMAng
	-- return pos, ang

end

local joint_multi = 1
local lastSpeed = 0

function SWEP:manipulateJoint()

	/*2*/
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
	-- // what below influence the first person experience secondary, constantly, manipulate // --
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
	local ent = self.Owner:GetViewModel()

	local wepBone = ent:LookupBone("wpn_body")

	local len = 9.828587		-- forearm length

	local l_hand = ent:LookupBone("l_wrist")
	local l_forearm = ent:LookupBone("l_forearm")

	local r_hand = ent:LookupBone("r_wrist")
	local r_forearm = ent:LookupBone("r_forearm")

	local delta_y = self:ConvertAngle(self.VMViewDelta.y)

	local par_x = self.VMViewOffset.z
	local par_y = delta_y

	local mul_j
	-- enhance the effect when walking
	if self.Owner:GetVelocity():Length() > 5 and (self.Owner:KeyDown(IN_WALK) and !(self.Owner:Crouching() or self.Owner:KeyDown(IN_SPEED))) then
		mul_j = math.Clamp(self.Owner:GetAbsVelocity():Length()/100, 0, 1)			-- make use of speed controling
		joint_multi = Lerp(FrameTime() * 20 * mul_j, joint_multi, 2)
		lastSpeed = self.Owner:GetAbsVelocity():Length()
	else
		mul_j = math.Clamp(math.abs((lastSpeed - self.Owner:GetAbsVelocity():Length())) / 100, 0.5, 1)
		joint_multi = Lerp(FrameTime() * 14 * mul_j, joint_multi, 0.5)
	end

	local delta_y_abs = math.abs(delta_y)

	-- both hands and forearms their argument x controls yaw, argument x controls pitch
	local LX_Delta = -par_y * 0.4 * joint_multi
	local LX_Offset = math.sin(math.rad(LX_Delta))

	local LY_Delta = -par_y * 0.2 * joint_multi
	local LY_Offset = math.sin(math.rad(LY_Delta))

	local RX_Delta = par_y * 0.4 * joint_multi
	local RX_Offset = math.sin(math.rad(RX_Delta))

	local RY_Delta = par_x * 0.8 * joint_multi
	local RY_Offset = math.sin(math.rad(RY_Delta))

	-- print(math.Round(LX_Delta),math.Round(LX_Offset),math.Round(LY_Delta),math.Round(LY_Offset),math.Round(RX_Delta),math.Round(RX_Offset))
	ent:ManipulateBoneAngles( l_hand, Angle(-delta_y_abs * 0.1, delta_y_abs * 0.2 * joint_multi, 0) )
	ent:ManipulateBoneAngles( l_forearm, Angle(LX_Delta, LY_Delta + RY_Delta * 0.3, -LX_Delta * 2 / joint_multi))
	ent:ManipulateBonePosition( l_forearm, Vector(0, len * LX_Offset, len * LY_Offset + len * RY_Offset * 0.3))

	ent:ManipulateBoneAngles( r_hand, Angle(-delta_y * 0.3, -delta_y_abs * 0.2 * joint_multi, 0) )
	ent:ManipulateBoneAngles( r_forearm, Angle(RX_Delta, RY_Delta, RX_Delta * 2 / joint_multi) )
	ent:ManipulateBonePosition( r_forearm, Vector(0, -len * RX_Offset, -len * RY_Offset) )

end

