
include('sh_bullets.lua')

POINTMAN_IDLE = 1
POINTMAN_HOLSTER = 2

POINTMAN_ST_AIM = 1
POINTMAN_ST_LOW = 2
POINTMAN_ST_IDLE = 3
POINTMAN_ST_HOLD = 4

SWEP.Category = "Other"
SWEP.PrintName = ""

SWEP.Author		= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions = ""

SWEP.ViewModel				= ""
SWEP.WorldModel			= ""
SWEP.Magazine				= nil
SWEP.DropPosition			= Vector(0, 0, 0)
SWEP.WeaponEntity		= nil
SWEP.ViewModelFOV			= 90
SWEP.ViewModelFlip			= false
SWEP.MuzzleAttachment		= 1
SWEP.UseHands				= true
SWEP.HoldType				= "smg"

SWEP.SwayScale			= 0
SWEP.DefaultSway		= 1
SWEP.IronSway			= 0.5
SWEP.BobScale			= 0

SWEP.Spawnable			= false
SWEP.AdminSpawnable	= false

SWEP.Primary.Damage		= 30
SWEP.Primary.Spread		= 0.0005
SWEP.Primary.NumShots		= 1
SWEP.Primary.RPM			= 690
SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip		= 120
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "AR2"

SWEP.SelectiveFire		= false
SWEP.NextSelectFire	= 0
SWEP.SelectDelay = 0

SWEP.Secondary.ClipSize		= 0
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= ""

SWEP.MuzzleEffect			= ""
SWEP.ShootSound			= ""
SWEP.SuppressedEffect	= ""
SWEP.SuppressedSound	= ""
SWEP.EjectEffect				= ""

SWEP.LaserOutlet = Vector(0, 0, 0)
SWEP.LaserOutlet3rd = Vector(0, 0, 0)
SWEP.LaserLineNearz3rd = 64

SWEP.Lighted = false
SWEP.LightOffset = Vector( 0, 0, 0)
SWEP.LightTexture = ""
SWEP.LightTextureSuppressed = ""
SWEP.LightBrightness = 1
SWEP.LightFarZ = 3072
SWEP.LightFOV = 64

SWEP.TriggerOffset		= 16
SWEP.ClipOutTime		= 0.72
SWEP.ClipInTime_1		= 1.6
SWEP.ClipInTime_2		= 1.2
SWEP.ReleaseTime		= 0.5

SWEP.DynamicViewMulti = 0.05
SWEP.PeekOffset = 0

SWEP.Stamina = 1
SWEP.Exhausted = 1

SWEP.LastUse = 0		-- last interact time
SWEP.InteractDuration = 1.6
SWEP.InteractAnimTime = 1.1

SWEP.NPCNextShoot	= 0			-- NPCs' primary attack kind of broken after recent updates

SWEP.SightPos = Vector(0, 0, 0)
SWEP.SightAng = Vector(0, 0, 0)
SWEP.CurrentPos = Vector(0, 0, 0)
SWEP.CurrentAng = Vector(0, 0, 0)
SWEP.IronSightPos = Vector(0, 0, 0)
SWEP.IronSightAng = Vector(0, 0, 0)
SWEP.RunSightPos = Vector(0, 0, 0)
SWEP.RunSightAng = Vector(0, 0, 0)
SWEP.SprintSightPos = Vector(0, 0, 0)
SWEP.SprintSightAng = Vector(0, 0, 0)

if game.SinglePlayer() then
	SWEP.SightSpeed = 6
else
	SWEP.SightSpeed = 12
end

SWEP.ClostNearZ = 68
SWEP.ClostNearZEx = 82
SWEP.CloseOffset = 1
SWEP.CloseOffsetEx = 1.2
SWEP.CloseAngleX = -12
SWEP.CloseAngleXEx = -12
SWEP.CloseAngleY = 10
SWEP.CloseAngleYEx = 12

SWEP.CanOpenMenu = true

SWEP.DebugCount = 0


/*---------------------------------------------------------
	Attachments
---------------------------------------------------------*/
SWEP.MenuOffset = Vector(-200, -180, 0)


