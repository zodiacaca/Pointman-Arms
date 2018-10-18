

SWEP.KickupMax = 0.5
SWEP.KickupMin = 0.15
SWEP.Horizontal = 0.15

SWEP.InitialSpeed = 341.376
SWEP.BulletDeviation = 0.15
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


/*---------------------------------------------------------
	ShootEffects
---------------------------------------------------------*/
function SWEP:ShootEffects()

	if self:Clip1() == 1 then
		self.Weapon:SendWeaponAnim( ACT_VM_DRYFIRE )
	else
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	end
	self.Owner:GetViewModel():SetPlaybackRate(1)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )			-- 3rd person animation

	self.Owner:MuzzleFlash()								-- crappy muzzle light

end

/*---------------------------------------------------------
	ShootBullet
---------------------------------------------------------*/
function SWEP:ShootBulletInformation()

	local CurrentDamage

	local damage_multi = GetConVarNumber("PointmanDamageMultiplier") or 1
	local damage_dice = math.Rand(0.98,1.02)

	CurrentDamage = self.Primary.Damage * damage_multi * damage_dice

	self:ShootBullet(CurrentDamage, self.Primary.NumShots, self.Primary.Spread)

end

function SWEP:ShootBullet(damage, num_bullets, aimcone)

	math.randomseed(CurTime())

	local pos, ang, dir
	
	if self.Owner:IsPlayer() then
		-- in sync with all kind of movements
		pos = self.AimPos
		ang = self.AimAng
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

		self.Owner:ViewPunch(Angle(punch_v, punch_h, 0))

		if game.SinglePlayer() then
			self.Owner:SetEyeAngles(self.Owner:EyeAngles() + Angle(punch_v, punch_h, 0))
		elseif CLIENT then
			self.Owner:SetEyeAngles(self.Owner:EyeAngles() + Angle(punch_v, punch_h, 0))
		end

		local ShellEject = EffectData()
			ShellEject:SetOrigin(pos + ang:Right() * 32)		-- only need the sound, make it so you can't see the extra big shell
			ang:RotateAroundAxis(ang:Up(), -90)
			ShellEject:SetAngles(ang)
		util.Effect(self.EjectEffect, ShellEject)
		
	end

end

function SWEP:ShootPhyBullet(pos, dir, aimcone, tracernum, damage)

	local bullet = {}
	bullet.Num		= 1
	bullet.Src		= pos			-- Source
	bullet.Dir		= dir				-- Dir of bullet
	bullet.Spread	= Vector(aimcone, aimcone, 0)			-- Aim cone
	bullet.Tracer	= tracernum							-- Show a tracer on every x bullets
	bullet.TracerName = "Tracer"
	bullet.Force	= damage * 0.1			-- Amount of force to give to physics objects
	bullet.Damage	= damage
	bullet.Callback	= function(attacker, tracedata, dmginfo)
	
		-- self:RicochetCallback(1, tracedata, dmginfo)
		
	end
	
	self.Owner:FireBullets(bullet)
	
end

function SWEP:RicochetCallback(num, tracedata, dmginfo)
	
	local mat = tracedata.MatType
	local surfaceMat = ""
	if mat == MAT_METAL or mat == MAT_WARPSHIELD or mat == MAT_GRATE then
		surfaceMat = "Metal"
	elseif mat == MAT_CONCRETE then
		surfaceMat = "Concrete"
	else
		self:Penetration(num, tracedata, dmginfo)
		return
	end
	-- print("Ricochet", num, surfaceMat)
	local dot = tracedata.HitNormal:Dot(tracedata.Normal * -1)
	dot = math.deg( math.acos( dot ) )
	
	if num >= 3 then return end		-- max bouncing number
	
	if dot >= self.BulletImpactPhysics.RicochetAngle[surfaceMat].min and dot < self.BulletImpactPhysics.RicochetAngle[surfaceMat].max then
	
		local ang = (tracedata.Normal * -1):Angle()
		ang:RotateAroundAxis(tracedata.HitNormal, 180)
		local dir = ang:Forward()
	
		local damage = dmginfo:GetDamage() * (dot + (90 - dot) * 0.5) / 90 * self.BulletImpactPhysics.RicochetAngle[surfaceMat].bounce
		local ratio = damage / self.Primary.Damage
		local cone = 0.05
		
		local ricochetbullet = {}
		ricochetbullet.Num		= 1
		ricochetbullet.Src			= tracedata.HitPos
		ricochetbullet.Dir			= dir
		ricochetbullet.Spread	= Vector(cone, cone, 0)
		ricochetbullet.Tracer	= 0
		ricochetbullet.TracerName = "m9k_aug_penetration_trace"
		ricochetbullet.Force		= damage * 0.1
		ricochetbullet.Damage	= damage
		ricochetbullet.Callback	= function(atker, tr, dmg)

			if SERVER then
				ptmBulletCrack(tr.StartPos, tr.HitPos, tr, Entity(0), tr.StartPos, dir, math.sqrt(0.5 * self.BulletMass * self.InitialSpeed^2 * ratio * 2 / self.BulletMass), 1)
			end
			self:RicochetCallback(num + 1, tr, dmg)
			
		end

		Entity(0):FireBullets(ricochetbullet)
		
	end
	
