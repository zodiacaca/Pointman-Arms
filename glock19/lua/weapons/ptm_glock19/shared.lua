
IncludeCS( "ai_translations.lua" )
IncludeCS( "sh_anim.lua" )
include('sh_bullets.lua')

SWEP.Base = "pointman_arms_base"
SWEP.Category = "Pointman Arms"
SWEP.PrintName = "Glock 19"

if GetConVar("PointmanVMArms"):GetBool() then
	SWEP.ViewModel				= "models/weapons/v_ptm_glock19.mdl"		-- female
else
	SWEP.ViewModel				= "models/weapons/v_ptm_glock19_m.mdl"		-- male
end
SWEP.WorldModel			= "models/weapons/w_ptm_glock19.mdl"
SWEP.Magazine				= "glock19_magazine"
SWEP.DropPosition			= Vector(-7, -1, -8)		-- drop offset
SWEP.WeaponEntity		= nil				-- the rifle on your back
SWEP.ViewModelFOV			= 90			-- use flashlight
SWEP.ViewModelFlip			= false
SWEP.MuzzleAttachment		= 1			-- index
SWEP.UseHands				= false			-- no c_mdoel
SWEP.HoldType				= "pistol"		-- sh_anim.lua

SWEP.SwayScale			= 0		-- disable default one
SWEP.DefaultSway		= 1
SWEP.IronSway			= 0.5
SWEP.BobScale			= 0		-- disable default one

SWEP.Spawnable			= true
SWEP.AdminSpawnable	= true

SWEP.Primary.Damage		= 300000
SWEP.Primary.Spread		= 0.005			-- this gun uses a fine barrel
SWEP.Primary.NumShots		= 1
SWEP.Primary.RPM			= 1300
SWEP.Primary.ClipSize		= 15
SWEP.Primary.DefaultClip		= 75			-- default carry ammo
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "pistol"

SWEP.SelectiveFire		= false

SWEP.MuzzleEffect			= "m9k_mk23_muzzle"
SWEP.ShootSound			= "Weapon_Glock19.Single"
SWEP.SuppressedEffect	= "m9k_mk23_muzzle_suppressed"
SWEP.SuppressedSound	= "Weapon_Glock19.Suppressed"
SWEP.EjectEffect				= "ShellEject"

SWEP.BreathSounds = {
	["01"] = Sound("weapons/pointman/breath/nose_loop_normal.wav"),
	["02"] = Sound("weapons/pointman/breath/mouth_loop_normal.wav"),
	["03"] = Sound("weapons/pointman/breath/running_loop_normal.wav"),
	["11"] = Sound("weapons/pointman/breath/nose_loop_mask.wav"),
	["12"] = Sound("weapons/pointman/breath/mouth_loop_mask.wav"),
	["13"] = Sound("weapons/pointman/breath/running_loop_mask.wav"),
}
SWEP.BreathSound = nil
SWEP.BreathData = { Stamina = 0, Mask = 3 }

SWEP.LaserOutlet = Vector(-0.5, 0, -2.3)
SWEP.LaserOutlet3rd = Vector(-0.5, 0, -2.3)
SWEP.LaserLineNearz3rd = 64

SWEP.Lighted = false
SWEP.LightOffset = Vector( 0, 0, -1.5)
SWEP.LightTexture = "effects/glock19_flashlight_01"
SWEP.LightTextureSuppressed = "effects/glock19_flashlight_02"
SWEP.LightBrightness = 2
SWEP.LightFarZ = 3072
SWEP.LightFOV = 56

SWEP.TriggerOffset		= 2
SWEP.ClipOutTime		= 0.6
SWEP.ClipInTime_1		= 1.3
SWEP.ClipInTime_2		= 1.3	-- not used
SWEP.ReleaseTime		= 0.8	-- not used

SWEP.DynamicViewMulti = 0.08		-- view based on VM sequences

SWEP.InteractDuration = 1.6
SWEP.InteractAnimTime = 1.1

SWEP.IronSightPos = Vector(0.1, -1.704, 1.231)
SWEP.IronSightAng = Vector(0, 0, 0)
SWEP.RunSightPos = Vector(0, 0, 0)
SWEP.RunSightAng = Vector(0, 0, 0)
SWEP.SprintSightPos = Vector(0, 0, -10)
SWEP.SprintSightAng = Vector(-20, 0, 0)

if game.SinglePlayer() then
	SWEP.SightSpeed = 6
else		-- seems no reason SightSpeed has to be doubled in MP
	SWEP.SightSpeed = 12
end