/*---------------------------------------------------------
	SetupDataTables
---------------------------------------------------------*/
function SWEP:SetupDataTables()
	self:DTVar("Int", 1, "State")
	self:DTVar("Float", 2, "HolsterDelay")
	self:DTVar("Int", 3, "StateLower")
	self:NetworkVar("Float", 4, "NextIdleTime")
end

/*---------------------------------------------------------
	OnEvents
---------------------------------------------------------*/
function SWEP:OnRestore()

	pointman_ent[self.PrintName] = {}
	
end

function SWEP:OnReloaded()

	pointman_ent[self.PrintName] = {}
	for k, v in pairs(ents.GetAll()) do
		if IsValid(v) and v:GetClass() == "pointman_lamp" then
			SafeRemoveEntity(v)
		end
	end

end

/*---------------------------------------------------------
	Deploy
---------------------------------------------------------*/
function SWEP:Deploy()

	if not IsValid(self.Weapon) then return end
	if not IsValid(self.Owner) then return end

	-- add network strings
	if SERVER then
		if util.NetworkStringToID( "pointman_aimpos"..self.Owner:EntIndex() ) == 0 then
			util.AddNetworkString( "pointman_aimpos"..self.Owner:EntIndex() )
		end
		if util.NetworkStringToID( "pointman_custom"..self.Owner:EntIndex() ) == 0 then		-- attachments menu
			util.AddNetworkString( "pointman_custom"..self.Owner:EntIndex() )
		end
		if util.NetworkStringToID( "pointman_opendoor" ) == 0 then		-- use KEY_USE to open door
			util.AddNetworkString( "pointman_opendoor" )
		end
	end

	-- prepare tables
	if pointman_ent[self.PrintName] == nil then
		pointman_ent[self.PrintName] = {}
	end
	PTM_PhyBullet[self.Owner:EntIndex()] = {}

	-- disable zoom for vacating the KEY_ZOOM
	if self.Owner:IsPlayer() then
		self.Owner:SetCanZoom(false)
	end

	-- the rifle is being deployed, remove it
	if pointman_ent[self.PrintName] != nil then
		if pointman_ent[self.PrintName][self.Owner:EntIndex()] != nil then
			SafeRemoveEntity(pointman_ent[self.PrintName][self.Owner:EntIndex()])
			pointman_ent[self.PrintName][self.Owner:EntIndex()] = nil
		end
	end

	-- set up the states
	self.dt.State = POINTMAN_IDLE

	-- find the true animation and play it
	if self.Weapon:GetNWBool("BoltHeld") then
		self.Owner:GetViewModel():SetSequence(self.Owner:GetViewModel():LookupSequence("draw_empty"))
	else
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
	end
	self.Owner:GetViewModel():SetPlaybackRate(1)

	-- cease the fire temporary
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration() - 0.25)
	self.Weapon:SetNextIdleTime(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	
	-- set the fov to 90, which has no distortion
	self:ChangeFOV()
	
	-- create client models
	self:CallOnClient( "CreateClientModels", "" )

	-- custom some deploy functions
	self:WeaponDeploy()

	return true

end

function SWEP:WeaponDeploy()

	if self.Owner:IsPlayer() then
		self:SetHoldType(self.HoldType)
	end
	
end

function SWEP:ChangeFOV()

	self.OriginalFOV = self.Owner:GetFOV()
	
	if GetConVar("PointmanAutoChangeFOV") != nil and GetConVar("PointmanAutoChangeFOV"):GetBool() then
		self.Owner:ConCommand("fov_desired 90")
	elseif self.Owner:GetFOV() != 90 then
		if game.SinglePlayer() then
			self.Owner:PrintMessage(HUD_PRINTTALK, "Your FOV is not 90.")
			self.Owner:PrintMessage(HUD_PRINTTALK, "Some functions may not work normally.")
		elseif CLIENT then
			self.Owner:PrintMessage(HUD_PRINTTALK, "Your FOV is not 90.")
			self.Owner:PrintMessage(HUD_PRINTTALK, "Some functions may not work normally.")
		end
	end
	
end

function SWEP:SetDeploySpeed( speed )
	self.m_WeaponDeploySpeed = tonumber( speed )
end

/*---------------------------------------------------------
	Holster
---------------------------------------------------------*/
function SWEP:Holster(wep)

	if wep == NULL then return end
	if not IsValid(self.Weapon) then return end
	if not IsValid(self.Owner) then return end
	if self.Weapon:GetNWBool("DoingSequence") then return end

	if self.dt.State == POINTMAN_IDLE then

		self.dt.State = POINTMAN_HOLSTER

		timer.Remove("npc_attack"..self:EntIndex())
		if self.Owner:IsNPC() then
			SafeRemoveEntity(self)
			return true
		end

		if IsFirstTimePredicted() then
			if self.Weapon:GetNWBool("BoltHeld") then
				self.Owner:GetViewModel():SetSequence(self.Owner:GetViewModel():LookupSequence("holster_empty"))
			else
				self.Weapon:SendWeaponAnim(ACT_VM_HOLSTER)
			end
		end
		if self.Owner:GetMoveType() == MOVETYPE_LADDER then		-- call by Think, climb ladder holster weapon
			self.Owner:GetViewModel():SetPlaybackRate(2)		-- double the animation speed
		else
			self.Owner:GetViewModel():SetPlaybackRate(1)
		end

		if not IsValid(wep) then return end
		self.dt.HolsterDelay = CurTime() + self.Owner:GetViewModel():SequenceDuration()
		self.ChosenWeapon = wep:GetClass()

	end

	if !self.dt.HolsterDelay or (CurTime() < self.dt.HolsterDelay) then return end
	if self.Owner:GetMoveType() == MOVETYPE_LADDER then self.ChosenWeapon = nil return end
	if !self.ChosenWeapon then return end

	if self.dt.HolsterDelay != 0 then		-- holster used in cw2 is much better and clearer
		
		if SERVER then
		
			self:RemoveLight()
			self:CallOnClient( "CreateLight", "" )
			self:CallOnClient( "RemoveClientModels", "" )
			self:StopBreathSound()
		
			if GetConVar("PointmanAutoChangeFOV") != nil and GetConVar("PointmanAutoChangeFOV"):GetBool() then
				self.Owner:ConCommand("fov_desired "..self.OriginalFOV)			-- change back to your fov
			end

			-- carry the rifle on back
			if self.Owner:LookupAttachment("chest") != nil and GetConVar("PointmanRifleOnBack") != nil and GetConVar("PointmanRifleOnBack"):GetBool() and pointman_ent[self.PrintName][self.Owner:EntIndex()] == nil and self.WeaponEntity != nil then
				pointman_ent[self.PrintName][self.Owner:EntIndex()] = ents.Create(self.WeaponEntity)
				if IsValid(pointman_ent[self.PrintName][self.Owner:EntIndex()]) then
					local height = self:CarryingCount()		-- you can carry more than one rifle
					pointman_ent[self.PrintName][self.Owner:EntIndex()]:SetParent(self.Owner, self.Owner:LookupAttachment("chest"))		-- need chest attachment
					pointman_ent[self.PrintName][self.Owner:EntIndex()]:SetLocalPos(Vector(-8 - 2 * height, -9, -19))
					pointman_ent[self.PrintName][self.Owner:EntIndex()]:SetLocalAngles(Angle(-60, 90, 0))
					pointman_ent[self.PrintName][self.Owner:EntIndex()]:SetOwner(self.Owner)
					pointman_ent[self.PrintName][self.Owner:EntIndex()]:Spawn()
					pointman_ent[self.PrintName][self.Owner:EntIndex()]:Activate()
				end
			end
			
		end

		if self.Owner:IsPlayer() then
			self.Owner:SetCanZoom(true)		-- enable zoom key
		end
		
	end
	
	self.dt.HolsterDelay = 0

	self.Owner:ConCommand("use "..self.ChosenWeapon)		-- switch to desired weapon

	return true

end

function SWEP:CarryingCount()

	local num = -1
	for k, v in pairs(self.Owner:GetWeapons()) do
		if v.Base == "pointman_arms_base" and v.WeaponEntity != nil and v:GetClass() != self.ChosenWeapon then
			num = num + 1
		end
	end

	return num
	
end

function SWEP:PlaySwitchSound()

	local pos = self.AimPos - self.AimAng:Forward() * self.TriggerOffset * 0.5
	sound.Play("weapons/pointman/common/mode_select.wav", pos, 100, 100 * GetConVarNumber("host_timescale"), 1)

end

/*---------------------------------------------------------
	Remove
---------------------------------------------------------*/
function SWEP:RemoveTimer()

	-- remove timers on weapon removed
	timer.Remove("ClipOut"..self:EntIndex())
	timer.Remove("ClipIn"..self:EntIndex())
	timer.Remove("Release"..self:EntIndex())
	timer.Remove("ReloadBool"..self:EntIndex())
	
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:CanPrimaryAttack()

	if self.Weapon:GetNWBool("BoltHeld") and self.Owner:IsPlayer() then
	
		self.Owner:GetViewModel():SendViewModelMatchingSequence(self.Owner:GetViewModel():LookupSequence("shoot_dry"))
		local pos = self.AimPos - self.AimAng:Forward() * self.TriggerOffset
		sound.Play( "weapons/pointman/common/empty.wav", pos, 45, math.random(98,102) * GetConVarNumber("host_timescale"), 1 )
		self:SetNextPrimaryFire( CurTime() + 0.5 )
		
		return false
		
	elseif ( self.Weapon:Clip1() == 1 ) then
	
		self.Weapon:SetNWBool("BoltHeld", true)
		
		return true
		
	elseif ( self.Weapon:Clip1() <= 0 ) then
	
		sound.Play( "weapons/pointman/common/empty.wav", self.Owner:GetShootPos(), 45, math.random(98,102) * GetConVarNumber("host_timescale"), 1 )
		self:SetNextPrimaryFire( CurTime() + 0.5 )
		
		return false
		
	end
	
	return true
	
end

function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() then return end

	if self.Owner:IsNPC() then

		if CurTime() > self.NPCNextShoot then		-- clamp the bullet number and shoot delay
			self:ShootBulletInformation()
			self:TakePrimaryAmmo(1)
			local fx = EffectData()
				fx:SetEntity(self.Weapon)
				fx:SetOrigin(self.Owner:GetShootPos())
				fx:SetNormal(self.Owner:GetAimVector())
				fx:SetAttachment(self.MuzzleAttachment)
			util.Effect(self.MuzzleEffect, fx)
			self.Weapon:EmitSound(self.ShootSound)
			self.Weapon:SetNextPrimaryFire(CurTime() + 1/(self.Primary.RPM/60))
			self.NPCNextShoot = CurTime() + 1/(self.Primary.RPM/60)
		end

	else

		-- redeploy the gun after climb ladder
		if self.dt.State == POINTMAN_HOLSTER then
			if self.dt.HolsterDelay and CurTime() > self.dt.HolsterDelay and self.Owner:GetMoveType() != MOVETYPE_LADDER then
				self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
				self.Owner:GetViewModel():SetPlaybackRate(1)
				self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration() - 0.25)
				self.dt.State = POINTMAN_IDLE
			end
			return
		end

		self:ShootEffects()
		self:ShootBulletInformation()
		self:TakePrimaryAmmo(1)

		if self.Weapon:GetNWFloat("Suppressor") == 1 then
			local fx = EffectData()
				fx:SetEntity(self.Weapon)
				fx:SetOrigin(self.Owner:GetShootPos())
				fx:SetNormal(self.Owner:GetAimVector())
				fx:SetAttachment(self.MuzzleAttachment)
			util.Effect(self.SuppressedEffect, fx)
			self.Weapon:EmitSound(self.SuppressedSound)
		else
			local fx = EffectData()
				fx:SetEntity(self.Weapon)
				fx:SetOrigin(self.Owner:GetShootPos())
				fx:SetNormal(self.Owner:GetAimVector())
				fx:SetAttachment(self.MuzzleAttachment)
			util.Effect(self.MuzzleEffect, fx)
			self.Weapon:EmitSound(self.ShootSound)
		end

		self.Weapon:SetNextPrimaryFire(CurTime() + 1/(self.Primary.RPM/60))
		self.Weapon:SetNextIdleTime(CurTime() + self.Owner:GetViewModel():SequenceDuration())

	end

