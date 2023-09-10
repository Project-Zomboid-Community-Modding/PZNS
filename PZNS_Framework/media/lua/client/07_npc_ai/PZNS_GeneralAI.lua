local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");

--[[
    Cows: This file is intended for "general" purpose AI that is applicable to all jobs and job routines.
    Basic Aim & Attack
    Washing Clothes
    Bandaging
--]]

local spottingRange = 30; -- Cows: Perhaps a user option in the future...
local PZNS_GeneralAI = {};

---Cows: A function to check if the NPC is armed.
---@param npcSurvivor any
---@return boolean
function PZNS_GeneralAI.PZNS_IsNPCArmed(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return false;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    ---@type HandWeapon
    local npcHandItem = npcIsoPlayer:getPrimaryHandItem();
    -- Cows: No item in hand equals NPC is unarmed.
    if (npcHandItem == nil) then
        return false;
    end
    -- Cows: Check if theh and item is a weapon.
    if (npcHandItem:IsWeapon() == true) then
        if (npcHandItem:isRanged() == true) then
            -- Cows: Check if the gun has ammo
            if (npcHandItem:getCurrentAmmoCount() > 0) then
                return true;
            elseif (PZNS_GeneralAI.PZNS_IsNPCBusyCombat(npcSurvivor) == true) then
                return true;
            end
        else
            -- Cows: Else assume the weapon is melee and the NPC is armed.
            return true;
        end
    end
    -- Cows: Default to false.
    return false;
end

---comment
---@param npcSurvivor any
---@return boolean
function PZNS_GeneralAI.PZNS_IsReloadNeeded(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return false;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local npc_inventory = npcIsoPlayer:getInventory();
    ---@type HandWeapon
    local npcHandItem = npcIsoPlayer:getPrimaryHandItem();
    local ammoCount = 0;
    -- Cows: No Item in hand, no reload needed
    if (npcHandItem == nil) then
        return false;
    end
    -- Cows: Ranged weapon
    if (npcHandItem:IsWeapon() == true and npcHandItem:isRanged() == true) then
        -- Cows: Refill the gun to full capacity if infinite ammo is active.
        if (IsInfiniteAmmoActive == true and npcHandItem:getCurrentAmmoCount() == 0) then
            PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor);
            PZNS_UtilsNPCs.PZNS_SetLoadedGun(npcSurvivor);
            return false;
        end
        local ammoType = npcHandItem:getAmmoType();
        ammoCount = npc_inventory:getItemCountRecurse(ammoType);
        -- Cows: Check if the gun has no ammo and there are ammo in the backpack or there is a magazine type but no magazine is in the gun.
        if (npcHandItem:getCurrentAmmoCount() == 0 and ammoCount > 0
                or (npcHandItem:getMagazineType() ~= nil and npcHandItem:isContainsClip() == false)
            )
        then
            local actionQueue = ISTimedActionQueue.getTimedActionQueue(npcIsoPlayer);
            local lastAction = actionQueue.queue[#actionQueue.queue];
            -- Cows: Look at 'ISGrabItemAction:checkQueueList()' in the vanilla TIS code as example reference.
            if (lastAction) then
                -- Cows: Only accept gun-related actions, need to clear the action queue to begin the reload sequence.
                if (lastAction.Type ~= "ISEjectMagazine"
                        and lastAction.Type ~= "ISLoadBulletsInMagazine"
                        and lastAction.Type ~= "ISInsertMagazine"
                        and lastAction.Type ~= "ISRackFirearm"
                        and lastAction.Type ~= "ISReloadWeaponAction"
                        and lastAction.Type ~= "ISWalkToTimedAction" -- Cows: Well, reload while walking IS possible...
                    ) then
                    PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor);
                end
            end
            return true;
        end
    end
    return false;
end

--- WIP - Cows: Perhaps this needs a distance check as well? Apparently NPCs can "see" more than 30 squares away (or off-screen).
---@param npcSurvivor any
---@return boolean
function PZNS_GeneralAI.PZNS_CanSeeAimTarget(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return false;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    -- Cows: No aimed target, return false.
    if (npcSurvivor.aimTarget == nil) then
        return false;
    end
    local npcWeapon = npcIsoPlayer:getPrimaryHandItem();
    local aimRange = 2;
    -- Cows: Check if npcWeapon is a weapon
    if (npcWeapon ~= nil) then
        if (npcWeapon:IsWeapon() == true) then
            aimRange = npcWeapon:getMaxRange();
        end
    end
    -- Cows: Zombie Check
    if (PZNS_WorldUtils.PZNS_IsObjectZombieActive(npcSurvivor.aimTarget) == true) then
        local distanceFromTarget = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(
            npcIsoPlayer,
            npcSurvivor.aimTarget
        );
        if (distanceFromTarget <= aimRange) then
            return npcIsoPlayer:CanSee(npcSurvivor.aimTarget); -- Cows: "vision cone" isn't a thing for NPCs... they can "see" the world objects without facing them.
        end
    end

    npcSurvivor.aimTarget = nil;
    return false;
end

--- Cows: Have the NPC aim and attack their aimed target.
---@param npcSurvivor any
function PZNS_GeneralAI.PZNS_NPCAimAttack(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return false;
    end
    -- Cows: Can only aim and/or attack aimTarget exists
    if (npcSurvivor.aimTarget ~= nil) then
        -- WIP - Cows: Should add a check to see if enemy is in range... 
        PZNS_WeaponAiming(npcSurvivor); -- Cows: Aim before attacking
        PZNS_WeaponAttack(npcSurvivor); -- Cows: Permission to attack is handled in the function.
    end
end

--- WIP - Cows: Basically will replace PZNS_CheckZombieThreat() with an added hostile to player check... and other NPCs eventually.
function PZNS_GeneralAI.PZNS_CheckForThreats(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    local isNPCHostileToPlayer = PZNS_GeneralAI.PZNS_IsNPCHostileToPlayer(npcSurvivor);
    local playerSurvivor = getSpecificPlayer(0);
    local distanceFromPlayerSurvivor = 30;
    local isThreatExist = false;
    local priorityThreatDistance = spottingRange;
    local priorityThreatObject = npcSurvivor.aimTarget;
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    -- Cows: Check if npcSurvivor currently has an aimed threat
    if (priorityThreatObject ~= nil) then
        --
        local canSeeTarget = npcIsoPlayer:CanSee(priorityThreatObject);
        local isOnSameFloorLevel = priorityThreatObject:getZ() == npcIsoPlayer:getZ();
        priorityThreatDistance = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(npcIsoPlayer, priorityThreatObject);
        -- Cows: Stop if the nearest threat is less than 3 squares away... need to prepare to run or attack.
        if (canSeeTarget == true and priorityThreatDistance < 3 and isOnSameFloorLevel == true) then
            return true;
        end
    end
    --
    local npcWeapon = npcIsoPlayer:getPrimaryHandItem();
    local aimRange = 2;
    -- Cows: Check if npcWeapon is a weapon
    if (npcWeapon ~= nil) then
        if (npcWeapon:IsWeapon() == true) then
            aimRange = npcWeapon:getMaxRange();
        end
    end
    -- Cows: Check if the NPC is hostile to the player ge.
    if (isNPCHostileToPlayer == true) then
        distanceFromPlayerSurvivor = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(npcIsoPlayer, playerSurvivor);
        local canSeeTarget = npcIsoPlayer:CanSee(playerSurvivor);
        -- Check if the player is inside the spotting range
        if (canSeeTarget == true and distanceFromPlayerSurvivor < spottingRange) then
            priorityThreatDistance = distanceFromPlayerSurvivor;
            priorityThreatObject = playerSurvivor;
            isThreatExist = true;
        end
    end
    -- Zombies list
    if (PZNS_CellZombiesList ~= nil) then
        for i = PZNS_CellZombiesList:size() - 1, 0, -1 do
            local zombie = PZNS_CellZombiesList:get(i);
            --
            if (PZNS_WorldUtils.PZNS_IsObjectZombieActive(zombie) == true) then
                local currentThreatDistance = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(npcIsoPlayer, zombie);
                local isOnSameFloorLevel = zombie:getZ() == npcIsoPlayer:getZ();
                local isTargetInAimRange = currentThreatDistance < aimRange;
                local canSeeTarget = npcIsoPlayer:CanSee(zombie); -- Cows: "vision cone" isn't a thing for NPCs... they can "see" the world objects without facing them.
                --
                if (canSeeTarget == true and currentThreatDistance < spottingRange) then
                    isThreatExist = true;
                    if (isTargetInAimRange == true) then
                        -- Cows: Check if the playerSurvivor is currently the nearest threat.
                        if (isNPCHostileToPlayer == true and distanceFromPlayerSurvivor < currentThreatDistance) then
                            priorityThreatDistance = distanceFromPlayerSurvivor;
                            priorityThreatObject = playerSurvivor;
                        end
                        if (priorityThreatDistance > currentThreatDistance and isOnSameFloorLevel == true) then
                            priorityThreatDistance = currentThreatDistance;
                            priorityThreatObject = zombie;
                        end
                        -- Cows: Stop and prioritize zombies within 3 squares on the same floor
                        if (priorityThreatDistance < 3 and isOnSameFloorLevel == true) then
                            priorityThreatObject = zombie;
                            PZNS_AimAtTarget(npcSurvivor, priorityThreatObject);
                            return isThreatExist;
                        end
                    end
                end
            end
        end -- Cows: End Zombies for loop.
    end
    -- Cows: Other NPCs list
    if (PZNS_CellNPCsList ~= nil) then
        local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
        for npcID, targetIsoPlayer in pairs(PZNS_CellNPCsList) do
            local targetNPCSurvivor = activeNPCs[npcID];
            local isNPCHostileToTargetNPC = PZNS_GeneralAI.PZNS_IsNPCHostileToTargetNPC(npcSurvivor, targetNPCSurvivor);
            if (npcIsoPlayer:getModData().survivorID ~= npcID) then
                if (isNPCHostileToTargetNPC == true) then
                    local canSeeTarget = npcIsoPlayer:CanSee(targetIsoPlayer);
                    local distanceFromTargetNPC = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(npcIsoPlayer,
                        targetIsoPlayer);
                    --
                    if (canSeeTarget == true and distanceFromTargetNPC < spottingRange) then
                        local isTargetInAimRange = distanceFromTargetNPC < aimRange;
                        isThreatExist = true;
                        --
                        if (isTargetInAimRange == true) then
                            -- Cows: Check if the targetNPC is the nearest threat.
                            if (isNPCHostileToTargetNPC == true and priorityThreatDistance > distanceFromTargetNPC) then
                                priorityThreatDistance = distanceFromTargetNPC;
                                priorityThreatObject = targetIsoPlayer;
                            end
                        end
                    end
                end
            end
        end -- Cows: End Other NPCs for loop.
    end
    PZNS_AimAtTarget(npcSurvivor, priorityThreatObject);
    return isThreatExist;
end

--- Cows: This function forces the npcSurvivor to look for threats nearby.
---@param npcSurvivor any
---@return boolean
function PZNS_GeneralAI.PZNS_NPCFoundThreat(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return false;
    end
    -- Cows: Check if threat is in sight.
    local isThreatInSight = PZNS_GeneralAI.PZNS_CanSeeAimTarget(npcSurvivor);
    -- Cows: check if any threats are found.
    if (isThreatInSight == true) then
        -- PZNS_NPCSpeak(npcSurvivor, "Threat is in Sight! Now Busy in combat", "InfoOnly");
        return true;
    end
    -- Cows: Check for other threats
    local isThreatFound = PZNS_GeneralAI.PZNS_CheckForThreats(npcSurvivor);
    -- Cows: check if any threats are found.
    if (isThreatFound == true) then
        -- PZNS_NPCSpeak(npcSurvivor, "Threat Found! Now Busy in combat", "InfoOnly");
        return true;
    end
    return false;
end

--- Cows: This should unify the combat AI code...
---@param npcSurvivor any
---@return boolean
function PZNS_GeneralAI.PZNS_IsNPCBusyCombat(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return false;
    end
    -- Cows: action ticks can go over 200 if the reload action was interrupted midway.
    if (npcSurvivor.actionTicks > 200) then
        npcSurvivor.actionTicks = 0;
    end
    --
    local isReloadNeeded = PZNS_GeneralAI.PZNS_IsReloadNeeded(npcSurvivor);
    if (isReloadNeeded == true) then
        -- Cows: only do a "full" reload every 100 - 150 ticks or so, otherwise it will be spammed and cause the NPC to become stuck due to animations.
        local ticksCheck = ZombRand(100, 150);
        if (npcSurvivor.actionTicks == ticksCheck) then
            PZNS_WeaponReload(npcSurvivor);
            npcSurvivor.actionTicks = 0;
        else
            npcSurvivor.actionTicks = npcSurvivor.actionTicks + 1;
        end
        npcSurvivor.idleTicks = 0;
        return true; -- Cows: Stop processing and start reloading.
    end
    --
    local isThreatFound = PZNS_GeneralAI.PZNS_NPCFoundThreat(npcSurvivor);
    if (isThreatFound == true) then
        PZNS_GeneralAI.PZNS_NPCAimAttack(npcSurvivor);
        npcSurvivor.idleTicks = 0;
        return true; -- Cows: Stop processing and start attacking.
    end

    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    npcIsoPlayer:NPCSetAttack(false);
    if (npcIsoPlayer:NPCGetAiming() == true) then
        npcIsoPlayer:NPCSetAiming(false);
    end
    return false;
end

--- WIP - Cows: This is a simplified movement function, doesn't update as often as companion movement because non-companions do not need to keep up with their target.
---@param npcSurvivor any
function PZNS_GeneralAI.PZNS_WalkToJobSquare(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return true;
    end
    ---@type IsoPlayer
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local npcPlayerSquare = npcIsoPlayer:getSquare();
    -- Cows: If the NPC has no jobSquare, stop processing.
    if (npcSurvivor.jobSquare == nil) then
        return;
    end
    -- Cows: Else Update the movement calculation every 200 ticks to reduce action queuing and resume the movement.
    local moveTickInterval = 200;
    if (npcSurvivor.moveTicks >= moveTickInterval) then
        -- Cows: Check the NPC at regular intervals to see if it is stuck in the same square...
        local isStuck = npcIsoPlayer:getLastSquare() == npcPlayerSquare;
        if (isStuck == true) then
            -- Cows: Only need 1 for the stuck interval check, isStuckTicks starts at 0 and is inside the moveTickInterval.
            -- Cows: This means the stuck check is done twice at 1 and 2, at 200 and 400 ticks respectively.
            PZNS_UtilsNPCs.PZNS_StuckNPCCheck(npcSurvivor, 2);
            if (npcSurvivor.isStuckTicks >= 2) then
                npcSurvivor.jobSquare = nil;
            end
        else
            npcSurvivor.isStuckTicks = 0;
        end
        --
        if (npcSurvivor.jobSquare) then
            local squareX = npcSurvivor.jobSquare:getX();
            local squareY = npcSurvivor.jobSquare:getY();
            local squareZ = npcSurvivor.jobSquare:getZ();
            PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor); -- Cows: Clear the actions queue and start moving.
            PZNS_WalkToSquareXYZ(npcSurvivor, squareX, squareY, squareZ);
        end
        npcSurvivor.moveTicks = 0;
    end
    npcSurvivor.moveTicks = npcSurvivor.moveTicks + 1;
end

-- Cows: Helper function for exploring a specified target building.
function PZNS_GeneralAI.PZNS_ExploreTargetBuilding(npcSurvivor, targetBuilding)
    -- Cows: Check if the target building is nil, if true, stop
    if (targetBuilding == nil) then
        return;
    end
    -- Cows: Now we assume there is a target building for the NPC to explore, hopefully with a room and square.
    local randomRoom = PZNS_WorldUtils.PZNS_GetBuildingRandomRoom(targetBuilding);
    if (randomRoom == nil) then
        return;
    end
    local randomRoomSquare = PZNS_WorldUtils.PZNS_GetRoomRandomFreeSquare(randomRoom);
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
    end
end

--- Cows: Check if the NPC next to a door and facing said door.
---@param npcIsoPlayer IsoPlayer
---@return IsoDoor | nil
function PZNS_GeneralAI.PZNS_IsInFrontOfDoor(npcIsoPlayer)
    if (npcIsoPlayer == nil) then
        return nil;
    end
    local currentSquare = npcIsoPlayer:getCurrentSquare();
    local direction = tostring(npcIsoPlayer:getDir());
    local nextSquare = PZNS_WorldUtils.PZNS_GetAdjSquare(currentSquare, direction);
    --
    if (nextSquare and currentSquare:getDoorTo(nextSquare) ~= nil) then
        local isoDoor = currentSquare:getDoorTo(nextSquare):getSquare():getIsoDoor();
        return isoDoor;
    end
    return nil;
end

--- Cows: Check if the NPC next to a window and facing said window.
---@param npcIsoPlayer IsoPlayer
---@return IsoWindow | nil
function PZNS_GeneralAI.PZNS_IsInFrontOfWindow(npcIsoPlayer)
    if (npcIsoPlayer == nil) then
        return nil;
    end
    local currentSquare = npcIsoPlayer:getCurrentSquare();
    local direction = tostring(npcIsoPlayer:getDir());
    local nextSquare = PZNS_WorldUtils.PZNS_GetAdjSquare(currentSquare, direction);
    --
    if currentSquare and nextSquare and currentSquare:getDoorTo(nextSquare) then
        return currentSquare:getWindowTo(nextSquare);
    end
    return nil;
end

--- Cows: Simple check to see if the NPC is facing a locked or barricaded door.
---@param npcSurvivor any
---@return boolean
function PZNS_GeneralAI.PZNS_IsFacingLockedDoor(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return true;
    end
    ---@type IsoPlayer
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    --
    local door = PZNS_GeneralAI.PZNS_IsInFrontOfDoor(npcIsoPlayer);
    if (door ~= nil) then
        local distanceFromDoor = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(
            npcIsoPlayer,
            door
        );
        if (distanceFromDoor < 0.9) then
            if (door:isLocked() or door:isLockedByKey() or door:isBarricaded()) and (not door:isDestroyed()) then
                return true;
            end
        end
    end
    return false;
end

--- Cows: Simple check to see if the NPC is facing a locked or barricaded window.
---@param npcSurvivor any
---@return boolean
function PZNS_GeneralAI.PZNS_IsFacingLockedWindow(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return true;
    end
    ---@type IsoPlayer
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    --
    local window = PZNS_GeneralAI.PZNS_IsInFrontOfWindow(npcIsoPlayer);
    if (window ~= nil) then
        local distanceFromTarget = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(
            npcIsoPlayer,
            window
        );
        if (distanceFromTarget < 0.9) then
            if (window:isLocked() or window:isBarricaded()) and (not window:isDestroyed()) then
                return true;
            end
        end
    end
    return false;
end

--- WIP - Cows: This is a placeholder... Added to allow NPCs to evaluate potential obstacles in their paths...
---@param npcSurvivor any
function PZNS_GeneralAI.PZNS_IsPathBlocked(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return true;
    end
    -- Cows: Check if the NPC is facing a locked door or locked window
    local isFacingLockedDoor = PZNS_GeneralAI.PZNS_IsFacingLockedDoor(npcSurvivor);
    local isFacingLockedWindow = PZNS_GeneralAI.PZNS_IsFacingLockedWindow(npcSurvivor);
    if (isFacingLockedDoor == true or isFacingLockedWindow == true) then
        return true;
    end
    return false;
end

--- WIP - Cows: Added this function to check if an NPC is actively hostile to the player
---@param npcSurvivor any
---@return boolean
function PZNS_GeneralAI.PZNS_IsNPCHostileToPlayer(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return false;
    end
    --
    local npcGroupID = npcSurvivor.groupID;
    local playerGroupID = "Player" .. tostring(0) .. "Group";
    -- Cows: Check if npc is in the same group as the player
    if (npcGroupID == playerGroupID) then
        return false;
    end
    -- Cows: Check if NPC affection is above 0
    if (npcSurvivor.affection > 0) then
        return false;
    end

    return true;
end

--- WIP - Cows: Added this function to check if an NPC is friendly to the player
---@param npcSurvivor any
---@return boolean
function PZNS_GeneralAI.PZNS_IsNPCFriendlyToPlayer(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return true;
    end
    --
    local npcGroupID = npcSurvivor.groupID;
    local playerGroupID = "Player" .. tostring(0) .. "Group";
    -- Cows: Check if npc is in the same group as the player
    if (npcGroupID == playerGroupID) then
        return true;
    end
    -- Cows: Check if NPC is not a raider and the NPC affection is above 70 to be considered frindly
    if (npcSurvivor.isRaider ~= true and npcSurvivor.affection > 70) then
        return true;
    end

    return false;
end

--- WIP - Cows: Added this function to check if an NPC is actively hostile to a target NPC
---@param npcSurvivor any
---@param targetNPCSurvivor any
---@return boolean
function PZNS_GeneralAI.PZNS_IsNPCHostileToTargetNPC(npcSurvivor, targetNPCSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false
            or PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(targetNPCSurvivor) == false
        ) then
        return false;
    end
    --
    local npcGroupID = npcSurvivor.groupID;
    local targetNPCGroupID = targetNPCSurvivor.groupID;
    -- Cows: Check if the 2 NPCs are in the same group and return false if true
    if (npcGroupID == targetNPCGroupID) then
        return false;
    end
    -- Cows: Check if the currentNPC is friendly to the player and the target NPC is hostile.
    if (PZNS_GeneralAI.PZNS_IsNPCFriendlyToPlayer(npcSurvivor) == true
            and PZNS_GeneralAI.PZNS_IsNPCHostileToPlayer(targetNPCSurvivor) == true
        )
    then
        return true;
    end
    -- Cows: Check if either NPC is a raider.
    if (npcSurvivor.isRaider or targetNPCSurvivor.isRaider) then
        return true;
    end
    -- Cows: Else consider the NPCs neutral to each other.
    return false;
end

return PZNS_GeneralAI;
