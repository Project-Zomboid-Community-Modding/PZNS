local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_PlayerUtils = require("02_mod_utils/PZNS_PlayerUtils");
local PZNS_NPCGroupsManager = require("04_data_management/PZNS_NPCGroupsManager");

---@diagnostic disable: duplicate-doc-alias
PZNS_SquareContextActionsText = {
    Drink = getText("ContextMenu_PZNS_Drink"),
    Eat = getText("ContextMenu_PZNS_Eat"),
    GrabItem = getText("ContextMenu_PZNS_Grab_Item"),
    GrabCorpse = getText("ContextMenu_PZNS_Grab_Corpse"),
    WashClothes = getText("ContextMenu_PZNS_Wash_Clothes"),
    WashSelf = getText("ContextMenu_PZNS_Wash_Self")
};
--
PZNS_SquareContextActions = {
    Drink = PZNS_DrinkWater,
    Eat = PZNS_EatObject,
    GrabItem = PZNS_GrabItem,
    GrabCorpse = PZNS_MoveToGrabCorpse,
    WashClothes = PZNS_WashClothesAtSquare,
    WashSelf = PZNS_WashSelfAtSquare
};
--- @type IsoGridSquare | nil
local mouseSquareToHighlight = nil;

--- Cows: Renders the mouseSquare
local function renderMouseSquare()
    --
    if (mouseSquareToHighlight ~= nil) then
        local red = ColorInfo.new(0.8, 0.169, 0.161, 0.8);
        -- Cows: Check if floor exists, because windows on the 2nd floor can be selected without a floor...
        if (mouseSquareToHighlight:getFloor() ~= nil) then
            mouseSquareToHighlight:getFloor():setHighlightColor(red);
            mouseSquareToHighlight:getFloor():setHighlighted(true);
        end
    end
end
--
local function stopRenderMouseSquare()
    mouseSquareToHighlight = nil;
    Events.OnRenderTick.Remove(renderMouseSquare);
    Events.OnMouseUp.Remove(stopRenderMouseSquare);
end

---comment
---@param square any
---@return boolean
---@return boolean
local function squareHasWater(square)
    local squareObjects = square:getObjects();
    local objectsListSize = squareObjects:size() - 1;
    local isDrinkingWaterFound = false;
    local isWashWaterFound = false;
    --
    for i = 1, objectsListSize do
        local currentObj = squareObjects:get(i);
        local hasWater = currentObj:hasWater();
        local isWaterTainted = currentObj:isTaintedWater();
        --
        if (hasWater == true) then
            local waterAmount = currentObj:getWaterAmount();
            --
            if (isWaterTainted == false) then
                isDrinkingWaterFound = true;
            end
            --
            if (waterAmount >= 50) then
                isWashWaterFound = true;
            end
        end
    end
    return isDrinkingWaterFound, isWashWaterFound;
end

---comment
---@param square any
---@return unknown
local function getSquareDeadBody(square)
    local squareDeadBodys = square:getDeadBodys();
    local deadBody = nil;
    --
    if (squareDeadBodys ~= nil) then
        -- Cows: Verify it is NOT an empty list.
        if (squareDeadBodys:size() > 0) then
            ---@alias List AbstractList|AbstractSequentialList|ArrayList|LinkedList|Stack|Vector
            deadBody = squareDeadBodys:get(0);
        end
    end
    return deadBody;
end

---comment
---@param parentContextMenu any
---@param mpPlayerID any
---@param groupID any
---@param orderKey any
---@param square IsoGridSquare
---@param deadBody IsoDeadBody | nil
---@return any
function PZNS_CreateSquareGroupNPCsSubMenu(parentContextMenu, mpPlayerID, groupID, orderKey, square, deadBody)
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    local groupMembers = PZNS_NPCGroupsManager.getGroupByID(groupID);
    --
    if (groupMembers) then
        local playerSurvivor = getSpecificPlayer(mpPlayerID);
        for survivorID, v in pairs(groupMembers) do
            local npcSurvivor = activeNPCs[survivorID];
            local callbackFunction = function()
                playerSurvivor:Say(npcSurvivor.forename .. ", " ..
                    PZNS_SquareContextActionsText[orderKey]
                );
                PZNS_NPCSpeak(npcSurvivor,
                    "Square Order " ..
                    PZNS_SquareContextActionsText[orderKey] ..
                    " acknowledged!",
                    "Friendly"
                );
                --
                if (orderKey == "GrabCorpse" and deadBody ~= nil) then
                    PZNS_SquareContextActions[orderKey](npcSurvivor, square, deadBody);
                else
                    PZNS_SquareContextActions[orderKey](npcSurvivor, square);
                end
                parentContextMenu:setVisible(false);
            end
            --
            if (npcSurvivor ~= nil) then
                local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
                local isNPCSquareLoaded = PZNS_UtilsNPCs.PZNS_GetIsNPCSquareLoaded(npcSurvivor);
                -- Cows: Check and make sure the NPC is both alive and loaded in the current game world.
                if (npcIsoPlayer:isAlive() == true and isNPCSquareLoaded == true) then
                    parentContextMenu:addOption(
                        npcSurvivor.survivorName,
                        nil,
                        callbackFunction
                    );
                end
            end
        end
    end

    return parentContextMenu;