end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:CanSecondaryAttack()
	return true
end

function SWEP:SecondaryAttack()
end

function SWEP:TakeSecondaryAmmo( num )
end

/*---------------------------------------------------------
   Ammo1 & Ammo2
---------------------------------------------------------*/
function SWEP:Ammo1()
	return self.Owner:GetAmmoCount( self.Weapon:GetPrimaryAmmoType() )
end

function SWEP:Ammo2()
	return self.Owner:GetAmmoCount( self.Weapon:GetSecondaryAmmoType() )
end

/*---------------------------------------------------------
	Reload
---------------------------------------------------------*/
function SWEP:Reload()

	if self.Owner:IsNPC() then self.Weapon:DefaultReload(ACT_VM_RELOAD) return end
	if self:Ammo1() <= 0 then return end
	if self:Clip1() >= (self.Primary.ClipSize + 1) then return end
	if self.Weapon:GetNWBool("DoingSequence") then return end
	if self.Owner:KeyDown(IN_USE) then return end
	if CurTime() < self.SelectDelay then return end	-- use + reload
	
	self.Weapon:SetNWBool("DoingSequence", true)
	
	local mag, ammo = self:Clip1(), self.Owner:GetAmmoCount(self.Primary.Ammo)
	
	if mag == 0 then
	
		if self.NoMagazine then
			self.Owner:GetViewModel():SetSequence(self.Owner:GetViewModel():LookupSequence("reload_empty_b"))
			insert_time = self.ClipInTime_2
		else
			self.Owner:GetViewModel():SetSequence(self.Owner:GetViewModel():LookupSequence("reload_empty"))
			insert_time = self.ClipInTime_1
			timer.Create("ClipOut"..self:EntIndex(), self.ClipOutTime, 1, function()
				self:DropMagazine(mag)
				self.NoMagazine = true
			end)
		end
		timer.Create("ClipIn"..self:EntIndex(), insert_time, 1, function()
			self.Owner:RemoveAmmo(math.min(ammo, self.Primary.ClipSize), self.Primary.Ammo)
			self.Owner:GetViewModel():SetBodygroup( 1, 0 )
			self.Weapon:SetBodygroup( 1, 0 )
			self.NoMagazine = false
			self:SetClip1(math.min(ammo + mag, self.Primary.ClipSize))
		end)
		timer.Create("Release"..self:EntIndex(), insert_time + self.ReleaseTime, 1, function()
			self.Weapon:SetNWBool("BoltHeld", false)
		end)
		
	else
	
		if self.Weapon:GetNWBool("BoltHeld") then
			self.Owner:GetViewModel():SetSequence(self.Owner:GetViewModel():LookupSequence("release"))
			timer.Create("Release"..self:EntIndex(), self.ReleaseTime, 1, function()
				self.Weapon:SetNWBool("BoltHeld", false)
			end)
		elseif self.NoMagazine then
			self.Owner:GetViewModel():SetSequence(self.Owner:GetViewModel():LookupSequence("reload_b"))
			insert_time = self.ClipInTime_2
		else
			self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
			insert_time = self.ClipInTime_1
			timer.Create("ClipOut"..self:EntIndex(), self.ClipOutTime, 1, function()
				self:SetClip1(1)
				if GetConVar("PointmanDropClip") != nil and GetConVar("PointmanDropClip"):GetBool() then
					self:DropMagazine(mag)
				end
				self.NoMagazine = true
			end)
		end
		timer.Create("ClipIn"..self:EntIndex(), insert_time, 1, function()
			if GetConVar("PointmanDropClip") != nil and GetConVar("PointmanDropClip"):GetBool() then
				self.Owner:RemoveAmmo(math.min(ammo, self.Primary.ClipSize), self.Primary.Ammo)
			else
				self.Owner:RemoveAmmo(math.min(ammo, self.Primary.ClipSize - mag + 1), self.Primary.Ammo)
			end
			self.Owner:GetViewModel():SetBodygroup( 1, 0 )
			self.Weapon:SetBodygroup( 1, 0 )
			self.NoMagazine = false
			self:SetClip1(math.min(ammo + mag, self.Primary.ClipSize + 1))
		end)
		
	end
	
	self.Owner:GetViewModel():SetPlaybackRate(1)
	
	self.Owner:SetAnimation(PLAYER_RELOAD)
	
	local time = self.Owner:GetViewModel():SequenceDuration()
	
	self.Weapon:SetNextPrimaryFire(CurTime() + time - 0.25)
	self.Weapon:SetNextIdleTime(CurTime() + self.Owner:GetViewModel():SequenceDuration())
	
	timer.Create("ReloadBool"..self:EntIndex(), time, 1, function()
		self.Weapon:SetNWBool("DoingSequence", false)
	end)
	
