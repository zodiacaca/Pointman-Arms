
AddCSLuaFile()

ENT.Type			= "anim"
ENT.Base			= "base_anim"
ENT.PrintName	= "pointman_lamp"
ENT.Spawnable	= false


--[[---------------------------------------------------------
   Name: SetupDataTables
-----------------------------------------------------------]]
function ENT:SetupDataTables()

	self:NetworkVar( "Vector", 1, "LaserOutlet" )
	self:NetworkVar( "Int", 1, "WeaponIndex" )
	self:NetworkVar( "Int", 2, "OwnerIndex" )
	
end

if SERVER then

--[[---------------------------------------------------------
   Name: Initialize
-----------------------------------------------------------]]
function ENT:Initialize()

	self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	self:DrawShadow( false )
	
	local phys = self:GetPhysicsObject()
	
	if ( IsValid( phys ) ) then
		phys:EnableGravity(false)
		phys:EnableCollisions(false)
		phys:EnableDrag(false)
		phys:Wake()
	end
	
	if self.Owner:IsNPC() then
		self:LightOn()
	end
	
end

function ENT:LightOn()

	local c = Color( 255, 255, 255 )
	
	self.flashlight = ents.Create( "env_projectedtexture" )
	
	self.flashlight:SetParent( self.Entity )
	
	self.flashlight:SetLocalPos( Vector( 0, 0, 0 ) )
	self.flashlight:SetLocalAngles( Angle(0, 0, 0) )
	self.flashlight:SetKeyValue( "farz", self.MaxDistance )
	self.flashlight:SetKeyValue( "lightfov", self.FOV )
	self.flashlight:SetKeyValue( "lightcolor", Format( "%i %i %i 255", c.r * self.Brightness, c.g * self.Brightness, c.b * self.Brightness ) )
	-- self.flashlight:SetKeyValue( "ambient", "1" )
	
	self.flashlight:Spawn()
	
	self.flashlight:Input( "SpotlightTexture", NULL, NULL, self.Texture )
	-- self.flashlight:Input( "TurnOff" )
	-- self.flashlight:Input( "Ambient", "1" )
	
end

--[[---------------------------------------------------------
   Name: OnRemove
-----------------------------------------------------------]]
function ENT:OnRemove()

	SafeRemoveEntity( self.flashlight )
	
end

--[[---------------------------------------------------------
   Name: Think
-----------------------------------------------------------]]
function ENT:Think()
end

end

if CLIENT then

--[[---------------------------------------------------------
   Name: Initialize
-----------------------------------------------------------]]
function ENT:Initialize()

	self.PixVis = util.GetPixelVisibleHandle()
	
end

--[[---------------------------------------------------------
   Name: Draw
-----------------------------------------------------------]]
function ENT:Draw()

	if Entity(self:GetOwnerIndex()):IsNPC() then
	
		local position, angles = self.Entity:GetPos(), self.Entity:GetAngles()

		position = position + angles:Up() * self.Entity:GetLaserOutlet().z
		position = position + angles:Right() * self.Entity:GetLaserOutlet().y
		position = position + angles:Forward() * self.Entity:GetLaserOutlet().x

		local trd = {}
			trd.start = position
			trd.endpos = trd.start + angles:Forward() * 33000
			trd.filter = { self.Entity, Entity(self.Entity:GetOwnerIndex()), Entity(self.Entity:GetWeaponIndex()) }
			trd.mask = MASK_BLOCKLOS_AND_NPCS
		local tracer = util.TraceLine(trd)

		if !tracer.HitSky and LocalPlayer():IsLineOfSightClear(tracer.HitPos) then
			local size = 8
			local a = (2.5 + math.sin(CurTime() * 120)) * 128
			a = math.Clamp(a, 0, 255)
			render.SetMaterial(Material("sprites/pointman_laser_beam"))
			render.DrawBeam(position, tracer.HitPos, 0.3, 0, 1, Color(255, 0, 0, 20))
			render.SetMaterial(Material("sprites/pointman_laser_dot"))
			render.DrawSprite(tracer.HitPos, size, size, Color(255, 255, 255, a))
		end
		
	end
	
end

end
