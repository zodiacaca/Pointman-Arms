

function ptm_PlayerSwitchWeapon(ply, oldWeapon, newWeapon)

	if not IsValid(ply) then return end
	
	if newWeapon.Base != "pointman_arms_base" then
		ply:ConCommand("-duck")
		ply:ConCommand("-walk")
		ply:ConCommand("-attack2")
	end
	
end
hook.Add("PlayerSwitchWeapon", "ptm_PlayerSwitchWeapon", ptm_PlayerSwitchWeapon)


function ptm_PlayerStepSoundTime( ply, type, walking )

	local wep = ply:GetActiveWeapon()
	
	if IsValid(wep) and wep.Base == "pointman_arms_base" then
		if walking then
		
			if ply:Crouching() then
				
				return 620
				
			elseif ply:KeyDown(IN_WALK) then
		
				return 500
				
			else
			
				return 450
				
			end
		
		else
		
			return 300
			
		end
		
	end

end
hook.Add("PlayerStepSoundTime", "ptm_PlayerStepSoundTime", ptm_PlayerStepSoundTime)


local LastDoor = 0

function ptm_CalcMainActivity( ply, vel )

	local wep = ply:GetActiveWeapon()

	if IsValid(wep) and wep.Base == "pointman_arms_base" and wep.LastUse then

		ply.CalcIdeal = -1
		ply.CalcSeqOverride = -1

		if CurTime() - wep.LastUse < wep.InteractAnimTime then

			if LastDoor != wep.LastUse then
				ply:SetCycle( 0 )			-- set to the start frame
			end
			ply.CalcSeqOverride = ply:LookupSequence("Open_door_towards_right")
			LastDoor = wep.LastUse

			return ply.CalcIdeal, ply.CalcSeqOverride

		end

		if wep.dt.StateLower != POINTMAN_ST_LOW then

			ply.CalcIdeal = ACT_MP_STAND_IDLE

			local len2d = vel:Length2D()

			if len2d > 0.5 and len2d < 210 then
				ply.CalcIdeal = ACT_MP_WALK			-- this sequence looks better
			end

			return ply.CalcIdeal, ply.CalcSeqOverride

		end

	end

end
hook.Add("CalcMainActivity", "ptm_CalcMainActivity", ptm_CalcMainActivity)

