

function SWEP:Holster(wep)

	if wep == NULL then return end
	if not IsValid(self.Weapon) then return end
	if not IsValid(self.Owner) then return end
	if self.Weapon:GetNWBool("DoingSequence") then return end
	if timer.Exists("ResetPosition"..self:EntIndex()) and timer.TimeLeft("ResetPosition"..self:EntIndex()) > 0 then return end
	if timer.Exists("Stab"..self:EntIndex()) and timer.TimeLeft("Stab"..self:EntIndex()) > 0 then return end
	
end

function SWEP:RemoveTimer()

	timer.Remove("ClipOut"..self:EntIndex())
	timer.Remove("ClipIn"..self:EntIndex())
	timer.Remove("Release"..self:EntIndex())
	timer.Remove("ReloadBool"..self:EntIndex())
	timer.Remove("Stab"..self:EntIndex())
	timer.Remove("ResetPosition"..self:EntIndex())

end

function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() then return end

	if self.Owner:IsNPC() then

		if CurTime() > self.NPCNextShoot then
			self:ShootBulletInformation()
			self:TakePrimaryAmmo(1)
			local fx = EffectData()
				fx:SetEntity(self.Weapon)
				fx:SetOrigin(self.Owner:GetShootPos())
				fx:SetNormal(self.Owner:GetAimVector())
				fx:SetAttachment(self.MuzzleAttachment)
			util.Effect(self.MuzzleEffect, fx)
			self.Weapon:EmitSound(self.ShootSound)
			self.Weapon:SetNextPrimaryFire(CurTime() + 1/(self.Primary.RPM/60))
			self.NPCNextShoot = CurTime() + 1/(self.Primary.RPM/60)
		end
		
	else

		local close, direction, fraction, hitpos = self:CloseSight()

		if self.Owner:KeyDown(IN_USE) or (close and fraction > 0.5 and util.PointContents(hitpos) != CONTENTS_GRATE and !self.Owner:KeyDown(IN_WALK) and !self.Owner:KeyDown(IN_BACK)) and GetConVar("AUGA3AutoMelee") != nil and GetConVar("AUGA3AutoMelee"):GetBool() then		-- use melee attack

			timer.Remove("ClipOut"..self:EntIndex())
			timer.Remove("ClipIn"..self:EntIndex())
			timer.Remove("Release"..self:EntIndex())
			timer.Remove("ReloadBool"..self:EntIndex())
			self.Weapon:SetNWBool("Reloading", false)

			self:KnifeAttack()

			self.dt.State = POINTMAN_IDLE

		elseif CurTime() > self.MeleeDelay then

			if self.dt.State == POINTMAN_HOLSTER then
				if self.dt.HolsterDelay and CurTime() > self.dt.HolsterDelay and self.Owner:GetMoveType() != MOVETYPE_LADDER then
					self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
					self.Owner:GetViewModel():SetPlaybackRate(1)
					self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration() - 0.25)
					self.dt.State = POINTMAN_IDLE
				end
				return
			end

			self:ShootEffects()
			self:ShootBulletInformation()
			self:TakePrimaryAmmo(1)

			if self.Weapon:GetNWFloat("Suppressor") == 1 then
				local fx = EffectData()
					fx:SetEntity(self.Weapon)
					fx:SetOrigin(self.Owner:GetShootPos())
					fx:SetNormal(self.Owner:GetAimVector())
					fx:SetAttachment(self.MuzzleAttachment)
				util.Effect(self.SuppressedEffect, fx)
				self.Weapon:EmitSound(self.SuppressedSound)
			else
				local fx = EffectData()
					fx:SetEntity(self.Weapon)
					fx:SetOrigin(self.Owner:GetShootPos())
					fx:SetNormal(self.Owner:GetAimVector())
					fx:SetAttachment(self.MuzzleAttachment)
				util.Effect(self.MuzzleEffect, fx)
				self.Weapon:EmitSound(self.ShootSound)
			end

			self.Weapon:SetNextPrimaryFire(CurTime() + 1/(self.Primary.RPM/60))

		end
		
	end

end

