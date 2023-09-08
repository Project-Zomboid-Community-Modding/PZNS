--[[
    Cows: This file is intended for ALL functions related to the creation, deletion, load,
    and editing of NPCs' specified attribute(s) and inventory data.
--]]
local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_UtilsNPCs = {};
--- Cows: Add a specified trait to the target npcSurvivor.
---@param npcSurvivor any
---@param traitName string
---@return any
function PZNS_UtilsNPCs.PZNS_AddNPCSurvivorTraits(npcSurvivor, traitName)
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if (npcIsoPlayer == nil) then
        return;
    end
    npcIsoPlayer:getTraits():add(traitName);
    return npcSurvivor;
end

--- Cows: Level the target npcSurvivor's specified perk by the specified levels.
---@param npcSurvivor any
---@param perkName string
---@param levels number
---@return any
function PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, perkName, levels)
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if (npcIsoPlayer == nil) then
        return;
    end
    -- Verify the perk exists and level it based on the levels number input.
    if (PerkFactory.getPerkFromName(perkName)) then
        for i = 1, levels do
            npcIsoPlayer:LevelPerk(Perks.FromString(perkName));
        end
    end

    return npcSurvivor;
end

--- Cows: Gets the target npcSurvivor's specified perk level
---@param npcSurvivor any
---@param perkName string
---@return any
function PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, perkName)
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if (npcIsoPlayer == nil) then
        return;
    end
    -- Verify the perk exists and level it based on the levels number input.
    if (PerkFactory.getPerkFromName(perkName)) then
        return npcIsoPlayer:getPerkLevel(Perks.FromString(perkName));
    end

    return 0;
end

--- Cows: Simple code to add item to npcSurvivor inventory.
---@param npcSurvivor any
---@param itemID string
function PZNS_UtilsNPCs.PZNS_AddItemToInventoryNPCSurvivor(npcSurvivor, itemID)
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if (npcIsoPlayer == nil) then
        return nil;
    end
    local item = instanceItem(itemID);
    --
    if (item ~= nil) then
        npcIsoPlayer:getInventory():AddItem(item);
    end
    return item
end

--- Ed: Tweaked with for loop to spawn multiple items by count.
---@param npcSurvivor any
---@param itemID string
---@param count integer
function PZNS_UtilsNPCs.PZNS_AddItemsToInventoryNPCSurvivor(npcSurvivor, itemID, count)
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if (npcIsoPlayer == nil) then
        return;
    end
    --
    for i = 1, count
    do
        local item = instanceItem(itemID);
        if (item ~= nil) then
            npcIsoPlayer:getInventory():AddItem(item);
        end
    end
end

--- Cows: Simple code to remove item to npcSurvivor inventory.
---@param npcSurvivor any
---@param itemID integer
function PZNS_UtilsNPCs.PZNS_RemoveItemFromInventoryNPCSurvivor(npcSurvivor, itemID)
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if (npcIsoPlayer == nil) then
        return false;
    end
    -- WIP - Cows: Need to specify the amount? Item ID?
    return npcIsoPlayer:getInventory():removeItemWithID(itemID);
end

--- Cows: Simple code to add clothingItem to npcSurvivor inventory and wear it.
---@param npcSurvivor any
---@param clothingID string
function PZNS_UtilsNPCs.PZNS_AddEquipClothingNPCSurvivor(npcSurvivor, clothingID)
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if (npcIsoPlayer == nil) then
        return nil;
    end
    local clothingItem = instanceItem(clothingID);
    --
    if (clothingItem ~= nil) then
        npcIsoPlayer:getInventory():AddItem(clothingItem);
        local bodyPartLocation = clothingItem:getBodyLocation();
        --
        if (bodyPartLocation ~= nil and bodyPartLocation ~= '') then
            npcIsoPlayer:setWornItem(bodyPartLocation, clothingItem);
        end
    end
    return clothingItem
end

