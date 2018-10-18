

SWEP.KickupMax = 2
SWEP.KickupMin = 1.5
SWEP.Horizontal = 0.75

SWEP.InitialSpeed = 341.376
SWEP.BulletDeviation = 0.15		-- spread
SWEP.InitialEnergy = 466.15
SWEP.AirResistanceCoefficient = 0.006
SWEP.BulletMass = 0.008

SWEP.BulletImpactPhysics = {
	RicochetAngle = {
		["Metal"] = { min = 0, max = 90, bounce = 0.95 },
		["Concrete"] = { min = 30, max = 90, bounce = 0.5 }
	},
	SplashAngle = {
		["Metal"] = { min = 90, max = 90 },
		["Concrete"] = { min = 90, max = 90 }
	},
	PenetrationLength = {
		["Flesh"] = 12,
		["Dirt"] = 8,
		["Loose"] = 32,
		["Sand"] = 6,
		["Tile"] = 4,
		["Default"] = 0
	}
}
-- SWEP.BulletImpactPhysics = {
	-- RicochetAngle = {
		-- ["Metal"] = { min = 45, max = 90 },
		-- ["Concrete"] = { min = 60, max = 90 }
	-- },
	-- SplashAngle = {
		-- ["Metal"] = { min = 0, max = 30 },
		-- ["Concrete"] = { min = 90, max = 90 }
	-- }
-- }


function SWEP:ShootEffects()

	if self:Clip1() == 1 then
		self.Weapon:SendWeaponAnim( ACT_VM_DRYFIRE )
	else
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	end
	self.Owner:GetViewModel():SetPlaybackRate(1)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )			-- 3rd person animation

	-- self.Owner:MuzzleFlash()								-- crappy muzzle light

end

function SWEP:ShootBullet(damage, num_bullets, aimcone)

	math.randomseed(CurTime())

	local pos, ang, dir

	if self.Owner:IsPlayer() then
		-- in sync with all kind of movements
		pos = self.AimPos
		ang = self.AimAng
		-- fix the direction in FP, a bit..
		if !((SERVER and self.In3rdBool) or (CLIENT and self.Owner:ShouldDrawLocalPlayer())) then
			ang:RotateAroundAxis(ang:Right(), -0.5)
		end
		ang = ang + self.Owner:GetViewPunchAngles()		-- gmod built-in function
		dir = ang:Forward()		-- turn into direction
	else
		pos = self.Owner:GetShootPos()
		dir = self.Owner:GetAimVector()
	end

	if self.Owner:IsPlayer() then
		self.Owner:LagCompensation(true)
	end

	-- stage 1
	local trd = {}
		trd.start = pos
		trd.endpos = trd.start + dir * self.InitialSpeed * 0.05 * 52
		trd.filter = { self.Weapon, self.Owner }
		trd.mask = MASK_SHOT + MASK_WATER
	local tracer = util.TraceLine(trd)

	if SERVER then
		ptmBulletCrack(trd.start, trd.endpos, tracer, self.Owner, pos, dir, self.InitialSpeed, 1)
	end

	if tracer.Hit then
		self:ShootPhyBullet(pos, dir, aimcone, 9, damage)
	else		-- not hit start the physics calculation
		local bullet = {}
			-- initial final constants since it's the first stage
			bullet.finalSpeed = self.InitialSpeed
			bullet.finalPos = pos
			bullet.finalEnergy = self.InitialEnergy

			bullet.stage = 1
			bullet.Deviation = Angle(math.Rand(-self.BulletDeviation,self.BulletDeviation), math.Rand(-self.BulletDeviation,self.BulletDeviation), 0)
			bullet.Mass = self.BulletMass
			bullet.BulletRC = self.AirResistanceCoefficient
			bullet.MuzzleEnergy = self.InitialEnergy
			bullet.InitialDamage = damage
			bullet.initialPos = bullet.finalPos
			bullet.initialSpeed = bullet.finalSpeed
			bullet.initialEnergy = 0.5 * bullet.Mass * bullet.initialSpeed^2
			bullet.finalSpeed = math.sqrt( ( bullet.initialEnergy - bullet.BulletRC * bullet.initialSpeed^2 * 0.05 ) * 2 / bullet.Mass )
			bullet.ShotPos = pos
			-- initial the deviation
			bullet.Matrix = Matrix()
			bullet.Matrix:SetTranslation(bullet.ShotPos)
			if self.Owner:IsPlayer() then
				bullet.Matrix:SetAngles(ang)
			else
				bullet.Matrix:SetAngles(dir:Angle())
			end
			if self.Weapon:GetNWFloat("Suppressor") == 1 then
				bullet.Matrix:Rotate(bullet.Deviation)
				bullet.Matrix:Rotate(Angle(0.05, 0, 0))
			else
				bullet.Matrix:Rotate(bullet.Deviation)
			end
			bullet.ShotDir = bullet.Matrix:GetForward()
			bullet.finalPos = bullet.initialPos + bullet.ShotDir * bullet.initialSpeed * 0.05 * 52 - Vector(0, 0, 0.5 * 9.8 * (0.05 * bullet.stage)^2)
			bullet.finalEnergy = 0.5 * bullet.Mass * bullet.finalSpeed^2
			bullet.Attacker = self.Owner
			bullet.Inflictor = self.Weapon
			bullet.finalDamage = bullet.finalEnergy / bullet.MuzzleEnergy * bullet.InitialDamage
		if SERVER then
			if self.Owner:IsPlayer() then
				table.insert( PTM_PhyBullet[self.Owner:EntIndex()], bullet )
			else
				table.insert( PTM_PhyBulletNPC, bullet )
			end
		end
		-- stage 1 finished

	end

	if self.Owner:IsPlayer() then
		self.Owner:LagCompensation(false)
	end

	if self.Owner:IsPlayer() then

		local punch_v = math.Rand(-self.KickupMax,-self.KickupMin)
		local punch_h = math.Rand(-self.Horizontal,self.Horizontal)

		if self.Weapon:GetNWFloat("Suppressor") == 1 then
			punch_v = punch_v/1.2
			punch_h = punch_h/1.2
		end

		if self.Owner:KeyDown(IN_FORWARD) or self.Owner:KeyDown(IN_MOVELEFT) or self.Owner:KeyDown(IN_MOVERIGHT) then
			punch_v = punch_v * 1.5
			punch_h = punch_h * 1.5
		elseif self.dt.StateLower == POINTMAN_ST_AIM then
			punch_v = punch_v/1.15
			punch_h = punch_h/1.2
		end

		self.Owner:ViewPunch(Angle(punch_v, punch_h, 0) * 0.5)

		if game.SinglePlayer() then
			self.Owner:SetEyeAngles(self.Owner:EyeAngles() + Angle(punch_v, punch_h, 0) * 0.5)
		elseif CLIENT then
			self.Owner:SetEyeAngles(self.Owner:EyeAngles() + Angle(punch_v, punch_h, 0) * 0.5)
		end

		local ShellEject = EffectData()
			ShellEject:SetOrigin(pos + ang:Right() * 32)		-- only need the sound, make it so you can't see the extra big shell
			ang:RotateAroundAxis(ang:Up(), -90)
			ShellEject:SetAngles(ang)
		util.Effect(self.EjectEffect, ShellEject)

	end

end

