local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");

--- Cows: Have the specified NPC move to the square specified by xyz coordinates.
---@param npcSurvivor any
---@param squareX any
---@param squareY any
---@param squareZ any
function PZNS_WalkToSquareXYZ(npcSurvivor, squareX, squareY, squareZ)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local targetSquare = getCell():getGridSquare(
        squareX, -- GridSquareX
        squareY, -- GridSquareY
        squareZ  -- Floor level
    );

	if targetSquare ~= nil then
		npcIsoPlayer:NPCSetRunning(false);
		local walkAction = ISWalkToTimedAction:new(npcIsoPlayer, targetSquare);
		PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, walkAction);
	end
end
