local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_NPCGroupsManager = require("04_data_management/PZNS_NPCGroupsManager");

---comment
---@param npcSurvivor any
---@param mpPlayerID any
---@return ItemContainer | nil
local function openNPCInventory(npcSurvivor, mpPlayerID)
    if (npcSurvivor == nil) then
        return;
    end
    --- @type IsoPlayer
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local npcItemContainer = npcIsoPlayer:getInventory();
    --
    PZNS_CreateInventoryTransferPanel(npcSurvivor.survivorID, mpPlayerID);
    return npcItemContainer;
end
---comment
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
    local playerGroupID = "Player" .. tostring(mpPlayerID) .. "Group";
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    local groupMembers = PZNS_NPCGroupsManager.getGroupByID(playerGroupID);
    --
    if (groupMembers ~= nil) then
        for survivorID, v in pairs(groupMembers) do
            local npcSurvivor = activeNPCs[survivorID];
            -- Cows: conditionally set the callback function for the context menu option.
            local callbackFunction = function()
                openNPCInventory(npcSurvivor, mpPlayerID);
            end
            --
            if (npcSurvivor ~= nil) then
                local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
                --
                if (npcIsoPlayer:isAlive()) then
                    inventorySubMenu_1:addOption(
                        getText(npcSurvivor.survivorName),
                        nil,
                        callbackFunction
                    );
                end
            end
        end
    end
end
