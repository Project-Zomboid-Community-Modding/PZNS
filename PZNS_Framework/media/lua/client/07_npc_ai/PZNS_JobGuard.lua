local followRange = 3;
local runRange = 5;
local idleActionOnTick = 200;

---comment
---@param npcSurvivor any
function PZNS_JobGuard(npcSurvivor)
    if (npcSurvivor == nil) then
        return nil;
    end

    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local isThreatInSight = PZNS_CanSeeAimTarget(npcSurvivor);
    --
    if (isThreatInSight == true) then
        npcSurvivor.idleTicks = 0;
        PZNS_NPCAimAttack(npcSurvivor);
        return; -- Cows: Stop processing and start attacking.
    end
    local isThreatFound = PZNS_CheckZombieThreat(npcSurvivor);
    --
    if (isThreatFound == true) then
        npcSurvivor.idleTicks = 0;
        PZNS_NPCAimAttack(npcSurvivor);
        return; -- Cows: Stop processing and start attacking.
    end
    -- Cows: Have the guard patrol the paremeter of the ZoneHome if it exists.
    if (npcSurvivor.isHoldingInPlace ~= true) then
    end
    -- Cows: Else have the guard simply hold position where ever it is.
end
