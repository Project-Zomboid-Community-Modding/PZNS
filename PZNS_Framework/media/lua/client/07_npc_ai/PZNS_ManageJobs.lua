local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_PresetsSpeeches = require("03_mod_core/PZNS_PresetsSpeeches");
local PZNS_NPCGroupsManager = require("04_data_management/PZNS_NPCGroupsManager");
--[[
    Cows: The differences between an action, an order, and a job is that an "action" can be queued, rearranged, or cleared as needed.
    An order may be made up of multiple actions and possibly carried out differently depending on job.
    A Job is a collection of actions and orders while conditionally carrying out said actions and orders.
--]]
PZNS_CellZombiesList = {}; -- Cows: Init PZNS_CellZombiesList as an empty table, which can then be used by all NPCs to evaluate the zombie threat.

local function doNothing()
end
-- WIP - Cows: Need to rethink how Global variables are used...
PZNS_JobsText = {
    Companion = "Companion",
    -- Farmer = "Farmer",     -- WIP - Cows: Commented out until implementation is ready.
    -- Engineer = "Engineer", -- WIP - Cows: Commented out until implementation is ready.
    Guard = "Guard",
    Undertaker = "Undertaker",
    Remove = "Remove From Group"
};
-- WIP - Cows: Need to rethink how Global variables are used...
PZNS_Jobs = {
    Companion = PZNS_JobCompanion,
    -- Farmer = doNothing, -- WIP - Cows: Commented out until implementation is ready.
    -- Engineer = doNothing, -- WIP - Cows: Commented out until implementation is ready.
    Guard = PZNS_JobGuard,
    Undertaker = PZNS_JobUndertaker,
    Remove = doNothing
};
--- Cows: Helper function for PZNS_UpdateAllJobsRoutines(), can also be used to update an npc's routine when their job is changed.
---@param npcSurvivor any
function PZNS_UpdateNPCJobRoutine(npcSurvivor)
    if (npcSurvivor == nil) then
        return;
    end
    -- Cows: Check if the NPC's job is currently "Remove" or "Remove Grom Group".
    if (npcSurvivor.jobName == "Remove" or npcSurvivor.jobName == "Remove From Group") then
        -- WIP - Cows: Being removed from the group which should make the NPC angry.
        if (PZNS_UtilsNPCs.PZNS_IsNPCSpeechTableValid(npcSurvivor.speechTable.PZNS_JobSpeechRemoveFromGroup) == true) then
            PZNS_UtilsNPCs.PZNS_UseNPCSpeechTable(
                npcSurvivor, npcSurvivor.speechTable.PZNS_JobSpeechRemoveFromGroup, "Neutral"
            );
        else
            PZNS_UtilsNPCs.PZNS_UseNPCSpeechTable(
                npcSurvivor, PZNS_PresetsSpeeches.PZNS_JobSpeechRemoveFromGroup, "Neutral"
            );
        end
        PZNS_NPCGroupsManager.removeNPCFromGroupBySurvivorID(npcSurvivor.groupID, npcSurvivor.survivorID);
        PZNS_UtilsNPCs.PZNS_SetNPCGroupID(npcSurvivor, nil);
        PZNS_UtilsNPCs.PZNS_SetNPCJob(npcSurvivor, "Guard"); -- WIP - Cows: Currently there is no NPC "wandering" AI nor job... so this is a placeholder
        return;                                              -- Cows: Stop Processing, the npc is no longer in the group.
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
