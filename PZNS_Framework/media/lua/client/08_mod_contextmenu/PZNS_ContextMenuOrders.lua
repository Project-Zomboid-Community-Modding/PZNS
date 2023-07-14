local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_PlayerUtils = require("02_mod_utils/PZNS_PlayerUtils");
local PZNS_NPCGroupsManager = require("04_data_management/PZNS_NPCGroupsManager");

PZNS_NPCOrdersText = {
    HoldPosition = "Hold Position",
    FollowMe = "Follow Me",
    -- AimAtMe = "Aim At Me",-- Cows: Meant for debugging
    Attack = "Attack Aimed Target",
    AttackStop = "Stop Attacking"
};
---
PZNS_NPCOrderActions = {
    HoldPosition = PZNS_HoldPosition,
    FollowMe = PZNS_Follow,
    -- AimAtMe = PZNS_AimAtPlayer, -- Cows: Meant for debugging
    Attack = PZNS_AttackTarget,
    AttackStop = PZNS_StopAttacking
};

---comment
---@param parentContextMenu any
---@param mpPlayerID number
---@param groupID any
---@param orderKey any
---@return any
function PZNS_CreateGroupNPCsSubMenu(parentContextMenu, mpPlayerID, groupID, orderKey)
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    local groupMembers = PZNS_NPCGroupsManager.getGroupByID(groupID);
    local followTargetID = "Player" .. tostring(mpPlayerID);
    local square = PZNS_PlayerUtils.PZNS_GetPlayerMouseGridSquare(mpPlayerID);
    -- Cows: Stop if the square isn't in a loaded visible square or there are no active npcs.
    if (square == nil or activeNPCs == nil or groupMembers == nil) then
        return;
    end
    --
    for survivorID, v in pairs(groupMembers) do
        local npcSurvivor = activeNPCs[survivorID];
        -- Cows: Conditionally set the callback function for the context menu option.
        local callbackFunction = function()
            -- Cows: Clear the existing queued actions for the npcSurvivor when an Order is issued.
            PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor);
            PZNS_NPCSpeak(npcSurvivor, "Order " .. PZNS_NPCOrdersText[orderKey] .. "  acknowledged!", "Friendly");
            local playerSurvivor = getSpecificPlayer(mpPlayerID);
            --
            if (orderKey == "FollowMe" or orderKey == "AimAtMe") then
                playerSurvivor:Say(npcSurvivor.forename ..
                    ", " .. PZNS_NPCOrdersText[orderKey] .. ", " .. followTargetID
                );
                PZNS_NPCOrderActions[orderKey](npcSurvivor, followTargetID);
            elseif (orderKey == "HoldPosition") then
                playerSurvivor:Say(npcSurvivor.forename .. ", " .. PZNS_NPCOrdersText[orderKey]);
                PZNS_NPCOrderActions[orderKey](npcSurvivor, square);
            else
                playerSurvivor:Say(npcSurvivor.forename .. ", " .. PZNS_NPCOrdersText[orderKey]);
                PZNS_NPCOrderActions[orderKey](npcSurvivor);
            end
        end
        --
        if (npcSurvivor ~= nil) then
            local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
            local isNPCSquareLoaded = PZNS_UtilsNPCs.PZNS_GetIsNPCSquareLoaded(npcSurvivor);
            -- Cows: Check and make sure the NPC is both alive and loaded in the current game world.
            if (npcIsoPlayer:isAlive() == true and isNPCSquareLoaded == true) then
                parentContextMenu:addOption(
                    getText(npcSurvivor.survivorName),
                    nil,
                    callbackFunction
                );
            end
        end
    end
    return parentContextMenu;
end

---comment
---@param mpPlayerID number
---@param context any
---@param worldobjects any
function PZNS_ContextMenuOrders(mpPlayerID, context, worldobjects)
    local orderSubMenu = context:getNew(context);
    local orderSubMenu_Option = context:addOption(
        getText("PZNS_Orders"),
        worldobjects,
        nil
    );
    context:addSubMenu(orderSubMenu_Option, orderSubMenu);
    --
    local playerGroupID = "Player" .. mpPlayerID .. "Group";
    --
    for orderKey, orderText in pairs(PZNS_NPCOrdersText) do
        local orderAction = orderSubMenu:getNew(context);
        local orderAction_Option = orderSubMenu:addOption(
            getText(orderText),
            worldobjects,
            nil
        );
        local npcsSubMenu = orderAction:getNew(context);
        PZNS_CreateGroupNPCsSubMenu(npcsSubMenu, mpPlayerID, playerGroupID, orderKey);
        --
        orderSubMenu:addSubMenu(orderAction_Option, orderAction);
        orderAction:addSubMenu(orderAction_Option, npcsSubMenu);
    end
end
