
ENT.Type			= "anim"
ENT.Base			= "base_anim"
ENT.PrintName	= "steyr_auga3_ent"
ENT.Spawnable	= false


if SERVER then

AddCSLuaFile()

function ENT:Initialize()

	self.Entity:SetModel("models/weapons/w_steyr_auga3.mdl")
	self.Entity:PhysicsInit(SOLID_NONE)
	self.Entity:SetMoveType(MOVETYPE_NOCLIP)
	self.Entity:SetSolid(SOLID_NONE)
	self.Entity:DrawShadow(true)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	
	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableGravity(false)
		phys:EnableCollisions(false)
		phys:EnableDrag(false)
		phys:Wake()
	end
	
end

function ENT:Think()

	if not IsValid(self.Owner) then
		SafeRemoveEntity(self)
	elseif self.Owner:Health() <= 0 then
		SafeRemoveEntity(self)
	end
	
end

end

if CLIENT then

function ENT:Draw()

	if LocalPlayer() == self.Owner and !self.Owner:ShouldDrawLocalPlayer() then return end
	
	self.Entity:DrawModel()
	
end

end