end

function SWEP:DropMagazine(mag)

	if SERVER and self.Magazine != nil then
	
		local ang = self.AimAng
		ang:RotateAroundAxis(ang:Forward(), math.Rand(-25,-10))
		ang:RotateAroundAxis(ang:Up(), math.Rand(30,65))
		local ent = ents.Create(self.Magazine)
		if (IsValid(ent)) then
			ent:SetPos(self.AimPos + ang:Forward() * self.DropPosition.x + ang:Right() * self.DropPosition.y + ang:Up() * self.DropPosition.z)
			ent:SetAngles(ang)
			ent:Spawn()
			ent:Activate()
			ent.Amount = mag
			ent.Owner = self.Owner
			
			local phys = ent:GetPhysicsObject()
			if ( IsValid( phys ) ) then phys:Wake() phys:AddVelocity( self.Owner:EyeAngles():Right() * -math.Rand(32,64) ) end
		end
		
	end
	
end

/*---------------------------------------------------------
   OwnerChanged
---------------------------------------------------------*/
function SWEP:OwnerChanged()
end

/*---------------------------------------------------------
	CloseSight
---------------------------------------------------------*/
function SWEP:CloseSight()

	if self.Owner:InVehicle() then
		return false, Vector(0, 0, 0), 0, Vector(0, 0, 0)
	end

	local dir = self.Owner:EyeAngles():Forward()
	local ang = self:ConvertAngle(self.Owner:EyeAngles().x)
	ang = math.abs(ang)

	local nearZ = self.ClostNearZ
	if self.Weapon:GetNWFloat("Suppressor") == 1 then
		nearZ = self.ClostNearZEx
	end

	local right = 1
	local td = {}
		td.start = self.Owner:EyePos() + self.Owner:GetRight() * right
		td.endpos = td.start + dir
		td.filter = { self.Owner, self.Weapon }
		td.mask = MASK_PLAYERSOLID
	local tr = util.TraceLine(td)

	-- turn into a ratio that closer the value is higher
	local frc = tr.Fraction == 0 and 1 or 1/tr.Fraction - 1
	frc = math.Clamp(frc, 0, 1)

	-- don't trigge if under a quarter
	local in_close
	if tr.Hit and frc > 0.25 then
		in_close = true
	else
		in_close = false
	end

	return in_close, dir, frc, tr.HitPos

