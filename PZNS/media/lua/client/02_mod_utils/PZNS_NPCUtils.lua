--- Cows: Placeholder: Apparently, all the IDs in PZ Java are numbers only... So this function is to ensure a set number of IDs are reserved.
--- Cows: Probably unnecessary if the mod uses it own ID tables...
---@param inputNumber number
---@param reserverNumber number
---@return boolean
function PZNS_IsSurvivorIDReserved(inputNumber, reserverNumber)
    if (inputNumber <= reserverNumber) then
        return true;
    end
    return false;
end

--- Cows: Add a specified trait to the target npcSurvivor.
---@param npcSurvivor any
---@param traitName string
---@return any
function PZNS_AddNPCSurvivorTraits(npcSurvivor, traitName)
    if (npcSurvivor.npcIsoPlayerObject == nil) then
        return;
    end
    npcSurvivor.npcIsoPlayerObject:getTraits():add(traitName);
    return npcSurvivor;
end

--- Cows: Set the target npcSurvivor's specified perk to the specified levels.
--- Cows: Setting the perk level is faster than adding perk levels.
---@param npcSurvivor any
---@param perkName string
---@param levels number
---@return any
function PZNS_SetNPCSurvivorPerkLevel(npcSurvivor, perkName, levels)
    if (npcSurvivor.npcIsoPlayerObject == nil) then
        return;
    end
    -- Verify the perk exists and set its level to the levels number input.
    if (PerkFactory.getPerkFromName(perkName)) then
        npcSurvivor.npcIsoPlayerObject:setPerkLevelDebug(Perks.FromString(perkName), levels);
    end

    return npcSurvivor;
end

--- Cows: Level the target npcSurvivor's specified perk by the specified levels.
---@param npcSurvivor any
---@param perkName string
---@param levels number
---@return any
function PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, perkName, levels)
    if (npcSurvivor.npcIsoPlayerObject == nil) then
        return;
    end
    -- Verify the perk exists and level it based on the levels number input.
    if (PerkFactory.getPerkFromName(perkName)) then
        for i = 1, levels do
            npcSurvivor.npcIsoPlayerObject:LevelPerk(Perks.FromString(perkName));
        end
    end

    return npcSurvivor;
end

--- Cows: Level the target npcSurvivor's specified perk by the specified levels.
---@param npcSurvivor any
---@param perkName string
---@return any
function PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, perkName)
    if (npcSurvivor.npcIsoPlayerObject == nil) then
        return;
    end
    -- Verify the perk exists and level it based on the levels number input.
    if (PerkFactory.getPerkFromName(perkName)) then
        return npcSurvivor.npcIsoPlayerObject:getPerkLevel(Perks.FromString(perkName));
    end

    return 0;
end

--- Cows: Simple code to add item to npcSurvivor inventory.
---@param npcSurvivor any
---@param itemID string
function PZNS_AddItemToNPCSurvivor(npcSurvivor, itemID)
    if (npcSurvivor.npcIsoPlayerObject == nil) then
        return;
    end
    local item = instanceItem(itemID);
    --
    if (item ~= nil) then
        npcSurvivor.npcIsoPlayerObject:getInventory():AddItem(item);
    end
end

--- Cows: Simple code to remove item to npcSurvivor inventory.
---@param npcSurvivor any
---@param item Item
function PZNS_RemoveItemFromInventoryNPCSurvivor(npcSurvivor, item)
    if (npcSurvivor.npcIsoPlayerObject == nil) then
        return;
    end
    -- WIP - Cows: Need to specify the amount? Item ID?
    npcSurvivor.npcIsoPlayerObject:getInventory():removeItemWithID(item);
end

--- Cows: Simple code to add clothingItem to npcSurvivor inventory and wear it.
---@param npcSurvivor any
---@param clothingID string
function PZNS_AddEquipClothingNPCSurvivor(npcSurvivor, clothingID)
    if (npcSurvivor.npcIsoPlayerObject == nil) then
        return;
    end
    local clothingItem = instanceItem(clothingID);
    --
    if (clothingItem ~= nil) then
        npcSurvivor.npcIsoPlayerObject:getInventory():AddItem(clothingItem);
        local bodyPartLocation = clothingItem:getBodyLocation();
        --
        if (bodyPartLocation ~= nil) then
            npcSurvivor.npcIsoPlayerObject:setWornItem(bodyPartLocation, clothingItem);
        end
    end
end

--- Cows: Simple code to add weaponItem to npcSurvivor inventory and equip it.
---@param npcSurvivor any
---@param weaponID string
function PZNS_AddEquipWeaponNPCSurvivor(npcSurvivor, weaponID)
    if (npcSurvivor.npcIsoPlayerObject == nil) then
        return;
    end
    local weaponItem = instanceItem(weaponID);
    --
    if (weaponItem ~= nil) then
        npcSurvivor.npcIsoPlayerObject:getInventory():AddItem(weaponItem);
        npcSurvivor.npcIsoPlayerObject:setPrimaryHandItem(weaponItem);

        if (weaponItem:isRequiresEquippedBothHands() or weaponItem:isTwoHandWeapon()) then
            npcSurvivor.npcIsoPlayerObject:setSecondaryHandItem(weaponItem);
        end
    end
end
