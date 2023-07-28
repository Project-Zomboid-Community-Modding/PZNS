local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");
local PZNS_GeneralAI = require("07_npc_ai/PZNS_GeneralAI");

--[[
    - WIP - Cows: "Wandering" can be unpredictable and without destination nor end goal... so my intent is to categorize the "wandering" into limited or specified areas to limit potential issues.
--]]

--- Cows: This "Job" has the NPC move around inside the current building it is in.
---@param npcSurvivor any
function PZNS_JobWanderInBuilding(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    if (PZNS_GeneralAI.PZNS_IsNPCBusyCombat(npcSurvivor) == true) then
        return; -- Cows Stop Processing and let the NPC finish its actions.
    end
    --- Cows: Now we can assume the NPC is valid and not busy in combat below this line ---
    ---@type IsoPlayer
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local npcPlayerSquare = npcIsoPlayer:getSquare();

    -- Cows: Check if npcSurvivor is not holding in place
    if (npcSurvivor.isHoldingInPlace ~= true) then
        -- Cows: Check if the npcSurvivor has a destination with jobSquare
        if (npcSurvivor.jobSquare == nil) then
            local targetBuilding = npcPlayerSquare:getBuilding();
            -- Cows: Check if the target building is nil, if true, look for another building in the cell.
            if (targetBuilding == nil) then
                -- Cows: get the list of buildings in the cell
                local buildingsInCell = PZNS_WorldUtils.PZNS_GetCellBuildingsList();
                if (buildingsInCell) then
                    targetBuilding = PZNS_WorldUtils.PZNS_GetRandomBuildingFromCell(buildingsInCell);
                else
                    -- Cows: Else there is no building in the cell to go into... what should the NPC do in this case?
                    PZNS_NPCSpeak(npcSurvivor, "I have no buildings in the cell...", "InfoOnly");
                    return;
                end
            end
            -- Cows: Check if the target building is nil again, if true, stop
            if (targetBuilding == nil) then
                -- Cows: At this point, there is no building to wander in... what should the NPC do in this case?
                PZNS_NPCSpeak(npcSurvivor, "I have no building to wander in...", "InfoOnly");
                return;
            end
            -- Cows: Now we can finally assume there is a target building for the NPC to get into, hopefully with a room and square.
            local randomRoom = PZNS_WorldUtils.PZNS_GetBuildingRandomRoom(targetBuilding);
            if (randomRoom) then
                local randomRoomSquare = PZNS_WorldUtils.PZNS_GetBuildingRoomRandomFreeSquare(randomRoom);
                if (randomRoomSquare) then
                    npcSurvivor.idleTicks = 0;
                    npcSurvivor.isStuckTicks = 0;
                    npcSurvivor.jobSquare = randomRoomSquare;
                    local squareX = npcSurvivor.jobSquare:getX();
                    local squareY = npcSurvivor.jobSquare:getY();
                    local squareZ = npcSurvivor.jobSquare:getZ();
                    PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor); -- Cows: Clear the actions queue and start moving.
                    PZNS_WalkToSquareXYZ(npcSurvivor, squareX, squareY, squareZ);
                else
                    -- Cows: At this point, there is no square to move to... what should the NPC do in this case?
                    PZNS_NPCSpeak(npcSurvivor, "I have no square to move to...", "InfoOnly");
                end
            else
                -- Cows: At this point, there is no room to move to... what should the NPC do in this case?
                PZNS_NPCSpeak(npcSurvivor, "I have no room to move to...", "InfoOnly");
            end
        else
            -- Cows: use idleTicks instead of action ticks, because the NPC is wandering around. Also because other actions may use actionTicks.
            npcSurvivor.idleTicks = npcSurvivor.idleTicks + 1;
            -- Cows: Else assume the NPC is moving inside the building it is in.
            local distanceFromTarget = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(
                npcIsoPlayer, npcSurvivor.jobSquare
            );
            -- Cows: Check if the NPC is near its destination...
            if (distanceFromTarget < 1) then
                -- Cows: Allow the NPC to idle for a moment before restarting its routine.
                if (npcSurvivor.idleTicks >= 600) then
                    npcSurvivor.jobSquare = nil;
                end
                return;-- Cows: Stop processing, the NPC is already at it's destination.
            else
                -- Cows: Else Update the movement calculation every 300 ticks to reduce action queuing and resume the movement.
                local moveTickInterval = 300;
                if (npcSurvivor.idleTicks >= moveTickInterval) then
                    -- Cows: Check the NPC at regular intervals to see if it is stuck in the same square...
                    local isStuck = npcIsoPlayer:getLastSquare() == npcPlayerSquare;
                    if (isStuck == true) then
                        -- Cows: only need 2 for the stuck interval check, because the moveTickInterval is 300; 2 * 300 = 600 ticks to confirm the NPC is stuck.
                        PZNS_UtilsNPCs.PZNS_StuckNPCCheck(npcSurvivor, 2);
                        if (npcSurvivor.isStuckTicks >= 2) then
                            npcSurvivor.jobSquare = nil;
                        end
                    end
                    --
                    if (npcSurvivor.jobSquare) then
                        local squareX = npcSurvivor.jobSquare:getX();
                        local squareY = npcSurvivor.jobSquare:getY();
                        local squareZ = npcSurvivor.jobSquare:getZ();
                        PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor); -- Cows: Clear the actions queue and start moving.
                        PZNS_WalkToSquareXYZ(npcSurvivor, squareX, squareY, squareZ);
                    end
                    npcSurvivor.idleTicks = 0;
                end
            end
        end
    else
        -- Cows: Else assume the npcSurvivor is holding in place.
        if (npcSurvivor.jobSquare) then
            local squareX = npcSurvivor.jobSquare:getX();
            local squareY = npcSurvivor.jobSquare:getY();
            local squareZ = npcSurvivor.jobSquare:getZ();
            PZNS_WalkToSquareXYZ(npcSurvivor, squareX, squareY, squareZ);
        end
    end
end
