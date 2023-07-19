local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");
local PZNS_NPCsManager = require("04_data_management/PZNS_NPCsManager");
local PZNS_GeneralAI = require("07_npc_ai/PZNS_GeneralAI");
--
--- Cows: Gets the target IsoPlayer object by targetID.
---@param targetID string
---@return IsoPlayer
local function getTargetIsoPlayerByID(targetID)
    local targetIsoPlayer;
    --
    if (targetID == "Player0") then
        targetIsoPlayer = getSpecificPlayer(0);
    else
        local targetNPC = PZNS_NPCsManager.getActiveNPCBySurvivorID(targetID);
        targetIsoPlayer = targetNPC.npcIsoPlayerObject;
    end
    return targetIsoPlayer;
end

--- Cows: Checks if npc is within the follow range of the target.
---@param npcIsoPlayer IsoPlayer
---@param targetIsoPlayer IsoPlayer
---@return boolean
local function isCompanionInFollowRange(npcIsoPlayer, targetIsoPlayer)
    local distanceFromTarget = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(npcIsoPlayer, targetIsoPlayer);
    --
    if (distanceFromTarget > CompanionFollowRange) then
        return false;
    end

    return true;
end

--- Cows: NPC companion will attempt to enter the car the target is in.
---@param npcSurvivor any
---@param targetIsoPlayer IsoPlayer
local function jobCompanion_EnterCar(npcSurvivor, targetIsoPlayer)
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local distanceFromTarget = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(npcIsoPlayer, targetIsoPlayer);
    local targetX = targetIsoPlayer:getX();
    local targetY = targetIsoPlayer:getY();
    local targetZ = targetIsoPlayer:getZ();
    -- Cows: Have the companion make an effort to get near the vehicle before forcing the companion to enter it.
    if (distanceFromTarget > 3) then
        PZNS_RunToSquareXYZ(npcSurvivor, targetX, targetY, targetZ);
    else
        PZNS_EnterVehicleAsPassenger(npcSurvivor, targetIsoPlayer);
    end
end

--- Cows: Offsets the target square so the npc doesn't run into the target
---@param currentSquare any
---@param targetSquare any
---@param offset number
---@return unknown
local function offsetTargetSquare(currentSquare, targetSquare, offset)
    --
    if (currentSquare > targetSquare) then
        targetSquare = targetSquare + offset;
    else
        targetSquare = targetSquare - offset;
    end
    return targetSquare;
end

--- Cows: Move the npcSurvivor relative to the target.
---@param npcSurvivor any
---@param targetIsoPlayer IsoPlayer
local function jobCompanion_Movement(npcSurvivor, targetIsoPlayer)
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local npcSquareX = npcIsoPlayer:getX();
    local npcSquareY = npcIsoPlayer:getY();
    npcIsoPlayer:NPCSetAiming(false);
    npcIsoPlayer:NPCSetAttack(false);
    --
    local distanceFromTarget = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(npcIsoPlayer, targetIsoPlayer);
    npcIsoPlayer:faceThisObject(targetIsoPlayer);
    --
    local targetX = targetIsoPlayer:getX();
    local targetY = targetIsoPlayer:getY();
    local targetZ = targetIsoPlayer:getZ();
    -- Cows: Offset by 1 square to ensure the npcSurvivor companion doesn't push into the followed target.
    targetX = offsetTargetSquare(npcSquareX, targetX, 1);
    targetY = offsetTargetSquare(npcSquareY, targetY, 1);
    -- Cows: Auto Close doors
    if (npcIsoPlayer:getLastSquare() ~= nil) then
        local cs = npcIsoPlayer:getCurrentSquare()
        local ls = npcIsoPlayer:getLastSquare()
        local tempdoor = ls:getDoorTo(cs);

        if (tempdoor ~= nil and tempdoor:IsOpen()) then
            tempdoor:ToggleDoor(npcIsoPlayer);
        end
    end
    -- Cows: Check the distance from target and start running if too far from target.
    if (distanceFromTarget > CompanionRunRange) then
        PZNS_RunToSquareXYZ(npcSurvivor, targetX, targetY, targetZ);
    else
        local actionsCount = PZNS_UtilsNPCs.PZNS_GetNPCActionsQueuedCount(npcSurvivor);
        -- Cows: If there are more than 15 actions queued, reset the queue so the NPC can start walking.
        if (actionsCount > 15) then
            PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor);
        end
        PZNS_WalkToSquareXYZ(npcSurvivor, targetX, targetY, targetZ);
    end
end

--- Cows: The "Companion" Job only works if the npcSurvivor and its target exists.
---@param npcSurvivor any
---@param targetID string
function PZNS_JobCompanion(npcSurvivor, targetID)
    if (npcSurvivor == nil) then
        return nil;
    end
    --
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local targetIsoPlayer = getTargetIsoPlayerByID(targetID);
    --
    if (npcIsoPlayer and targetIsoPlayer) then
        -- Cows: Check if npcSurvivor is not holding in place
        if (npcSurvivor.isHoldingInPlace ~= true) then
            local isTargetInCar = targetIsoPlayer:getVehicle();
            local isSelfInCar = npcIsoPlayer:getVehicle();
            -- Cows: Check if target is in a car and if npcSurvivor is not in a car.
            if (isTargetInCar ~= nil and isSelfInCar == nil) then
                npcSurvivor.idleTicks = 0;
                jobCompanion_EnterCar(npcSurvivor, targetIsoPlayer);
                -- Cows: Else check if npcSurvivor and follow target are both in a car
            elseif (isTargetInCar ~= nil and isSelfInCar ~= nil) then
                -- WIP - Cows: perhaps NPCs can attack hostiles while in the car with a gun?...
                npcSurvivor.idleTicks = 0;

                -- Cows: Check if target is NOT in a car and exit the car if self is in one.
            elseif (isTargetInCar == nil and isSelfInCar ~= nil) then
                PZNS_ExitVehicle(npcSurvivor);
            else -- Cows: Else assume both npcSurvivor and target are on foot.
                local canSeeTarget = npcIsoPlayer:CanSee(targetIsoPlayer);
                -- Cows: Check if npcSurvivor is NOT near their follow target...
                if (isCompanionInFollowRange(npcIsoPlayer, targetIsoPlayer) == false or canSeeTarget == false) then
                    npcSurvivor.idleTicks = 0;
                    jobCompanion_Movement(npcSurvivor, targetIsoPlayer);
                    return; -- Cows: Stop processing and start moving to target.
                end
                if (PZNS_GeneralAI.PZNS_IsNPCBusyCombat(npcSurvivor) == true) then
                    npcSurvivor.idleTicks = 0;
                    return; -- Cows Stop Processing and let the NPC finish its actions.
                end
                --Cows: Check if companion has idled for too long and take action.
                if (npcSurvivor.idleTicks >= CompanionIdleTicks) then
                    -- Cows: Do Idle stuff, eat, wash, read books?
                    -- PZNS_NPCSpeak(npcSurvivor,
                    --     "I am getting bored here... idleTicks: " .. tostring(npcSurvivor.idleTicks), "InfoOnly"
                    -- );
                else
                    npcSurvivor.idleTicks = npcSurvivor.idleTicks + 1;
                end
            end
        else
            -- Cows: else assume the npcSurvivor is holding in place.
            if (PZNS_GeneralAI.PZNS_IsNPCBusyCombat(npcSurvivor) == true) then
                npcSurvivor.idleTicks = 0;
                return; -- Cows Stop Processing and let the NPC finish its actions.
            end
        end
    end
end