end

---comment
---@param mpPlayerID number
---@param context any
---@param worldobjects any
function PZNS_ContextMenuSquareObjects(mpPlayerID, context, worldobjects)
    local playerGroupID = "Player" .. mpPlayerID .. "Group";
    local squareSubMenu = context:getNew(context);
    --
    local square = PZNS_PlayerUtils.PZNS_GetPlayerMouseGridSquare(mpPlayerID);
    mouseSquareToHighlight = square;
    Events.OnRenderTick.Add(renderMouseSquare);
    Events.OnMouseUp.Add(stopRenderMouseSquare);
    --
    local deadBody = getSquareDeadBody(square);
    --
    if (deadBody ~= nil) then
        local grabCorpseSubMenu = squareSubMenu:getNew(context);
        local grabCorpseSubMenu_Option = squareSubMenu:addOption(
            PZNS_SquareContextActionsText["GrabCorpse"],
            worldobjects,
            nil
        );
        squareSubMenu:addSubMenu(grabCorpseSubMenu_Option, grabCorpseSubMenu);
        local npcsSubMenuCorpse = grabCorpseSubMenu:getNew(context);
        PZNS_CreateSquareGroupNPCsSubMenu(
            npcsSubMenuCorpse, mpPlayerID, playerGroupID,
            "GrabCorpse", square, deadBody
        );
        grabCorpseSubMenu:addSubMenu(grabCorpseSubMenu_Option, npcsSubMenuCorpse);
    end
    --
    local isDrinkingWaterFound, isWashWaterFound = squareHasWater(square);
    --
    if (isDrinkingWaterFound == true) then
        local drinkSubMenu = squareSubMenu:getNew(context);
        local drinkSubMenu_Option = squareSubMenu:addOption(
            PZNS_SquareContextActionsText["Drink"],
            worldobjects,
            nil
        );
        squareSubMenu:addSubMenu(drinkSubMenu_Option, drinkSubMenu);
        local npcsSubMenuDrink = drinkSubMenu:getNew(context);
        PZNS_CreateSquareGroupNPCsSubMenu(npcsSubMenuDrink, mpPlayerID, playerGroupID, "Drink", square, nil);
        drinkSubMenu:addSubMenu(drinkSubMenu_Option, npcsSubMenuDrink);
    end
    --
    if (isWashWaterFound == true) then
        --
        local washClothesSubMenu = squareSubMenu:getNew(context);
        local washClothesSubMenu_Option = squareSubMenu:addOption(
            PZNS_SquareContextActionsText["WashClothes"],
            worldobjects,
            nil
        );
        --
        local washSelfSubMenu = squareSubMenu:getNew(context);
        local washSelfSubMenu_Option = squareSubMenu:addOption(
            PZNS_SquareContextActionsText["WashSelf"],
            worldobjects,
            nil
        );
        squareSubMenu:addSubMenu(washClothesSubMenu_Option, washClothesSubMenu);
        squareSubMenu:addSubMenu(washSelfSubMenu_Option, washSelfSubMenu);
        local npcsSubMenuWashClothes = washClothesSubMenu:getNew(context);
        local npcsSubMenuWashSelf = washSelfSubMenu:getNew(context);
        PZNS_CreateSquareGroupNPCsSubMenu(npcsSubMenuWashClothes, mpPlayerID, playerGroupID, "WashClothes", square);
        PZNS_CreateSquareGroupNPCsSubMenu(npcsSubMenuWashSelf, mpPlayerID, playerGroupID, "WashSelf", square);
        washClothesSubMenu:addSubMenu(washClothesSubMenu_Option, npcsSubMenuWashClothes);
        washSelfSubMenu:addSubMenu(washSelfSubMenu_Option, npcsSubMenuWashSelf);
    end
    -- Cows: Only add the contextmenu if there are things found on the square
    if (deadBody ~= nil
            or isDrinkingWaterFound == true
            or isWashWaterFound == true
        ) then
        local squareSubMenu_Option = context:addOption(
            getText("ContextMenu_PZNS_PZNS_Square"),
            worldobjects,
            nil
        );
        context:addSubMenu(squareSubMenu_Option, squareSubMenu);
    else
        squareSubMenu = nil;
    end
end
