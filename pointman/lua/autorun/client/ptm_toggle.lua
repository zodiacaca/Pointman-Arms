

local LastAim = 0
local LastWalk = 0
local LastCrouch = 0
local toggle_aim = false
local toggle_walk = false
local toggle_crouch = false
local temp_walk = false
local shouldWalk = false

function ptm_CreateMove(cmd)

	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) then return end

	if wep.Base == "pointman_arms_base" or GetConVar("PointmanToggleGlobal"):GetBool() then

		local FT = FrameTime()
		
		-- limit speed
		if ply:KeyDown(IN_ATTACK2) or ply:KeyDown(IN_BACK) or (wep.Stamina and wep.Stamina > 2000) then
			shouldWalk = true
		else
			shouldWalk = false
		end
		
		if ply:GetAbsVelocity():Length() > 5 then
			if shouldWalk and !ply:KeyDown(IN_WALK) then
				ply:ConCommand("+walk")			-- toggle to walk mode
				temp_walk = true
			end
		end
		if temp_walk and !shouldWalk then
			ply:ConCommand("-walk")
			temp_walk = false
		end

		-- toggles
		if !input.IsMouseDown(MOUSE_RIGHT) and toggle_aim == false then
			ply:ConCommand("-attack2")
		end
		if input.IsMouseDown(MOUSE_RIGHT) and ply:KeyDown(IN_ATTACK2) and CurTime() - LastAim > 0.3 then
			toggle_aim = false
		else
			toggle_aim = true
		end

		if input.LookupBinding("+walk") == "ALT" then
			if !input.IsKeyDown(KEY_LALT) and toggle_walk == false then
				ply:ConCommand("-walk")
			end
			if input.IsKeyDown(KEY_LALT) and ply:KeyDown(IN_WALK) and CurTime() - LastWalk > 0.3 then
				toggle_walk = false
			else
				toggle_walk = true
			end
		end

		if input.LookupBinding("+duck") == "CTRL" then
			if !input.IsKeyDown(KEY_LCONTROL) and toggle_crouch == false then
				ply:ConCommand("-duck")
			end
			if input.IsKeyDown(KEY_LCONTROL) and ply:KeyDown(IN_DUCK) and CurTime() - LastCrouch > 0.3 then
				toggle_crouch = false
			else
				toggle_crouch = true
			end
		end

		if ply:KeyDown(IN_SPEED) or ply:KeyDown(IN_JUMP) then
			ply:ConCommand("-duck")
		end
		if ply:KeyDown(IN_SPEED) then
			ply:ConCommand("-attack2")
		end
		
	end

end
hook.Add("CreateMove", "ptm_CreateMove", ptm_CreateMove)


local lastMenuTime = 0

function ptm_PlayerBindPressed(ply, bind, pressed)

	if not IsValid(ply) then return end
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) then return end

	if wep.Base == "pointman_arms_base" or GetConVar("PointmanToggleGlobal"):GetBool() then

		-- toggles
		if bind == "+walk" then
			if ply:KeyDown(IN_WALK) then
				ply:ConCommand("-walk")
			else
				ply:ConCommand("+walk")
				LastWalk = CurTime()
			end
		end

		if bind == "+attack2" then
			if ply:KeyDown(IN_ATTACK2) then
				ply:ConCommand("-attack2")
			else
				ply:ConCommand("+attack2")
				LastAim = CurTime()
			end
		end

		if bind == "+duck" then
			if ply:KeyDown(IN_DUCK) then
				ply:ConCommand("-duck")
			else
				ply:ConCommand("+duck")
				LastCrouch = CurTime()
			end
		end

		-- open door
		local tr = ply:GetEyeTrace()
		
		if IsValid(tr.Entity) then
		
			local door = string.find( tr.Entity:GetClass(), "door", 1, false)
			local dist = tr.HitPos:Distance(ply:EyePos())

			if bind == "+use" and door and dist < 88 then
				wep.LastUse = CurTime()
				net.Start("pointman_opendoor")
					net.WriteFloat(CurTime())
				net.SendToServer()
			end
			
		end
		
		-- disable spawn menu
		if bind == "noclip" then
			if CurTime() - lastMenuTime <= 0.2 then
				wep.CanOpenMenu = !wep.CanOpenMenu
			end
			lastMenuTime = CurTime()
		end

	end

end
hook.Add("PlayerBindPress", "ptm_PlayerBindPress", ptm_PlayerBindPressed)


local function ptm_DisallowSpawnMenu()

	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) then return end

	if wep.Base == "pointman_arms_base" and !wep.CanOpenMenu then
		return false
	end
	
end
hook.Add( "SpawnMenuOpen", "ptm_DisallowSpawnMenu", ptm_DisallowSpawnMenu)

