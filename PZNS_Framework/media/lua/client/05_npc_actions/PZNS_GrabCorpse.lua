local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");

---comment
---@param npcSurvivor any
---@param targetBody any
function PZNS_GrabCorpse(npcSurvivor, targetBody)
    --
    if (npcSurvivor == nil or targetBody == nil) then
        return;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local grabAction =
        ISGrabCorpseAction:new(
            npcIsoPlayer,
            targetBody,
            50 -- Cows: This seems to be a delay for animation?
        );
    PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, grabAction);
end
