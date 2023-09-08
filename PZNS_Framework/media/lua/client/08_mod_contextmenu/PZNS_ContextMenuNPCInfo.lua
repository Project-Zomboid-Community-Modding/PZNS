local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");
local PZNS_NPCGroupsManager = require("04_data_management/PZNS_NPCGroupsManager");
local PZNS_NPCsManager = require("04_data_management/PZNS_NPCsManager");

PZNS_ContextMenu = PZNS_ContextMenu or {}

---comment
---@param npcSurvivor any
---@return ItemContainer | nil
local function openNPCInfoPanel(npcSurvivor)
    if (npcSurvivor == nil) then
        return;
    end
    PZNS_ShowNPCSurvivorInfo(npcSurvivor);
end

--- Cows: mpPlayerID is a placeholder, it always defaults to 0 in local.
---@param mpPlayerID number
---@param context any
---@param worldobjects any
function PZNS_ContextMenu.NPCInfoOptions(mpPlayerID, context, worldobjects)
    local infoSubMenu_1 = context:getNew(context);
    local infoSubMenu_1_Option = context:addOption(
        getText("ContextMenu_PZNS_PZNS_NPC_Info"),
        worldobjects,
        nil
    );
    context:addSubMenu(infoSubMenu_1_Option, infoSubMenu_1);
    --
    local playerGroupID = "Player" .. tostring(mpPlayerID) .. "Group";
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    local groupMembers = PZNS_NPCGroupsManager.getMembers(playerGroupID);
    --
    if (groupMembers ~= nil) then
        for i = 1, #groupMembers do
            local npcSurvivor = activeNPCs[groupMembers[i]];
            if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == true) then
                -- Cows: conditionally set the callback function for the infoSubMenu_1 option.
                local callbackFunction = function()
                    openNPCInfoPanel(npcSurvivor);
                end
                infoSubMenu_1:addOption(
                    npcSurvivor.survivorName,
                    nil,
                    callbackFunction
                );
            end
        end -- Cows: End groupMembers For-loop.
    end
end
