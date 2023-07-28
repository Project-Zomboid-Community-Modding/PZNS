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

    -- Cows: Check if npcSurvivor is not holding in place
    if (npcSurvivor.isHoldingInPlace ~= true) then
        -- Cows: Check if the npcSurvivor has a destination with jobSquare
        if (npcSurvivor.jobSquare == nil) then
            local npcPlayerSquare = npcIsoPlayer:getSquare();
            local targetBuilding = npcPlayerSquare:getBuilding();
            PZNS_GeneralAI.PZNS_ExploreTargetBuilding(npcSurvivor, targetBuilding);
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
                -- Cows: Allow the NPC to idle for a moment before restarting its routine.
                if (npcSurvivor.idleTicks >= 600) then
                    PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor);
                    npcSurvivor.jobSquare = nil;
                end
                return; -- Cows: Stop processing, the NPC is already at it's destination.
            else
                PZNS_GeneralAI.PZNS_WalkToJobSquare(npcSurvivor);
            end
        end
    else
        -- Cows: Else assume the npcSurvivor is holding in place, but will attempt to walk to any assigned jobSquare.
        npcSurvivor.idleTicks = npcSurvivor.idleTicks + 1;
        PZNS_GeneralAI.PZNS_WalkToJobSquare(npcSurvivor);
    end
end
