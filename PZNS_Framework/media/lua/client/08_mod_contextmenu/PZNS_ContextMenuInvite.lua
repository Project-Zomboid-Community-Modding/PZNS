local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_PlayerUtils = require("02_mod_utils/PZNS_PlayerUtils");
local PZNS_NPCGroupsManager = require("04_data_management/PZNS_NPCGroupsManager");
local PZNS_NPCsManager = require("04_data_management/PZNS_NPCsManager");

---comment
---@param mpPlayerID number
---@param context any
---@param worldobjects any
function PZNS_ContextMenuInvite(mpPlayerID, context, worldobjects)
    local isInviteeFound = false;
    local playerSurvivor = getSpecificPlayer(mpPlayerID);
    local playerGroupID = "Player" .. tostring(mpPlayerID) .. "Group";
    --
    local square = PZNS_PlayerUtils.PZNS_GetPlayerMouseGridSquare(mpPlayerID);
    local squareObjects = square:getMovingObjects();
    local objectsListSize = squareObjects:size() - 1;
    --
    local inviteSubMenu = context:getNew(context);
    --
    for i = 0, objectsListSize do
        local currentObj = squareObjects:get(i);
        --
        if (instanceof(currentObj, "IsoPlayer") == true) then
            -- Cows: Check and make sure it is NOT the current player and is alive
            if (currentObj ~= playerSurvivor and currentObj:isAlive() == true) then
                local npcSurvivor = PZNS_NPCsManager.getActiveNPCBySurvivorID(currentObj:getModData().survivorID);
                local callbackFunction = function()
                    -- Cows: Remove the npcSurvivor from its original group if it was in a group
                    if (npcSurvivor.groupID ~= nil) then
                        PZNS_NPCGroupsManager.removeNPCFromGroupBySurvivorID(
                            npcSurvivor.groupID, npcSurvivor.survivorID
                        );
                    end
                    PZNS_UtilsNPCs.PZNS_SetNPCGroupID(npcSurvivor, playerGroupID);   -- Cows: Update the npcSurvivor groupID
                    PZNS_NPCGroupsManager.addNPCToGroup(npcSurvivor, playerGroupID); -- Cows: Add the npcSurvivor to the group's moddata
                end
                -- Cows: Check if the npcSurvivor is NOT in a group or in a different group... Perhaps we can use "affection" at this point for invite-able NPCs.
                if (npcSurvivor.groupID == nil or npcSurvivor.groupID ~= playerGroupID) then
                    isInviteeFound = true;
                    inviteSubMenu:addOption(
                        npcSurvivor.survivorName,
                        nil,
                        callbackFunction
                    );
                end
            end
        end
    end
    --
    if (isInviteeFound == true) then
        local inviteSubMenu_Option = context:addOption(
            getText("ContextMenu_PZNS_PZNS_Invite"),
            worldobjects,
            nil
        );
        context:addSubMenu(inviteSubMenu_Option, inviteSubMenu);
    else
        inviteSubMenu = nil;
    end
end
