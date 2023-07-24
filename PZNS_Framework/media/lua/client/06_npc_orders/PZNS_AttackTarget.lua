---comment
---@param npcSurvivor any
function PZNS_AttackTarget(npcSurvivor)
    --
    if (npcSurvivor == nil) then
        return;
    end
    npcSurvivor.canAttack = true;
end
