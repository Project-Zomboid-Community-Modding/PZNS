local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
---comment
---@param npcSurvivor any
function PZNS_WeaponReload(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    ---@type IsoPlayer
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local npcHandItem = npcIsoPlayer:getPrimaryHandItem();
    if (npcHandItem == nil) then
        return;
    end
    --
    npcIsoPlayer:NPCSetAttack(false);
    if (npcIsoPlayer:NPCGetAiming() == true) then
        npcIsoPlayer:NPCSetAiming(false);
    end
    local actionsCount = PZNS_UtilsNPCs.PZNS_GetNPCActionsQueuedCount(npcSurvivor);
    local actionQueue = ISTimedActionQueue.getTimedActionQueue(npcIsoPlayer);
    local lastAction = actionQueue.queue[#actionQueue.queue];
    -- Cows: Magazine based reload
    local magazineType = npcHandItem:getMagazineType();
    if (magazineType ~= nil) then
        -- Cows: If there are more than 3 actions queued, reset the queue so the NPC can start reloading right away.
        if (actionsCount > 3) then
            PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor);
        end

        local npc_inventory = npcIsoPlayer:getInventory();
        local bestMagazine = npcHandItem:getBestMagazine(npcIsoPlayer);
        local magazine = npc_inventory:getFirstTypeRecurse(npcHandItem:getMagazineType());
        local weaponAmmoType = npcHandItem:getAmmoType();
        --
        if (bestMagazine) then
            if (lastAction) then
                -- Cows: If the last action wasn't ISLoadBulletsInMagazine and there is more than 1 action, clear the queue right away and load the best magazine.
                if (lastAction.Type ~= "ISLoadBulletsInMagazine" and actionsCount > 1) then
                    PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor);
                end
            end
            if (IsInfiniteAmmoActive == true and npcHandItem:getCurrentAmmoCount() == 0) then
                PZNS_UtilsNPCs.PZNS_AddItemsToInventoryNPCSurvivor(npcSurvivor, weaponAmmoType, npcHandItem:getMaxAmmo());
            end
            -- PZNS_NPCSpeak(npcSurvivor, "Reloading... Inserting Mag into Gun");
            PZNS_GunMagazineInsert(npcSurvivor);
        else
            if (npcHandItem:isContainsClip()) then
                -- PZNS_NPCSpeak(npcSurvivor, "Reloading... Ejecting Mag");
                PZNS_GunMagazineEject(npcSurvivor);
            end
            if (magazine) then
                -- PZNS_NPCSpeak(npcSurvivor, "Reloading... Inserting Ammo into Mag");
                PZNS_GunMagazineReload(npcSurvivor);
            end
        end
        -- End Magazine based reload
    else
        if (IsInfiniteAmmoActive == true and npcHandItem:getCurrentAmmoCount() == 0) then
            PZNS_UtilsNPCs.PZNS_AddItemsToInventoryNPCSurvivor(npcSurvivor, weaponAmmoType, npcHandItem:getMaxAmmo());
        end
        -- Cows: Testing this out, but ISReloadWeaponAction seems to have worked for SS/SSC...
        ISTimedActionQueue.add(ISReloadWeaponAction:new(npcIsoPlayer, npcHandItem));
    end
end
