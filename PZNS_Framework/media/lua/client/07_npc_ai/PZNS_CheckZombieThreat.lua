local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");

local spottingRange = 30; -- Cows: Perhaps a user option in the future...

--[[
    -- WIP -
    Cows: Perhaps it would be better to load the zombies squares in the same cell update their locations?
    Distance calculation should be much quicker than scanning 30x30 squares.
]]
---comment
function PZNS_CheckZombieThreat(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    local isThreatExist = false;
    local targetThreatDistance = 30;
    local targetThreatObject = npcSurvivor.aimTarget;
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    -- Cows: Check if npcSurvivor currently has an aimed zombie
    if (targetThreatObject ~= nil) then
        --
        if (PZNS_WorldUtils.PZNS_IsObjectZombieActive(targetThreatObject) == true) then
            --
            local canSeeTarget = npcIsoPlayer:CanSee(targetThreatObject);
            local isOnSameFloorLevel = targetThreatObject:getZ() == npcIsoPlayer:getZ();
            targetThreatDistance = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(npcIsoPlayer, targetThreatObject);
            -- Cows: Stop if the nearest threat is less than 3 squares away... need to prepare to run or attack.
            if (canSeeTarget == true and targetThreatDistance < 3 and isOnSameFloorLevel == true) then
                PZNS_AimAtTarget(npcSurvivor, targetThreatObject);
                return true;
            end
        else
            targetThreatObject = nil;
        end
    end
    --
    local npcWeapon = npcIsoPlayer:getPrimaryHandItem();
    local aimRange = 2;
    -- Cows: Check if npcWeapon is a weapon
    if (npcWeapon ~= nil) then
        if (npcWeapon:IsWeapon() == true) then
            aimRange = npcWeapon:getMaxRange();
        end
    end
    --
    if (PZNS_CellZombiesList == nil) then
        return isThreatExist;
    end
    --
    for i = PZNS_CellZombiesList:size() - 1, 0, -1 do
        local zombie = PZNS_CellZombiesList:get(i);
        --
        if (PZNS_WorldUtils.PZNS_IsObjectZombieActive(zombie) == true) then
            --
            local currentThreatDistance = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(npcIsoPlayer, zombie);
            local isOnSameFloorLevel = zombie:getZ() == npcIsoPlayer:getZ();
            local isTargetInAimRange = currentThreatDistance < aimRange;
            local canSeeTarget = npcIsoPlayer:CanSee(zombie);     -- Cows: "vision cone" isn't a thing for NPCs... they can "see" the world objects without facing them.
            --
            if (canSeeTarget == true and currentThreatDistance < spottingRange) then
                isThreatExist = true;
                --
                if (isTargetInAimRange == true) then
                    --
                    if (targetThreatDistance > currentThreatDistance and isOnSameFloorLevel == true) then
                        targetThreatDistance = currentThreatDistance;
                        targetThreatObject = zombie;
                        -- PZNS_NPCSpeak(npcSurvivor, "Threat Aimed");
                    end
                    --
                    if (targetThreatDistance < 3) then
                        break;
                    end
                end
            end
        end
    end
    PZNS_AimAtTarget(npcSurvivor, targetThreatObject);
    return isThreatExist;
end
