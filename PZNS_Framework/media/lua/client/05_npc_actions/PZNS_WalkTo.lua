local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");

---comment
---@param npcSurvivor any
---@param squareX any
---@param squareY any
---@param squareZ any
function PZNS_WalkToSquareXYZ(npcSurvivor, squareX, squareY, squareZ)
    if (npcSurvivor == nil) then
        return nil;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local targetSquare = getCell():getGridSquare(
        squareX, -- GridSquareX
        squareY, -- GridSquareY
        squareZ  -- Floor level
    );

    npcIsoPlayer:NPCSetRunning(false);
    local walkAction = ISWalkToTimedAction:new(npcIsoPlayer, targetSquare);
    PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, walkAction);
end
