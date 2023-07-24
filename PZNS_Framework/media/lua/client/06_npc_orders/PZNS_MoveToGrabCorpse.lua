local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");

---Cows: npcSurvivor needs to move to square then pick up the deadBody.
---@param npcSurvivor any
---@param square IsoGridSquare
---@param deadBody IsoDeadBody
function PZNS_MoveToGrabCorpse(npcSurvivor, square, deadBody)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false or square == nil) then
        return;
    end
    --
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local distanceFromPickup = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(npcIsoPlayer, square);
    local squareX, squareY, squareZ = square:getX(), square:getY(), square:getZ();
    --
    if (distanceFromPickup <= 1) then
        PZNS_UtilsNPCs.PZNS_StuckNPCCheck(npcSurvivor);
        --
        if (npcSurvivor.currentAction ~= "GrabCorpse") then
            PZNS_GrabCorpse(npcSurvivor, deadBody);
            npcSurvivor.currentAction = "GrabCorpse";
        end
    else
        npcSurvivor.currentAction = "Walking";
        PZNS_WalkToSquareXYZ(npcSurvivor, squareX, squareY, squareZ);
    end
end
