local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");
--[[
    Cows: This file is intended for "general" purpose AI that is applicable to all jobs and job routines.
    Basic Aim & Attack
    Washing Clothes
    Bandaging
--]]

local PZNS_GeneralAI = {};

function PZNS_GeneralAI.PZNS_CanSeeAimTarget(npcSurvivor)
    --
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    -- Cows: Can only see if npcSurvivor is Alive.
    if (npcIsoPlayer:isAlive() == true) then
        --
        if (PZNS_WorldUtils.PZNS_IsObjectZombieActive(npcSurvivor.aimTarget) == true) then
            local canSeeTarget = npcIsoPlayer:CanSee(npcSurvivor.aimTarget); -- Cows: "vision cone" isn't a thing for NPCs... they can "see" the world objects without facing them.
            return canSeeTarget;
        end
    end
    npcSurvivor.aimTarget = nil;
    return false;
end

--- Cows: Have the NPC aim and attack their aimed target.
---@param npcSurvivor any
function PZNS_GeneralAI.PZNS_NPCAimAttack(npcSurvivor)
    --
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    -- Cows: Can only aim and/or attack if npcSurvivor is Alive.
    if (npcIsoPlayer:isAlive() == true) then
        if (npcSurvivor.aimTarget ~= nil) then
            PZNS_WeaponAiming(npcSurvivor); -- Cows: Aim before attacking
            PZNS_WeaponAttack(npcSurvivor); -- Cows: Permission to attack is handled in the function.
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

return PZNS_GeneralAI;