local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");
--[[
    Cows: This is based on Aiteron's NPC Mod https://github.com/aiteron/NPC/blob/master/media/lua/client/NPC-Mod/UI/NPCInventoryUI.lua
--]]

---Cows: Adds a button to the right panel of the inventory UI which allows the access to the NPC inventory.
---@param page any
---@param step any
function PZNS_AddNPCInv(page, step)
    if page == ISPlayerData[1].lootInventory and step == "beforeFloor" then
        local npcIsoPlayer = PZNS_ActiveInventoryNPC.npcIsoPlayerObject;

        if (npcIsoPlayer) then
            ISPlayerData[1].lootInventory:addContainerButton(npcIsoPlayer:getInventory(),
                getTexture("media/textures/NPC_Icon.png"), tostring(PZNS_ActiveInventoryNPC.survivorName), nil
            );

            local it = npcIsoPlayer:getInventory():getItems();
            --
            for i = 0, it:size() - 1 do
                local item = it:get(i);
                --
                if item:getCategory() == "Container" and npcIsoPlayer:isEquipped(item) or item:getType() == "KeyRing" then
                    local containerButton = ISPlayerData[1].lootInventory:addContainerButton(
                        item:getInventory(), item:getTex(), item:getName(), item:getName()
                    );
                    if (item:getVisual() and item:getClothingItem()) then
                        local tint = item:getVisual():getTint(item:getClothingItem());
                        containerButton:setTextureRGBA(tint:getRedFloat(), tint:getGreenFloat(), tint:getBlueFloat(), 1.0);
                    end
                end
            end
        end
    end
end
---comment
---@param npcIsoPlayer any
---@param items any
local function NPCDrop(npcIsoPlayer, items)
    local container = ItemContainer.new("floor", nil, nil, 10, 10);
    container:setExplored(true);
    --
    for _, item in ipairs(items) do
        --
        if npcIsoPlayer:isEquipped(item) then
            ISTimedActionQueue.add(ISUnequipAction:new(npcIsoPlayer, item, 50));
        end
        ISTimedActionQueue.add(ISInventoryTransferAction:new(npcIsoPlayer, item, item:getContainer(), container));
    end
end

--- WIP - Cows: Need to consider preset equipments or "last" equipments...
---@param npcIsoPlayer IsoPlayer
---@param items any
local function NPCUnequip(npcIsoPlayer, items)
    for _, item in ipairs(items) do
        ISTimedActionQueue.add(ISUnequipAction:new(npcIsoPlayer, item, 50));
    end
end

--- WIP - Cows: Need to consider preset equipments or "last" equipments...
---@param npcIsoPlayer any
---@param item any
---@param items any
local function NPCWear(npcIsoPlayer, item, items)
    for i, item1 in ipairs(items) do
        if not npcIsoPlayer:isEquipped(item1) and item1:getCategory() == "Clothing" then
            ISTimedActionQueue.add(ISWearClothing:new(npcIsoPlayer, item1, 50));
        end
    end
end

---comment
---@param npcIsoPlayer any
---@param item any
local function NPCEquipBack(npcIsoPlayer, item)
    ISTimedActionQueue.add(ISWearClothing:new(npcIsoPlayer, item, 50));
end

