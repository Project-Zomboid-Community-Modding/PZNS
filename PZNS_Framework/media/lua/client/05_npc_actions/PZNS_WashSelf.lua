local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");

---comment
---@param npcSurvivor any
---@param targetItem IsoObject
---@param soapList any
function PZNS_WashSelf(npcSurvivor, targetItem, soapList)
    if (npcSurvivor == nil) then
        return;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local washAction = ISWashYourself:new(npcIsoPlayer, targetItem, soapList);

    PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, washAction);
end
