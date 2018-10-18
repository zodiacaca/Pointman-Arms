
SWEP.MeleeDamage = 50
SWEP.MeleeRange = 64
SWEP.MeleePunchAngles = Angle(0, 5, 0)

SWEP.MeleeDelay = 0

SWEP.SlashSound = Sound("Weapon_Knife.Slash")
SWEP.StabSound = { Sound("weapons/pointman/melee/stab1.wav"), Sound("weapons/pointman/melee/stab2.wav") }
SWEP.JarringSound = Sound("Weapon_Knife.HitWall")


function SWEP:KnifeAttack()

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK_SILENCED )
	self.Owner:GetViewModel():SetPlaybackRate( 1 )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Owner:GetViewModel():SetBodygroup( 5, 1 )		-- draw the knife from hiding
	if self.Owner:GetModel() == "" then
		self.Owner:SetBodygroup( 2, 1 )			-- pull out the knife from sheath
	end
	-- attack breaks the reloading
	if self.NoMagazine then		
		self.Owner:GetViewModel():SetBodygroup( 1, 1 )
		self.Weapon:SetBodygroup( 1, 1 )
	end
	
	timer.Remove("ResetPosition"..self:EntIndex())		-- reset the timer
	timer.Create("Stab"..self:EntIndex(), 0.3, 1, function()
		self:Stab()
	end)
	
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
	self.MeleeDelay = CurTime() + 1			-- next gun fire time
	
end

function SWEP:Stab()

	self.Weapon:EmitSound(self.SlashSound)
	
	if self.Owner:IsPlayer() then
		self.Owner:LagCompensation(true)
	end
	
	local pos = self.Owner:EyePos()
	local ang = self.Owner:EyeAngles() + self.Owner:GetViewPunchAngles()
	local dir = ang:Forward()
	
	local stab = {}
		stab.start = pos
		stab.endpos = pos + (dir * self.MeleeRange)
		stab.filter = { self.Owner, self.Weapon }
	local tracer = util.TraceLine(stab)
	
	if self.Owner:IsPlayer() then
		self.Owner:LagCompensation(false)
	end
	
	if self.Owner:GetModel() == "" then
		self.Owner:EmitSound("weapons/pointman/bonus/jill/melee_exhale1.wav", 32, math.Rand(100,105) * GetConVarNumber("host_timescale"), 1, CHAN_WEAPON)
	end
	
	local damage_multi = GetConVarNumber("PointmanDamageMultiplier") or 1
	local damage_dice = math.Rand(0.95,1.05)
	local pain = self.MeleeDamage * damage_multi * damage_dice * math.Clamp(1 - tracer.Fraction, 0, 1)			-- the closer the higher the damage
	
	if IsValid(self.Weapon) and IsValid(self.Owner) then
		if tracer.Hit and tracer.Entity != nil then
			local target = tracer.Entity
			if target:IsValid() then
				if target:IsNPC() or target:IsPlayer() or tracer.Entity:GetClass() == "prop_ragdoll"then
					self:BloodDecal(tracer.HitPos, target)
					sound.Play(self.StabSound[math.random(1,2)], tracer.HitPos, 100, math.random(95,105) * GetConVarNumber("host_timescale"), 1)
				else
					self:CutDecal(tracer.MatType)
				end
				local paininfo = DamageInfo()
					if GetConVar("AUGA3KnifeOneHit") != nil and GetConVar("AUGA3KnifeOneHit"):GetBool() then
						paininfo:SetDamage(target:Health())
					else
						paininfo:SetDamage(pain)
					end
					paininfo:SetDamageType(DMG_SLASH)
					paininfo:SetAttacker(self.Owner)
					paininfo:SetInflictor(self.Weapon)
					paininfo:SetDamageForce(tracer.Normal)
				if SERVER then target:TakeDamageInfo(paininfo) end
			else
				self:CutDecal(tracer.MatType)
			end
			self.Owner:ViewPunch(self.MeleePunchAngles * 0.5)
		else
			self.Owner:ViewPunch(self.MeleePunchAngles)
		end
	end
	
	if self.Stamina then
		self.Stamina = self.Stamina + 50			-- client?
		self.Stamina = math.Clamp(self.Stamina, 1, 2750)
	end
	
	timer.Create("ResetPosition"..self:EntIndex(), 0.6, 1, function()
		self.Owner:GetViewModel():SetBodygroup( 5, 0 )
		self.Owner:GetViewModel():SetSequence( self.Owner:GetViewModel():LookupSequence( "reset" ) )
		self.Owner:GetViewModel():SetPlaybackRate( 2 )
		if self.Owner:GetModel() == "" then
			self.Owner:SetBodygroup( 2, 0 )
		end
	end)
	
end

function SWEP:BloodDecal(pos, victim)

	local td = {}
		td.start = pos
		td.endpos = td.start - Vector(0, 0, 2048)
		td.filter = { self.Weapon, self.Owner, victim }
	local tr = util.TraceLine(td)
	if tr.Hit then
		util.Decal("Blood", tr.HitPos + Vector(0, 0, 1), tr.HitPos - Vector(0, 0, 1))
	end
	
end

function SWEP:CutDecal(mat)

	local look = self.Owner:GetEyeTrace()
	local pos = look.HitPos - Vector(0, 0, 8)
	util.Decal("ManhackCut", pos + look.HitNormal, pos - look.HitNormal)
	if mat == MAT_WOOD then
		self.Weapon:EmitSound(Sound("Wood.ImpactSoft"))
	elseif mat == MAT_PLASTIC then
		self.Weapon:EmitSound(Sound("Default.ImpactSoft"))
	elseif mat == MAT_FLESH then
		self.Weapon:EmitSound(Sound("Flesh.ImpactSoft"))
	elseif mat == MAT_SAND then
		self.Weapon:EmitSound(Sound("Sand.BulletImpact"))
	else
		self.Weapon:EmitSound(self.JarringSound)
	end
	
end