--- WIP - Cows: Need to consider preset weapons or "last equipped" weapons...
local function NPCEquipWeapon(npcIsoPlayer, item, primary, twohands)
    if twohands then
        if npcIsoPlayer:getPrimaryHandItem() then
            ISTimedActionQueue.add(ISUnequipAction:new(npcIsoPlayer, npcIsoPlayer:getPrimaryHandItem(), 50));
        end
        if npcIsoPlayer:getSecondaryHandItem() then
            ISTimedActionQueue.add(ISUnequipAction:new(npcIsoPlayer, npcIsoPlayer:getSecondaryHandItem(), 50));
        end
        ISInventoryPaneContextMenu.transferIfNeeded(npcIsoPlayer, item)
        ISTimedActionQueue.add(ISEquipWeaponAction:new(npcIsoPlayer, item, 50, primary, twohands));
    else
        if primary then
            if npcIsoPlayer:getPrimaryHandItem() then
                ISTimedActionQueue.add(ISUnequipAction:new(npcIsoPlayer, npcIsoPlayer:getPrimaryHandItem(), 50));
            end
            ISInventoryPaneContextMenu.transferIfNeeded(npcIsoPlayer, item)
            ISTimedActionQueue.add(ISEquipWeaponAction:new(npcIsoPlayer, item, 50, primary, twohands));
        else
            if npcIsoPlayer:getSecondaryHandItem() then
                ISTimedActionQueue.add(ISUnequipAction:new(npcIsoPlayer, npcIsoPlayer:getSecondaryHandItem(), 50));
            end
            ISInventoryPaneContextMenu.transferIfNeeded(npcIsoPlayer, item)
            ISTimedActionQueue.add(ISEquipWeaponAction:new(npcIsoPlayer, item, 50, primary, twohands));
        end
    end

    if npcIsoPlayer:getPrimaryHandItem() then
        ISTimedActionQueue.add(ISUnequipAction:new(npcIsoPlayer, npcIsoPlayer:getPrimaryHandItem(), 50));
    end
    ISInventoryPaneContextMenu.transferIfNeeded(npcIsoPlayer, item);
    ISTimedActionQueue.add(ISEquipWeaponAction:new(npcIsoPlayer, item, 50, primary, twohands));
end

---comment
---@param playerObj any
---@param location any
---@return unknown
local function getWornItemInLocation(playerObj, location)
    local wornItems = playerObj:getWornItems();
    local bodyLocationGroup = wornItems:getBodyLocationGroup();
    --
    for i = 1, wornItems:size() do
        local wornItem = wornItems:get(i - 1);
        --
        if (wornItem:getLocation() == location) or bodyLocationGroup:isExclusive(wornItem:getLocation(), location) then
            return wornItem:getItem();
        end
    end
    return nil;
end

