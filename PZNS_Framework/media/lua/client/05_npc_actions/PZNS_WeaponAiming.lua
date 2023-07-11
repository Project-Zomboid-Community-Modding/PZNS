local PZNS_CombatUtils = require("02_mod_utils/PZNS_CombatUtils");
local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");

local spottingRange = 30; -- Cows: Perhaps a user option in the future...

---comment
---@param npcSurvivor any
function PZNS_WeaponAiming(npcSurvivor)
    --
    if (npcSurvivor == nil) then
        return;
    end
    --
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local targetObject = npcSurvivor.aimTarget;
    --
    if (targetObject ~= nil) then
        -- Cows: Check if the entity the NPC is aiming at exists
        if (PZNS_CombatUtils.PZNS_IsTargetInvalidForDamage(targetObject) == true) then
            npcIsoPlayer:NPCSetAiming(false);
            return;
        else
            -- Cows: Need to add a "Vision" check for hostiles before aiming...
            local distanceFromTarget = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(npcIsoPlayer, targetObject);
            local canSeeTarget = npcIsoPlayer:CanSee(targetObject); -- Cows: "vision cone" isn't a thing for NPCs... they can "see" the world objects without facing them.
            local isTargetAlive = targetObject:isAlive();
            local isTargetInSpottingRange = distanceFromTarget < spottingRange;
            --
            local aimRange = npcIsoPlayer:getPrimaryHandItem():getMaxRange();
            local isTargetInAimRange = distanceFromTarget < aimRange;
            --
            if (
                    isTargetAlive == true
                    and canSeeTarget == true
                    and isTargetInSpottingRange == true
                )
            then
                npcIsoPlayer:faceThisObject(targetObject);
                --
                if (isTargetInAimRange == true) then
                    npcIsoPlayer:NPCSetAiming(true);
                else
                    npcIsoPlayer:NPCSetAiming(false);
                end
            else
                npcSurvivor.aimTarget = nil;
                npcIsoPlayer:NPCSetAiming(false);
            end
        end
    end
end
