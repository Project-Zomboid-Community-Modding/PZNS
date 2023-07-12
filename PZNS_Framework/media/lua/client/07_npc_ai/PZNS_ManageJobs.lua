local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
--[[
    Cows: The differences between an action, an order, and a job is that an "action" can be queued, rearranged, or cleared as needed.
    An order may be made up of multiple actions and possibly carried out differently depending on job.
    A Job is a collection of actions and orders while conditionally carrying out said actions and orders.
--]]
PZNS_CellZombiesList = {}; -- Cows: Init PZNS_CellZombiesList as an empty table, which can then be used by all NPCs to evaluate the zombie threat.

local function doNothing()
end

PZNS_JobsText = {
    Companion = "Companion",
    -- Farmer = "Farmer",     -- WIP - Cows: Commented out until implementation is ready.
    -- Engineer = "Engineer", -- WIP - Cows: Commented out until implementation is ready.
    Guard = "Guard",
    Undertaker = "Undertaker"
};
--
PZNS_Jobs = {
    Companion = PZNS_JobCompanion,
    Farmer = doNothing,
    Engineer = doNothing,
    Guard = PZNS_JobGuard,
    Undertaker = PZNS_JobUndertaker
};

--- Cows: Helper function for PZNS_UpdateAllJobsRoutines(), can also be used to update an npc's routine when their job is changed.
---@param npcSurvivor any
function PZNS_UpdateNPCJobRoutine(npcSurvivor)
    if (npcSurvivor == nil) then
        return;
    end
    -- Cows: Only update living npcSurvivor routine.
    if (npcSurvivor.isAlive == true) then
        if (PZNS_Jobs[npcSurvivor.jobName] ~= nil) then
            --
            if (npcSurvivor.jobName == "Companion") then
                PZNS_Jobs[npcSurvivor.jobName](npcSurvivor, npcSurvivor.followTargetID);
            else
                PZNS_Jobs[npcSurvivor.jobName](npcSurvivor);
            end
        end
    end
end

--- Cows: Updates all active npcs' job routine
function PZNS_UpdateAllJobsRoutines()
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    -- Cows: Update the PZNS_CellZombiesList before proceeding to each NPC's job routine.
    PZNS_CellZombiesList = getCell():getZombieList();
    -- Cows: Go through all the active NPCs and update their job routines
    for survivorID, v1 in pairs(activeNPCs) do
        local npcSurvivor = activeNPCs[survivorID];
        -- Cows: Only update living npcSurvivors
        if (npcSurvivor.isAlive == true) then
            PZNS_UpdateNPCJobRoutine(npcSurvivor);
        end
    end
end
