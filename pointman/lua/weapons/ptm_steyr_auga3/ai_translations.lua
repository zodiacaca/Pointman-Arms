
/*---------------------------------------------------------
   Name: SetupWeaponHoldTypeForAI
   Desc: Mainly a Todo.. In a seperate file to clean up the init.lua
---------------------------------------------------------*/
function SWEP:SetupWeaponHoldTypeForAI( t )

	self.ActivityTranslateAI = {}

	local idle, run, walk
	if t == "pistol" then
		idle = ACT_IDLE_AIM_RIFLE_STIMULATED
		run = ACT_RUN_AIM_RIFLE_STIMULATED
		walk = ACT_WALK_AIM_RIFLE_STIMULATED
	else
		idle = ACT_IDLE_SMG1
		run = ACT_RUN_AIM_RIFLE
		walk = ACT_WALK_AIM_RIFLE
	end

	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1 ] 				= ACT_RANGE_ATTACK_AR2
	self.ActivityTranslateAI [ ACT_GESTURE_RANGE_ATTACK_PISTOL ] 				= ACT_GESTURE_RANGE_ATTACK_PISTOL
	self.ActivityTranslateAI [ ACT_RANGE_ATTACK1_LOW ] 			= ACT_RANGE_ATTACK_SMG1_LOW

	self.ActivityTranslateAI [ ACT_IDLE ] 						= idle
	self.ActivityTranslateAI [ ACT_IDLE_ANGRY ] 				= idle
	self.ActivityTranslateAI [ ACT_IDLE_RELAXED ] 				= idle
	self.ActivityTranslateAI [ ACT_IDLE_STIMULATED ] 			= idle
	self.ActivityTranslateAI [ ACT_IDLE_AGITATED ] 				= idle

	self.ActivityTranslateAI [ ACT_MP_RUN ] 					= run	
	self.ActivityTranslateAI [ ACT_MP_CROUCHWALK ] 				= walk

	self.ActivityTranslateAI [ ACT_RELOAD ] 					= ACT_RELOAD_SMG1
	self.ActivityTranslateAI [ ACT_RELOAD_LOW ] 				= ACT_RELOAD_SMG1_LOW

	self.ActivityTranslateAI [ ACT_WALK_AIM_RELAXED ] 			= walk
	self.ActivityTranslateAI [ ACT_WALK_AIM_STIMULATED ] 		= walk
	self.ActivityTranslateAI [ ACT_WALK_AIM_AGITATED ] 			= walk

	self.ActivityTranslateAI [ ACT_RUN_AIM_RELAXED ] 			= run
	self.ActivityTranslateAI [ ACT_RUN_AIM_STIMULATED ] 		= run
	self.ActivityTranslateAI [ ACT_RUN_AIM_AGITATED ] 			= run

	self.ActivityTranslateAI [ ACT_WALK_AIM ] 					= walk
	self.ActivityTranslateAI [ ACT_WALK_CROUCH ] 				= walk
	self.ActivityTranslateAI [ ACT_WALK_CROUCH_AIM ] 			= walk
	self.ActivityTranslateAI [ ACT_RUN ] 						= run
	self.ActivityTranslateAI [ ACT_RUN_AIM ] 					= run	

	self.ActivityTranslateAI [ ACT_WALK_RELAXED ] 				= walk	
	self.ActivityTranslateAI [ ACT_WALK_STIMULATED ] 			= walk	
	self.ActivityTranslateAI [ ACT_WALK_AGITATED ] 				= walk	

	self.ActivityTranslateAI [ ACT_RUN_RELAXED ] 				= run	
	self.ActivityTranslateAI [ ACT_RUN_STIMULATED ] 			= run	
	self.ActivityTranslateAI [ ACT_RUN_AGITATED ] 				= run	

end
