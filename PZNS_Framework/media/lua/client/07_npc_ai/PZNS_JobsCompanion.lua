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
    npcSurvivor.idleTicks = 0;
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
    npcSurvivor.idleTicks = 0;
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    -- Cows: Auto Close doors
    if (npcIsoPlayer:getLastSquare() ~= nil) then
        local cs = npcIsoPlayer:getCurrentSquare();
        local ls = npcIsoPlayer:getLastSquare();
        local tempdoor = ls:getDoorTo(cs);
        if (tempdoor ~= nil and tempdoor:IsOpen()) then
            tempdoor:ToggleDoor(npcIsoPlayer);
        end
    end
    local npcSquareX = npcIsoPlayer:getX();
    local npcSquareY = npcIsoPlayer:getY();
    npcIsoPlayer:NPCSetAttack(false);
    if (npcIsoPlayer:NPCGetAiming() == true) then
        npcIsoPlayer:NPCSetAiming(false);
    end
    --
    local distanceFromTarget = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(npcIsoPlayer, targetIsoPlayer);
    npcIsoPlayer:faceThisObject(targetIsoPlayer);
    --
    local targetX = targetIsoPlayer:getX();
    local targetY = targetIsoPlayer:getY();
    local targetZ = targetIsoPlayer:getZ();
    -- Cows: Offset by at least 1 square to ensure the npcSurvivor companion doesn't push into the followed target.
    local offset = ZombRand(1, CompanionFollowRange);
    targetX = offsetTargetSquare(npcSquareX, targetX, offset);
    targetY = offsetTargetSquare(npcSquareY, targetY, offset);
    -- Cows: Check the distance from target and start running if too far from target.
    if (distanceFromTarget > CompanionRunRange) then
        npcSurvivor.isForcedMoving = true;
        PZNS_RunToSquareXYZ(npcSurvivor, targetX, targetY, targetZ);
    else
        npcSurvivor.isForcedMoving = false;
        PZNS_WalkToSquareXYZ(npcSurvivor, targetX, targetY, targetZ);
    end
end