end

/*---------------------------------------------------------
	SightConversion
---------------------------------------------------------*/
function SWEP:SightConversion()
end

function SWEP:ResetPosition()
end

function SWEP:BreakReload()

	self:ResetPosition()
	timer.Remove("ClipOut"..self:EntIndex())
	timer.Remove("ClipIn"..self:EntIndex())
	timer.Remove("Release"..self:EntIndex())
	timer.Remove("ReloadBool"..self:EntIndex())
	if self.NoMagazine then			-- don't draw the magazine bodygroup
		self.Owner:GetViewModel():SetBodygroup( 1, 1 )
		self.Weapon:SetBodygroup( 1, 1 )
	end
	self.Weapon:SetNWBool("DoingSequence", false)			-- is it doing or not ?
	
end

function SWEP:RecoverStamina(FT)

	local health = math.Clamp(self:GetHealth() * 2, 1, 4)
	
	self.Stamina = self.Stamina - 20 * FT / health
	self.Stamina = math.Clamp(self.Stamina, self.Exhausted, 2750)
	self.Exhausted = self.Exhausted - 5 * FT / health
	self.Exhausted = math.Clamp(self.Exhausted, 1, 2250)
	
end

function SWEP:GetStamina()

	stm = math.Clamp(self.Stamina/500, 1, 1.5) + self:GetHealth()
	
	return stm
	
