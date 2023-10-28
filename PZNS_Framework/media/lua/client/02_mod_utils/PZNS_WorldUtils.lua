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
    -- Cows: Only continue to check spawn range if the playerSurvivor not nil and is alive.
    if (playerSurvivor == nil) then
        return;
    end
    if (playerSurvivor:isAlive() ~= true) then
        return;
    end
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

--- Cows: Helper function to spawn and despawn/unload NPCs from the game world.
---@param npcSurvivor any
local function spawnNPCIsoPlayer(npcSurvivor)
    if (npcSurvivor == nil) then
        return;
    end
    --
    if (npcSurvivor.isAlive == true) then
        local isNPCSquareLoaded = PZNS_UtilsNPCs.PZNS_GetIsNPCSquareLoaded(npcSurvivor);
        -- Cows: Check isNPCSquareLoaded
        if (isNPCSquareLoaded == true) then
            local playerSurvivor = getSpecificPlayer(0);
            -- Cows: Realized that there are times when the IsoPlayer object is in the world, but the parent object npcSurvivor isn't updated... 
            local spawnX = npcSurvivor.squareX;
            local spawnY = npcSurvivor.squareY;
            local spawnZ = npcSurvivor.squareZ;
            ---@type IsoPlayer
            local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
            -- Cows: Check if the IsoPlayer object exists and use it instead as the most recent NPC location.
            if (npcIsoPlayer) then
                spawnX = npcIsoPlayer:getX();
                spawnY = npcIsoPlayer:getY();
                spawnZ = npcIsoPlayer:getZ();
            end
            local isNPCInSpawnRange = PZNS_WorldUtils.PZNS_IsSquareInPlayerSpawnRange(playerSurvivor,
                spawnX, spawnY, spawnZ
            );
            -- Cows: Check if the NPC is in spawn range
            if (isNPCInSpawnRange == true) then
                -- Cows: Check if npcSurvivor isSpawned
                if (npcSurvivor.isSpawned ~= true) then
                    -- Cows: set the isSavedInWorld to false so NPC can be saved later if off-screen.
                    PZNS_UtilsDataNPCs.PZNS_SpawnNPCFromModData(npcSurvivor);
                    npcSurvivor.isSavedInWorld = false;
                end
            else
                -- Cows: Else remove the NPC from the game world to prevent issues from happening in the background.
                -- Cows: Check if the NPC is NOT saved in the world and save its relevant data.
                if (npcSurvivor.isSavedInWorld ~= true) then
                    npcSurvivor.textObject:ReadString("");
                    npcSurvivor.isSpawned = false;
                    npcSurvivor.isSavedInWorld = true;
                    PZNS_UtilsDataNPCs.PZNS_SaveNPCData(npcSurvivor.survivorID, npcSurvivor);
                end
                -- Cows: Check if the IsoPlayer object exists then remove and reset the npc IsoPlayer Object.
                if (npcIsoPlayer) then
                    npcIsoPlayer:removeFromSquare();
                    npcIsoPlayer:removeFromWorld();
                    npcSurvivor.npcIsoPlayerObject = nil;
                end
                -- Cows: Check if the npc cannot be saved and permanently remove from game world.
                if (npcSurvivor.canSaveData == false) then
                    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
                    activeNPCs[npcSurvivor.survivorID] = nil;
                end
            end
        end
    end
end

--- Cows: A function to spawn/despawn NPCs when they become unloaded off-screen.
--- Cows: There may be some sync issues because the "spawning" depends on the file in the save folder.
function PZNS_WorldUtils.PZNS_SpawnNPCIfSquareIsLoaded()
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    if (activeNPCs == nil) then
        return;
    end
    --
    for survivorID, v1 in pairs(activeNPCs) do
        local npcSurvivor = activeNPCs[survivorID];
        spawnNPCIsoPlayer(npcSurvivor);
    end
    --
    PZNS_WorldUtils.PZNS_UpdateCellNPCsList();    -- Update the loaded NPCs list
    PZNS_WorldUtils.PZNS_UpdateCellZombiesList(); -- Update the loaded zombies list
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
    if (targetSquare == nil) then
        return;
    end
    local npcSquareX = targetSquare:getX();
    local npcSquareY = targetSquare:getY();
    local npcSquareZ = targetSquare:getZ();
    local zombiesRemoved = 0;
    -- Cows: Assign npcSquareZ to 0 if it is nil for whatever reason.
    if (npcSquareZ == nil) then
        npcSquareZ = 0;
    end
    for xSquare = (npcSquareX - squareRadius), (npcSquareX + squareRadius) do
        --
        for ySquare = (npcSquareY - squareRadius), (npcSquareY + squareRadius) do
            local currentSquare = getCell():getGridSquare(xSquare, ySquare, npcSquareZ);
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

