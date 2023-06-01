local PZNS_NPCsManager = require("04_data_management/PZNS_NPCsManager");

---comment
---@param npcSurvivor any
---@param targetID any
function PZNS_AimAtPlayer(npcSurvivor, targetID)
    --
    if (npcSurvivor == nil) then
        return;
    end
    local targetIsoPlayer;
    --
    if (targetID == "Player0") then
        targetIsoPlayer = getSpecificPlayer(0);
    else
        local targetNPC = PZNS_NPCsManager.getActiveNPCBySurvivorID(targetID);
        targetIsoPlayer = targetNPC.npcIsoPlayerObject;
    end
    --
    npcSurvivor.aimTarget = targetIsoPlayer;
    npcSurvivor.isHoldingInPlace = true; -- WIP - Cows: Currently not possible for NPCs to aim while moving.
end
