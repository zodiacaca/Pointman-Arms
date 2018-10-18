

SWEP.Weight				= 25
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom	= false		-- pick up the weapon if its weight is bigger then this gun


--[[---------------------------------------------------------
   Name: Initialize
-----------------------------------------------------------]]
function SWEP:WeaponInitialize()

	if self.Owner:IsNPC() then
	
		if self.Owner:GetClass() == "npc_citizen" then
			self:SetHoldType("pistol")
		else
			self:SetHoldType(self.HoldType)
		end
		
		self:CreateNPCLight()
		
		self.Owner:SetKeyValue("spawnflags", "256")
		self.Owner:Fire("DisableWeaponPickup")
		
	end
	
end

function SWEP:CreateNPCLight()

	if GetConVar("PointmanNPCFlashlights") != nil then
		if GetConVar("PointmanNPCFlashlights"):GetBool() then
		
			self.Light = ents.Create( "pointman_lamp" )
			self.Light:SetParent( self.Weapon, 1 )
			self.Light:SetLocalPos( self.LightOffset )
			self.Light:SetLocalAngles( Angle( 0, 0, 0 ) )
			self.Light:SetOwnerIndex(self.Owner:EntIndex())
			self.Light:SetWeaponIndex(self.Weapon:EntIndex())
			self.Light:SetLaserOutlet(self.LaserOutlet)
			self.Light.Brightness = self.LightBrightness
			self.Light.MaxDistance = self.LightFarZ
			self.Light.FOV = self.LightFOV
			self.Light.Texture = self.LightTexture
			self.Light:Spawn()
			self.Light:Activate()
			
			self.Lighted = true
			
		end
	end
	
end

--[[---------------------------------------------------------
   Name: Equip
-----------------------------------------------------------]]
function SWEP:Equip( NewOwner )

	-- if NewOwner:IsPlayer() then
		-- if IsValid(self.Weapon) and self.Lighted then
			-- if ptmFlashlight != nil then
				-- for k, v in pairs(ptmFlashlight) do
					 -- if IsValid(v) then
						-- v:SetKeyValue( "lightcolor", Format( "%i %i %i 255", 0, 0, 0 ) )
						-- SafeRemoveEntity( v )
					-- end
				-- end
			-- end
		-- end
	-- end
	
end

--[[---------------------------------------------------------
   Name: EquipAmmo
-----------------------------------------------------------]]
function SWEP:EquipAmmo( NewOwner )
end

--[[---------------------------------------------------------
   Name: ShouldDropOnDie
-----------------------------------------------------------]]
function SWEP:ShouldDropOnDie()

	-- if self.Owner:IsNPC() then
		-- return false
	-- else
		-- return true
	-- end
	
end