end

function SWEP:Penetration(num, tracedata, dmginfo)
	
	local dir = tracedata.Normal
	local ratio = dmginfo:GetDamage() / self.Primary.Damage
	
	local mat = tracedata.MatType
	local surfaceMat = "Default"
	if mat == MAT_ALIENFLESH or mat == MAT_BLOODYFLESH or mat == MAT_FLESH or mat == MAT_ANTLION or mat == MAT_SLOSH then
		surfaceMat = "Flesh"
	elseif mat == MAT_DIRT or mat == MAT_GRASS or MAT_WOOD then
		surfaceMat = "Dirt"
	elseif mat == MAT_FOLIAGE or mat == MAT_COMPUTER or mat == MAT_GLASS or mat == MAT_PLASTIC or mat == MAT_VENT then
		surfaceMat = "Loose"
	elseif mat == MAT_SAND then
		surfaceMat = "Sand"
	elseif mat == MAT_TILE then
		surfaceMat = "Tile"
	end
	
	local length = self.BulletImpactPhysics.PenetrationLength[surfaceMat] * ratio		-- length decreased as the damage drop
	
	local td = {}
		td.start = tracedata.HitPos + dir * length
		td.endpos = td.start - dir * 33000
		if surfaceMat == "Flesh" then
			td.filter = { self.Owner, self.Weapon }
		else
			td.filter = { player.GetAll(), self.Weapon }			-- incase target get too close to the surface
		end
	local tr = util.TraceLine(td)
	
	local thickness = tr.HitPos:Distance(tracedata.HitPos)
	-- print(surfaceMat, thickness)
	if thickness >= length or thickness == 0 then return end
	
	local damage = dmginfo:GetDamage() * (1 - thickness / length)		-- left damage after penetration
	ratio = damage / self.Primary.Damage			-- update ratio
	local minimunRatio = 50^2 / self.InitialSpeed^2			-- consider a bullet has the speed of 50m/s still has the damage power
	if ratio < minimunRatio then return end
	
	-- effects
	util.Decal("Impact.Concrete", td.start, td.endpos)
	local effectdata = EffectData()
	effectdata:SetOrigin( tr.HitPos )
	util.Effect( "GlassImpact", effectdata, true, true )

	local bullet = {}
	bullet.Num		= 1
	bullet.Src			= tracedata.HitPos + dir * thickness
	bullet.Dir			= dir
	bullet.Spread	= Vector(0, 0, 0)
	bullet.Tracer	= 0
	bullet.TracerName = "m9k_aug_penetration_trace"
	bullet.Force		= damage * 0.1
	bullet.Damage	= damage
	bullet.Callback	= function(atker, tr, dmg)
	-- print("Penetration", thickness, tr.StartSolid, surfaceMat)
		if SERVER then
			ptmBulletCrack(tr.StartPos, tr.HitPos, tr, Entity(0), tr.StartPos, dir, math.sqrt(0.5 * self.BulletMass * self.InitialSpeed^2 * ratio * 2 / self.BulletMass), 1)
		end
		self:RicochetCallback(num, tr, dmg)
		
	end

	Entity(0):FireBullets(bullet)
	
end

/*---------------------------------------------------------
	DoImpactEffect
---------------------------------------------------------*/
function SWEP:DoImpactEffect( tr, damageType  )
	return false
end

/*---------------------------------------------------------
	TakePrimaryAmmo
---------------------------------------------------------*/
function SWEP:TakePrimaryAmmo( num )

	self.Weapon:SetClip1( self.Weapon:Clip1() - num )	
	
end

