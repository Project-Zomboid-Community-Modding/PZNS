local PZNS_DebuggerUtils = require("02_mod_utils/PZNS_DebuggerUtils");
local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_NPCGroupsManager = require("04_data_management/PZNS_NPCGroupsManager");
local PZNS_NPCsManager = require("04_data_management/PZNS_NPCsManager");
local PZNS_SpeechTableJill = require("10_mod_templates/PZNS_SpeechTableJill");

local npcSurvivorID = "PZNS_JillTester";

--- Cows: mpPlayerID is merely a placeholder... PZ has issues as of B41 with NPCs/non-players in a MP environment.
--- Cows: Example of spawning in an NPC. This Npc is "Jill Tester"
---@param mpPlayerID any
function PZNS_SpawnJillTester(mpPlayerID)
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
                true,                      -- isFemale
                "Tester",                  -- Surname
                "Jill",                    -- Forename
                playerSurvivor:getSquare() -- Square to spawn at
            );
            --
            if (npcSurvivor ~= nil) then
                PZNS_UtilsNPCs.PZNS_SetNPCSpeechTable(npcSurvivor, PZNS_SpeechTableJill);
                PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Strength", 5);
                PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Fitness", 5);
                PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Aiming", 5);
                PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Reloading", 5);
                PZNS_UtilsNPCs.PZNS_AddNPCSurvivorTraits(npcSurvivor, "Lucky");
                -- Cows: Setup npcSurvivor outfit... Example mod patcher check
                -- "jill" is a costume mod created/uploaded by "Satispie" at https://steamcommunity.com/sharedfiles/filedetails/?id=2903870282
                if (PZNS_DebuggerUtils.PZNS_IsModActive("jill") == true) then
                    PZNS_UtilsNPCs.PZNS_AddEquipClothingNPCSurvivor(npcSurvivor, "Base.jill");
                else
                    -- Cows: Else use vanilla assets
                    PZNS_UtilsNPCs.PZNS_AddEquipClothingNPCSurvivor(npcSurvivor, "Base.Vest_DefaultTEXTURE");
                    PZNS_UtilsNPCs.PZNS_AddEquipClothingNPCSurvivor(npcSurvivor, "Base.Skirt_Mini");
                    PZNS_UtilsNPCs.PZNS_AddEquipClothingNPCSurvivor(npcSurvivor, "Base.Shoes_ArmyBoots");
                    PZNS_UtilsNPCs.PZNS_AddItemToInventoryNPCSurvivor(npcSurvivor, "Base.BaseballBat");
                end
                PZNS_UtilsNPCs.PZNS_AddEquipWeaponNPCSurvivor(npcSurvivor, "Base.Pistol");
                PZNS_UtilsNPCs.PZNS_AddItemToInventoryNPCSurvivor(npcSurvivor, "Base.9mmClip");
                PZNS_UtilsNPCs.PZNS_AddItemsToInventoryNPCSurvivor(npcSurvivor, "Base.Bullets9mm", 15);
                -- Cows: Set the job...
                PZNS_UtilsNPCs.PZNS_SetNPCJob(npcSurvivor, "Companion");
                PZNS_UtilsNPCs.PZNS_SetNPCFollowTargetID(npcSurvivor, playerID);
                -- Cows: Begin styling customizations...
                PZNS_UtilsNPCs.PZNS_SetNPCHairModel(npcSurvivor, "Bob");
                PZNS_UtilsNPCs.PZNS_SetNPCHairColor(npcSurvivor, 0.720, 0.451, 0.230);
                PZNS_UtilsNPCs.PZNS_SetNPCSkinTextureIndex(npcSurvivor, 1);
                PZNS_UtilsNPCs.PZNS_SetNPCSkinColor(npcSurvivor, 0.970, 0.934, 0.873);
                -- Cows: Group Assignment
                PZNS_NPCGroupsManager.addNPCToGroup(npcSurvivor, playerGroupID);
                PZNS_UtilsNPCs.PZNS_SetNPCGroupID(npcSurvivor, playerGroupID);

                PZNS_UtilsDataNPCs.PZNS_SaveNPCData(npcSurvivorID, npcSurvivor);
            end
        end
    end
end

-- Cows: NPC Cleanup function...
function PZNS_DeleteJillTester(mpPlayerID)
    local playerGroupID = "Player" .. tostring(mpPlayerID) .. "Group";
    local npcSurvivor = PZNS_NPCsManager.getActiveNPCBySurvivorID(npcSurvivorID);
    PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor);
    PZNS_NPCGroupsManager.removeNPCFromGroupBySurvivorID(playerGroupID, npcSurvivorID); -- Cows: REMOVE THE NPC FROM THEIR GROUP BEFORE DELETING THEM! OTHERWISE IT'S A NIL REFERENCE
    PZNS_NPCsManager.deleteActiveNPCBySurvivorID(npcSurvivorID);
end
