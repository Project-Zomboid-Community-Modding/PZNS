local PZNS_NPCsManager = require("04_data_management/PZNS_NPCsManager");

---@diagnostic disable: duplicate-set-field
--- Cows: This code is based on the old "SuperSurvivorInventory.lua" code with using the new npc data structure.
--****************************************************
-- TitleBar
--****************************************************
local TitleBar = ISButton:derive("TitleBar");
local targetPlayerID = 0; -- WIP - Cows: Placeholder

function TitleBar:initialise()
    ISButton.initialise(self);
end

function TitleBar:onMouseMove(_, _)
    self.parent.mouseOver = true;
end

function TitleBar:onMouseMoveOutside(_, _)
    self.parent.mouseOver = false;
end

function TitleBar:onMouseUp(_, _)
    if not self.parent:getIsVisible() then
        return;
    end
    self.parent.moving = false;
    ISMouseDrag.dragView = nil;
end

function TitleBar:onMouseUpOutside(_, _)
    if not self.parent:getIsVisible() then
        return
    end
    self.parent.moving = false;
    ISMouseDrag.dragView = nil;
end

function TitleBar:onMouseDown(x, y)
    if not self.parent:getIsVisible() then
        return;
    end
    self.parent.downX = x;
    self.parent.downY = y;
    self.parent.moving = true;
    self.parent:bringToTop();
end

function TitleBar:new(x, width, title, parent)
    local o = {};
    o = ISButton:new(x, 0, width, 25);
    setmetatable(o, self);
    self.__index = self;
    o.borderColor = { r = 1, g = 1, b = 1, a = 0.2 };
    o.title = title;
    o.parent = parent;
    return o;
end

local function isItemDisplayCategoryStackable(displayCategoryString)
    if (displayCategoryString == "Ammo"
            or displayCategoryString == "Craft"
            or displayCategoryString == "Med"
        ) then
        return true;
    end
    return false;
end

---comment
---@param itemTable any
---@param itemID string
local function setStackableItemRows(itemTable, itemID)
    --
    if (itemTable[itemID] == nil) then
        itemTable[itemID] = 1;
    else
        itemTable[itemID] = itemTable[itemID] + 1;
    end
    return itemTable;
end

--****************************************************
-- InventoryRow
--****************************************************
local InventoryRow = ISPanel:derive("InventoryRow")
local inventoryPanels = {}; -- This variable is responsible for the player panel and npc panel

function InventoryRow:initialize()
    ISCollapsableWindow.initialise(self);
end

function InventoryRow:on_click_transfer(direction)
    -- > player to npc
    -- < npc to player
    local item_id = self.item:getID();
    local npcSurvivor = PZNS_NPCsManager.getActiveNPCBySurvivorID(self.survivorID);
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local npc_inventory = npcIsoPlayer:getInventory();
    local player_inventory = getPlayerInventory(0).inventory;
    if direction == ">" then
        if self.item:isEquipped() then
            ISTimedActionQueue.add(ISUnequipAction:new(getSpecificPlayer(targetPlayerID), self.item, 1));
        end
        player_inventory:removeItemWithID(item_id);
        npc_inventory:addItem(self.item);
        --
    else
        if self.item:isEquipped() then
            ISTimedActionQueue.add(ISUnequipAction:new(npcIsoPlayer, self.item, 1));
        end
        npc_inventory:removeItemWithID(item_id);
        player_inventory:addItem(self.item);
        --
    end
    inventoryPanels[1]:dupdate(); -- Cows: Player Inventory
    inventoryPanels[2]:dupdate(); -- Cows: NPC Inventory
end

function InventoryRow:update_tooltip()
    if self.item then
        if self.tool_render then
            self.tool_render:setItem(self.item)
            self.tool_render:setVisible(true);
            self.tool_render:addToUIManager();
            self.tool_render:bringToTop();
        else
            self.tool_render = ISToolTipInv:new(self.item);
            self.tool_render:initialise();
            self.tool_render:addToUIManager();
            self.tool_render:setVisible(true);
            self.tool_render:setOwner(self);
        end
        self.tool_render.followMouse = not self.doController;
    elseif self.tool_render then
        self.tool_render:removeFromUIManager();
        self.tool_render:setVisible(false);
    end
