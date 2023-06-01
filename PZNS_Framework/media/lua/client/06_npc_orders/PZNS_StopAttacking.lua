---comment
---@param npcSurvivor any
function PZNS_StopAttacking(npcSurvivor)
    --
    if (npcSurvivor == nil) then
        return;
    end
    --
    npcSurvivor.canAttack = false;
end
