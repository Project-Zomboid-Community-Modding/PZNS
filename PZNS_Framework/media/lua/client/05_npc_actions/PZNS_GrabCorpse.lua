local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");

--- WIP - Cows: Errors are throw while grabbing a corpse, seems related to forced Equip/Unequip weapons when a heavy object is carried...
---@param npcSurvivor any
---@param targetBody any
function PZNS_GrabCorpse(npcSurvivor, targetBody)
    --
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false or targetBody == nil) then
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
