

ptmFlashlight = {}
ptm3rdFlashlights = {}

hook.Add("PreRender", "Pointman PreRender", function()

	local wep = LocalPlayer():GetActiveWeapon()

	-- update the flashlight
	if IsValid(wep) and wep.Lighted then

		local pos = LocalPlayer():GetViewModel():GetAttachment(1).Pos
		local ang = LocalPlayer():GetViewModel():GetAttachment(1).Ang
		if LocalPlayer():ShouldDrawLocalPlayer() then
			pos = wep:GetAttachment(1).Pos
			ang = wep:GetAttachment(1).Ang
		end

		if ptmFlashlight != nil and IsValid(ptmFlashlight.Main) then

			ptmFlashlight.Main:SetPos( pos + ang:Forward() * wep.LightOffset.x + ang:Right() * wep.LightOffset.y + ang:Up() * wep.LightOffset.z )
			ptmFlashlight.Main:SetAngles( ang )
			if wep:GetNWFloat("Suppressor") == 1 then
				ptmFlashlight.Main:SetTexture( wep.LightTextureSuppressed )
			else
				ptmFlashlight.Main:SetTexture( wep.LightTexture )
			end
			ptmFlashlight.Main:Update()

			if IsValid(ptmFlashlight.Env) then

				ptmFlashlight.Env:SetPos( pos + ang:Forward() * (wep.LightOffset.x - 16) + ang:Right() * wep.LightOffset.y + ang:Up() * wep.LightOffset.z )
				ptmFlashlight.Env:SetAngles( ang )
				ptmUpdateEnvLight(LocalPlayer(), wep, wep.AimPos, wep.AimAng)

			end

		elseif wep.Base == "pointman_arms_base" then

			wep.Lighted = false
			wep:CreateLight()

		end

	end

	-- create 3rd flashlights for every player
	for k, v in pairs(ents.GetAll()) do

		if IsValid(v) and v:GetClass() == "pointman_lamp" and Entity(v:GetOwnerIndex()):IsPlayer() and v:GetOwnerIndex() != LocalPlayer():EntIndex() then
		
			local index = v:EntIndex()
			local weapon = Entity(v:GetOwnerIndex()):GetActiveWeapon()

			local pos = weapon:GetAttachment(1).Pos
			local ang = weapon:GetAttachment(1).Ang

			if ptm3rdFlashlights[index] != nil and IsValid(ptm3rdFlashlights[index].Main) then

				ptm3rdFlashlights[index].Main:SetPos( pos + ang:Forward() * weapon.LightOffset.x + ang:Right() * weapon.LightOffset.y + ang:Up() * weapon.LightOffset.z )
				ptm3rdFlashlights[index].Main:SetAngles( ang )
				if weapon:GetNWFloat("Suppressor") == 1 then
					ptm3rdFlashlights[index].Main:SetTexture( weapon.LightTextureSuppressed )
				else
					ptm3rdFlashlights[index].Main:SetTexture( weapon.LightTexture )
				end
				ptm3rdFlashlights[index].Main:Update()

			else

				ptm3rdFlashlights[index] = {}
				ptm3rdFlashlights[index].Main = ProjectedTexture()
				ptm3rdFlashlights[index].Main:SetPos( pos + ang:Forward() * weapon.LightOffset.x + ang:Right() * weapon.LightOffset.y + ang:Up() * weapon.LightOffset.z )
				ptm3rdFlashlights[index].Main:SetAngles( ang )
				ptm3rdFlashlights[index].Main:SetBrightness( weapon.LightBrightness )
				ptm3rdFlashlights[index].Main:SetFarZ( weapon.LightFarZ )
				ptm3rdFlashlights[index].Main:SetFOV( weapon.LightFOV )
				if weapon:GetNWFloat("Suppressor") == 1 then
					ptm3rdFlashlights[index].Main:SetTexture( weapon.LightTextureSuppressed )
				else
					ptm3rdFlashlights[index].Main:SetTexture( weapon.LightTexture )
				end
				ptm3rdFlashlights[index].Main:Update()

			end

		end

	end

end)

--	remove flashlights
hook.Add("EntityRemoved", "Pointman EntityRemoved", function(ent)

	if ent:GetClass() == "pointman_lamp" then
	
		if game.SinglePlayer() and Entity(ent:GetOwnerIndex()):IsPlayer() then
		
			if ptmFlashlight != nil then
			
				for k, v in pairs(ptmFlashlight) do

					if IsValid(v) then

						v:Remove()

					end

				end
				ptmFlashlight = nil

			end
			
		else
	
			if ptm3rdFlashlights[ent:EntIndex()] != nil then
			
				for k, v in pairs(ptm3rdFlashlights[ent:EntIndex()]) do
					
						if IsValid(v) then
							
							v:Remove()
							
						end
					
					end
					
				end
			
			end
	
	end

end)

local pBrightness = 0

ptmUpdateEnvLight = function(owner, wep, pos, ang)

	-- environment lighting casted from flashlight
	-- no pretty way to do this
	local length = 2		-- radius of middle light spot
	
	-- right
	local td1 = {}
		td1.start = pos + ang:Right() * length
		td1.endpos = td1.start + ang:Forward() * 1024
		td1.filter = { owner, wep }
	local tr1 = util.TraceLine(td1)
	
	-- left
	local td2 = {}
		td2.start = pos - ang:Right() * length
		td2.endpos = td2.start + ang:Forward() * 1024
		td2.filter = { owner, wep }
	local tr2 = util.TraceLine(td2)
	
	local dist1 = tr1.HitPos:Distance(pos)
	local dist2 = tr2.HitPos:Distance(pos)
	local dist = math.min(dist1, dist2)
	
	local brightness = dist == 0 and 0.3 or 1/(dist^2 * 0.0001)		-- avoid 0 as the denominator
	brightness = wep:LerpLocal(0.8 * FrameTime(), pBrightness, brightness)
	brightness = math.Clamp(brightness, 0.05, 0.3)
	pBrightness = brightness
	
	ptmFlashlight.Env:SetBrightness( brightness )
	ptmFlashlight.Env:Update()

end