end

function SWEP:GetHealth()

	health = (self.Owner:GetMaxHealth() - self.Owner:Health())/50
	
	return health
	
end

/*---------------------------------------------------------
	ModeSelect
---------------------------------------------------------*/
function SWEP:SelectFireMode()

	local pos = self.AimPos - self.AimAng:Forward() * self.TriggerOffset
	
	self.Primary.Automatic = !self.Primary.Automatic
	self.NextSelectFire = CurTime() + 0.5
	sound.Play( "weapons/pointman/common/mode_switch.wav", pos, 50, math.random(98,102) * GetConVarNumber("host_timescale"), 1 )
	
end

function SWEP:ModeSelect()
	
	if self.Weapon:GetNWBool("DoingSequence") then return end
	
	if self.Owner:KeyDown(IN_USE) then
	
		self.SelectDelay = CurTime() + 0.5
		
		if self.SelectiveFire and self.NextSelectFire < CurTime() then
			if self.Owner:KeyPressed(IN_RELOAD) then
				self:SelectFireMode()
			end
		end
		
	end
	
end

/*---------------------------------------------------------
	Think
---------------------------------------------------------*/
function SWEP:Think()

	if not IsValid(self.Weapon) then return end
	if not IsValid(self.Owner) then return end
	
	if SERVER then
		net.Receive( "pointman_aimpos"..self.Owner:EntIndex(), function( len, ply )
			if ( IsValid( ply ) and ply:IsPlayer() ) then
				self.AimPos = net.ReadVector()
				self.AimAng = net.ReadAngle()
				self.In3rdBool = net.ReadBool()
				self.PeekOffset = net.ReadFloat()
				self.Stamina = net.ReadFloat()
			end
		end )
		net.Receive( "pointman_custom"..self.Owner:EntIndex(), function( len, ply )
			if ( IsValid( ply ) and ply:IsPlayer() ) then
				self.Weapon:SetNWFloat(net.ReadString(), net.ReadFloat())
			end
		end )
		net.Receive( "pointman_opendoor"..self.Owner:EntIndex(), function( len, ply )
			if ( IsValid( ply ) and ply:IsPlayer() ) then
				self.LastUse = net.ReadFloat()
			end
		end )
	end
	
	if self.dt.State == POINTMAN_HOLSTER or self.Owner:GetMoveType() == MOVETYPE_LADDER then
		self:Holster()
	end
	
	self:SightConversion()
	self:ModeSelect()
	
	self:WeaponThink()
	
