local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_PresetsSpeeches = require("03_mod_core/PZNS_PresetsSpeeches");
local PZNS_NPCGroupsManager = require("04_data_management/PZNS_NPCGroupsManager");
--[[
    Cows: The differences between an action, an order, and a job is that an "action" can be queued, rearranged, or cleared as needed.
    An order may be made up of multiple actions and possibly carried out differently depending on job.
    A Job is a collection of actions and orders while conditionally carrying out said actions and orders.
--]]

-- Cows: Init PZNS_CellZombiesList as an empty table, which can then be used by all NPCs to evaluate the zombie threat.
PZNS_CellZombiesList = nil; -- WIP - Cows: Need to rethink how Global variables are used...
PZNS_CellNPCsList = {};     -- WIP - Cows: Need to rethink how Global variables are used...

-- WIP - Cows: Need to rethink how Global variables are used...
PZNS_JobsText = {
    Companion = getText("ContextMenu_PZNS_Companion"),
    -- Farmer = getText("ContextMenu_PZNS_Farmer"),     -- WIP - Cows: Commented out until implementation is ready.
    -- Engineer = getText("ContextMenu_PZNS_Engineer"),, -- WIP - Cows: Commented out until implementation is ready.
    Guard = getText("ContextMenu_PZNS_Guard"),
    Undertaker = getText("ContextMenu_PZNS_Undertaker"),
    Remove = getText("ContextMenu_PZNS_Remove_From_Group"),
    WanderInBuilding = "Wander In Building",
    WanderInCell = "Wander In Cell"
};

-- WIP - Cows: Need to rethink how Global variables are used...
PZNS_Jobs = {
    Companion = PZNS_JobCompanion,
    -- Farmer = doNothing, -- WIP - Cows: Commented out until implementation is ready.
    -- Engineer = doNothing, -- WIP - Cows: Commented out until implementation is ready.
    Guard = PZNS_JobGuard,
    Undertaker = PZNS_JobUndertaker
};

--- Cows: Helper function for PZNS_UpdateAllJobsRoutines(), can also be used to update an npc's routine when their job is changed.
---@param npcSurvivor any
function PZNS_UpdateNPCJobRoutine(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    -- Cows: Check if the NPC's job is currently "Remove" or "Remove Grom Group".
    if (npcSurvivor.jobName == "Remove" or npcSurvivor.jobName == "Remove From Group") then
        -- WIP - Cows: Being removed from the group which should make the NPC angry.
        if (npcSurvivor.speechTable == nil) then
            PZNS_UtilsNPCs.PZNS_UseNPCSpeechTable(
                npcSurvivor, PZNS_PresetsSpeeches.PZNS_JobSpeechRemoveFromGroup, "Neutral"
            );
        elseif (npcSurvivor.speechTable.PZNS_JobSpeechRemoveFromGroup ~= nil) then
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
        PZNS_UtilsNPCs.PZNS_SetNPCJob(npcSurvivor, "Wander In Cell");
        return; -- Cows: Stop Processing, the npc is no longer in the group.
    end
    --
    if (npcSurvivor.jobName == nil) then
        PZNS_NPCSpeak(npcSurvivor, "My job is nil", "InfoOnly");
        return;
    end
    -- Cows: The job name mapping only works if the job name is ONE WORD.
    if (PZNS_Jobs[npcSurvivor.jobName] ~= nil) then
        --
        if (npcSurvivor.jobName == "Companion") then
            PZNS_Jobs[npcSurvivor.jobName](npcSurvivor, npcSurvivor.followTargetID);
        else
            PZNS_Jobs[npcSurvivor.jobName](npcSurvivor);
        end
    else
        if (npcSurvivor.jobName == "Wander In Building") then
            PZNS_JobWanderInBuilding(npcSurvivor);
        elseif (npcSurvivor.jobName == "Wander In Cell") then
            PZNS_JobWanderInCell(npcSurvivor);
        else
            PZNS_NPCSpeak(npcSurvivor, "I am not doing a known job", "InfoOnly");
        end
    end
end

--- Cows: Updates all active npcs' job routine
function PZNS_UpdateAllJobsRoutines()
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    -- Cows: Go through all the active NPCs and update their job routines
    for survivorID, v1 in pairs(activeNPCs) do
        local npcSurvivor = activeNPCs[survivorID];
        PZNS_UpdateNPCJobRoutine(npcSurvivor);
    end
end

local PZNS_ManageJobs = {};

--- Cows: Input a JobName (without space) and associated JobFunction to make the NPC run on a custom job AI.
---@param JobName string
---@param JobFunction any
function PZNS_ManageJobs.updatePZNSJobsTable(JobName, JobFunction)
    -- Cows: Check if the JobName is not in the table.
    if (PZNS_Jobs[JobName] == nil) then
        PZNS_Jobs[JobName] = JobFunction;
    end
end

return PZNS_ManageJobs;
