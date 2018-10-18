

-- for NPC and easier to create the flare and sync to server
SWEP.Light = {}

function SWEP:CreateLight()

	if !self.Lighted and self.LightState then
	
		self.Light = ents.Create("pointman_lamp")
		
		if IsValid(self.Light) then
		
			self.Light:SetParent(self.Weapon, 1)
			self.Light:SetLocalPos(self.LightOffset)
			self.Light:SetLocalAngles(Angle(0, 0, 0))
			self.Light:SetOwnerIndex(self.Owner:EntIndex())
			self.Light:Spawn()
			self.Light:Activate()
			
		end

		self.Lighted = true

	else

		self:RemoveLight()
		
		self.Lighted = false

	end

end

function SWEP:RemoveLight()

	if self.Light then
	
		SafeRemoveEntity(self.Light)

	end

end

