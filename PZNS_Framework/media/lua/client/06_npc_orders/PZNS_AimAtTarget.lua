---comment
---@param npcSurvivor any
---@param targetIsoObject any
function PZNS_AimAtTarget(npcSurvivor, targetIsoObject)
    --
    if (npcSurvivor == nil) then
        return;
    end
    npcSurvivor.aimTarget = targetIsoObject;
end
