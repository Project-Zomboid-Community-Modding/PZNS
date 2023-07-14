--[[
    Cows: This code file is based on some code from SuperSurvivorsBaseManagement.lua code.
    All the zones data are now managed by moddata and should run *much* better than before.
    The Zones management code essentially locks the NPC mods in to local single player only however...
--]]
local PZNS_UtilsDataZones = require("02_mod_utils/PZNS_UtilsDataZones");

PZNS_IsCreatingZone = false; -- WIP - Cows: Need to rethink how Global variables are used...
PZNS_IsShowingZone = false;  -- WIP - Cows: Need to rethink how Global variables are used...
PZNS_IsZoneActive = false;   -- WIP - Cows: Need to rethink how Global variables are used...
-- WIP - Cows: Need to rethink how Global variables are used... Cows: The zoneKeys also serves as zoneType.
PZNS_ZonesText = {
    -- ZoneChopWood = "Chop Wood Zone",
    -- ZoneConstruction = "Construction Zone",
    ZoneDropCorpses = "Corpse Drop Zone",
    -- ZoneFarm = "Farm Zone",
    ZoneHome = "Home Zone",
    -- ZoneStoreFood = "Food Store Zone",
    -- ZoneStoreWood = "Wood Store Zone",
};
-- WIP - Cows: Need to rethink how Global variables are used... Cows: Color for each zone type... but rendering multiple zones highlight kills the game performance...
PZNS_ZoneColors = {
    -- ZoneChopWood = ColorInfo.new(0, 0, 0, 0.8),
    -- ZoneConstruction = ColorInfo.new(0, 0, 0, 0.8),
    ZoneDropCorpsesColor = ColorInfo.new(0.902, 0.502, 0, 0.8), -- Orange
    -- ZoneFarm = ColorInfo.new(0, 0, 0, 0.8),
    ZoneHomeColor = ColorInfo.new(0.161, 0.8, 0.102, 0.8),      -- Green
    -- ZoneStoreFood = ColorInfo.new(0, 0, 0, 0.8),
    -- ZoneStoreWood = ColorInfo.new(0, 0, 0, 0.8),
};
local PZNS_UtilsZones = {};
--
local mouseDownTicks = 0;
local zoneHighlightX1 = 0;
local zoneHighlightX2 = 0;
local zoneHighlightY1 = 0;
local zoneHighlightY2 = 0;
local zoneHighlightZ = 0;
local startAtTick = 40;

--- gets the world Y position of the mouse
---@return number returns the Y position
local function PZNS_GetZoneMouseSquareY()
    local sw = (128 / getCore():getZoom(0));
    local sh = (64 / getCore():getZoom(0));

    local mapy = getSpecificPlayer(0):getY();
    local mousex = ((getMouseX() - (getCore():getScreenWidth() / 2)));
    local mousey = ((getMouseY() - (getCore():getScreenHeight() / 2)));

    local sy = mapy + (mousey / (sh / 2) - (mousex / (sw / 2))) / 2;

    return sy;
end

--- gets the world X position of the mouse
---@return number returns the X position
local function PZNS_GetZoneMouseSquareX()
    local sw = (128 / getCore():getZoom(0));
    local sh = (64 / getCore():getZoom(0));

    local mapx = getSpecificPlayer(0):getX();
    local mousex = ((getMouseX() - (getCore():getScreenWidth() / 2)));
    local mousey = ((getMouseY() - (getCore():getScreenHeight() / 2)));

    local sx = mapx + (mousex / (sw / 2) + mousey / (sh / 2)) / 2;

    return sx;
end

