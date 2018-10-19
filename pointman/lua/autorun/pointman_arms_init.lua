

if GetConVar("PointmanViewBobMultiplier") == nil then
	CreateClientConVar("PointmanViewBobMultiplier", "1", { FCVAR_ARCHIVE }, "Dynamic views")
end

if GetConVar("PointmanLeanAngleMultiplier") == nil then
	CreateClientConVar("PointmanLeanAngleMultiplier", "1", { FCVAR_ARCHIVE }, "Dynamic views")
end

if GetConVar("PointmanDropClip") == nil then
	CreateConVar("PointmanDropClip", "0", { FCVAR_NOTIFY, FCVAR_ARCHIVE }, "I'm feeling rich")
end

if GetConVar("PointmanDamageMultiplier") == nil then
	CreateConVar("PointmanDamageMultiplier", "1", { FCVAR_NOTIFY, FCVAR_ARCHIVE }, "Multiplier for damage")
end

if GetConVar("PointmanNoFriendlyDamage") == nil then
	CreateConVar("PointmanNoFriendlyDamage", "1", { FCVAR_NOTIFY, FCVAR_ARCHIVE }, "Disable blue on blue for NPCs")
end

if GetConVar("PointmanRifleOnBack") == nil then
	CreateConVar("PointmanRifleOnBack", "1", { FCVAR_ARCHIVE }, "Show your rifles?")
end

if GetConVar("PointmanAutoChangeFOV") == nil then
	CreateConVar("PointmanAutoChangeFOV", "1", { FCVAR_ARCHIVE }, "Auto change FOV?")
end

if GetConVar("PointmanNPCFlashlights") == nil then
	CreateConVar("PointmanNPCFlashlights", "1", { FCVAR_ARCHIVE }, "Wanna NPCs blind your eyes?")
end


if GetConVar("PointmanVMArms") == nil then
	CreateClientConVar("PointmanVMArms", "0", { FCVAR_ARCHIVE }, "Which arms")
end

if GetConVar("PointmanVMHands") == nil then
	CreateClientConVar("PointmanVMHands", "0", { FCVAR_ARCHIVE }, "Which color")
end


if GetConVar("PointmanToggleGlobal") == nil then  // totally forgot why this is here
	CreateClientConVar("PointmanToggleGlobal", "0", { FCVAR_ARCHIVE }, "")
end

if GetConVar("PointmanDebugMultiply") == nil then
	CreateClientConVar("PointmanDebugMultiply", "0", { FCVAR_ARCHIVE }, "")
end

ptm_cModel = {}
pointman_ent = {}
PTM_PhyBullet = {}
PTM_PhyBulletNPC = {}

