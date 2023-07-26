---comment
---@param npcSurvivor any
---@param targetID any
function PZNS_Follow(npcSurvivor, targetID)
    --
    if (npcSurvivor == nil) then
        return;
    end
    --
    npcSurvivor.isHoldingInPlace = false;
    npcSurvivor.jobName = "Companion";
    npcSurvivor.followTargetID = targetID;
    npcSurvivor.jobSquare = nil;
end