-- Begin selectZoneSquares
local function selectZoneSquares()
    if (PZNS_IsCreatingZone == true) then
        if (Mouse.isLeftDown()) then
            mouseDownTicks = mouseDownTicks + 1;
        else
            mouseDownTicks = 0;
            PZNS_IsZoneActive = false;
        end

        if (mouseDownTicks > startAtTick) then
            --
            if (not PZNS_IsZoneActive) then
                zoneHighlightX1 = PZNS_GetZoneMouseSquareX();
                zoneHighlightX2 = PZNS_GetZoneMouseSquareX();
                zoneHighlightY1 = PZNS_GetZoneMouseSquareY();
                zoneHighlightY2 = PZNS_GetZoneMouseSquareY();
            end

            PZNS_IsZoneActive = true;

            if (zoneHighlightX1 == nil) or (zoneHighlightX1 > PZNS_GetZoneMouseSquareX()) then
                zoneHighlightX1 = PZNS_GetZoneMouseSquareX();
            end
            if (zoneHighlightX2 == nil) or (zoneHighlightX2 <= PZNS_GetZoneMouseSquareX()) then
                zoneHighlightX2 = PZNS_GetZoneMouseSquareX();
            end
            if (zoneHighlightY1 == nil) or (zoneHighlightY1 > PZNS_GetZoneMouseSquareY()) then
                zoneHighlightY1 = PZNS_GetZoneMouseSquareY();
            end
            if (zoneHighlightY2 == nil) or (zoneHighlightY2 <= PZNS_GetZoneMouseSquareY()) then
                zoneHighlightY2 = PZNS_GetZoneMouseSquareY();
            end
        elseif (PZNS_IsZoneActive) then
            PZNS_IsZoneActive = false;
        end

        if (Mouse.isLeftPressed()) then
            PZNS_IsZoneActive = false; -- new
        end
        --
        if (zoneHighlightX1) and (zoneHighlightX2) then
            local x1 = zoneHighlightX1;
            local x2 = zoneHighlightX2;
            local y1 = zoneHighlightY1;
            local y2 = zoneHighlightY2;
            local z = getSpecificPlayer(0):getZ();
            --
            for xx = x1, x2 do
                --
                for yy = y1, y2 do
                    --
                    local sq = getCell():getGridSquare(xx, yy, z);
                    --
                    if (sq) and (sq:getFloor()) then
                        sq:getFloor():setHighlighted(true);
                    end
                end
            end
        end
    end
end

---comment
local function renderZoneSquare()
    local playerSurvivor = getSpecificPlayer(0);
    --
    for i = zoneHighlightX1, zoneHighlightX2 do
        --
        for j = zoneHighlightY1, zoneHighlightY2 do
            local cell = getCell():getGridSquare(i, j, playerSurvivor:getZ());
            --
            if cell and cell:getFloor() then
                cell:getFloor():setHighlighted(true);
            end
        end
    end
end

---comment
function PZNS_CancelCreatingZone()
    PZNS_IsCreatingZone = false;
end

--- Cows: Gets the specified zone boundary of the group based on zoneType.
---@param groupID string
---@param zoneType string
---@return unknown
function PZNS_UtilsZones.PZNS_GetGroupZoneBoundary(groupID, zoneType)
    local activeZones = PZNS_UtilsDataZones.PZNS_GetCreateActiveZonesModData();
    local groupZoneID = groupID .. "_" .. zoneType;
    local currentZone = activeZones[groupZoneID];

    if (currentZone ~= nil) then
        return {
            currentZone.zoneBoundaryX1,
            currentZone.zoneBoundaryX2,
            currentZone.zoneBoundaryY1,
            currentZone.zoneBoundaryY2,
            currentZone.zoneBoundaryZ
        };
    end
    return nil;
end

---comment
---@param groupID string
---@param zoneType string
---@param boundaries any
function PZNS_UtilsZones.PZNS_SetGroupZoneBoundary(groupID, zoneType, boundaries)
    local activeZones = PZNS_UtilsDataZones.PZNS_GetCreateActiveZonesModData();
    local groupZoneID = groupID .. "_" .. zoneType;
    local currentZone = activeZones[groupZoneID];

    if (currentZone ~= nil) then
        currentZone.zoneBoundaryX1 = boundaries[1];
        currentZone.zoneBoundaryX2 = boundaries[2];
        currentZone.zoneBoundaryY1 = boundaries[3];
        currentZone.zoneBoundaryY2 = boundaries[4];
        currentZone.zoneBoundaryZ = boundaries[5];
    end
end