end

function SWEP:WeaponThink()
end


function SWEP:LerpLocal(lerp, from, to)

	from = from + lerp * (to - from)

	return from

end

function SWEP:LerpVectorLocal(lerp, from, to)

	from.x = from.x + lerp * (to.x - from.x)
	from.y = from.y + lerp * (to.y - from.y)
	from.z = from.z + lerp * (to.z - from.z)

	return from

end

function SWEP:LerpAngleLocal(lerp, from, to)

	from.x = from.x + lerp * (to.x - from.x)
	from.y = from.y + lerp * (to.y - from.y)
	from.z = from.z + lerp * (to.z - from.z)

	return from

end

function SWEP:ClampVector(vec, X, Y, Z)

	vec.x = math.Clamp(vec.x, -X, X)
	vec.y = math.Clamp(vec.y, -Y, Y)
	vec.z = math.Clamp(vec.z, -Z, Z)

	return vec

end

function SWEP:ClampAngle(ang, X, Y, Z)

	ang.x = math.Clamp(ang.x, -X, X)
	ang.y = math.Clamp(ang.y, -Y, Y)
	ang.z = math.Clamp(ang.z, -Z, Z)

	return ang

end

function SWEP:ConvertAngle(ang)

	-- turn 270 into -90
	if math.abs(ang) > 180 then
		ang = -ang/math.abs(ang) * (360 - math.abs(ang))
	end
	
	return ang
	
end

function SWEP:ConvertAngles(ang)

	if math.abs(ang.x) > 180 then
		ang.x = -ang.x/math.abs(ang.x) * (360 - math.abs(ang.x))
	end
	
	if math.abs(ang.y) > 180 then
		ang.y = -ang.y/math.abs(ang.y) * (360 - math.abs(ang.y))
	end
	
	if math.abs(ang.z) > 180 then
		ang.z = -ang.z/math.abs(ang.z) * (360 - math.abs(ang.z))
	end
	
	return ang
	
end

