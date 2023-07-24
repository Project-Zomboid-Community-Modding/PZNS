local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");

---comment
---@param npcSurvivor any
---@param targetItem any
function PZNS_DropItem(npcSurvivor, targetItem)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    --
    if (targetItem == nil) then
        return;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local dropAction =
        ISDropItemAction:new(
            npcIsoPlayer,
            targetItem,
            50 -- Cows: This seems to be a delay for animation?
        );
    PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, dropAction);
end
