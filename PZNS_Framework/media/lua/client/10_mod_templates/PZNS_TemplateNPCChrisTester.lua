local PZNS_DebuggerUtils = require("02_mod_utils/PZNS_DebuggerUtils");
local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_NPCGroupsManager = require("04_data_management/PZNS_NPCGroupsManager");
local PZNS_NPCsManager = require("04_data_management/PZNS_NPCsManager");

local npcSurvivorID = "PZNS_ChrisTester";

--- Cows: mpPlayerID is merely a placeholder... PZ has issues as of B41 with NPCs/non-players in a MP environment.
--- Cows: Example of spawning in an NPC. This Npc is "Chris Tester".
---@param mpPlayerID any
function PZNS_SpawnChrisTester(mpPlayerID)
    local isNPCActive = PZNS_NPCsManager.getActiveNPCBySurvivorID(npcSurvivorID);
    local defaultID = 0;
    --
    local playerID = "Player" .. tostring(defaultID);
    local playerGroupID = "Player" .. tostring(defaultID) .. "Group";
    local isGroupExists = PZNS_NPCGroupsManager.getGroupByID(playerGroupID);
    -- Cows: Check if the group exists before continuing, can be removed if NPC doesn't need or have a group.
    if (isGroupExists) then
        -- Cows: Check if the NPC is active before continuing.
        if (isNPCActive == nil) then
            local playerSurvivor = getSpecificPlayer(defaultID);
            local npcSurvivor = PZNS_NPCsManager.createNPCSurvivor(
                npcSurvivorID,             -- Unique Identifier for the npcSurvivor so that it can be managed.
                false,                     -- isFemale
                "Tester",                  -- Surname
                "Chris",                   -- Forename
                playerSurvivor:getSquare() -- Square to spawn at
            );
            --
            if (npcSurvivor ~= nil) then
                PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Strength", 5);
                PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Fitness", 5);
                PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Aiming", 5);
                PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Reloading", 5);
                PZNS_UtilsNPCs.PZNS_AddNPCSurvivorTraits(npcSurvivor, "Lucky");
                -- Cows: Setup npcSurvivor outfit... Example mod patcher check
                -- "redfield" is a costume mod created/uploaded by "Satispie" at https://steamcommunity.com/sharedfiles/filedetails/?id=2903317798
                if (PZNS_DebuggerUtils.PZNS_IsModActive("redfield") == true) then
                    PZNS_UtilsNPCs.PZNS_AddEquipClothingNPCSurvivor(npcSurvivor, "Base.redfield");
                else
                    -- Cows: Else use vanilla assets
                    PZNS_UtilsNPCs.PZNS_AddEquipClothingNPCSurvivor(npcSurvivor, "Base.Trousers_Denim");
                    PZNS_UtilsNPCs.PZNS_AddEquipClothingNPCSurvivor(npcSurvivor, "Base.Shoes_ArmyBoots");
                    PZNS_UtilsNPCs.PZNS_AddEquipWeaponNPCSurvivor(npcSurvivor, "Base.BaseballBat");
                end
                PZNS_UtilsNPCs.PZNS_AddEquipWeaponNPCSurvivor(npcSurvivor, "Base.Shotgun");
                PZNS_UtilsNPCs.PZNS_SetLoadedGun(npcSurvivor);
                PZNS_UtilsNPCs.PZNS_AddItemsToInventoryNPCSurvivor(npcSurvivor, "Base.ShotgunShells", 12);
                -- Cows: Set the job...
                PZNS_UtilsNPCs.PZNS_SetNPCJob(npcSurvivor, "Companion");
                PZNS_UtilsNPCs.PZNS_SetNPCFollowTargetID(npcSurvivor, playerID);
                -- Cows: Group Assignment
                PZNS_NPCGroupsManager.addNPCToGroup(npcSurvivor, playerGroupID);
                PZNS_UtilsNPCs.PZNS_SetNPCGroupID(npcSurvivor, playerGroupID);

                PZNS_UtilsDataNPCs.PZNS_SaveNPCData(npcSurvivorID, npcSurvivor);
            end
        end
    end
end

-- Cows: NPC Cleanup function...
function PZNS_DeleteChrisTester(mpPlayerID)
    local playerGroupID = "Player" .. tostring(mpPlayerID) .. "Group";
    local npcSurvivor = PZNS_NPCsManager.getActiveNPCBySurvivorID(npcSurvivorID);
    PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor);
    PZNS_NPCGroupsManager.removeNPCFromGroupBySurvivorID(playerGroupID, npcSurvivorID); -- Cows: REMOVE THE NPC FROM THEIR GROUP BEFORE DELETING THEM! OTHERWISE IT'S A NIL REFERENCE
    PZNS_NPCsManager.deleteActiveNPCBySurvivorID(npcSurvivorID);
end
