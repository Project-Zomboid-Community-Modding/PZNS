local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");
local PZNS_GeneralAI = require("07_npc_ai/PZNS_GeneralAI");

--[[
    - WIP - Cows: "Wandering" can be unpredictable and without destination nor end goal... so my intent is to categorize the "wandering" into limited or specified areas to limit potential issues.
--]]
local chanceToStay = 30; -- Cows: Perhaps an option user can set?

--- Cows: NPC will wander around in the current loaded cell.
---@param npcSurvivor any
function PZNS_JobWanderInCell(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    if (PZNS_GeneralAI.PZNS_IsNPCBusyCombat(npcSurvivor) == true) then
        return; -- Cows Stop Processing and let the NPC finish its actions.
    end
    -- Cows: Wandering NPCs do not hold in place...
    if (npcSurvivor.isHoldingInPlace == true) then
        npcSurvivor.isHoldingInPlace = false;
    end
    --- Cows: Now we can assume the NPC is valid and not busy in combat below this line ---
    ---@type IsoPlayer
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    -- Cows: Check if npcSurvivor is outdoors, force them to sneak/crouch? Perhaps a function is needed here to evaluate when to hide...
    if (npcIsoPlayer:isOutside()) then
        -- Cows: Do something while outside...
        npcIsoPlayer:setSneaking(true);
    else
        npcIsoPlayer:setSneaking(false);
    end
    -- Cows: Check if the npcSurvivor has a destination with jobSquare
    if (npcSurvivor.jobSquare == nil) then
        -- Cows: Get a random square from the cell...?
        local targetBuilding = nil;
        local roomsInCell = PZNS_WorldUtils.PZNS_GetCellRoomsList();
        if (roomsInCell) then
            -- WIP - Cows: Perhaps a check is needed here to prevent NPCs from exploring the player's base...
            local randomRoom = PZNS_WorldUtils.PZNS_GetCellRandomRoom(roomsInCell);
            if (randomRoom) then
                targetBuilding = PZNS_WorldUtils.PZNS_GetBuildingFromRoom(randomRoom);
                PZNS_GeneralAI.PZNS_ExploreTargetBuilding(npcSurvivor, targetBuilding);
            else
                -- Cows: At this point, there is no building to explore... what should the NPC do in this case?
                return;
            end
        else
            -- Cows: Else there are no rooms in the cell explore... what should the NPC do in this case?
            return;
        end
    else
        -- Cows: use idleTicks instead of action ticks, because the NPC is wandering around without a group goal. Also because other actions may use actionTicks.
        npcSurvivor.idleTicks = npcSurvivor.idleTicks + 1;
        -- Cows: Else assume the NPC is moving inside the building it is in.
        local distanceFromTarget = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(
            npcIsoPlayer, npcSurvivor.jobSquare
        );
        --- Cows: Check if the NPC path is blocked every 60 ticks or so.
        if (npcSurvivor.idleTicks % 60 == 0) then
            if (PZNS_GeneralAI.PZNS_IsPathBlocked(npcSurvivor) == true) then
                PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor);
                npcSurvivor.jobSquare = nil;
                return;
            end
        end
        -- Cows: Check if the NPC is near its destination...
        if (distanceFromTarget < 1) then
            -- Cows: Chance the NPC will continue to stay and explore in the current building they are in.
            local isStaying = chanceToStay > ZombRand(1, 100);
            if (npcSurvivor.jobSquare:isOutside() == false and isStaying == true) then
                local targetBuilding = npcSurvivor.jobSquare:getBuilding();
                PZNS_GeneralAI.PZNS_ExploreTargetBuilding(npcSurvivor, targetBuilding);
                return;
            else
                PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor);
                npcSurvivor.jobSquare = nil;
            end
        end
        PZNS_GeneralAI.PZNS_WalkToJobSquare(npcSurvivor);
    end
end