---comment
---@param player IsoPlayer
---@param context any
---@param items any
function PZNS_NPCInventoryContext(player, context, items)
    if not PZNS_ActiveInventoryNPC.npcIsoPlayerObject then
        return
    end

    local npcIsoPlayer = PZNS_ActiveInventoryNPC.npcIsoPlayerObject;
    items = ISInventoryPane.getActualItems(items);

    local clothing = nil;
    local backItem = nil;
    local bothHandsItem = nil;
    local primaryHandItem = nil;
    local secondaryHandItem = nil;
    local uneqipItem = nil;
    local hairDye = nil;
    local itemExtraOption = nil;

    for _, item in ipairs(items) do
        if npcIsoPlayer:getInventory() ~= item:getOutermostContainer() then
            return;
        end

        if item:isHairDye() then
            hairDye = item;
        end

        -- Fanny pack and other extra context items
        if item:getClothingItemExtraOption() then
            itemExtraOption = item;
        end

        if not npcIsoPlayer:isEquipped(item) then
            if item:getCategory() == "Clothing" then
                clothing = item;
            elseif instanceof(item, "InventoryContainer") and item:canBeEquipped() == "Back" then
                backItem = item;
            end

            if item:isTwoHandWeapon() and item:getCondition() > 0 and not npcIsoPlayer:isItemInBothHands(item) then
                bothHandsItem = item;
            end
            if (instanceof(item, "HandWeapon") and item:getCondition() > 0) or (instanceof(item, "InventoryItem") and not instanceof(item, "HandWeapon")) then
                primaryHandItem = item;
            end
            if (instanceof(item, "HandWeapon") and item:getCondition() > 0) or (instanceof(item, "InventoryItem") and not instanceof(item, "HandWeapon")) then
                secondaryHandItem = item;
            end
        else
            uneqipItem = item;
        end
    end
    --
    if itemExtraOption then
        local context2
        --
        if (itemExtraOption:IsClothing() or itemExtraOption:IsInventoryContainer()) and itemExtraOption:getClothingExtraSubmenu() then
            local option = context:addOption("NPC: " .. getText("ContextMenu_PZNS_Wear"));
            local subMenu = context:getNew(context);
            context:addSubMenu(option, subMenu);
            context2 = subMenu;

            local location = itemExtraOption:IsClothing() and itemExtraOption:getBodyLocation() or
            itemExtraOption:canBeEquipped();
            local existingItem = getWornItemInLocation(npcIsoPlayer, location);

            if existingItem ~= itemExtraOption then
                local text = getText("ContextMenu_" .. itemExtraOption:getClothingExtraSubmenu());
                local option = context2:addOption(
                    text, itemExtraOption, ISInventoryPaneContextMenu.onClothingItemExtra,
                    itemExtraOption:getType(), npcIsoPlayer
                );
                ISInventoryPaneContextMenu.doWearClothingTooltip(npcIsoPlayer, itemExtraOption, itemExtraOption, option);
            end
        end

        for i = 0, itemExtraOption:getClothingItemExtraOption():size() - 1 do
            local text = getText("ContextMenu_" .. itemExtraOption:getClothingItemExtraOption():get(i));
            local itemType = moduleDotType(itemExtraOption:getModule(), itemExtraOption:getClothingItemExtra():get(i));
            local item = ISInventoryPaneContextMenu.getItemInstance(itemType);
            local option = context2:addOption(
                text, itemExtraOption, ISInventoryPaneContextMenu.onClothingItemExtra,
                itemType, npcIsoPlayer
            );
            ISInventoryPaneContextMenu.doWearClothingTooltip(npcIsoPlayer, item, itemExtraOption, option);
        end
    end
    --
    if clothing then
        context:addOption(getText("ContextMenu_PZNS_NPCWear"), npcIsoPlayer, NPCWear, clothing, items);
    elseif backItem then
        context:addOption(getText("ContextMenu_PZNS_NPCWearOnBack"), npcIsoPlayer, NPCEquipBack, backItem);
    end
    --
    if hairDye and npcIsoPlayer:getHumanVisual():getHairModel() and npcIsoPlayer:getHumanVisual():getHairModel() ~= "Bald" then
        context:addOption(getText("ContextMenu_PZNS_NPCDyeHair"), hairDye, ISInventoryPaneContextMenu.onDyeHair, npcIsoPlayer, false);
    end
    --
    if hairDye and npcIsoPlayer:getHumanVisual():getBeardModel() and npcIsoPlayer:getHumanVisual():getBeardModel() ~= "" then
        context:addOption(getText("ContextMenu_PZNS_NPCDyeBeard"), hairDye, ISInventoryPaneContextMenu.onDyeHair, npcIsoPlayer, true);
    end
    --
    if bothHandsItem then
        context:addOption(getText("ContextMenu_PZNS_NPCEquipBothHands"), npcIsoPlayer, NPCEquipWeapon, bothHandsItem, true, true);
    end
    --
    if primaryHandItem then
        context:addOption(getText("ContextMenu_PZNS_NPCEquipPrimary"), npcIsoPlayer, NPCEquipWeapon, primaryHandItem, true, false);
    end
    --
    if secondaryHandItem then
        context:addOption(getText("ContextMenu_PZNS_NPCEquipSecondary"), npcIsoPlayer, NPCEquipWeapon, secondaryHandItem, false, false);
    end
    --
    context:addOption(getText("ContextMenu_PZNS_NPCDropItem"), npcIsoPlayer, NPCDrop, items);
    --
    if uneqipItem then
        context:addOption(getText("ContextMenu_PZNS_NPCUnquipItem"), npcIsoPlayer, NPCUnequip, items);
    end
end
--
local temp = ISInventoryPane.transferItemsByWeight;
function ISInventoryPane:transferItemsByWeight(items, container)
    if not PZNS_ActiveInventoryNPC then
        temp(self, items, container);
        return;
    end

    local npcIsoPlayer = PZNS_ActiveInventoryNPC.npcIsoPlayerObject;
    if (npcIsoPlayer ~= nil) then
        if npcIsoPlayer:getInventory():containsRecursive(items[1]) then
            for i, item in ipairs(items) do
                ISTimedActionQueue.add(ISInventoryTransferAction:new(npcIsoPlayer, item, item:getContainer(), container));
            end
        else
            temp(self, items, container);
        end
    else
        temp(self, items, container);
    end
end
--
local temp2 = ISInventoryPaneContextMenu.dropItem;
ISInventoryPaneContextMenu.dropItem = function(item, player)
    if not PZNS_ActiveInventoryNPC then
        temp2(item, player)
        return
    end

    local npcIsoPlayer = PZNS_ActiveInventoryNPC.npcIsoPlayerObject;
    if (npcIsoPlayer ~= nil) then
        if npcIsoPlayer:getInventory():containsRecursive(item) then
            local container = ItemContainer.new("floor", nil, nil, 10, 10);
            container:setExplored(true);
            ISTimedActionQueue.add(ISInventoryTransferAction:new(npcIsoPlayer, item, item:getContainer(), container));
        else
            temp2(item, player);
        end
    else
        temp2(item, player);
    end
