
ENT.Type			= "anim"
ENT.Base			= "base_anim"
ENT.PrintName	= "rf_plst_magazine"
ENT.Spawnable	= false


if SERVER then

AddCSLuaFile()

function ENT:Initialize()

	self.Entity:SetModel("models/weapons/rf_plst_magazine.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(false)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end

	self.Entity:SetUseType(SIMPLE_USE)

	self.LifeTime = CurTime() + 600

end

local mat = {
	MAT_COMPUTER,
	MAT_CONCRETE,
	MAT_METAL,
	MAT_PLASTIC
}
function ENT:PhysicsCollide(data, phys)

	local td = {}
		td.start = self.Entity:GetPos()
		td.endpos = td.start - Vector(0, 0, 32)
		td.filter = { self.Entity }
	local tr = util.TraceLine(td)
	
	local hard = false
	for k, v in pairs(mat) do
		if tr.MatType == v then
			hard = true
		end
	end
	
	local volume = math.Clamp(data.Speed/2, 50, 80)
	if data.Speed > 150 then
		if hard then 
			sound.Play( "weapons/pointman/impact/hard"..math.random(1,3)..".wav", self.Entity:GetPos(), volume, math.random(95,105) * GetConVarNumber("host_timescale"), 1 )
		else
			sound.Play( "weapons/pointman/impact/soft"..math.random(1,2)..".wav", self.Entity:GetPos(), volume, math.random(95,105) * GetConVarNumber("host_timescale"), 1 )
		end
	else
		sound.Play( "weapons/pointman/impact/soft"..math.random(1,2)..".wav", self.Entity:GetPos(), volume, math.random(95,105) * GetConVarNumber("host_timescale"), 1 )
	end
	
end

function ENT:Use(activator, caller, useType, value)

	if not IsValid(activator) then return end

	activator:GiveAmmo(self.Amount, "AR2", false)
	SafeRemoveEntity(self)

end

function ENT:Think()

	if CurTime() > self.LifeTime then
		SafeRemoveEntity(self)
	end

end

end

if CLIENT then

function ENT:Draw()

	self.Entity:DrawModel()

end

end