end

function InventoryRow:onMouseMove(_, _)
    self.mouseOver = self:isMouseOver();
    self:update_tooltip();
end

function InventoryRow:onMouseMoveOutside(dx, dy)
    self.mouseOver = false;
    if self.onmouseoutfunction then
        self.onmouseoutfunction(self.target, self, dx, dy);
    end
    if self.tool_render then
        self.tool_render:removeFromUIManager();
        self.tool_render:setVisible(false);
    end
end

function InventoryRow:createChildren()
    local col_icon = ISButton:new(0, 0, 25, 25, "", nil, nil);
    local col_item = ISButton:new(25, 0, 250, 25, tostring(self.item:getName()), nil, nil);
    local col_type = ISButton:new(25 + 250, 0, 150, 25, tostring(self.item:getCategory()), nil, nil);
    local col_transfer = ISButton:new(25 + 250 + 150, 0, 50, 25, self.direction, nil,
        function() self:on_click_transfer(self.direction) end
    );
    col_icon:setImage(self.item:getTex());
    col_icon:forceImageSize(25, 25);
    col_icon.onMouseDown = function() return end
    col_item.onMouseDown = function() return end
    col_type.onMouseDown = function() return end
    col_icon.borderColor = { r = 0, g = 0, b = 0, a = 0 };
    col_item.borderColor = { r = 0, g = 0, b = 0, a = 0 };
    col_type.borderColor = { r = 0, g = 0, b = 0, a = 0 };
    col_transfer.borderColor = { r = 0, g = 0, b = 0, a = 0 };
    --
    if self.switch == 0 then
        col_icon.backgroundColor = { r = 0.25, g = 0.31, b = 0.37, a = 0.23 };
        col_item.backgroundColor = { r = 0.25, g = 0.31, b = 0.37, a = 0.23 };
        col_type.backgroundColor = { r = 0.25, g = 0.31, b = 0.37, a = 0.23 };
        col_transfer.backgroundColor = { r = 0.25, g = 0.31, b = 0.37, a = 0.23 };
        col_icon.backgroundColorMouseOver = { r = 0.25, g = 0.31, b = 0.37, a = 0.23 };
        col_item.backgroundColorMouseOver = { r = 0.25, g = 0.31, b = 0.37, a = 0.23 };
        col_type.backgroundColorMouseOver = { r = 0.25, g = 0.31, b = 0.37, a = 0.23 };
    else
        col_icon.backgroundColor = { r = 0, g = 0, b = 0, a = 0 };
        col_item.backgroundColor = { r = 0, g = 0, b = 0, a = 0 };
        col_type.backgroundColor = { r = 0, g = 0, b = 0, a = 0 };
        col_transfer.backgroundColor = { r = 0, g = 0, b = 0, a = 0 };
        col_icon.backgroundColorMouseOver = { r = 0, g = 0, b = 0, a = 0 };
        col_item.backgroundColorMouseOver = { r = 0, g = 0, b = 0, a = 0 };
        col_type.backgroundColorMouseOver = { r = 0, g = 0, b = 0, a = 0 };
    end
    self:addChild(col_icon);
    self:addChild(col_item);
    self:addChild(col_type);
    self:addChild(col_type);
    self:addChild(col_transfer);
end

function InventoryRow:new(y, width, height, item, direction, switch, index)
    local o = {};
    o = ISPanel:new(0, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    o.borderColor = { r = 1, g = 1, b = 1, a = 0.2 };
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 };
    o.switch = switch;
    o.item = item;
    o.direction = direction;
    o.index = index;
    return o;
end

--****************************************************
-- PanelNPCInventory
--****************************************************
local PanelNPCInventory = ISPanel:new(475, 25 + 2, 475, ((25 * 10) + (8 * 7)) - (50 + 8 * 2));
table.insert(inventoryPanels, 1, PanelNPCInventory); -- Cows: NPC inventory is inserted first.

