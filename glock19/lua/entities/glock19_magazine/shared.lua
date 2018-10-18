
ENT.Type			= "anim"
ENT.Base			= "base_anim"
ENT.PrintName	= "glock19_magazine"
ENT.Spawnable	= false


if SERVER then

AddCSLuaFile()

function ENT:Initialize()

	self.Entity:SetModel("models/weapons/pistol_magazine.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(false)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end

	self.Entity:SetUseType(SIMPLE_USE)		-- pick up ammo

	self.LifeTime = CurTime() + 600		-- remove after 10 minutes

end

-- a table of hard surfaces
local mat = {
	MAT_COMPUTER,
	MAT_CONCRETE,
	MAT_METAL,
	MAT_PLASTIC
	}

function ENT:PhysicsCollide(data, phys)

	local td = {}
		td.start = self.Entity:GetPos()
		td.endpos = td.start + Vector(0, 0, -32)
		td.filter = { self.Entity }
	local tr = util.TraceLine(td)

	local hard = false		-- hit hard surface or not
	for k, v in pairs(mat) do
		if tr.MatType == v then
			hard = true
		end
	end
	
	local volume = math.Clamp(data.Speed, 50, 150)
	if !hard then
		volume = volume/2
	end
	if data.Speed > 90 then
		sound.Play( "weapons/pointman/impact/soft"..math.random(1,2)..".wav", self.Entity:GetPos(), volume, 150 * GetConVarNumber("host_timescale"), 1 )
	elseif data.Speed > 50 then
		sound.Play( "weapons/pointman/impact/soft4.wav", self.Entity:GetPos(), volume, 150 * GetConVarNumber("host_timescale"), 1 )
	end

	-- add random force
	local forward = self.Owner:GetForward()
	phys:AddVelocity(Vector(forward.x * data.Speed * math.Rand(-0.02,0.02), forward.y * data.Speed * math.Rand(-0.05,0.1), data.Speed/8))

end

function ENT:Think()

	if CurTime() > self.LifeTime then
		SafeRemoveEntity(self)
	end

end

function ENT:Use(activator, caller, useType, value)

	if not IsValid(activator) then return end

	activator:GiveAmmo(self.Amount, "pistol", false)
	SafeRemoveEntity(self)

end

end

if CLIENT then

function ENT:Draw()

	self.Entity:DrawModel()

end

end