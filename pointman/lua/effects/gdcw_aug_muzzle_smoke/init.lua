

function EFFECT:Init(data)
	
	if not IsValid(data:GetEntity()) then return end
	if not IsValid(data:GetEntity():GetOwner()) then return end
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()

	self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Forward = data:GetNormal()

	self.AddVel = self.WeaponEnt:GetOwner():GetVelocity() || Vector(0,0,0)

	local envlight = (render.ComputeLighting(self.Position + self.Forward * 16, Vector(0, 0, 1)) + render.ComputeDynamicLighting(self.Position + self.Forward * 16, Vector(0, 0, 1))):Length()
	envlight = math.Clamp(envlight * 200, 0.05, 1)

	local emitter = ParticleEmitter(self.Position)

		for i=1, 4 do
		local particle = emitter:Add("particle/smokesprites_000"..math.random(1,9), self.Position)
		particle:SetVelocity(40*i*self.Forward)
		particle:SetDieTime(math.Rand(0.4,0.6))
		particle:SetStartAlpha(math.Rand(10,15)*envlight)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(8,10))
		particle:SetEndSize(math.Rand(20,24))
		particle:SetRoll(math.Rand(0,360))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(120,120,120)
		particle:SetAirResistance(250)
		end

		local dice = math.random(3,4)
		for i=1, 3 do
		local particle = emitter:Add("effects/muzzleflash"..math.random(1,4), self.Position+(self.Forward*i*2))
		particle:SetVelocity((self.Forward*i*5) + self.AddVel)
		particle:SetDieTime(0.05)
		particle:SetStartAlpha(20/envlight^10)
		particle:SetEndAlpha(0)
		particle:SetStartSize((4-i)*dice/4)
		particle:SetEndSize((6-i)*dice/4)
		particle:SetRoll(math.Rand(0,360))
		particle:SetColor(255,255,255)
		end

	emitter:Finish()

end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

