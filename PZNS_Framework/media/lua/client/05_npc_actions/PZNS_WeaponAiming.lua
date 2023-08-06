local PZNS_CombatUtils = require("02_mod_utils/PZNS_CombatUtils");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");

local spottingRange = 30; -- Cows: Perhaps a user option in the future...

---comment
---@param npcSurvivor any
function PZNS_WeaponAiming(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    --
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    -- Cows: Check if the NPC has an item in hand
    local npcWeapon = npcIsoPlayer:getPrimaryHandItem();
    if (npcWeapon == nil) then
        if (npcIsoPlayer:NPCGetAiming() == true) then
            npcIsoPlayer:NPCSetAiming(false);
        end
        return;
    end
    if (npcWeapon:IsWeapon() ~= true) then
        if (npcIsoPlayer:NPCGetAiming() == true) then
            npcIsoPlayer:NPCSetAiming(false);
        end
        return;
    end
    -- Cows: Check if the entity the NPC is aiming at exists
    local targetObject = npcSurvivor.aimTarget;
    if (targetObject == nil) then
        if (npcIsoPlayer:NPCGetAiming() == true) then
            npcIsoPlayer:NPCSetAiming(false);
        end
        return;
    end
    -- Cows: Check if the target is valid to be damaged.
    if (PZNS_CombatUtils.PZNS_IsTargetInvalidForDamage(targetObject) == true) then
        if (npcIsoPlayer:NPCGetAiming() == true) then
            npcIsoPlayer:NPCSetAiming(false);
        end
        return;
    end
    -- Cows: Get all check values for the NPC before said NPC can aim.
    local distanceFromTarget = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(npcIsoPlayer, targetObject);
    local canSeeTarget = npcIsoPlayer:CanSee(targetObject); -- Cows: "vision cone" isn't a thing for NPCs... they can "see" the world objects without facing them.
    local isTargetAlive = targetObject:isAlive();
    local isTargetInSpottingRange = distanceFromTarget < spottingRange;
    local aimRange = npcWeapon:getMaxRange();
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
            return;
        end
    end
    npcSurvivor.aimTarget = nil;
    if (npcIsoPlayer:NPCGetAiming() == true) then
        npcIsoPlayer:NPCSetAiming(false);
    end
end