function PanelNPCInventory:dupdate()
    local isLocalFunctionLoggingEnabled = false;
    -- Cows: There should be a better way.. because if an inventory has over > 100 items, that means > 100 new items are being re-rendered every time...
    self:clearChildren()
    local dy = 0;
    local switch = 0;
    local npcSurvivor = PZNS_NPCsManager.getActiveNPCBySurvivorID(self.survivorID);
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local npc_inventory = npcIsoPlayer:getInventory();
    local items = npc_inventory:getItems();
    local scroll_height = 0;
    -- Cows: There should be a better way.. because if an inventory has over > 100 items, that means > 100 new items are being re-rendered every time...
    for i = 0, items:size() - 1 do
        local item = items:get(i);
        local inventory_row = InventoryRow:new(dy, self.width, 25, item, "<", switch, i);
        switch = (switch == 0) and 1 or 0;
        -- Cows: Don't show equipped items.
        if (not item:isEquipped()) then
            self:addChild(inventory_row);
            dy = dy + 25;
            scroll_height = scroll_height + 1;
        end
    end
    self:addScrollBars();
    self:setScrollWithParent(false);
    self:setScrollChildren(true);
    self:setScrollHeight((25 * scroll_height) + 4);
end

function PanelNPCInventory:prerender()
    self:setStencilRect(0, 0, self.width, self.height);
    if self.background then
        self:drawRectStatic(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r,
            self.backgroundColor.g, self.backgroundColor.b);
    end
    if self.border then
        self:drawRectBorderStatic(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r,
            self.borderColor.g, self.borderColor.b);
    end
end

function PanelNPCInventory:render()
    self:clearStencilRect();
end

function PanelNPCInventory:onMouseWheel(dir)
    dir = dir * -1;
    dir = (self:getScrollHeight() / 50) * dir;
    dir = self:getYScroll() + dir;
    self:setYScroll(dir);
    return true;
end

--****************************************************
-- PanelOwnInventory
--****************************************************
local PanelOwnInventory = ISPanel:new(0, 25 + 2, 475, ((25 * 10) + (8 * 7)) - (50 + 8 * 2));
table.insert(inventoryPanels, 1, PanelOwnInventory); -- Cows: Now player inventory is inserted at first index.

---comment
---@param itemTable any
---@param item any
local function stackCategoryAmmo(itemTable, item)
    --
    if (itemTable[item] == nil) then
        itemTable[item] = 1;
    else
        itemTable[item] = itemTable[item] + 1;
    end
end
---comment
function PanelOwnInventory:dupdate()
    local isLocalFunctionLoggingEnabled = false;
    -- Cows: There should be a better way.. because if an inventory has over > 100 items, that means > 100 new items are being re-rendered every time...
    self:clearChildren();
    local dy = 0;
    local switch = 0;
    local items = getPlayerInventory(0).inventory:getItems();
    local scroll_height = 0;
    -- Cows: Looking at it, stackable items (ammo for example) should not take up multiple rows because they come in dozens/hundreds.
    local inventoryAmmo = {};
    -- Cows: There should be a better way.. because if an inventory has over > 100 items, that means > 100 new items are being re-rendered every time...
    for i = 0, items:size() - 1 do
        local item = items:get(i);
        local inventory_row = {};
        if (item:getCategory() == "") then

        else
            inventory_row = InventoryRow:new(dy, self.width, 25, item, ">", switch, i);
        end

        switch = (switch == 0) and 1 or 0;
        -- Cows: Don't show equipped items(?).
        if (not item:isEquipped()) then
            self:addChild(inventory_row);
            dy = dy + 25;
            scroll_height = scroll_height + 1;
        end
    end
    self:addScrollBars();
    self:setScrollWithParent(false);
    self:setScrollChildren(true);
    self:setScrollHeight((25 * scroll_height) + 4);
end

function PanelOwnInventory:prerender()
    self:setStencilRect(0, 0, self.width, self.height);
    if self.background then
        self:drawRectStatic(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r,
            self.backgroundColor.g, self.backgroundColor.b);
    end
    if self.border then
        self:drawRectBorderStatic(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r,
            self.borderColor.g, self.borderColor.b);
    end