--- Cows: Simple code to add weaponItem to npcSurvivor inventory and equip it.
---@param npcSurvivor any
---@param weaponID string
function PZNS_UtilsNPCs.PZNS_AddEquipWeaponNPCSurvivor(npcSurvivor, weaponID)
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if (npcIsoPlayer == nil) then
        return nil;
    end
    local weaponItem = instanceItem(weaponID);
    --
    if (weaponItem ~= nil) then
        --removes already equipped item if any
        local previousPHandItem = npcIsoPlayer:getPrimaryHandItem();
        if previousPHandItem then
            local previousSHandItem = npcIsoPlayer:getSecondaryHandItem();
            if previousSHandItem == previousPHandItem then
                npcIsoPlayer:setSecondaryHandItem(nil);
            end
        end
        npcIsoPlayer:getInventory():AddItem(weaponItem);
        npcIsoPlayer:setPrimaryHandItem(weaponItem);
        --
        local npcHandItem = npcIsoPlayer:getPrimaryHandItem();
        --
        if (npcHandItem:IsWeapon() == true) then
            --
            if (npcHandItem:isRanged() == true) then
                npcSurvivor.lastEquippedRangeWeapon = npcHandItem;
            else
                npcSurvivor.lastEquippedMeleeWeapon = npcHandItem;
            end
        end

        if (weaponItem:isRequiresEquippedBothHands() or weaponItem:isTwoHandWeapon()) then
            npcIsoPlayer:setSecondaryHandItem(weaponItem);
        end
    end
    return weaponItem or npcIsoPlayer:getPrimaryHandItem();
end

--- WIP - Cows: Simple code to equip the last weapon the npcSurvivor had.
---@param npcSurvivor any
function PZNS_UtilsNPCs.PZNS_EquipLastWeaponNPCSurvivor(npcSurvivor)
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if (npcIsoPlayer == nil) then
        return nil;
    end
    local weaponItem = nil
    --
    if (npcSurvivor.isMeleeOnly == true) then -- TODO reuse item from inventory if any of the same type
        weaponItem = instanceItem(npcSurvivor.lastEquippedMeleeWeapon or "");
    else
        weaponItem = instanceItem(npcSurvivor.lastEquippedRangeWeapon or "");
    end
    --
    if (weaponItem ~= nil) then
        npcIsoPlayer:getInventory():AddItem(weaponItem);
        npcIsoPlayer:setPrimaryHandItem(weaponItem);
        --
        local npcHandItem = npcIsoPlayer:getPrimaryHandItem();
        --
        if (npcHandItem:IsWeapon() == true) then
            --
            if (npcHandItem:isRanged() == true) then
                npcSurvivor.lastEquippedRangeWeapon = npcHandItem;
            else
                npcSurvivor.lastEquippedMeleeWeapon = npcHandItem;
            end
        end

        if (weaponItem:isRequiresEquippedBothHands() or weaponItem:isTwoHandWeapon()) then
            npcIsoPlayer:setSecondaryHandItem(weaponItem);
        end
    end
    return weaponItem or npcIsoPlayer:getPrimaryHandItem()
end

---comment
---@param npcSurvivor any
---@param r float
---@param g float
---@param b float
function PZNS_UtilsNPCs.PZNS_SetNPCHairColor(npcSurvivor, r, g, b)
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if (npcIsoPlayer == nil) then
        return;
    end
    local hairColor = ImmutableColor.new(r, g, b);
    npcIsoPlayer:getHumanVisual():setHairColor(hairColor);
end

---comment
---@param npcSurvivor any
---@param hairModelString string
function PZNS_UtilsNPCs.PZNS_SetNPCHairModel(npcSurvivor, hairModelString)
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if (npcIsoPlayer == nil) then
        return;
    end

    npcIsoPlayer:getHumanVisual():setHairModel(hairModelString);
end

---comment
---@param npcSurvivor any
---@param r float
---@param g float
---@param b float
function PZNS_UtilsNPCs.PZNS_SetNPCSkinColor(npcSurvivor, r, g, b)
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if (npcIsoPlayer == nil) then
        return;
    end
    local skinColor = ImmutableColor.new(r, g, b);
    npcIsoPlayer:getHumanVisual():setSkinColor(skinColor);
end

---comment
---@param npcSurvivor any
---@param idx number
function PZNS_UtilsNPCs.PZNS_SetNPCSkinTextureIndex(npcSurvivor, idx)
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if (npcIsoPlayer == nil) then
        return;
    end
    npcIsoPlayer:getHumanVisual():setSkinTextureIndex(idx);
end

---comment
---@param npcSurvivor any
---@param groupID string | nil
function PZNS_UtilsNPCs.PZNS_SetNPCGroupID(npcSurvivor, groupID)
    npcSurvivor.groupID = groupID;
end

---comment
---@param npcSurvivor any
---@param jobName string
function PZNS_UtilsNPCs.PZNS_SetNPCJob(npcSurvivor, jobName)
    if (npcSurvivor == nil) then
        return;
    end

    if (jobName) then
        for _, job in pairs(PZNS_JobsText) do
            if job and job[1] == jobName then
                npcSurvivor.jobName = jobName
                return
            end
        end
    end
