
local ActIndex = {
	[ "pistol" ] 		= ACT_HL2MP_IDLE_PISTOL,
	[ "smg" ] 			= ACT_HL2MP_IDLE_SMG1,
	[ "grenade" ] 		= ACT_HL2MP_IDLE_GRENADE,
	[ "ar2" ] 			= ACT_HL2MP_IDLE_AR2,
	[ "shotgun" ] 		= ACT_HL2MP_IDLE_SHOTGUN,
	[ "rpg" ]	 		= ACT_HL2MP_IDLE_RPG,
	[ "physgun" ] 		= ACT_HL2MP_IDLE_PHYSGUN,
	[ "crossbow" ] 		= ACT_HL2MP_IDLE_CROSSBOW,
	[ "melee" ] 		= ACT_HL2MP_IDLE_MELEE,
	[ "slam" ] 			= ACT_HL2MP_IDLE_SLAM,
	[ "normal" ]		= ACT_HL2MP_IDLE,
	[ "fist" ]			= ACT_HL2MP_IDLE_FIST,
	[ "melee2" ]		= ACT_HL2MP_IDLE_MELEE2,
	[ "passive" ]		= ACT_HL2MP_IDLE_PASSIVE,
	[ "knife" ]			= ACT_HL2MP_IDLE_KNIFE,
	[ "duel" ]			= ACT_HL2MP_IDLE_DUEL,
	[ "camera" ]		= ACT_HL2MP_IDLE_CAMERA,
	[ "magic" ]			= ACT_HL2MP_IDLE_MAGIC,
	[ "revolver" ]		= ACT_HL2MP_IDLE_REVOLVER
}

