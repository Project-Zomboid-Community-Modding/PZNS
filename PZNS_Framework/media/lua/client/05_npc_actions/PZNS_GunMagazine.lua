local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");

--- Cows: Eject clip/magazine from gun.
---@param npcSurvivor any
function PZNS_GunMagazineEject(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    ---@type HandWeapon
    local npcHandItem = npcIsoPlayer:getPrimaryHandItem();
    --
    if (npcHandItem == nil) then
        return;
    end
    if (npcHandItem:IsWeapon() == true and npcHandItem:isRanged() == true) then
        if (npcHandItem:isContainsClip()) then
            -- Cows: This is a modified copy from 'ISReloadWeaponAction.BeginAutomaticReload'
            local ejectMagAction = ISEjectMagazine:new(npcIsoPlayer, npcHandItem);
            PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, ejectMagAction);
            return ejectMagAction;
        end
    end
end

--- Cows: Reload by inserting ammo into clip/magazine.
---@param npcSurvivor any
function PZNS_GunMagazineReload(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    --
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    ---@type HandWeapon
    local npcHandItem = npcIsoPlayer:getPrimaryHandItem();
    if (npcHandItem == nil) then
        return;
    end
    --
    if (npcHandItem:IsWeapon() == true and npcHandItem:isRanged() == true) then
        local npc_inventory = npcIsoPlayer:getInventory();
        local magazine = npc_inventory:getFirstTypeRecurse(npcHandItem:getMagazineType());
        local ammoType = npcHandItem:getAmmoType();
        local bullets = 0;
        local count = 0;
        --
        if ammoType then
            bullets = npc_inventory:getItemCountRecurse(ammoType);
        end
        --
        if (bullets % npcHandItem:getMaxAmmo() == 0) then
            count = npcHandItem:getMaxAmmo();
            bullets = bullets - npcHandItem:getMaxAmmo();
        else
            count = bullets;
        end
        --
        if (magazine) then
            local reloadMagAction = ISLoadBulletsInMagazine:new(npcIsoPlayer, magazine, count);
            PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, reloadMagAction);
            return reloadMagAction;
        end
    end
end

--- Cows: Insert clip/magazine into gun.
---@param npcSurvivor any
function PZNS_GunMagazineInsert(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    --
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local npcHandItem = npcIsoPlayer:getPrimaryHandItem();
    if (npcHandItem == nil) then
        return;
    end
    -- Cows: This function looks for the magazine with the most ammo in it and inserts it into the current gun.
    if (npcHandItem:IsWeapon() == true and npcHandItem:isRanged() == true) then
        local magazine = npcHandItem:getBestMagazine(npcIsoPlayer);
        if (magazine) then
            local insertMagAction = ISInsertMagazine:new(npcIsoPlayer, npcHandItem, magazine);
            PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, insertMagAction);
            return insertMagAction;
        end
    end
end
