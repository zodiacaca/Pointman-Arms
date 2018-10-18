
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

SWEP.Weight				= 20
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom	= false		-- pick up the weapon if its weight is bigger then this gun


--[[---------------------------------------------------------
     Initialize
-----------------------------------------------------------]]
function SWEP:WeaponInitialize()

	if self.Owner:IsNPC() then
	
		-- hack the hold type
		if self.Owner:GetClass() == "npc_citizen" then
			self:SetHoldType("pistol")
		else
			self:SetHoldType("ar2")
		end
		
		-- self:CreateNPCLight()
		
		-- some properties
		self.Owner:SetKeyValue("spawnflags", "256")		-- long range
		self.Owner:Fire("DisableWeaponPickup")
		
	end
	
end

function SWEP:CreateNPCLight()			-- draw laser as well

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

--[[---------------------------------------------------------
     Equip
-----------------------------------------------------------]]
function SWEP:Equip( NewOwner )

	-- if NewOwner:IsPlayer() then
		-- if IsValid(self.Weapon) and self.Lighted then
			-- if ptmFlashlight != nil then
				-- for k, v in pairs(ptmFlashlight) do
					 -- if IsValid(v) then
						-- v:SetKeyValue( "lightcolor", Format( "%i %i %i 255", 0, 0, 0 ) )
						-- v:Remove()
					-- end
				-- end
				-- ptmFlashlight = nil
			-- end
		-- end
	-- end
	
end

function SWEP:EquipAmmo( NewOwner )
end

--[[---------------------------------------------------------
     ShouldDropOnDie
-----------------------------------------------------------]]
function SWEP:ShouldDropOnDie()

	-- if self.Owner:IsNPC() then
		-- return false
	-- else
		-- return true
	-- end
	
end