--[[---------------------------------------------------------
   Name: SetWeaponHoldType
   Desc: Sets up the translation table, to translate from normal 
			standing idle pose to holding weapon pose
-----------------------------------------------------------]]
function SWEP:SetWeaponHoldType( t )

	t = string.lower( t )
	local index = ACT_HL2MP_IDLE_REVOLVER
	
	self.ActivityTranslate = {}
	self.ActivityTranslate [ ACT_MP_STAND_IDLE ] 				= index
	self.ActivityTranslate [ ACT_MP_WALK ] 						= index + 1
	self.ActivityTranslate [ ACT_MP_RUN ] 						= index + 2
	self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ] 				= index+3
	self.ActivityTranslate [ ACT_MP_CROUCHWALK ] 				= index+4
	self.ActivityTranslate [ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] 	= index+5
	self.ActivityTranslate [ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = index+5
	self.ActivityTranslate [ ACT_MP_RELOAD_STAND ]		 		= ACT_HL2MP_IDLE_PISTOL+6
	self.ActivityTranslate [ ACT_MP_RELOAD_CROUCH ]		 		= ACT_HL2MP_IDLE_PISTOL+6
	self.ActivityTranslate [ ACT_MP_JUMP ] 						= index+7
	self.ActivityTranslate [ ACT_RANGE_ATTACK1 ] 				= index+5
	self.ActivityTranslate [ ACT_MP_SWIM ] 						= ACT_HL2MP_SWIM_PISTOL
	
	-- "normal" jump animation doesn't exist
	if t == "normal" then
		self.ActivityTranslate [ ACT_MP_JUMP ] = ACT_HL2MP_JUMP_SLAM
	end
	
	self:SetupWeaponHoldTypeForAI( t )
	
end
-- menu_walk crouchidlehide crouchRUNALL1 ACT_HL2MP_WALK_CROUCH_PISTOL ACT_HL2MP_WALK_ZOMBIE_01
--[[---------------------------------------------------------
   Name: TranslateActivity
   Desc: Translate a player's activity into a weapon's activity
		 For example, ACT_HL2MP_RUN becomes ACT_HL2MP_RUN_PISTOL
		 Depending on how you want the player holds the weapon
-----------------------------------------------------------]]
local angUpperL = Angle(0, 0, 0)
local angForeL = Angle(0, 0, 0)
local angUpperR = Angle(0, 0, 0)
local angForeR = Angle(0, 0, 0)

function SWEP:TranslateActivity( act )

	if ( self.Owner:IsNPC() ) then
		if ( self.ActivityTranslateAI[ act ] ) then

			return self.ActivityTranslateAI[ act ]
		end
		return -1
	end

	local index = ACT_HL2MP_IDLE_REVOLVER
	
	local FT = FrameTime()

	if ( self.ActivityTranslate[ act ] != nil ) then

		local l_upperarm = self.Owner:LookupBone("ValveBiped.Bip01_L_UpperArm")
		local l_forearm = self.Owner:LookupBone("ValveBiped.Bip01_L_ForeArm")
		local r_upperarm = self.Owner:LookupBone("ValveBiped.Bip01_R_UpperArm")
		local r_forearm = self.Owner:LookupBone("ValveBiped.Bip01_R_ForeArm")

		local spine1 = self.Owner:LookupBone("ValveBiped.Bip01_Spine1")
		local spine2 = self.Owner:LookupBone("ValveBiped.Bip01_Spine2")
		local pelvis = self.Owner:LookupBone("ValveBiped.Bip01_Pelvis")

		local close, direction, fraction, hitpos = self:CloseSight()

		if self.dt.StateLower == POINTMAN_ST_LOW or fraction >= 0.5 then

			self.ActivityTranslate[ ACT_MP_STAND_IDLE ] = ACT_HL2MP_IDLE_PASSIVE
			self.ActivityTranslate[ ACT_MP_WALK ] = ACT_HL2MP_WALK_PASSIVE
			self.ActivityTranslate[ ACT_MP_RUN ] = ACT_HL2MP_RUN_PASSIVE
	
		else

			self.ActivityTranslate[ ACT_MP_STAND_IDLE ] = index
			self.ActivityTranslate[ ACT_MP_WALK ] = index + 1
			self.ActivityTranslate[ ACT_MP_RUN ] = index + 2

		end
		
		-- fix passive pose for holding pistol
		local activity = self.Owner:GetSequenceActivityName( self.Owner:GetSequence() )
		
		if activity == "ACT_HL2MP_IDLE_PASSIVE" or activity == "ACT_HL2MP_WALK_PASSIVE" or activity == "ACT_HL2MP_RUN_PASSIVE" then
			
			angUpperL = LerpAngle( 4 * FT, angUpperL, Angle(0, -20, 0) )
			angForeL = LerpAngle( 4 * FT, angForeL, Angle(10, 0, 0) )
			angUpperR = LerpAngle( 4 * FT, angUpperR, Angle(0, -30, 0) )
			angForeR = LerpAngle( 4 * FT, angForeR, Angle(30, 30, 0) )
			
		else
		
			angUpperL = LerpAngle( 4 * FT, angUpperL, Angle(0, 0, 0) )
			angForeL = LerpAngle( 4 * FT, angForeL, Angle(0, 0, 0) )
			angUpperR = LerpAngle( 4 * FT, angUpperR, Angle(0, 0, 0) )
			angForeR = LerpAngle( 4 * FT, angForeR, Angle(0, 0, 0) )
		
		end
		
		self.Owner:ManipulateBoneAngles( l_upperarm, angUpperL )
		self.Owner:ManipulateBoneAngles( l_forearm, angForeL )
		self.Owner:ManipulateBoneAngles( r_upperarm, angUpperR )
		self.Owner:ManipulateBoneAngles( r_forearm, angForeR )

		-- peek
		self.Owner:ManipulateBonePosition( pelvis, Vector(0, -self.PeekOffset * 0.5, 0) )
		self.Owner:ManipulateBoneAngles( pelvis, Angle(0, self.PeekOffset * 0.6, 0) )
		self.Owner:ManipulateBoneAngles( spine1, Angle(self.PeekOffset * 0.5, 0, 0) )
		self.Owner:ManipulateBoneAngles( spine2, Angle(self.PeekOffset * 0.4, 0, 0) )

		return self.ActivityTranslate[ act ]

	end

	return -1

end

