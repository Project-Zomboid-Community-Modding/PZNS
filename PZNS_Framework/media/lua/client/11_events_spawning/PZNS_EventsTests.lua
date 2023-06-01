local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_NPCsManager = require("04_data_management/PZNS_NPCsManager");
require "11_events_spawning/PZNS_Events";

-- Cows: Make sure the NPC spawning functions come AFTER PZNS_InitLoadNPCsData() to prevent duplicate spawns.
--[[
    Cows: Currently, NPCs cannot spawn off-screen because gridsquare data is not loaded outside of the player's range...
    Need to figure out how to handle gridsquare data loading.
--]]

--- Cows: these template spawns are intended for testing and debugging.
function PZNSTest_logTemplateNPCsInfo()
    PZNS_ShowNpcSurvivorInfo(PZNS_NPCsManager.getActiveNPCBySurvivorID("PZNS_ChrisTester"));
    PZNS_ShowNpcSurvivorInfo(PZNS_NPCsManager.getActiveNPCBySurvivorID("PZNS_JillTester"));
end

local function ChrisTesterClearNeeds()
    local npcSurvivorID = "PZNS_ChrisTester";
    local npcSurvivor = PZNS_NPCsManager.getActiveNPCBySurvivorID(npcSurvivorID);
    PZNS_UtilsNPCs.PZNS_ClearNPCAllNeedsLevel(npcSurvivor);
end

local function JillTesterClearNeeds()
    local npcSurvivorID = "PZNS_JillTester";
    local npcSurvivor = PZNS_NPCsManager.getActiveNPCBySurvivorID(npcSurvivorID);
    PZNS_UtilsNPCs.PZNS_ClearNPCAllNeedsLevel(npcSurvivor);
end

local function PZNS_TestEvents()
    Events.EveryHours.Add(ChrisTesterClearNeeds);
    Events.EveryHours.Add(JillTesterClearNeeds);
end

-- Cows: Try spawning every minute until NPCs data is loaded
local function spawnTestNPCs()
    -- Cows: Check the NPCs data are loaded first before continuing.
    PZNS_SpawnJillTester();
    PZNS_SpawnChrisTester();
    PZNS_TestEvents();
end

Events.OnGameStart.Add(spawnTestNPCs);
