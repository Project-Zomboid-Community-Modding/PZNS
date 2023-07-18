local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");

--- Cows: Eject clip/magazine from gun.
---@param npcSurvivor any
function PZNS_GunMagazineEject(npcSurvivor)
    if (npcSurvivor == nil) then
        return;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    ---@type HandWeapon
    local npcHandItem = npcIsoPlayer:getPrimaryHandItem();
    --
    if (npcHandItem ~= nil) then
        if (npcHandItem:IsWeapon() == true and npcHandItem:isRanged() == true) then
            if (npcHandItem:isContainsClip()) then
                -- Cows: This is a modified copy from 'ISReloadWeaponAction.BeginAutomaticReload'
                local ejectAction = ISEjectMagazine:new(npcIsoPlayer, npcHandItem);
                PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, ejectAction);
                return ejectAction;
            end
        end
    end
end

--- Cows: Reload by inserting ammo into clip/magazine.
---@param npcSurvivor any
function PZNS_GunMagazineReload(npcSurvivor)
    if (npcSurvivor == nil) then
        return;
    end
    --
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    ---@type HandWeapon
    local npcHandItem = npcIsoPlayer:getPrimaryHandItem();
    local bullets = 0;
    local count = 0;
    --
    if (npcHandItem:IsWeapon() == true and npcHandItem:isRanged() == true) then
        local npc_inventory = npcIsoPlayer:getInventory();
        local magazine = npc_inventory:getFirstTypeRecurse(npcHandItem:getMagazineType());
        local ammoType = npcHandItem:getAmmoType();
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
            local reloadAction = ISLoadBulletsInMagazine:new(npcIsoPlayer, magazine, count);
            PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, reloadAction);
            return reloadAction;
        end
    end
end

--- Cows: Insert clip/magazine into gun.
---@param npcSurvivor any
function PZNS_GunMagazineInsert(npcSurvivor)
    if (npcSurvivor == nil) then
        return;
    end
    --
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local npcHandItem = npcIsoPlayer:getPrimaryHandItem();
    -- Cows: This function looks for the magazine with the most ammo in it and inserts it into the current gun.
    if (npcHandItem:IsWeapon() == true and npcHandItem:isRanged() == true) then
        local magazine = npcHandItem:getBestMagazine(npcIsoPlayer);
        if (magazine) then
            local insertAction = ISInsertMagazine:new(npcIsoPlayer, npcHandItem, magazine);
            PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, insertAction);
            return insertAction;
        end
    end
end
