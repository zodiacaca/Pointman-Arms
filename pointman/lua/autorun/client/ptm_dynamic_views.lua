

local reg = debug.getregistry()
local wSpeed = reg.Player.GetWalkSpeed
local rSpeed = reg.Player.GetRunSpeed

local endPos = 0

function Pointman_CalcView(ply, pos, ang, fov, nearz, farz)

	if not IsValid(ply) then return end

	local wep = ply:GetActiveWeapon()

	if IsValid(wep) and wep.Base == "pointman_arms_base" then

		-- view of the player opens the door
		if CurTime() - wep.LastUse < wep.InteractDuration then

			local camPos = ply:GetPos()
			local camAng = ply:GetAngles()

			local coursePos
			if CurTime() - wep.LastUse < wep.InteractDuration - wep.InteractDuration/3 then
				coursePos = 64 * ((CurTime() - wep.LastUse)/14 + 0.2)
				endPos = coursePos
			else
				coursePos = endPos + endPos * (wep.LastUse + wep.InteractDuration - wep.InteractDuration/3 - CurTime()) / 2
			end
			camPos = camPos - camAng:Forward() * coursePos + Vector(0, 0, 64)

			local ViewData = {}

			ViewData.origin = camPos
			ViewData.angles = camAng
			ViewData.drawviewer = true

			return ViewData

		else

			/*1*/
			-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
			-- // what below influence the first person experience majorly, constantly, view bob // --
			-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
			-- bob
			if ply:OnGround() and ply:GetMoveType() != MOVETYPE_NOCLIP and !ply:InVehicle() and !ply:ShouldDrawLocalPlayer() then

				local scale = ScrH()/900

				local frqc = 1
				local str =0/scale
				local str_r = 0

				if ply:KeyDown(IN_SPEED) then
					frqc = frqc * 1.3
					str = 0/scale
					str_r = 0
				end

				local delta_x = 0
				local delta_r = 0

				if !ply:KeyDown(IN_WALK) or ply:KeyDown(IN_SPEED) or ply:Crouching() then
					delta_x = math.cos(CurTime() * 9.8 * frqc) * str * GetConVarNumber("PointmanViewBobMultiplier") or 0
					ang.x = ang.x + delta_x
					delta_r = math.sin(CurTime() * 9.8 * frqc) * str * str_r * GetConVarNumber("PointmanViewBobMultiplier") or 0
					ang.r = ang.r + delta_r
				end

			end

			-- dynamic view
			local vm = ply:GetViewModel()
			if IsValid(vm) then

				local att = vm:GetAttachment(1)

				if att != nil then

					local att_ang = att.Ang
					local gun_ang = vm:WorldToLocalAngles(att_ang)

					local wep_dvm = wep.DynamicViewMulti or 0.05

					ang.x = ang.x + gun_ang.x * wep_dvm
					ang.z = ang.z + gun_ang.x * wep_dvm * 0.5		-- use x

				end

				local ViewData = {}
				ViewData.origin = pos
				ViewData.angles = ang

				wep.CalcViewAng = ang - ply:EyeAngles()

				return ViewData

			end

		end

	end

end
hook.Add("CalcView", "Pointman CalcView", Pointman_CalcView)



local multi_offsetZ = 2

local nextLerpMulti = 8