SWEP.ClostNearZ = 68				-- how close start to drag the view model
SWEP.ClostNearZEx = 82
SWEP.CloseOffset = 0.8				-- drag distance
SWEP.CloseOffsetEx = 1.2
SWEP.CloseAngleX = -14			-- drag angles
SWEP.CloseAngleXEx = -28
SWEP.CloseAngleY = 10			-- drag angles
SWEP.CloseAngleYEx = 16


/*---------------------------------------------------------
	Attachments
---------------------------------------------------------*/
SWEP.Attachments = {
	[1] = { ["Name"] = "Suppressor", ["Mode"] = { ["Empty"] = 0, ["Model 1"] = 1 }, ["Bodygroup"] = 2 ,["Sound"] = "weapons/pointman/common/att_supp.wav" },
	[2] = { ["Name"] = "LAM", ["Mode"] = { ["Empty"] = 0, ["Model 1"] = 1 }, ["Children"] = 3, ["Bodygroup"] = 3, ["Sound"] = "weapons/pointman/common/click1.wav" },
	[3] = { ["Name"] = "Mode", ["Mode"] = { ["Off"] = 0, ["Laser"] = 1, ["Flashlight"] = 2, ["Both"] = 3 }, ["Parent"] = "LAM", ["Sound"] = "weapons/pointman/common/mode_select.wav" }
}
SWEP.MenuOffset = Vector(-200, -120, 0)


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

		if self.Weapon:GetNWFloat("LAM") >= 1 then
			self:PlaySwitchSound()		-- turn off the LAM
		end

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

/*---------------------------------------------------------
	Deploy
---------------------------------------------------------*/
function SWEP:WeaponDeploy()

	-- maximum carrying ammo
	self.Owner:RemoveAmmo(math.max(self:Ammo1() - 105, 0), self.Primary.Ammo)

	if self.Owner:IsPlayer() then
		self:SetHoldType(self.HoldType)
		if self.Weapon:GetNWFloat("LAM") >= 1 then
			self:PlaySwitchSound()
		end
	end

	-- attach the attachments
	local vm = self.Owner:GetViewModel()

	for i = 2, 3 do
		if vm:GetBodygroup( i ) != self.Weapon:GetNWFloat( self.Attachments[i-1]["Name"] ) then
			vm:SetBodygroup( i, self.Weapon:GetNWFloat( self.Attachments[i-1]["Name"] ) )
		end
		if self.Weapon:GetBodygroup( i ) != self.Weapon:GetNWFloat( self.Attachments[i-1]["Name"] ) then
			self.Weapon:SetBodygroup( i, self.Weapon:GetNWFloat( self.Attachments[i-1]["Name"] ) )
		end
	end

	self.Weapon:EmitSound("weapons/pointman/common/holster3.wav", 40, math.Rand(100,105) * GetConVarNumber("host_timescale"), 1, CHAN_WEAPON)

	-- choice the hands, set the skin on client side
	self:CallOnClient( "UpdateHands", "" )