--- Cows: The "Companion" Job only works if the npcSurvivor and its target exists.
---@param npcSurvivor PZNS_NPCSurvivor
---@param targetID string
function PZNS_JobCompanion(npcSurvivor, targetID)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    ---@type IsoPlayer
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if targetID ~= "" and targetID ~= npcSurvivor.followTargetID then
        npcSurvivor.followTargetID = targetID
    end
    if not targetID or targetID == "" then
        print(string.format("Invalid targetID (%s) for Companion job", targetID))
        PZNS_NPCSpeak(npcSurvivor, string.format("Can't follow '%s' (invalid target)!", targetID))
        PZNS_UtilsNPCs.PZNS_SetNPCJob(npcSurvivor, "Wander In Cell")
        return
    end
    local targetIsoPlayer = getTargetIsoPlayerByID(targetID);
    --
    if (targetIsoPlayer == nil) then
        return;
    end
    npcSurvivor.jobTicks = npcSurvivor.jobTicks + 1;
    -- Cows: Sneak if the follow target is sneaking.
    if (targetIsoPlayer:isSneaking()) then
        npcIsoPlayer:setSneaking(true);
    else
        npcIsoPlayer:setSneaking(false);
    end
    -- Cows: Check if npcSurvivor is not holding in place
    if (npcSurvivor.isHoldingInPlace ~= true) then
        local isTargetInCar = targetIsoPlayer:getVehicle();
        local isSelfInCar = npcIsoPlayer:getVehicle();
        -- Cows: Check if target is in a car and if npcSurvivor is not in a car.
        if (isTargetInCar ~= nil and isSelfInCar == nil) then
            -- Cows: Check and make the enter call at set ticks interval to account for animation timing.
            if (npcSurvivor.jobTicks % 30 == 0) then
                PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor); -- Cows: Clear the actions queue and start running.
                jobCompanion_EnterCar(npcSurvivor, targetIsoPlayer);
            end
            -- Cows: Else check if npcSurvivor and follow target are both in a car
        elseif (isTargetInCar ~= nil and isSelfInCar ~= nil) then
            -- WIP - Cows: perhaps NPCs can attack hostiles while in the car with a gun?...
            npcSurvivor.idleTicks = 0;

            -- Cows: Check if target is NOT in a car and exit the car if self is in one.
        elseif (isTargetInCar == nil and isSelfInCar ~= nil) then
            -- Cows: Check and make the exit call at set ticks interval to account for animation timing.
            if (npcSurvivor.jobTicks % 30 == 0) then
                PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor); -- Cows: Clear the actions queue and start running.
                PZNS_ExitVehicle(npcSurvivor);
            end
        else -- Cows: Else assume both npcSurvivor and target are on foot.
            -- Cows: Check if Companion is currently being forced to move or npcSurvivor is NOT near their follow target
            if (npcSurvivor.isForcedMoving == true or isCompanionInFollowRange(npcIsoPlayer, targetIsoPlayer) == false) then
                -- Cows: Update the movement calculation at set ticks interval, otherwise NPCs can become stuck due to animations' timing.
                if (npcSurvivor.jobTicks % 30 == 0) then
                    PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor); -- Cows: Clear the actions queue and start running.
                    jobCompanion_Movement(npcSurvivor, targetIsoPlayer);
                end
                return; -- Cows: Stop processing and start moving to target.
                -- Cows: Else Check if the NPC is busy in combat related stuff.
            elseif (PZNS_GeneralAI.PZNS_IsNPCBusyCombat(npcSurvivor) == true) then
                return; -- Cows Stop Processing and let the NPC finish its combat actions.
            end
            local canSeeTarget = npcIsoPlayer:CanSee(targetIsoPlayer);
            -- WIP - Cows: Check if Companion can't see their target, and move them to a square that is visible within follow range.
            if (canSeeTarget == false) then
                -- jobCompanion_Movement(npcSurvivor, targetIsoPlayer);
                -- return;
            end

            -- WIP - Cows: Check if companion has idled for too long and take idle action.
            if (npcSurvivor.idleTicks >= CompanionIdleTicks) then
                npcIsoPlayer:NPCSetAttack(false);
                npcIsoPlayer:NPCSetAiming(false);
                -- Cows: Do Idle stuff, eat, wash, read books?
                -- PZNS_NPCSpeak(npcSurvivor,
                --     "I am getting bored here... idleTicks: " .. tostring(npcSurvivor.idleTicks), "InfoOnly"
                -- );
            else
                npcSurvivor.isForcedMoving = false;
                npcSurvivor.idleTicks = npcSurvivor.idleTicks + 1;
            end
        end
    else
        -- Cows: Else assume the npcSurvivor is holding in place.
        if (PZNS_GeneralAI.PZNS_IsNPCBusyCombat(npcSurvivor) == true) then
            return; -- Cows Stop Processing and let the NPC finish its actions.
        end
        if (npcSurvivor.jobSquare == nil) then
            return; -- Cows Stop Processing as the NPC has no destination
        end
        -- Cows: Update the path to the jobSquare every 30 ticks or so.
        if (npcSurvivor.jobTicks % 30 == 0) then
            PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor); -- Cows: Clear the actions queue and start moving towards jobSquare.
            local distanceFromTarget = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(npcIsoPlayer, targetIsoPlayer);
            local targetX = npcSurvivor.jobSquare:getX();
            local targetY = npcSurvivor.jobSquare:getY();
            local targetZ = npcSurvivor.jobSquare:getZ();
            -- Cows: Check the distance from target and determine how to approach.
            if (distanceFromTarget < 1) then
                npcSurvivor.isForcedMoving = false;
                npcSurvivor.jobSquare = nil;
                PZNS_WalkToSquareXYZ(npcSurvivor, targetX, targetY, targetZ);
            elseif (distanceFromTarget > 3) then
                npcSurvivor.isForcedMoving = true;
                PZNS_RunToSquareXYZ(npcSurvivor, targetX, targetY, targetZ);
            else
                npcSurvivor.isForcedMoving = false;
                PZNS_WalkToSquareXYZ(npcSurvivor, targetX, targetY, targetZ);
            end
        end
    end
    -- Cows: Reset the jobTicks to 0 at >= 60 ticks
    if (npcSurvivor.jobTicks >= 60) then
        npcSurvivor.jobTicks = 0;
    end
end
