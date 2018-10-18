

function Pointman_CanPlayerEnterVehicle(ply, vehicle, sRole)

	local wep = ply:GetActiveWeapon()

	if IsValid(wep) then
		if wep.Base == "pointman_arms_base" then

			ply:PrintMessage(HUD_PRINTTALK, "Holster the gun first")

			return false

		end
	end

end
hook.Add("CanPlayerEnterVehicle", "Pointman CanPlayerEnterVehicle", Pointman_CanPlayerEnterVehicle)


function Pointman_Move(ply, mv)

	if not IsValid(ply) then return end
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) then return end

	if wep.Base == "pointman_arms_base" then
		if (ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT)) and ply:KeyDown(IN_WALK) and !ply:KeyDown(IN_SPEED) then
			mv:SetMaxClientSpeed(ply:GetWalkSpeed() * (0.5 - math.abs(wep.PeekOffset) * 0.00625))		-- slower when peeking
		end
	end

end
hook.Add("Move", "Pointman Move", Pointman_Move)


function Pointman_EntityTakeDamage(target, dmginfo)

	if not IsValid(target) then return end
	local attacker = dmginfo:GetAttacker()
	if not IsValid(attacker) then return end

	if target:IsNPC() and attacker:IsNPC() then

		if GetConVar("PointmanNoFriendlyDamage") != nil and GetConVar("PointmanNoFriendlyDamage"):GetBool() then
			dmginfo:ScaleDamage(0)
		end

	end
	
	if GetConVar("PointmanToggleGlobal"):GetBool() and target:IsNPC() then
	
		dmginfo:ScaleDamage(2)
		
	end

end
hook.Add("EntityTakeDamage", "Pointman EntityTakeDamage", Pointman_EntityTakeDamage)


local pEyeAngles = Angle(0, 0, 0)

function Pointman_SetupMove(ply, mv, cmd)

	local wep = ply:GetActiveWeapon()

	if IsValid(wep) and wep.Base == "pointman_arms_base" and wep.LastUse then
	
		local ea = ply:EyeAngles()
		local delta = Angle(wep:ConvertAngle(ea.x - pEyeAngles.x), wep:ConvertAngle(ea.y - pEyeAngles.y), 0)
		pEyeAngles = ea
		
		-- add side drag when forwarding
		if !(ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT)) and ply:KeyDown(IN_FORWARD) and ply:OnGround() then
			local side = delta.y * 450
			mv:SetSideSpeed( side )
			cmd:SetSideMove( side )
		end
		
		net.Receive( "pointman_opendoor", function( len, ply )
			if ( IsValid( ply ) and ply:IsPlayer() ) then
				wep.LastUse = net.ReadFloat()
			end
		end )

		-- freeze the movement
		if CurTime() - wep.LastUse < wep.InteractDuration then

			mv:SetUpSpeed( 0 )
			cmd:SetUpMove( 0 )
			mv:SetForwardSpeed( 0 )
			cmd:SetForwardMove( 0 )
			mv:SetSideSpeed( 0 )
			cmd:SetSideMove( 0 )

		end

	end

end
hook.Add("SetupMove", "Pointman SetupMove", Pointman_SetupMove)



