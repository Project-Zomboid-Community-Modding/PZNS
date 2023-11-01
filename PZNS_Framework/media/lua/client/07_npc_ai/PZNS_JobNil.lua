-- Used strictly to solve the spawn|despawn issues in spawnIsoPlayer, it's a dummy job
local PZNS_ManageJobs = require("07_npc_ai/PZNS_ManageJobs")
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs")

local function nil_job(npcSurvivor) -- [testing]
    if not npcSurvivor then return nil end
    if 1 == ZombRand(1,20) then PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor) end
    npcSurvivor.aimTarget = nil
    npcSurvivor.jobSquare = nil
end

PZNS_ManageJobs.updatePZNSJobsTable( "Debug Nil Job", nil_job )
