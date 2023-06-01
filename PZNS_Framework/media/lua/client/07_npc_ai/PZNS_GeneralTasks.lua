local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");
--[[
    Cows: This file is intended for "general" purpose AI that is applicable to all jobs and job routines.
    Basic Aim & Attack
    Washing Clothes
    Bandaging
--]]

function PZNS_CanSeeAimTarget(npcSurvivor)
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
function PZNS_NPCAimAttack(npcSurvivor)
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
