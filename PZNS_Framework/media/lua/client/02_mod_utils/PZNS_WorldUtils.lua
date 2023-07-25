--[[
    Cows: This file is intended for ALL functions related to the creation, deletion, load,
    and editing of data found in the game world. Mostly involving distances, world objects, and handling off-screen data loading/unloading.
--]]
local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");

local PZNS_WorldUtils = {};
--- Cows: Get the distance between 2 objects.
---@param currentObject any
---@param targetObject any
function PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(currentObject, targetObject)
    if (currentObject == nil) or (targetObject == nil) then
        return 1;
    end

    local o1x = currentObject:getX();
    local o1y = currentObject:getY();
    local o1z = currentObject:getZ();

    local o2x = targetObject:getX();
    local o2y = targetObject:getY();
    local o2z = targetObject:getZ();

    local dX = o1x - o2x;
    local dY = o1y - o2y;
    local dZ = o1z - o2z;

    local distance = math.sqrt(dX * dX + dY * dY + (dZ * dZ * 2));
    --
    if (distance ~= nil) then
        return distance;
    end

    return 1;
end

--- Cows: Apparently "IsoSquare" can't be used directly because the function would try to call it on the world map, which would always return nil if not in the loaded cell...
---@param playerSurvivor IsoPlayer
---@param squareX number
---@param squareY number
---@param squareZ number
function PZNS_WorldUtils.PZNS_IsSquareInPlayerSpawnRange(playerSurvivor, squareX, squareY, squareZ)
    local o1x = playerSurvivor:getX();
    local o1y = playerSurvivor:getY();
    local o1z = playerSurvivor:getZ();
    local dX = o1x - squareX;
    local dY = o1y - squareY;
    local dZ = o1z - squareZ;

    local distance = math.sqrt(dX * dX + dY * dY + (dZ * dZ * 2));

    if (distance ~= nil) then
        -- Cows: Check if the distance is at 45 squares or less and return true if the square is loaded.
        if (distance <= 45) then
            local square = getCell():getGridSquare(squareX, squareY, squareZ);
            if (square ~= nil) then
                return true;
            end
        end
    end
    return false;
end

---comment
---@param npcSurvivor any
local function spawnNPCIsoPlayer(npcSurvivor)
    --
    if (npcSurvivor == nil) then
        return;
    end
    --
    if (npcSurvivor.isAlive == true) then
        local isNPCSquareLoaded = PZNS_UtilsNPCs.PZNS_GetIsNPCSquareLoaded(npcSurvivor);
        ---@type IsoPlayer
        local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
        -- Cows: Check isNPCSquareLoaded
        if (isNPCSquareLoaded == true) then
            -- Cows: Check if NPC does not exists in the world, set the isSavedInWorld to false so NPC can be saved later if off-screen.
            if (npcSurvivor.isSpawned ~= true) then
                if (npcIsoPlayer:getSquare() ~= nil and npcIsoPlayer:isExistInTheWorld() ~= true) then
                    PZNS_UtilsDataNPCs.PZNS_SpawnNPCFromModData(npcSurvivor);
                    npcSurvivor.isSavedInWorld = false;
                end
            end
        else
            if (npcSurvivor.isSavedInWorld ~= true) then
                npcSurvivor.isSpawned = false;
                npcSurvivor.isSavedInWorld = true;
                PZNS_UtilsDataNPCs.PZNS_SaveNPCData(npcSurvivor.survivorID, npcSurvivor);
            end
            -- Cows: Else remove the NPC from the game world to prevent issues from happening.
            npcIsoPlayer:removeFromWorld();
            npcIsoPlayer:removeFromSquare();
        end
    end
end
--- Cows: A function to spawn/despawn NPCs when they become unloaded off-screen.
--- WIP - Cows: There may be some sync issues because the "spawning" depends on the file in the save folder.
function PZNS_WorldUtils.PZNS_SpawnNPCIfSquareIsLoaded()
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    -- Cows: check if activeNPCs is not nil and loaded.
    if (activeNPCs ~= nil) then
        --
        for survivorID, v1 in pairs(activeNPCs) do
            local npcSurvivor = activeNPCs[survivorID];
            --
            spawnNPCIsoPlayer(npcSurvivor);
        end -- Cows: End for k1, v1 in pairs(activeNPCs)
    end
