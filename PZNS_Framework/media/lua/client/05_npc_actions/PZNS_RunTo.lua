--** Cows: Based on "ISWalkToTimedAction" by ROBERT JOHNSON **

require "TimedActions/ISBaseTimedAction";
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");
local PZNS_NPCsManager = require("04_data_management/PZNS_NPCsManager");
PZNS_RunToTimedAction = ISBaseTimedAction:derive("ISWalkToTimedAction");

-- Cows: resetRunAtTick is approximately how long it takes for the "run" animation to complete and move the npc.
local resetRunAtTick = 35;

function PZNS_RunToTimedAction:isValid()
    if self.character:getVehicle() then return false end
    return getGameSpeed() <= 2;
end

function PZNS_RunToTimedAction:update()
    --
    if instanceof(self.character, "IsoPlayer") == true and
        (self.character:pressedMovement(false) or self.character:pressedCancelAction()) then
        self:forceStop()
        return
    end
    -- Cows: Stop setting the npcSurvivor to run and allow the default pathfinding to takeover and get to its on-the-dot location.
    if (PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(self.character, self.location) > 2) then
        -- Cows: Added for run... the npcSurvivor would run for 1 square then resumes walking for some reason...
        self.character:NPCSetRunning(true);
    end
    self.result = self.character:getPathFindBehavior2():update();
    self.runTicks = self.runTicks + 1;

    if self.result == BehaviorResult.Working then
        if (self.runTicks > resetRunAtTick) then
            self.character:NPCSetRunning(false);
            self.character:setPath2(nil);
            self.character:getPathFindBehavior2():pathToLocation(
                self.location:getX(), self.location:getY(), self.location:getZ()
            );

            self.runTicks = 0;
        end
        return;
    end
    --
    if self.result == BehaviorResult.Failed then
        self.character:NPCSetRunning(false);
        self:forceStop();
        return;
    end
    --
    if self.additionalTest ~= nil then
        if self.additionalTest(self.additionalContext) then
            self.character:NPCSetRunning(false);
            self:forceComplete();
            return
        end
    end
    --
    if self.result == BehaviorResult.Succeeded then
        self.character:NPCSetRunning(false);
        self:forceComplete();
    end
end

function PZNS_RunToTimedAction:start()
    self.character:getPathFindBehavior2():pathToLocation(self.location:getX(), self.location:getY(), self.location:getZ());
end

function PZNS_RunToTimedAction:stop()
    ISBaseTimedAction.stop(self);
    self.character:getPathFindBehavior2():cancel()
    self.character:setPath2(nil);
end

function PZNS_RunToTimedAction:perform()
    self.character:getPathFindBehavior2():cancel()
    self.character:setPath2(nil);

    ISBaseTimedAction.perform(self);

    if self.onCompleteFunc then
        local args = self.onCompleteArgs
        self.onCompleteFunc(args[1], args[2], args[3], args[4])
    end
end

function PZNS_RunToTimedAction:setOnComplete(func, arg1, arg2, arg3, arg4)
    self.onCompleteFunc = func
    self.onCompleteArgs = { arg1, arg2, arg3, arg4 }
end

--
-- Can pass in an additional test to allow the walk to action to complete early.
--
-- Example if you have walking to a door, you can end it early if you get to the door, so you don't walk through it
-- meaning you'll always barricade the side of the door you reach first.
-- Example a doorN is on the tile below it, not above it. Walking down the character would walk through the door
-- Then barricade it from below.
--
function PZNS_RunToTimedAction:new(character, location, additionalTest, additionalContext)
    local survivorID = character:getModData().survivorID;
    --
    if (survivorID == nil) then
        return;
    end
    local npcSurvivor = PZNS_NPCsManager.getActiveNPCBySurvivorID(survivorID);

    local o = {}
    setmetatable(o, self)
    self.__index = self
    --
    -- PZNS_NPCSpeak(npcSurvivor, "New PZNS_RunToTimedAction");
    o.npcSurvivor = npcSurvivor; -- Cows: Added this so that npcSurvivor moddata is hooked in for this timebased action.
    o.character = character;

    o.stopOnWalk = false;
    o.stopOnRun = false;
    o.maxTime = -1;
    o.location = location;
    o.pathIndex = 0;
    o.additionalTest = additionalTest;
    o.additionalContext = additionalContext;
    o.runTicks = 0;

    return o;
end

--- Cows: Have the specified NPC move to the square specified by xyz coordinates.
---@param npcSurvivor any
---@param squareX any
---@param squareY any
---@param squareZ any
function PZNS_RunToSquareXYZ(npcSurvivor, squareX, squareY, squareZ)
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
		local runAction = PZNS_RunToTimedAction:new(npcIsoPlayer, targetSquare);
		PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, runAction);
	end
end