---comment
---@param groupID string
---@param zoneType string
function PZNS_UtilsZones.PZNS_StartSelectingZone(groupID, zoneType)
    --
    PZNS_IsCreatingZone = true;
    local baseBounds = PZNS_UtilsDataZones.PZNS_GetGroupZoneBoundary(groupID, zoneType);
    --
    if (baseBounds ~= nil) then
        zoneHighlightX1 = baseBounds[1];
        zoneHighlightX2 = baseBounds[2];
        zoneHighlightY1 = baseBounds[3];
        zoneHighlightY2 = baseBounds[4];
        zoneHighlightZ = baseBounds[5];
    end
    Events.OnRenderTick.Add(selectZoneSquares);
end

---comment
---@param groupID string
---@param zoneType string
function PZNS_UtilsZones.PZNS_EndSelectingZone(groupID, zoneType)
    local zoneBoundaries = {
        math.floor(zoneHighlightX1),
        math.floor(zoneHighlightX2),
        math.floor(zoneHighlightY1),
        math.floor(zoneHighlightY2),
        math.floor(getSpecificPlayer(0):getZ())
    };

    PZNS_UtilsZones.PZNS_SetGroupZoneBoundary(groupID, zoneType, zoneBoundaries);

    PZNS_IsCreatingZone = false;

    Events.OnRenderTick.Remove(selectZoneSquares);
end

---comment
---@param groupID string
---@param zoneType string
function PZNS_UtilsZones.PZNS_ShowGroupZoneSquares(groupID, zoneType)
    PZNS_IsShowingZone = true;
    local baseBounds = PZNS_UtilsZones.PZNS_GetGroupZoneBoundary(groupID, zoneType);
    --
    if (baseBounds ~= nil) then
        zoneHighlightX1 = baseBounds[1];
        zoneHighlightX2 = baseBounds[2];
        zoneHighlightY1 = baseBounds[3];
        zoneHighlightY2 = baseBounds[4];
        zoneHighlightZ = baseBounds[5];
    end
    PZNS_UtilsZones.PZNS_GetGroupZoneCenterSquare(groupID, zoneType);

    Events.OnRenderTick.Add(renderZoneSquare);
end

---comment
function PZNS_UtilsZones.PZNS_HideGroupZoneSquares()
    PZNS_IsShowingZone = false;
    Events.OnRenderTick.Remove(renderZoneSquare);
end

---comment
---@param groupID string
---@param zoneType string
function PZNS_UtilsZones.PZNS_GetGroupZoneCenterSquare(groupID, zoneType)
    local baseBounds = PZNS_UtilsZones.PZNS_GetGroupZoneBoundary(groupID, zoneType);
    --
    if (baseBounds ~= nil) then
        zoneHighlightX1 = baseBounds[1];
        zoneHighlightX2 = baseBounds[2];
        zoneHighlightY1 = baseBounds[3];
        zoneHighlightY2 = baseBounds[4];
        zoneHighlightZ = baseBounds[5];
    end
    --
    local xdiff = zoneHighlightX2 - zoneHighlightX1;
    local ydiff = zoneHighlightY2 - zoneHighlightY1;
    local middleX = zoneHighlightX1 + math.floor(xdiff / 2);
    local middleY = zoneHighlightY1 + math.floor(ydiff / 2);
    --
    local centerSquare = getCell():getGridSquare(middleX, middleY, zoneHighlightZ);

    local playerSurvivor = getSpecificPlayer(0);
    playerSurvivor:Say("middleX: " .. tostring(middleX) .. " | " .. tostring(middleY));
    return centerSquare;
end

---comment
---@param groupID any
---@param zoneType any
function PZNS_UtilsZones.PZNS_CheckGroupWorkZoneExists(groupID, zoneType)
    local workZone = PZNS_UtilsZones.PZNS_GetGroupZoneBoundary(groupID, zoneType);
    --
    if (workZone == nil) then
        return;
    end
    local workZoneSquareX = workZone[1];
    local workZoneSquareY = workZone[3];
    local workZoneSquareZ = workZone[5];
    -- WIP - Cows: Currently this is only specific to ONE square, rather than ALL squares in the selected zone.
    local groupDropSquare = getCell():getGridSquare(workZoneSquareX, workZoneSquareY, workZoneSquareZ);
    --
    if (workZone == nil or groupDropSquare == nil) then
        return;
    end
    --
    return groupDropSquare;
end

return PZNS_UtilsZones;