end

---comment
---@param npcSurvivor any
---@param targetID any
function PZNS_UtilsNPCs.PZNS_SetNPCFollowTargetID(npcSurvivor, targetID)
    if (npcSurvivor == nil) then
        return;
    end

    if (targetID) then
        npcSurvivor.followTargetID = targetID;
    end
end

--- Cows: Assigns a speech table to the npcSurvivor.
---@param npcSurvivor any
---@param speechTable table | nil
function PZNS_UtilsNPCs.PZNS_SetNPCSpeechTable(npcSurvivor, speechTable)
    if (npcSurvivor == nil) then
        return;
    end

    if (speechTable) then
        npcSurvivor.speechTable = speechTable;
    end
end

--- Cows: Have the NPC speak using the input speech table with a specified intention.
---@param npcSurvivor any
---@param speechTable table
---@param intention string | nil
function PZNS_UtilsNPCs.PZNS_UseNPCSpeechTable(npcSurvivor, speechTable, intention)
    if (npcSurvivor == nil or speechTable == nil) then
        return;
    end
    local tableSize = #speechTable;
    local rolled = ZombRand(tableSize) + 1;
    PZNS_NPCSpeak(npcSurvivor, speechTable[rolled], intention);
end

--- Cows: Clears the queued ISTimedActionQueue
---@param npcSurvivor any
function PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor)
    if (npcSurvivor == nil) then
        return;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if (npcIsoPlayer == nil) then
        return;
    end
    -- Cows: Reset the actionTicks, so NPC can restart their actions
    npcSurvivor.actionTicks = 0;
    -- Cows: Stop attacking and stop aiming
    npcIsoPlayer:NPCSetAttack(false);
    if (npcIsoPlayer:NPCGetAiming() == true) then
        npcIsoPlayer:NPCSetAiming(false);
    end
    ISTimedActionQueue.clear(npcIsoPlayer);
end

---comment
---@param npcSurvivor any
function PZNS_UtilsNPCs.PZNS_GetNPCActionsQueue(npcSurvivor)
    if (npcSurvivor == nil) then
        return;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local npcActionQueue = ISTimedActionQueue.getTimedActionQueue(npcIsoPlayer);

    return npcActionQueue;
end

---
---@param npcSurvivor any
---@return integer | nil
function PZNS_UtilsNPCs.PZNS_GetNPCActionsQueuedCount(npcSurvivor)
    if (npcSurvivor == nil) then
        return;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local actionsCount = #ISTimedActionQueue.getTimedActionQueue(npcIsoPlayer.queue);
    return actionsCount;
end

--- Cows: Adds an action to ISTimedActionQueue; this is a wrapper function that allows the npcSurvivor to be updated without changing ISTimedActionQueue
---@param npcSurvivor any
---@param npcQueueAction any
function PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, npcQueueAction)
    if (npcSurvivor == nil or npcQueueAction == nil) then
        return;
    end
    -- Cows: Perhaps add a check for how many actions are in queue? Automatic cleanup and updates will keep the NPCs responsive.
    local actionsCount = PZNS_UtilsNPCs.PZNS_GetNPCActionsQueuedCount(npcSurvivor);
    local actionsQueueLimit = 30;

    if (actionsCount < actionsQueueLimit) then
        ISTimedActionQueue.add(npcQueueAction);
    else
        PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor);
    end
end

--- Cows Checks if NPC square is loaded, this is critical to ensure NPC IsoPlayer can act.
---@param npcSurvivor any
---@return boolean
function PZNS_UtilsNPCs.PZNS_GetIsNPCSquareLoaded(npcSurvivor)
    if (npcSurvivor == nil) then
        return false;
    end
    local npcSquare = nil;
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    -- Cows: Use the current IsoPlayer's object position if available
    if (npcIsoPlayer) then
        npcSquare = npcIsoPlayer:getSquare();
    else
        -- Cows: Else Use the last known/saved position of the NPC
        npcSquare = getCell():getGridSquare(
            npcSurvivor.squareX,
            npcSurvivor.squareY,
            npcSurvivor.squareZ
        );
    end
    -- Cows: if the npcSquare is still nil, the square is unloaded.
    if (npcSquare == nil) then
        return false;
    end
    return true;
end

