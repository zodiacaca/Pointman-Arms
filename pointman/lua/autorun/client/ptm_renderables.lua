

-- draw lasers and flares
hook.Add("PostDrawTranslucentRenderables", "Pointman PostDrawTranslucentRenderables", function()

	for idx, ent in pairs(ents.GetAll()) do

		if IsValid(ent) and ent:GetClass() == "pointman_lamp" and ent:GetOwnerIndex() != LocalPlayer():EntIndex() then

			local LightNormal = ent:GetAngles():Forward()
			local ViewNormal = ent:GetPos() - EyePos()
			local Distance = ViewNormal:Length()
			ViewNormal:Normalize()
			local ViewDot = ViewNormal:Dot( LightNormal * -1 )
			local LightPos = ent:GetPos()

			local Visibile	= util.PixelVisible( LightPos, 2, ent.PixVis )

			render.SetMaterial(Material("sprites/pointman_flashlight_beam"))
			render.DrawBeam(LightPos, LightPos + LightNormal * 128, 50, 0, 0.99, Color(255, 255, 255, 80 * (1 - ViewDot)))		-- bug?

			if (!Visibile) then return end

			Distance = math.Clamp( Distance / 20, 2, 64 )
			local Size = math.Clamp( Visibile * ( ViewDot^3 ) * 1000 / Distance, 16, 64 )

			local Alpha = math.Clamp( 1000 * Visibile * ViewDot, 0, 100 )
			-- render.SetMaterial( Material( "sprites/ptm_lens_02" ) )
			render.SetMaterial( Material( "sprites/ptm_light_02" ) )
			render.DrawSprite( LightPos, Size, Size, Color(255, 255, 255, Alpha) )
			render.DrawSprite( LightPos, Size * 0.3, Size * 0.3, Color(255, 255, 255, Alpha) )		-- enhance

		end

	end

	for k ,v in pairs(player.GetAll()) do

		if IsValid(LocalPlayer()) and IsValid(v) then

			local wep = v:GetActiveWeapon()

			if IsValid(wep) then

				if wep:GetClass() == "ptm_glock19" then

					if wep:GetNWFloat("LAM") >= 1 and (wep:GetNWFloat("Mode") == 1 or wep:GetNWFloat("Mode") == 3) then

						if LocalPlayer() == wep.Owner and !LocalPlayer():ShouldDrawLocalPlayer() then

							local position, direction = wep:GetAimInfo()
							local angles = direction:Angle()

							position = position + angles:Forward() * wep.LaserOutlet.x
							position = position + angles:Right() * wep.LaserOutlet.y
							position = position + angles:Up() * wep.LaserOutlet.z

							local trd = {}
								trd.start = position
								trd.endpos = trd.start + angles:Forward() * 33000
								trd.filter = { v, wep }
								trd.mask = MASK_BLOCKLOS_AND_NPCS
							local tracer = util.TraceLine(trd)

							local diff1 = math.abs(direction.y - LocalPlayer():EyeAngles():Forward().y)
							local diff2 = math.abs(direction.x - LocalPlayer():EyeAngles():Forward().x)
							local diff = math.max(diff1, diff2)
							local laser_mul = math.Clamp(1 - diff * 30, 0, 1)
							render.SetMaterial(Material("sprites/pointman_laser_beam"))
							render.DrawBeam(position, tracer.HitPos, 0.15, 0, 1, Color(255, 255, 255, 15 * laser_mul))

							local dist = v:EyePos():Distance(tracer.HitPos)
							if !tracer.HitSky and LocalPlayer():IsLineOfSightClear(tracer.HitPos) then
								local size = math.Clamp(dist/420, 0.25, 1) * 24
								local a = (2.5 + math.sin(CurTime() * 120)) * 128
								a = math.Clamp(a, 0, 255)
								render.SetMaterial(Material("sprites/ptm_light_01"))		-- enhance
								render.DrawSprite(tracer.HitPos, size + 2, size + 2, Color(255, 0, 0, a))
								render.SetMaterial(Material("sprites/pointman_laser_dot"))
								render.DrawSprite(tracer.HitPos, size, size, Color(255, 255, 255, a))
							end

						else

							local position, angles = wep:GetAttachment(1).Pos, wep:GetAttachment(1).Ang

							position = position + angles:Forward() * wep.LaserOutlet3rd.x
							position = position + angles:Right()  * wep.LaserOutlet3rd.y
							position = position + angles:Up() * wep.LaserOutlet3rd.z

							local trd = {}
								trd.start = position
								trd.endpos = trd.start + angles:Forward() * 33000
								trd.filter = { v, wep }
								trd.mask = MASK_BLOCKLOS_AND_NPCS
							local tracer = util.TraceLine(trd)

							render.SetMaterial(Material("sprites/pointman_laser_beam"))
							render.DrawBeam(position, tracer.HitPos, 0.3, 0, 1, Color(255, 255, 255, 20))

							local dist = v:EyePos():Distance(tracer.HitPos)
							if dist > wep.LaserLineNearz3rd then
								if !tracer.HitSky and LocalPlayer():IsLineOfSightClear(tracer.HitPos) then
									local size = math.Clamp(dist/420, 0.25, 1) * 32
									local a = (2.5 + math.sin(CurTime() * 120)) * 128
									a = math.Clamp(a, 0, 255)
									render.SetMaterial(Material("sprites/pointman_laser_dot"))
									render.DrawSprite(tracer.HitPos, size, size, Color(255, 255, 255, a))
								end
							end

						end

					end

				end

			end

		end

	end

end)