end
--
local temp3 = ISInventoryPaneContextMenu.transferItems;
ISInventoryPaneContextMenu.transferItems = function(items, playerInv, player, dontWalk)
    if not PZNS_ActiveInventoryNPC then
        temp3(items, playerInv, player, dontWalk);
        return;
    end

    items = ISInventoryPane.getActualItems(items);
    local npcIsoPlayer = PZNS_ActiveInventoryNPC.npcIsoPlayerObject;
    if (npcIsoPlayer ~= nil) then
        if npcIsoPlayer:getInventory():containsRecursive(items[1]) then
            for i, item in ipairs(items) do
                ISTimedActionQueue.add(ISInventoryTransferAction:new(npcIsoPlayer, item, item:getContainer(), playerInv));
            end
        else
            temp3(items, playerInv, player, dontWalk);
        end
    else
        temp3(items, playerInv, player, dontWalk);
    end
end
--
local temp4 = ISInventoryPaneContextMenu.onGrabHalfItems;
ISInventoryPaneContextMenu.onGrabHalfItems = function(items, player)
    if not PZNS_ActiveInventoryNPC then
        temp4(items, player);
        return;
    end

    items = ISInventoryPane.getActualItems(items)
    local npcIsoPlayer = PZNS_ActiveInventoryNPC.npcIsoPlayerObject;
    if (npcIsoPlayer ~= nil) then
        if npcIsoPlayer:getInventory():containsRecursive(items[1]) then
            local countNeed = #items / 2;
            local count = 0;
            for i, k in ipairs(items) do
                ISTimedActionQueue.add(
                    ISInventoryTransferAction:new(npcIsoPlayer, k, k:getContainer(),
                        getPlayerInventory(player).inventory)
                );
                count = count + 1;
                if count >= countNeed then
                    return;
                end
            end
        else
            temp4(items, player);
        end
    else
        temp4(items, player);
    end
end
--
local temp5 = ISInventoryPaneContextMenu.onGrabOneItems;
ISInventoryPaneContextMenu.onGrabOneItems = function(items, player)
    if not PZNS_ActiveInventoryNPC then
        temp5(items, player);
        return;
    end

    items = ISInventoryPane.getActualItems(items);
    local npcIsoPlayer = PZNS_ActiveInventoryNPC.npcIsoPlayerObject;
    if (npcIsoPlayer ~= nil) then
        if npcIsoPlayer:getInventory():containsRecursive(items[1]) then
            for i, item in ipairs(items) do
                ISTimedActionQueue.add(ISInventoryTransferAction:new(
                    npcIsoPlayer, item, item:getContainer(),
                    getPlayerInventory(player).inventory)
                );
                return;
            end
        else
            temp5(items, player);
        end
    else
        temp5(items, player);
    end
end
--
local temp6 = ISInventoryPaneContextMenu.wearItem;
ISInventoryPaneContextMenu.wearItem = function(item, player)
    if not PZNS_ActiveInventoryNPC then
        temp6(item, player);
        return;
    end

    local npcIsoPlayer = PZNS_ActiveInventoryNPC.npcIsoPlayerObject;
    if (npcIsoPlayer ~= nil) then
        if item:isEquipped() then
            ISTimedActionQueue.add(ISUnequipAction:new(npcIsoPlayer, item, 50));
        else
            temp6(item, player);
        end
    else
        temp6(item, player);
    end
end
--
local temp7 = ISInventoryPaneContextMenu.onInspectClothing;
ISInventoryPaneContextMenu.onInspectClothing = function(playerObj, clothing)
    if not PZNS_ActiveInventoryNPC then
        temp7(playerObj, clothing);
        return;
    end

    local npcIsoPlayer = PZNS_ActiveInventoryNPC.npcIsoPlayerObject;
    if (npcIsoPlayer ~= nil) then
        if clothing:isEquipped() then
            ISTimedActionQueue.add(ISUnequipAction:new(npcIsoPlayer, clothing, 50));
        else
            temp7(playerObj, clothing);
        end
    else
        temp7(playerObj, clothing);
    end
end