end

--- Cows: Checks if zombie is active/isAlive.
---@param currentObject any
---@return boolean
function PZNS_WorldUtils.PZNS_IsObjectZombieActive(currentObject)
    if (currentObject ~= nil) and (instanceof(currentObject, "IsoZombie") == true) then
        if (currentObject:isAlive() == true) then
            return true;
        end
    end
    return false;
end

--- Cows: Clears the target square and its surrounding square radius of zombies for safe(r) spawning.
---@param targetSquare IsoGridSquare
---@param squareRadius number
function PZNS_WorldUtils.PZNS_ClearZombiesFromSquare(targetSquare, squareRadius)
    local npcSquareX = targetSquare:getX();
    local npcSquareY = targetSquare:getY();
    local zombiesRemoved = 0;
    --
    for xSquare = (npcSquareX - squareRadius), (npcSquareX + squareRadius) do
        --
        for ySquare = (npcSquareY - squareRadius), (npcSquareY + squareRadius) do
            local currentSquare = getCell():getGridSquare(xSquare, ySquare, 0);
            -- Cows: Needed to add a check for current square - because if it's off-screen and the square data is unloaded, the function will throw an error.
            if (currentSquare ~= nil) then
                local Objs = currentSquare:getMovingObjects();
                -- Cows: get the Objects on the currentSquare.
                for j = 0, Objs:size() - 1 do
                    local currentObj = Objs:get(j);
                    -- Cows: Check if currentObj is a zombie and remove if true.
                    if (PZNS_WorldUtils.PZNS_IsObjectZombieActive(currentObj) == true) then
                        zombiesRemoved = zombiesRemoved + 1;
                        currentObj:removeFromWorld();
                    end
                end
            end
        end
    end
end

--- Cows: Gets a list of buildings in the cell.
function PZNS_WorldUtils.PZNS_GetCellBuildingsList()
    local buildingsList = getCell():getBuildingList();
    return buildingsList;
end

--- Cows: 
---@param buildingsList ArrayList
---@return any returns a random building from the buildingsList
function PZNS_WorldUtils.PZNS_GetRandomBuildingFromCell(buildingsList)
    local building = buildingsList[ZombRand(0, buildingsList:size() - 1)];
    return building;
end

---
---@param building IsoBuilding
---@return any returns a list of rooms in the specified building.
function PZNS_WorldUtils.PZNS_GetBuildingRooms(building)
    local bdef = building:getDef();
    local rooms = bdef:getRooms();
    return rooms;
end

---
---@param building IsoBuilding
---@return any returns a random rooms in the specified building.
function PZNS_WorldUtils.PZNS_GetBuildingRandomRoom(building)
    local randomRoom = building:getRandomRoom();
    return randomRoom;
end

---
---@param room IsoRoom
---@return any returns a list of squares in the specified room.
function PZNS_WorldUtils.PZNS_GetBuildingRoomSquares(room)
    local squares = room:getSquares();
    return squares;
end

---
---@param room IsoRoom
---@return any returns a random free square in the specified room.
function PZNS_WorldUtils.PZNS_GetBuildingRoomRandomFreeSquare(room)
    local squares = room:getRandomFreeSquare();
    return squares;
end

--- Cows: Based on 'GetRandomBuildingSquare()' from SuperSurvivorContextUtilities.lua
---@param building IsoBuilding
---@return any returns a random square inside of the building
function PZNS_WorldUtils.PZNS_GetBuildingRandomSquare(building)
    local bdef = building:getDef();
    local x = ZombRand(bdef:getX(), (bdef:getX() + bdef:getW()));
    local y = ZombRand(bdef:getY(), (bdef:getY() + bdef:getH()));
    local sq = getCell():getGridSquare(x, y, 0);

    if (sq) then
        return sq;
    end
    return nil;
end

return PZNS_WorldUtils;