function Pointman_InputMouseApply(cmd, x, y, ang)

	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local wep = ply:GetActiveWeapon()

	if IsValid(wep) and wep.Base == "pointman_arms_base" then
		if !ply:InVehicle() then

			local FT = FrameTime()

			local speed = ply:GetAbsVelocity():Length()

			local leanAng = 10
			
			wep.ViewDataAng = ang

			if ply:KeyDown(IN_SPEED) and speed > 5 then

				ang.r = Lerp(2 * FT, ang.r, math.Clamp(x/12, -10, 10) * GetConVarNumber("PointmanLeanAngleMultiplier") or 0)
				wep.PeekOffset = Lerp(8 * FT, wep.PeekOffset, 0)
				nextLerpMulti = 6

			elseif input.IsKeyDown(KEY_E) then

				ang.r = Lerp(5 * FT, ang.r, leanAng)
				wep.PeekOffset = Lerp(5 * FT, wep.PeekOffset, leanAng * 1.6)
				nextLerpMulti = 5

			elseif input.IsKeyDown(KEY_Q) then

				ang.r = Lerp(5 * FT, ang.r, -leanAng)
				wep.PeekOffset = Lerp(5 * FT, wep.PeekOffset, -leanAng * 1.6)
				nextLerpMulti = 5

			elseif math.abs(x) > 35 then

				ang.r = Lerp(6 * FT, ang.r, math.Clamp(x/90, -4, 4) * GetConVarNumber("PointmanLeanAngleMultiplier") or 0)
				wep.PeekOffset = Lerp(8 * FT, wep.PeekOffset, 0)
				nextLerpMulti = 8

			else

				ang.r = Lerp(nextLerpMulti * FT, ang.r, 0)
				wep.PeekOffset = Lerp(nextLerpMulti * FT, wep.PeekOffset, 0)

			end

			/*1*/
			-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
			-- // what below influence the first person experience majorly, constantly, view bob // --
			-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
			local scale = ScrH()/900
			local dur = wep.FirstStepDuration or 0.5
			local mul = math.Clamp(wep.FirstStep + dur - CurTime(), 0, dur) * 5 / dur + 1
			if wep.Side != 0 and !(input.IsKeyDown(KEY_E) or input.IsKeyDown(KEY_Q)) then
				mul = 1
			end
			local multiDelta = 0.018
			if ply:KeyDown(IN_BACK) then
				ang.y = ang.y - wep.VMViewDelta.y * multiDelta * 0.5 * math.Clamp(ply:GetAbsVelocity():Length() / 100, 0, 1) / scale * GetConVarNumber("PointmanViewBobMultiplier") or 0
			end
			if wep.VMViewDelta and ply:KeyDown(IN_WALK) and !ply:KeyDown(IN_SPEED) and !ply:Crouching() then
				ang.r = ang.r - wep.VMViewDelta.z * multiDelta * math.Clamp(ply:GetAbsVelocity():Length() / 100, 0, 1) / scale * GetConVarNumber("PointmanViewBobMultiplier") or 0
				ang.x = ang.x - wep.VMViewDelta.x * multiDelta * mul * math.Clamp(ply:GetAbsVelocity():Length() / 100, 0, 1) / scale * GetConVarNumber("PointmanViewBobMultiplier") or 0
			end
			
			-- lock angle x
			ang.x = math.Clamp(ang.x, -180, 80)
			
			-- set the eye angles
			cmd:SetViewAngles(ang)
			wep.ViewDataAng = ang - wep.ViewDataAng

			-- set the eye offsets
			local eyeHeight = ply:Crouching() and 40 or 62
			local closeWall = { [1] = 0, [3] = 0 }
			for i = -1, 1 do
				if i != 0 then
					local trd = {}
						trd.start = ply:EyePos()
						trd.endpos = trd.start + ply:GetRight() * 16 * i
						trd.filter = { ply }
					local tracer = util.TraceLine(trd)
					closeWall[i + 2] = 8 * (1 - tracer.Fraction)
				end
			end
			local multi_offsetZ = wep.Side != 0 and 4 * mul or 2 * mul
			local offsetY = wep.VMViewOffset.y * 0.5
			if math.abs(closeWall[1]) > math.abs(closeWall[3]) then
				ply:SetCurrentViewOffset( Vector(0, 0, eyeHeight + math.Clamp(wep.VMViewOffset.z * multi_offsetZ, -multi_offsetZ, multi_offsetZ)) + ply:GetRight() * (offsetY + closeWall[1] + wep.PeekOffset) + ply:GetForward() * wep.PeekOffset * -0.2 )
			elseif math.abs(closeWall[1]) < math.abs(closeWall[3]) then
				ply:SetCurrentViewOffset( Vector(0, 0, eyeHeight + math.Clamp(wep.VMViewOffset.z * multi_offsetZ, -multi_offsetZ, multi_offsetZ)) + ply:GetRight() * (offsetY - closeWall[3] + wep.PeekOffset) + ply:GetForward() * wep.PeekOffset * -0.2 )
			else
				ply:SetCurrentViewOffset( Vector(0, 0, eyeHeight + math.Clamp(wep.VMViewOffset.z * multi_offsetZ, -multi_offsetZ, multi_offsetZ)) + ply:GetRight() * (offsetY + wep.PeekOffset) + ply:GetForward() * wep.PeekOffset * -0.2)
			end

		end
	end

end
hook.Add("InputMouseApply", "Pointman InputMouseApply", Pointman_InputMouseApply)