function ptmBulletCrack(trStart, trEnd, tr, attacker, shotPos, shotDir, speed, stage)

	for i, p in pairs(player.GetAll()) do
		if p != attacker and IsValid(p) then
		
			local wep = p:GetActiveWeapon()
			
			if IsValid(wep) and wep.Base == "pointman_arms_base" then
			
				local vecA = (trEnd - trStart):GetNormal()
				local vecB = (p:EyePos() - trStart):GetNormal()
				local dot = vecA:Dot(vecB)
				local rad = math.acos(dot)
				local lengthC = p:EyePos():Distance(trStart)
				local shorterCathetus = lengthC * math.sin(rad)
				local forward = shotDir * (dot * (lengthC))
				local distEye = p:EyePos():Distance(shotPos)
				local distStart = trStart:Distance(shotPos)
				local checkA = lengthC * math.cos(rad)
				local checkB = trEnd:Distance(trStart)
				if shorterCathetus <= 128 and distStart < distEye and checkA < checkB then

					local pos = trStart + forward

					if p:IsLineOfSightClear(pos) and forward:Length() < tr.HitPos:Distance(trStart) then

						local bulletmiss = {}
						bulletmiss[1] = Sound("weapons/fx/near_mono/bulletLtoR07.wav")
						bulletmiss[2] = Sound("weapons/fx/near_mono/bulletLtoR13.wav")
						bulletmiss[3] = Sound("weapons/fx/near_mono/bulletLtoR11.wav")
						bulletmiss[4] = Sound("weapons/fx/near_mono/bulletLtoR09.wav")
						bulletmiss[5] = Sound("weapons/fx/near_mono/bulletLtoR05.wav")
						bulletmiss[6] = Sound("weapons/fx/near_mono/bulletLtoR12.wav")
						local soundtospeed = speed > 1020 and table.Count(bulletmiss) or math.floor(speed/170)
						-- print(stage, dot, soundtospeed, (pos - trStart):Length()/52)
						local volume = 45 + (128 - shorterCathetus)/128 * 50

						wep:CallOnClient( "PlayCrackSound", bulletmiss[soundtospeed].." "..volume.." "..pos.x.." "..pos.y.." "..pos.z )

					end
				
				end

			end

		end
	end

end


function ptmProcessPhyBullet(b, tbl, idx)

	local trd = {}
		trd.start = b.finalPos
		trd.endpos = trd.start + b.ShotDir * b.finalSpeed * 0.05 * 52
		trd.filter = { b.Attacker, b.Inflictor }
		trd.mask = MASK_SHOT + MASK_WATER
	local tracer = util.TraceLine(trd)

	ptmBulletCrack(trd.start, trd.endpos, tracer, b.Attacker, b.ShotPos, b.ShotDir, b.initialSpeed, b.stage)

	if tracer.Hit then
		-- local tbl = {
			-- dmg = b.finalDamage,
			-- dist = tracer.HitPos:Distance(b.ShotPos) / 52,
			-- deb = b.Deviation,
			-- stg = b.stage,
			-- eng = b.finalEnergy
		-- }
		-- PrintTable(tbl)
		if IsValid(b.Inflictor) then
			b.Inflictor:ShootPhyBullet(b.finalPos, b.ShotDir, 0, 0, b.finalDamage)
		end
		table.remove( tbl, idx )
	else
		b.initialPos = b.finalPos
		b.initialSpeed = b.finalSpeed
		b.initialEnergy = 0.5 * b.Mass * b.initialSpeed^2
		b.finalSpeed = math.sqrt( ( b.initialEnergy - b.BulletRC * b.initialSpeed^2 * 0.05 ) * 2 / b.Mass )
		b.finalPos = b.initialPos + b.ShotDir * b.initialSpeed * 0.05 * 52 - Vector(0, 0, 0.5 * 9.8 * (0.05 * b.stage)^2)
		b.finalEnergy = 0.5 * b.Mass * b.finalSpeed^2
		b.finalDamage = b.finalEnergy / b.MuzzleEnergy * b.InitialDamage
	end

end


function Pointman_PlayerTick(ply, mv)

	if !IsValid(ply) then return end

	ply:LagCompensation(true)

	if PTM_PhyBullet[ply:EntIndex()] then
		for k, v in pairs(PTM_PhyBullet[ply:EntIndex()]) do

			v.stage = v.stage + 1			-- proceeding every tick
			ptmProcessPhyBullet(v, PTM_PhyBullet[ply:EntIndex()], k)

		end
	end

	ply:LagCompensation(false)

end
hook.Add("PlayerTick", "Pointman PlayerTick", Pointman_PlayerTick)


function Pointman_NPCTick()

	if PTM_PhyBulletNPC then
		for k, v in pairs(PTM_PhyBulletNPC) do

			v.stage = v.stage + 1
			ptmProcessPhyBullet(v, PTM_PhyBulletNPC, k)

		end
	end

end
hook.Add("Tick", "Pointman NPCTick", Pointman_NPCTick)

