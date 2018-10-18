

function EFFECT:Init(data)
	
	if not IsValid(data:GetEntity()) then return end
	if not IsValid(data:GetEntity():GetOwner()) then return end
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	
	if self.WeaponEnt == nil or self.WeaponEnt:GetOwner() == nil or self.WeaponEnt:GetOwner():GetVelocity() == nil then
		return
	else
	
	self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
	local AddVel = self.WeaponEnt:GetOwner():GetVelocity()
	
	local envlight = (render.ComputeLighting(self.Position + self.Forward * 16, Vector(0, 0, 1)) + render.ComputeDynamicLighting(self.Position + self.Forward * 16, Vector(0, 0, 1))):Length()
	envlight = math.Clamp(envlight * 200, 0.05, 1)
	
	local emitter = ParticleEmitter(self.Position)
	if emitter != nil then	
		local particle = emitter:Add( "sprites/heatwave", self.Position - self.Forward * 4 )
		if particle != nil then
	
			-- particle:SetVelocity( 80 * self.Forward + 20 * VectorRand() + 1.05 * AddVel )
			-- particle:SetGravity( Vector( 0, 0, 100 ) )
			-- particle:SetAirResistance( 160 )

			-- particle:SetDieTime( math.Rand( 0.2, 0.25 ) )

			-- particle:SetStartSize( math.random( 25, 40 ) )
			-- particle:SetEndSize( 10 )

			-- particle:SetRoll( math.Rand( 180, 480 ) )
			-- particle:SetRollDelta( math.Rand( -1, 1 ) )
		
		for i = 1, 4 do
			local particle = emitter:Add( "particle/particle_smokegrenade", self.Position )

				particle:SetVelocity( 140 * i * self.Forward + 8 * VectorRand() + AddVel )
				particle:SetAirResistance( 400 )
				particle:SetGravity( Vector( 0, 0, math.Rand( 100, 200 ) ) )

				particle:SetDieTime( math.Rand( 0.5, 1.0 ) )

				particle:SetStartAlpha( math.Rand( 25, 70 ) * envlight )
				particle:SetEndAlpha( 0 )

				particle:SetStartSize( math.Rand( 4, 8 ) )
				particle:SetEndSize( math.Rand( 20, 50 ) )

				particle:SetRoll( math.Rand( -25, 25 ) )
				particle:SetRollDelta( math.Rand( -0.05, 0.05 ) )

				particle:SetColor( 120, 120, 120 )
		end

		end
	emitter:Finish()
	end
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end

