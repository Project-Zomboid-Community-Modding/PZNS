local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");

---Cows: npcSurvivor needs to move to square then drop the item.
---@param npcSurvivor any
---@param square IsoGridSquare
---@param itemToDrop IsoObject
function PZNS_MoveToDropItem(npcSurvivor, square, itemToDrop)
    if (npcSurvivor == nil or square == nil) then
        return;
    end
    --
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local distanceFromDropoff = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(npcIsoPlayer, square);
    local squareX, squareY, squareZ = square:getX(), square:getY(), square:getZ();
    -- Cows: Make sure the NPC drop off is INSIDE the square, otherwise it will pickup the item right outside the destination square.
    if (distanceFromDropoff <= 0.75) then
        PZNS_UtilsNPCs.PZNS_StuckNPCCheck(npcSurvivor);
        --
        if (npcSurvivor.currentAction ~= "DropItem") then
            PZNS_DropItem(npcSurvivor, itemToDrop);
            npcSurvivor.currentAction = "DropItem";
        end
    else
        npcSurvivor.currentAction = "Walking";
        PZNS_WalkToSquareXYZ(npcSurvivor, squareX, squareY, squareZ);
    end
end
