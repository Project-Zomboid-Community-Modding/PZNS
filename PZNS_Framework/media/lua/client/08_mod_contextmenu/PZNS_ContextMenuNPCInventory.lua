local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");
local PZNS_NPCGroupsManager = require("04_data_management/PZNS_NPCGroupsManager");
local PZNS_NPCsManager = require("04_data_management/PZNS_NPCsManager");

---comment
---@param mpPlayerID any
---@param npcSurvivor any
---@return ItemContainer | nil
local function openNPCInventory(mpPlayerID, npcSurvivor)
    if (npcSurvivor == nil) then
        return;
    end
    PZNS_NPCsManager.setActiveInventoryNPCBySurvivorID(npcSurvivor.survivorID);
    -- Cows: Force reload the container window.
    ISPlayerData[mpPlayerID + 1].lootInventory:refreshBackpacks();
    Events.OnPlayerMove.Add(PZNS_CheckDistToNPCInventory);
end

--- Cows: mpPlayerID is a placeholder, it always defaults to 0 in local.
---@param mpPlayerID number
---@param context any
---@param worldobjects any
function PZNS_ContextMenuNPCInventory(mpPlayerID, context, worldobjects)
    local inventorySubMenu_1 = context:getNew(context);
    local inventorySubMenu_1_Option = context:addOption(
        getText("PZNS_Inventory"),
        worldobjects,
        nil
    );
    context:addSubMenu(inventorySubMenu_1_Option, inventorySubMenu_1);
    --
    local playerSurvivor = getSpecificPlayer(mpPlayerID);
    local playerGroupID = "Player" .. tostring(mpPlayerID) .. "Group";
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    local groupMembers = PZNS_NPCGroupsManager.getGroupByID(playerGroupID);
    --
    if (groupMembers ~= nil) then
        for survivorID, v in pairs(groupMembers) do
            local npcSurvivor = activeNPCs[survivorID];
            --
            if (npcSurvivor ~= nil) then
                local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
                --
                if (npcIsoPlayer) then
                    local npcDistanceFromPlayer = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(
                        playerSurvivor, npcIsoPlayer
                    );
                    if (npcIsoPlayer:isAlive() == true and npcDistanceFromPlayer <= 2) then
                        -- Cows: conditionally set the callback function for the inventorySubMenu_1 option.
                        local callbackFunction = function()
                            openNPCInventory(mpPlayerID, npcSurvivor);
                        end
                        inventorySubMenu_1:addOption(
                            getText(npcSurvivor.survivorName),
                            nil,
                            callbackFunction
                        );
                    end
                end
            end
        end -- Cows: End groupMembers For-loop.
    end
end
