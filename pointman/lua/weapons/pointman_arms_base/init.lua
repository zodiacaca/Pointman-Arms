
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
include('sv_flashlight.lua')

SWEP.Weight				= 25
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom	= false		-- pick up the weapon if its weight is bigger then this gun


--[[---------------------------------------------------------
   Name: Initialize
-----------------------------------------------------------]]
function SWEP:Initialize()

	for k, v in pairs(self.Attachments) do
		self.Weapon:SetNWFloat(k, 0)
	end

	self:WeaponInitialize()

end

function SWEP:WeaponInitialize()
end

--[[---------------------------------------------------------
   Name: AcceptInput
-----------------------------------------------------------]]
function SWEP:AcceptInput( name, activator, caller, data )
	return false
end

--[[---------------------------------------------------------
   Name: KeyValue
-----------------------------------------------------------]]
function SWEP:KeyValue( key, value )
end

--[[---------------------------------------------------------
   Name: Equip
-----------------------------------------------------------]]
function SWEP:Equip( NewOwner )
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
end

--[[---------------------------------------------------------
   Name: OnDrop
-----------------------------------------------------------]]
function SWEP:OnDrop()

	self:RemoveTimer()
	timer.Remove("npc_attack"..self:EntIndex())
	-- self.Owner:SetCanZoom(true)			-- player is not valid
	self:RemoveLight()
	self:CallOnClient( "CreateLight", "" )
	self:CallOnClient( "RemoveClientModels", "" )
	self:StopBreathSound()
	if IsValid(pointman_ent[self.Owner:EntIndex()]) then
		SafeRemoveEntity(pointman_ent[self.Owner:EntIndex()])
	end

end

--[[---------------------------------------------------------
   Name: OnRemove
-----------------------------------------------------------]]
function SWEP:OnRemove()

	self:RemoveTimer()
	timer.Remove("npc_attack"..self:EntIndex())
	-- self.Owner:SetCanZoom(true)			-- player is not valid
	self:RemoveLight()
	self:CallOnClient( "CreateLight", "" )
	self:CallOnClient( "RemoveClientModels", "" )
	self:StopBreathSound()
	if IsValid(pointman_ent[self.Owner:EntIndex()]) then
		SafeRemoveEntity(pointman_ent[self.Owner:EntIndex()])
	end

end


--[[---------------------------------------------------------
   Name: GetCapabilities
-----------------------------------------------------------]]
function SWEP:GetCapabilities()

	return bit.bor( CAP_WEAPON_RANGE_ATTACK1, CAP_INNATE_RANGE_ATTACK1 )

end

--[[---------------------------------------------------------
   Name: NPCShoot_Secondary
-----------------------------------------------------------]]
function SWEP:NPCShoot_Secondary( ShootPos, ShootDir )

	self:SecondaryAttack()

end

--[[---------------------------------------------------------
   Name: NPCShoot_Primary
-----------------------------------------------------------]]
function SWEP:NPCShoot_Primary( ShootPos, ShootDir )

	if self:Clip1() <= 0 then
		self.Owner:SetSchedule(SCHED_RELOAD)
		return
	end

	if self.Primary.Automatic then

		local num = 3
		-- use longer burst on bigger enemies
		if self.Owner:GetEnemy() != nil and self.Owner:GetEnemy():OBBMaxs():Length() > 512 then
			num = 5
		end

		-- use timer to create bursts
		timer.Create("npc_attack"..self:EntIndex(), 1/(self.Primary.RPM/60), math.random(num,num+4), function()
			if !self.Owner:IsCurrentSchedule(SCHED_RELOAD) then
				self:PrimaryAttack()
			end
		end)

	else

		self:PrimaryAttack()

	end

end