end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:CanPrimaryAttack()

	if self.Weapon:GetNWBool("BoltHeld") and self.Owner:IsPlayer() then

		local pos = self.AimPos - self.AimAng:Forward() * self.TriggerOffset
		self.Owner:GetViewModel():SendViewModelMatchingSequence(self.Owner:GetViewModel():LookupSequence("shoot_dry"))
		sound.Play( "weapons/pointman/glock19/dry.mp3", pos, 45, math.random(98,105) * GetConVarNumber("host_timescale"), 1 )
		self:SetNextPrimaryFire( CurTime() + 0.2 )

		return false

	elseif ( self.Weapon:Clip1() == 1 ) then		-- logic for player should have been closed

		self.Weapon:SetNWBool("BoltHeld", true)

		return true

	elseif ( self.Weapon:Clip1() <= 0 ) then		-- for the NPC

		sound.Play( "weapons/pointman/glock19/dry.mp3", self.Owner:GetShootPos(), 45, math.random(98,105) * GetConVarNumber("host_timescale"), 1 )
		self:SetNextPrimaryFire( CurTime() + 0.2 )

		return false

	end

	return true

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
				-- self.NoMagazine = true
			end)
		end
		timer.Create("ClipIn"..self:EntIndex(), insert_time, 1, function()
			self.Owner:RemoveAmmo(math.min(ammo, self.Primary.ClipSize), self.Primary.Ammo)
			self.Owner:GetViewModel():SetBodygroup( 1, 0 )
			self.Weapon:SetBodygroup( 1, 0 )
			-- self.NoMagazine = false
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

/*---------------------------------------------------------
	Close
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
		td.endpos = td.start + dir * nearZ
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
	Think
---------------------------------------------------------*/
function SWEP:SightConversion()

	local FT = FrameTime()

	/*1*/
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- ---
	-- // what below influence the first person experience majorly, based on action, first step // --
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- ---
	-- update first step
	if self.Owner:KeyDown(IN_FORWARD) then
		if self.ShouldUpdateStep then
			self.RunTime = 0.2
			self.FirstStep = CurTime()
			self.FirstStepDuration = 0.5
			self.ShouldUpdateStep = false
		end
	elseif self.Owner:KeyDown(IN_MOVERIGHT) or self.Owner:KeyDown(IN_MOVELEFT) then
		if self.ShouldUpdateStep then
			self.RunTime = math.pi/2 + 0.2
			self.FirstStep = CurTime()
			self.FirstStepDuration = 1
			self.ShouldUpdateStep = false
		end
	else
		self.ShouldUpdateStep = true
	end

	local len = self.Owner:GetAbsVelocity():Length()

	local close, direction, fraction, hitpos = self:CloseSight()

	/*1*/
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- ---
	-- // what below influence the first person experience majorly, constantly, VM transfom // --
	-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- ---
	if self.Owner:KeyDown(IN_ATTACK2) and !self.Owner:KeyDown(IN_SPEED) and !close then
		if CLIENT then
			if self.Owner:Crouching() then
				self.Stamina = self.Stamina + 10 * FT
				self.Stamina = math.Clamp(self.Stamina, 1, 2750)
			else
				self:RecoverStamina(FT)
			end
		end
		self.CurrentPos = LerpVector(self.SightSpeed * FT, self.CurrentPos, self.IronSightPos + Vector(0, 0, -len/self.Owner:GetWalkSpeed()))
		self.CurrentAng= LerpVector(self.SightSpeed * FT, self.CurrentAng, self.IronSightAng)
		self.SwayIntensity = self.IronSway
		self.dt.StateLower = POINTMAN_ST_AIM
	elseif self.Owner:Crouching() then
		if CLIENT then
			self:RecoverStamina(FT)
		end
		self.CurrentPos = LerpVector((self.SightSpeed - 3) * FT, self.CurrentPos, self.SprintSightPos)
		self.CurrentAng = LerpVector((self.SightSpeed - 3) * FT, self.CurrentAng, self.SprintSightAng)
		self.SwayIntensity = self.DefaultSway
		self.dt.StateLower = POINTMAN_ST_LOW
	elseif self.Owner:KeyDown(IN_SPEED) and len > 5 then
		-- self:BreakReload()
		if CLIENT then
			self.Stamina = self.Stamina + 50 * FT
			self.Exhausted = self.Exhausted + 20 * FT
			self.Stamina = math.Clamp(self.Stamina, 1, 2750)
			self.Exhausted = math.Clamp(self.Exhausted, 1, 2250)
		end
		self.CurrentPos = LerpVector((self.SightSpeed - 3) * FT, self.CurrentPos, self.SprintSightPos)
		self.CurrentAng= LerpVector((self.SightSpeed - 3) * FT, self.CurrentAng, self.SprintSightAng)
		self.SwayIntensity = self.DefaultSway
		self.dt.StateLower = POINTMAN_ST_LOW
	else
		if CLIENT then
			if len > self.Owner:GetWalkSpeed()/2 + 5 then
				self.Stamina = self.Stamina + 25 * FT
				self.Exhausted = self.Exhausted + 5 * FT
				self.Stamina = math.Clamp(self.Stamina, 1, 2750)
				self.Exhausted = math.Clamp(self.Exhausted, 1, 2250)
			else
				self:RecoverStamina(FT)
			end
		end
		self.CurrentPos = LerpVector((self.SightSpeed - 1) * FT, self.CurrentPos, self.SightPos)
		self.CurrentAng= LerpVector((self.SightSpeed - 1) * FT, self.CurrentAng, self.SightAng)
		-- self.CurrentPos = LerpVector((self.SightSpeed - 1) * FT, self.CurrentPos, Vector(GetConVarNumber("par_adj1"), GetConVarNumber("par_adj2"), GetConVarNumber("par_adj3")))
		-- self.CurrentAng= LerpVector((self.SightSpeed - 1) * FT, self.CurrentAng, Vector(GetConVarNumber("par_adj4"), GetConVarNumber("par_adj5"), GetConVarNumber("par_adj6")))
		self.SwayIntensity = self.DefaultSway
		self.dt.StateLower = POINTMAN_ST_IDLE
	end

	if self.Owner:KeyPressed(IN_JUMP) then
		-- self:BreakReload()
		if CLIENT then
			self.Stamina = self.Stamina + 50
			self.Stamina = math.Clamp(self.Stamina, 1, 2750)
		end
	end

end

function SWEP:ModeSelect()

	if self.Weapon:GetNWFloat("Mode") >= 2 and self.Weapon:GetNWFloat("LAM") >= 1 then
		self.LightState = true
	else
		self.LightState = false
	end
	if self.LightState != self.Lighted and self.dt.State != POINTMAN_HOLSTER then
		self:CreateLight()
	end

	if self.Weapon:GetNWBool("DoingSequence") then return end

	if self.Owner:KeyDown(IN_USE) then

		self.SelectDelay = CurTime() + 0.5		-- make a delay so you don't accidently reload the weapon

		if self.SelectiveFire and self.NextSelectFire < CurTime() then
			if self.Owner:KeyPressed(IN_RELOAD) then
				self:SelectFireMode()
			end
		end

	end

end

function SWEP:WeaponThink()

	local vm = self.Owner:GetViewModel()

	for i = 2, 3 do
		if vm:GetBodygroup( i ) != self.Weapon:GetNWFloat( self.Attachments[i-1]["Name"] ) then
			vm:SetBodygroup( i, self.Weapon:GetNWFloat( self.Attachments[i-1]["Name"] ) )
		end
		if self.Weapon:GetBodygroup( i ) != self.Weapon:GetNWFloat( self.Attachments[i-1]["Name"] ) then
			self.Weapon:SetBodygroup( i, self.Weapon:GetNWFloat( self.Attachments[i-1]["Name"] ) )
		end
	end

	if CLIENT then
		self:manipulateJoint()
	else
		local breathShouldUpdate = self:ShouldSelectBreathSound()
		if breathShouldUpdate then
			self.BreathSound = self:SelectBreathSound()
		end
		if self.BreathSound then
			self.BreathSound:Play()
		end
	end

	if SERVER and self.dt.State != POINTMAN_HOLSTER then
		if self.Weapon:GetNextIdleTime() != nil and CurTime() > self.Weapon:GetNextIdleTime() then

			local vm = self.Owner:GetViewModel()
			local idle = ""
			if self.Weapon:GetNWBool("BoltHeld") then
				idle = "idle_empty"..tostring(self.StaminaStage)
			else
				idle = "idle"..tostring(self.StaminaStage)
			end
			vm:SendViewModelMatchingSequence(vm:LookupSequence(idle))
			vm:SetPlaybackRate(1)
			self.Weapon:SetNextIdleTime(CurTime() + self.Owner:GetViewModel():SequenceDuration())
			
		end
	end

end

function SWEP:ShouldSelectBreathSound()

	if self.Stamina < 800 then
		self.StaminaStage = 1
	elseif self.Stamina < 1500 then
		self.StaminaStage = 2
	else
		self.StaminaStage = 3
	end

	local getMask = self.Weapon:GetNWBool("Gasmask")
	if getMask then
		getMask = 1
	else
		getMask = 0
	end
	
	local shouldUpdate = false
	if self.BreathData.Stamina != self.StaminaStage or self.BreathData.Mask != getMask then
		shouldUpdate = true
		self:StopBreathSound()
	end
	
	self.BreathData = { Stamina = self.StaminaStage, Mask = getMask }
	
	return shouldUpdate
	
end

function SWEP:SelectBreathSound()

	local str = tostring(self.BreathData.Mask)..tostring(self.BreathData.Stamina)

	return CreateSound( self.Owner, self.BreathSounds[str] )

end

function SWEP:StopBreathSound()

	if self.BreathSound then
		self.BreathSound:Stop()
		self.BreathSound = nil
	end

end


-- function ptmHUDPaint()

	-- local seqinfo, textpos = nil, nil

	-- for k, v in pairs( player.GetAll() ) do

		-- seqinfo = v:GetSequenceInfo( v:GetSequence() )
		-- textpos = ( v:GetPos() + Vector( 0, 0, seqinfo.bbmax.z + 8 ) ):ToScreen()

		-- if ( textpos.visible ) then
			-- draw.SimpleText( seqinfo.label, "GModNotify", textpos.x, textpos.y, color_white, TEXT_ALIGN_CENTER )
			-- draw.SimpleText( seqinfo.activity..": "..seqinfo.activityname, "GModNotify", textpos.x, textpos.y+16, color_white, TEXT_ALIGN_CENTER )
		-- end

	-- end

-- end
-- hook.Add("HUDPaint", "ptmHUDPaint", ptmHUDPaint)

