local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");
--[[
    Cows: This file is intended for "general" purpose AI that is applicable to all jobs and job routines.
    Basic Aim & Attack
    Washing Clothes
    Bandaging
--]]

local PZNS_GeneralAI = {};

---comment
---@param npcSurvivor any
---@return boolean
function PZNS_GeneralAI.PZNS_IsReloadNeeded(npcSurvivor)
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    -- Cows: Can only if npcSurvivor is Alive.
    if (npcIsoPlayer:isAlive() == true) then
        local npc_inventory = npcIsoPlayer:getInventory();
        ---@type HandWeapon
        local npcHandItem = npcIsoPlayer:getPrimaryHandItem();
        local ammoType = npcHandItem:getAmmoType();
        local ammoCount = 0;
        -- Cows: No Item in hand, no reload needed
        if (npcHandItem == nil) then
            return false;
        end
        -- Cows: Ranged weapon
        if (npcHandItem:IsWeapon() == true and npcHandItem:isRanged() == true) then

            ammoCount = npc_inventory:getItemCountRecurse(ammoType);
            -- Cows: Check if the gun has no ammo and there are ammo in the backpack.
            if (npcHandItem:getCurrentAmmoCount() == 0 and ammoCount > 0) then
                local actionQueue = ISTimedActionQueue.getTimedActionQueue(npcIsoPlayer);
                local lastAction = actionQueue.queue[#actionQueue.queue];
                -- Cows: Look at 'ISGrabItemAction:checkQueueList()' in the vanilla TIS code as example reference.
                if (lastAction) then
                    -- Cows: Only accept gun-related actions, need to clear the action queue to begin the reload sequence.
                    if (lastAction.Type ~= "ISEjectMagazine"
                            and lastAction.Type ~= "ISLoadBulletsInMagazine"
                            and lastAction.Type ~= "ISInsertMagazine"
                            and lastAction.Type ~= "ISRackFirearm"
                            and lastAction.Type ~= "ISReloadWeaponAction"
                        ) then
                        PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor);
                    end
                end

                if (npcIsoPlayer:NPCGetAiming() == true) then
                    npcIsoPlayer:NPCSetAiming(false);
                end
                if (npcIsoPlayer:isAttacking() == true) then
                    npcIsoPlayer:NPCSetAttack(false);
                end
                return true;
            end
        end
    end
    return false;
end

---comment
---@param npcSurvivor any
---@return boolean
function PZNS_GeneralAI.PZNS_CanSeeAimTarget(npcSurvivor)
    --
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if (npcIsoPlayer) then
        -- Cows: Can only see if npcSurvivor is Alive.
        if (npcIsoPlayer:isAlive() == true) then
            --
            if (PZNS_WorldUtils.PZNS_IsObjectZombieActive(npcSurvivor.aimTarget) == true) then
                local canSeeTarget = npcIsoPlayer:CanSee(npcSurvivor.aimTarget); -- Cows: "vision cone" isn't a thing for NPCs... they can "see" the world objects without facing them.
                return canSeeTarget;
            end
        end
    end
    npcSurvivor.aimTarget = nil;
    return false;
end

--- Cows: Have the NPC aim and attack their aimed target.
---@param npcSurvivor any
function PZNS_GeneralAI.PZNS_NPCAimAttack(npcSurvivor)
    ---@type IsoPlayer
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if (npcIsoPlayer) then
        -- Cows: Can only aim and/or attack if npcSurvivor is Alive.
        if (npcIsoPlayer:isAlive() == true) then
            if (npcSurvivor.aimTarget ~= nil) then
                PZNS_WeaponAiming(npcSurvivor); -- Cows: Aim before attacking
                PZNS_WeaponAttack(npcSurvivor); -- Cows: Permission to attack is handled in the function.
            end
        end
    end
end

--- Cows: This function forces the npcSurvivor to look for threats nearby.
---@param npcSurvivor any
---@return boolean
function PZNS_GeneralAI.PZNS_NPCFoundThreat(npcSurvivor)
    -- Cows: Check if threat is in sight.
    local isThreatInSight = PZNS_GeneralAI.PZNS_CanSeeAimTarget(npcSurvivor);
    -- Cows: check if any threats are found.
    if (isThreatInSight == true) then
        return true;
    end
    -- Cows: Check for other threats
    local isThreatFound = PZNS_CheckZombieThreat(npcSurvivor);
    -- Cows: check if any threats are found.
    if (isThreatFound == true) then
        return true;
    end
    return false;
end

--- Cows: This should unify the combat AI code...
---@param npcSurvivor any
---@return boolean
function PZNS_GeneralAI.PZNS_IsNPCBusyCombat(npcSurvivor)
    -- Cows: action ticks can go over 200 if the reload action was interrupted midway.
    if (npcSurvivor.actionTicks > 200) then
        npcSurvivor.actionTicks = 0;
    end
    --
    local isReloadNeeded = PZNS_GeneralAI.PZNS_IsReloadNeeded(npcSurvivor);
    if (isReloadNeeded == true) then
        -- Cows: only do a "full" reload every 100 - 150 ticks or so, otherwise it will be spammed and cause the NPC to become stuck due to animations.
        local ticksCheck = ZombRand(100, 150);
        if (npcSurvivor.actionTicks == ticksCheck) then
            PZNS_WeaponReload(npcSurvivor);
            npcSurvivor.actionTicks = 0;
        else
            npcSurvivor.actionTicks = npcSurvivor.actionTicks + 1;
        end
        return true; -- Cows: Stop processing and start reloading.
    end
    --
    local isThreatFound = PZNS_GeneralAI.PZNS_NPCFoundThreat(npcSurvivor);
    if (isThreatFound == true) then
        PZNS_GeneralAI.PZNS_NPCAimAttack(npcSurvivor);
        return true; -- Cows: Stop processing and start attacking.
    end

    return false;
end

return PZNS_GeneralAI;