--- Cows: Gets a list of rooms in the cell.
---@return ArrayList
function PZNS_WorldUtils.PZNS_GetCellRoomsList()
    local roomsList = getCell():getRoomList();
    return roomsList;
end

--- Cows: Gets a random room from the cell rooms list.
---@param roomsList ArrayList
---@return IsoRoom
function PZNS_WorldUtils.PZNS_GetCellRandomRoom(roomsList)
    local listSize = roomsList:size() - 1;
    local randomSelect = ZombRand(0, listSize);
    local randomRoom = roomsList:get(randomSelect);
    return randomRoom;
end

--- Cows: Gets the building of the input room.
---@param inputRoom IsoRoom
---@return any returns a random building from the buildingsList
function PZNS_WorldUtils.PZNS_GetBuildingFromRoom(inputRoom)
    local building = inputRoom:getBuilding();
    return building;
end

--- Cows: Gets the list of rooms in the building .
---@param building IsoBuilding
---@return any returns a list of rooms in the specified building.
function PZNS_WorldUtils.PZNS_GetBuildingRooms(building)
    local bdef = building:getDef();
    local rooms = bdef:getRooms();
    return rooms;
end

--- Get a random room in the building
---@param building IsoBuilding
---@return any returns a random room in the specified building.
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
function PZNS_WorldUtils.PZNS_GetRoomRandomFreeSquare(room)
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

--- Get an adjacent square based on a direction
--- Cows: Based on GetAdjSquare() from 'SuperSurvivorContextUtilities.lua', but won't need the alias.
---@param square any
---@param dir string
---@return IsoGridSquare |nil the adjacent square
function PZNS_WorldUtils.PZNS_GetAdjSquare(square, dir)
    if (square == nil or dir == nil) then
        return;
    end
    if (dir == 'N') then
        return getCell():getGridSquare(square:getX(), square:getY() - 1, square:getZ());
    elseif (dir == 'E') then
        return getCell():getGridSquare(square:getX() + 1, square:getY(), square:getZ());
    elseif (dir == 'S') then
        return getCell():getGridSquare(square:getX(), square:getY() + 1, square:getZ());
    else
        return getCell():getGridSquare(square:getX() - 1, square:getY(), square:getZ());
    end
end

--- Cows: Updates all the zombies and NPCs in the cell, fires after a grid square is loaded.
function PZNS_WorldUtils.PZNS_UpdateCellZombiesList()
    PZNS_CellZombiesList = getCell():getZombieList(); -- Cows: Update the PZNS_CellZombiesList
end

--- Cows: Updates all the zombies and NPCs in the cell, fires after a grid square is loaded.
function PZNS_WorldUtils.PZNS_UpdateCellNPCsList()
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    PZNS_CellNPCsList = {}; -- Cows: Update the PZNS_CellNPCsList
    -- Cows: Go through all the active NPCs and update their job routines
    for survivorID, v1 in pairs(activeNPCs) do
        local npcSurvivor = activeNPCs[survivorID];
        if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == true) then
            PZNS_CellNPCsList[survivorID] = npcSurvivor.npcIsoPlayerObject;
        end
    end
end

--- Cows: Checks if the specified npcSurvivor's square is on screen, this was used to debug and test a reported issue
--- https://github.com/shadowhunter100/PZNS/issues/36
---@param npcSurvivorID any
function PZNS_WorldUtils.PlayerSayIsNPCSquareOnScreen(npcSurvivorID)
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    if (activeNPCs[npcSurvivorID] ~= nil) then
        local npcSurvivor = activeNPCs[npcSurvivorID];
        local square = getCell():getGridSquare(
            npcSurvivor.squareX,
            npcSurvivor.squareY,
            npcSurvivor.squareZ
        );
        local distanceFromSquare = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(getSpecificPlayer(0), square);
        if (square == nil) then
            return;
        end
        local isSquareOnScreen = square:IsOnScreen();
        if (isSquareOnScreen) then
            getSpecificPlayer(0):Say(npcSurvivorID .. ", isSquareOnScreen: " .. tostring(isSquareOnScreen) ..
                " | distance: " .. tostring(distanceFromSquare)
            );
        end
    end
end

return PZNS_WorldUtils;