---comment
---@param npcSurvivor any
---@return IsoGridSquare | nil
function PZNS_UtilsNPCs.PZNS_GetNPCIsoGridSquare(npcSurvivor)
    if (npcSurvivor == nil) then
        return;
    end
    ---@type IsoPlayer
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local npcSquare = npcIsoPlayer:getSquare();
    --
    return npcSquare;
end

--- Cows: Checks if any of the ActiveNPCs have the specified jobName.
---@param jobName string
---@return boolean
function PZNS_UtilsNPCs.PZNS_CheckIfJobIsActive(jobName)
    local isJobActive = false;
    --
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    --
    for survivorID, v in pairs(activeNPCs) do
        local npcSurvivor = activeNPCs[survivorID];
        --
        if (npcSurvivor.jobName == jobName) then
            if (PZNS_UtilsNPCs.PZNS_GetIsNPCSquareLoaded(npcSurvivor) == true) then
                isJobActive = true;
                break;
            end
        end
    end
    return isJobActive;
end

--- Cows: needType based on values in Java API
--- https://projectzomboid.com/modding/zombie/characters/Stats.html
---@param npcSurvivor any
---@param needType any
---@param needValue any
function PZNS_UtilsNPCs.PZNS_SetNPCNeedLevel(npcSurvivor, needType, needValue)
    if (npcSurvivor == nil) then
        return;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;

    if (needType == "Anger") then
        npcIsoPlayer:getStats():setAnger(needValue);
    elseif (needType == "Boredom") then
        npcIsoPlayer:getStats():setBoredom(needValue);
    elseif (needType == "Drunkenness") then
        npcIsoPlayer:getStats():setDrunkenness(needValue);
    elseif (needType == "Endurance") then
        npcIsoPlayer:getStats():setEndurance(needValue);
    elseif (needType == "Fatigue") then
        npcIsoPlayer:getStats():setFatigue(needValue);
    elseif (needType == "Fear") then
        npcIsoPlayer:getStats():setFear(needValue);
    elseif (needType == "Hunger") then
        npcIsoPlayer:getStats():setHunger(needValue);
    elseif (needType == "IdleBoredom") then
        npcIsoPlayer:getStats():setIdleboredom(needValue);
    elseif (needType == "Morale") then
        npcIsoPlayer:getStats():setMorale(needValue);
    elseif (needType == "Pain") then
        npcIsoPlayer:getStats():setPain(needValue);
    elseif (needType == "Panic") then
        npcIsoPlayer:getStats():setPanic(needValue);
    elseif (needType == "Sanity") then
        npcIsoPlayer:getStats():setSanity(needValue);
    elseif (needType == "Sickness") then
        npcIsoPlayer:getStats():setSickness(needValue);
    elseif (needType == "Stress") then
        npcIsoPlayer:getStats():setStress(needValue);
    elseif (needType == "StressFromCigarettes") then
        npcIsoPlayer:getStats():setStressFromCigarettes(needValue);
    elseif (needType == "Thirst") then
        npcIsoPlayer:getStats():setThirst(needValue);
    end
end

--- Cows: needType based on values in Java API
---@param npcSurvivor any
function PZNS_UtilsNPCs.PZNS_ClearNPCAllNeedsLevel(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid == false) then
        return;
    end
    local playerGroupID = "Player" .. tostring(0) .. "Group";
    -- Cows; Check if the npc is in the playerGroup and increase their affection accordingly.
    if (npcSurvivor.groupID == playerGroupID) then
        npcSurvivor.affection = npcSurvivor.affection + 10;
    end
    --
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if (npcIsoPlayer) then
        npcIsoPlayer:getStats():setAnger(0.0);
        npcIsoPlayer:getStats():setBoredom(0.0);
        npcIsoPlayer:getStats():setDrunkenness(0.0);
        npcIsoPlayer:getStats():setEndurance(100.0);
        npcIsoPlayer:getStats():setFatigue(0.0);
        npcIsoPlayer:getStats():setFear(0.0);
        npcIsoPlayer:getStats():setHunger(0.0);
        npcIsoPlayer:getStats():setIdleboredom(0.0);
        npcIsoPlayer:getStats():setMorale(0.0);
        npcIsoPlayer:getStats():setPain(0.0);
        npcIsoPlayer:getStats():setPanic(0.0);
        npcIsoPlayer:getStats():setSanity(0.0);
        npcIsoPlayer:getStats():setSickness(0.0);
        npcIsoPlayer:getStats():setStress(0.0);
        npcIsoPlayer:getStats():setStressFromCigarettes(0.0);
        npcIsoPlayer:getStats():setThirst(0.0);
        npcIsoPlayer:getBodyDamage():AddGeneralHealth(25);
    end