end

function PanelOwnInventory:render()
    self:clearStencilRect();
end

function PanelOwnInventory:onMouseWheel(dir)
    dir = dir * -1;
    dir = (self:getScrollHeight() / 50) * dir;
    dir = self:getYScroll() + dir;
    self:setYScroll(dir);
    return true;
end

--****************************************************
-- PanelInventoryTransfer
--****************************************************
PanelInventoryTransfer = ISPanel:derive("PanelInventoryTransfer")
local npcTransferPanel;

function PZNS_CreateInventoryTransferPanel(survivorID, mpPlayerID)
    if npcTransferPanel then
        npcTransferPanel:removeFromUIManager();
        npcTransferPanel = nil;
    end
    npcTransferPanel = PanelInventoryTransfer:new(
        200,
        20,
        950,
        300,
        survivorID,
        mpPlayerID
    );
    npcTransferPanel:addToUIManager();
    npcTransferPanel:setVisible(true);
end

function PanelInventoryTransfer:initialise()
    ISPanel.initialise(self);
end

function PanelInventoryTransfer:createChildren()
    local isLocalFunctionLoggingEnabled = false;
    self:clearChildren();
    local npcSurvivor = PZNS_NPCsManager.getActiveNPCBySurvivorID(self.survivorID);
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local npc_inventory = npcIsoPlayer:getInventory();
    local player_inventory = getPlayerInventory(0).inventory;
    self.header_player = TitleBar:new(
        0,
        self.width / 2,
        tostring(getPlayer():getDisplayName()) ..
        "    [" ..
        string.format("%.2f", player_inventory:getCapacityWeight()) ..
        " / " .. string.format("%.2f", player_inventory:getContentsWeight()) .. "]",
        self
    );
    self.header_npc = TitleBar:new(
        self.width / 2,
        self.width / 2,
        tostring(npcSurvivor.survivorName) ..
        "    [" ..
        string.format("%.2f", npc_inventory:getCapacityWeight()) ..
        " / " .. string.format("%.2f", npc_inventory:getContentsWeight()) .. "]",
        self
    );
    local button_close = ISButton:new(0,
        self.height - 25,
        self.width, 25, "close",
        nil,
        function() self:removeFromUIManager() end
    );
    InventoryRow.survivorID = self.survivorID;
    PanelOwnInventory.mpPlayerID = self.mpPlayerID;
    PanelNPCInventory.survivorID = self.survivorID;
    self:addChild(self.header_player);
    self:addChild(self.header_npc);
    self:addChild(PanelOwnInventory);
    self:addChild(PanelNPCInventory);
    self:addChild(button_close);
    PanelOwnInventory:dupdate();
    PanelNPCInventory:dupdate();
end

function PanelInventoryTransfer:onMouseMove(dx, dy)
    self.mouseOver = true;
    if self.moving then
        self:setX(self.x + dx);
        self:setY(self.y + dy);
        self:bringToTop();
    end
end

function PanelInventoryTransfer:onMouseMoveOutside(dx, dy)
    self.mouseOver = false;
    if self.moving then
        self:setX(self.x + dx);
        self:setY(self.y + dy);
        self:bringToTop();
    end
end

function PanelInventoryTransfer:onMouseUp(_, _)
    if not self:getIsVisible() then
        return;
    end
    self.moving = false;
    ISMouseDrag.dragView = nil;
end

function PanelInventoryTransfer:onMouseUpOutside(_, _)
    if not self:getIsVisible() then
        return
    end
    self.moving = false;
    ISMouseDrag.dragView = nil;
end

function PanelInventoryTransfer:onMouseDown(x, y)
    if not self:getIsVisible() then
        return;
    end
    self.downX = x;
    self.downY = y;
    self.moving = true;
    self:bringToTop();
end

function PanelInventoryTransfer:new(x, y, width, height, survivorID, mpPlayerID)
    local o = {};
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    o.borderColor = { r = 1, g = 1, b = 1, a = 0.2 };
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.7 };
    o.survivorID = survivorID;
    o.mpPlayerID = mpPlayerID;
    return o;
end