end

--- Cows: Clears ALL npcs' needs on call.
function PZNS_UtilsNPCs.PZNS_ClearAllNPCsAllNeedsLevel()
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    --
    for survivorID, v in pairs(activeNPCs) do
        local npcSurvivor = activeNPCs[survivorID];
        if (npcSurvivor.isAlive == true) then
            PZNS_UtilsNPCs.PZNS_ClearNPCAllNeedsLevel(npcSurvivor);
        end
    end
end

--- Cows: Check and update the npcSurvivor isStuckTicks, using the input tickInterval
---@param npcSurvivor any
---@param tickInterval number
function PZNS_UtilsNPCs.PZNS_StuckNPCCheck(npcSurvivor, tickInterval)
    -- Cows: 50 Ticks per action on average... also need ticks for animations.
    if (npcSurvivor.isStuckTicks > tickInterval) then
        PZNS_NPCSpeak(npcSurvivor, "I was stuck...", "InfoOnly");
        PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor);
        npcSurvivor.currentAction = "";
        npcSurvivor.isStuckTicks = 0;
    else
        npcSurvivor.isStuckTicks = npcSurvivor.isStuckTicks + 1;
    end
    -- PZNS_NPCSpeak(npcSurvivor, "isStuckTicks: " .. tostring(npcSurvivor.isStuckTicks), "InfoOnly");
end

--- Cows: This is to streamline the multiple npcIsoPlayerObject checks...
function PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor)
    if (npcSurvivor == nil) then
        return false;
    end
    if (npcSurvivor.isSpawned ~= true) then
        return false;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if (npcIsoPlayer == nil) then
        return false;
    end
    if (npcIsoPlayer:isAlive() ~= true) then
        return false;
    end
    return true;
end

--- Cows: This is to streamline complete random rolls of stats for NPCs.
function PZNS_UtilsNPCs.PZNS_SetNPCPerksRandomly(npcSurvivor)
    local from1to10 = function() return ZombRand(1, 10); end;
    local from1to7 = function() return ZombRand(1, 7); end;
    local from0to3 = function() return ZombRand(0, 3); end;
    -- WIP - Cows: There seems to be a conflict with 'More Traits'... unsure which perk is affecting it at the moment.
    PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Strength", from1to7());
    PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Fitness", from1to7());
    -- PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Sprinting", from0to3());
    -- PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Lightfoot", from0to3());
    -- PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Nimble", from1to7());
    PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Sneak", from1to7());
    PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Axe", from0to3());
    PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Blunt", from1to7());
    PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "SmallBlunt", from1to7());
    PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "LongBlade", from0to3());
    PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "SmallBlade", from0to3());
    PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Spear", from0to3());
    -- PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Maintenance", from0to3());
    PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Woodwork", from0to3());
    PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Cooking", from0to3());
    PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Farming", from0to3());
    PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Doctor", from0to3());
    PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Electricity", from0to3());
    PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "MetalWelding", from0to3());
    PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Mechanics", from0to3());
    PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Tailoring", from0to3());
    PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Aiming", from0to3());
    PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Reloading", from0to3());
    -- PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Fishing", from0to3());
    -- PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Trapping", from0to3());
    -- PZNS_UtilsNPCs.PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "PlantScavenging", from0to3());
end

--- Cows: This is to streamline complete random rolls of stats for NPCs.
function PZNS_UtilsNPCs.PZNS_SetLoadedGun(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid == false) then
        return;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    ---@type HandWeapon
    local npcHandItem = npcIsoPlayer:getPrimaryHandItem();
    if (npcHandItem == nil) then
        return;
    end
    if (npcHandItem:IsWeapon() == true and npcHandItem:isRanged() == true) then
        local ammoType = npcHandItem:getAmmoType();
        local magazineType = npcHandItem:getMagazineType();
        if (magazineType) then
            npcHandItem:setContainsClip(true);
        end
        if (ammoType) then
            if (npcHandItem:getCurrentAmmoCount() == 0) then
                npcHandItem:setCurrentAmmoCount(npcHandItem:getMaxAmmo());
            end
        end
        if npcHandItem:haveChamber() then
            npcHandItem:setRoundChambered(true);
        end
    end
end

return PZNS_UtilsNPCs;
