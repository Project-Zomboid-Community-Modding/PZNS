ModId = "PZNS_Framework";
local PZNS_UtilsDataGroups = require("02_mod_utils/PZNS_UtilsDataGroups");
local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_UtilsDataZones = require("02_mod_utils/PZNS_UtilsDataZones");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_NPCsManager = require("04_data_management/PZNS_NPCsManager");
local PZNS_NPCGroupsManager = require("04_data_management/PZNS_NPCGroupsManager");

local PZNS_DebuggerUtils = {};

-- Cows: Use this function to write a line to a text file, this is useful to identify when and how many times a function is called.
---@param fileName any
---@param isEnabled any
---@param newLine any
function PZNS_DebuggerUtils.CreateLogLine(fileName, isEnabled, newLine)
    if (isEnabled) then
        local timestamp = os.time();
        local formattedTimeDay = os.date("%Y-%m-%d", timestamp);
        local formattedTime = os.date("%Y-%m-%d %H:%M:%S", timestamp);
        local file = getFileWriter(
            ModId .. "/PZNS_logs/" .. formattedTimeDay .. "_" .. ModId .. "_" .. fileName .. "_Logs.txt", true, true);
        local content = formattedTime .. " : " .. "CreateLogLine called";

        if newLine then
            content = formattedTime .. " : " .. newLine;
        end

        file:write(content .. "\r\n");
        file:close();
    end
end

-- Example usage:
-- CreateLogLine("PZNS_0_DebuggerUtils", true, "Start...");

--- Cows: Log the ISTimedActionQueue.queues
function PZNS_DebuggerUtils.LogQueuedActions()
    local isLoggingLocalFunction = true;
    --
    if (ISTimedActionQueue.queues ~= nil) then
        --
        for k1, v1 in pairs(ISTimedActionQueue.queues) do
            PZNS_DebuggerUtils.CreateLogLine("LogQueuedAction", isLoggingLocalFunction,
                "k1: " .. tostring(k1) .. " | v1: " .. tostring(v1)
            );
            if (type(v1) == "table") then
                --
                for k2, v2 in pairs(v1) do
                    PZNS_DebuggerUtils.CreateLogLine("LogQueuedAction", isLoggingLocalFunction,
                        "k2: " .. tostring(k2) .. " | v2: " .. tostring(v2)
                    );
                    --
                    if (type(v2) == "table") then
                        for k3, v3 in pairs(v2) do
                            PZNS_DebuggerUtils.CreateLogLine("LogQueuedAction", isLoggingLocalFunction,
                                "k3: " .. tostring(k3) .. " | v3: " .. tostring(v3)
                            );
                        end
                    end
                end
            end
        end
    end
end

---comment
function PZNS_DebuggerUtils.LogNPCsModData()
    local modData = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    local isLoggingLocalFunction = true;
    --
    if (isLoggingLocalFunction and modData ~= nil) then
        for k1, v1 in pairs(modData) do
            PZNS_DebuggerUtils.CreateLogLine("LogNPCsModData", isLoggingLocalFunction,
                "k1: " .. tostring(k1) .. " | v1: " .. tostring(v1)
            );
            --
            if (type(v1) == "table") then
                for k2, v2 in pairs(v1) do
                    PZNS_DebuggerUtils.CreateLogLine("LogNPCsModData", isLoggingLocalFunction,
                        "k2: " .. tostring(k2) .. " | v2: " .. tostring(v2)
                    );
                end
                PZNS_DebuggerUtils.CreateLogLine("LogNPCsModData", isLoggingLocalFunction, "");
            end
        end
    end
end

---comment
function PZNS_DebuggerUtils.LogNPCGroupsModData()
    local modData = PZNS_UtilsDataGroups.PZNS_GetCreateActiveGroupsModData();
    local isLoggingLocalFunction = true;
    --
    if (isLoggingLocalFunction) then
        for k1, v1 in pairs(modData) do
            PZNS_DebuggerUtils.CreateLogLine("LogNPCGroupsModData", isLoggingLocalFunction,
                "k1: " .. tostring(k1) .. " | v1: " .. tostring(v1)
            );
            --
            if (type(v1) == "table") then
                for k2, v2 in pairs(v1) do
                    PZNS_DebuggerUtils.CreateLogLine("LogNPCGroupsModData", isLoggingLocalFunction,
                        "k2: " .. tostring(k2) .. " | v2: " .. tostring(v2)
                    );
                end
                PZNS_DebuggerUtils.CreateLogLine("LogNPCGroupsModData", isLoggingLocalFunction, "");
            end
        end
    end
end

--- Cows: Wipe ALL moddata.
function PZNS_DebuggerUtils.PZNS_WipeAllData()
    if (PZNS_ActiveNPCs == nil) then
        return;
    end
    --
    for k1, v1 in pairs(PZNS_ActiveNPCs) do
        local npcSurvivor = PZNS_ActiveNPCs[k1];
        local npcGroupID = npcSurvivor.groupID;
        local npcSurvivorID = npcSurvivor.survivorID;
        PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor);
        --
        if (npcGroupID ~= nil) then
            PZNS_NPCGroupsManager.removeNPCFromGroupBySurvivorID(npcGroupID, npcSurvivorID); -- Cows: REMOVE THE NPC FROM THEIR GROUP BEFORE DELETING THEM! OTHERWISE IT'S A NIL REFERENCE
        end
        PZNS_NPCsManager.deleteActiveNPCBySurvivorID(npcSurvivorID);
    end
    PZNS_UtilsDataNPCs.PZNS_ClearNPCModData();
    PZNS_UtilsDataGroups.PZNS_ClearGroupsModData();
    PZNS_UtilsDataZones.PZNS_ClearZonesData();
end

--- Cows: Get all the ModData tables.
function PZNS_DebuggerUtils.PZNS_LogAllModDataTables()
    local isLoggingLocalFunction = true;
    --
    if (isLoggingLocalFunction) then
        local tableNames = ModData.getTableNames();
        PZNS_DebuggerUtils.CreateLogLine("PZNS_GetAllModDataTables", isLoggingLocalFunction,
            "tableNames: " .. tostring(tableNames)
        );
    end
end

-- Cows: Thanks to albion#0123 for sharing this function.
-- This will retrieve a list of ALL the active mods the user currently has.
local activatedMods = getActivatedMods();

-- Cows: Check if active mod lists includes <ModId> and write for handler for dealing with it.
-- This block may need to be added to relevant functions such as equipment, perks, traits.
---@param modId any
---@return boolean
function PZNS_DebuggerUtils.PZNS_IsModActive(modId)
    if activatedMods:contains(modId) then
        return true;
    end

    return false;
end

--- Cows: this was a test function for all the getting all the cell objects and printing them to text files.
function PZNS_DebuggerUtils.PZNS_GetAllObjectsInCell()
    local isLoggingLocalFunction = true;
    local IsoMovingObjectsInCell = getCell():getObjectList();              -- Cows: Returns a list of whatever is an IsoMovingObject
    local StaticIsoObjectsInCell = getCell():getStaticUpdaterObjectList(); -- Cows: Returns a list of Light Switches, Radios, TVs
    local getProcessItemsInCell = getCell():getProcessItems();             -- Cows: Returns a list of clothing and items on the floor
    local getProcessWorldItemsInCell = getCell():getProcessWorldItems();   -- Cows: Returned nothing...
    local getPushableObjectListInCell = getCell():getPushableObjectList(); -- Cows: Returned nothing...
    local getAddListInCell = getCell():getAddList();                       -- Cows: Returned nothing...
    local getRemoveListInCell = getCell():getRemoveList();                 -- Cows: Returned nothing...
    local getProcessIsoObjectsInCell = getCell():getProcessIsoObjects();   -- Cows: Returns a list of interactive objects (Dryers/Washer, Stove)
    local getZombieListInCell = getCell():getZombieList();
    --
    local playerSurvivor = getSpecificPlayer(0);
    playerSurvivor:Say("Getting Cell ObjectsList...");
    --
    for i = 1, IsoMovingObjectsInCell:size() - 1 do
        local currentObj = IsoMovingObjectsInCell:get(i);
        --
        PZNS_DebuggerUtils.CreateLogLine("IsoMovingObjectsInCell", isLoggingLocalFunction,
            "currentObj: " .. tostring(currentObj)
        );
    end
    --
    for i = 1, StaticIsoObjectsInCell:size() - 1 do
        local currentObj = StaticIsoObjectsInCell:get(i);
        --
        PZNS_DebuggerUtils.CreateLogLine("StaticIsoObjectsInCell", isLoggingLocalFunction,
            "currentObj: " .. tostring(currentObj)
        );
    end
    --
    for i = 1, getProcessItemsInCell:size() - 1 do
        local currentObj = getProcessItemsInCell:get(i);
        --
        PZNS_DebuggerUtils.CreateLogLine("getProcessItemsInCell", isLoggingLocalFunction,
            "currentObj: " .. tostring(currentObj)
        );
    end
    --
    for i = 1, getProcessWorldItemsInCell:size() - 1 do
        local currentObj = getProcessWorldItemsInCell:get(i);
        --
        PZNS_DebuggerUtils.CreateLogLine("getProcessWorldItemsInCell", isLoggingLocalFunction,
            "currentObj: " .. tostring(currentObj)
        );
    end
    --
    for i = 1, getPushableObjectListInCell:size() - 1 do
        local currentObj = getPushableObjectListInCell:get(i);
        --
        PZNS_DebuggerUtils.CreateLogLine("getPushableObjectListInCell", isLoggingLocalFunction,
            "currentObj: " .. tostring(currentObj)
        );
    end
    --
    for i = 1, getAddListInCell:size() - 1 do
        local currentObj = getAddListInCell:get(i);
        --
        PZNS_DebuggerUtils.CreateLogLine("getAddListInCell", isLoggingLocalFunction,
            "currentObj: " .. tostring(currentObj)
        );
    end
    --
    for i = 1, getRemoveListInCell:size() - 1 do
        local currentObj = getRemoveListInCell:get(i);
        --
        PZNS_DebuggerUtils.CreateLogLine("getRemoveListInCell", isLoggingLocalFunction,
            "currentObj: " .. tostring(currentObj)
        );
    end
    --
    for i = 1, getProcessIsoObjectsInCell:size() - 1 do
        local currentObj = getProcessIsoObjectsInCell:get(i);
        --
        PZNS_DebuggerUtils.CreateLogLine("getProcessIsoObjectsInCell", isLoggingLocalFunction,
            "currentObj: " .. tostring(currentObj)
        );
    end
    --
    for i = 1, getZombieListInCell:size() - 1 do
        local currentObj = getZombieListInCell:get(i);
        --
        PZNS_DebuggerUtils.CreateLogLine("getZombieListInCell", isLoggingLocalFunction,
            "currentObj: " .. tostring(currentObj)
        );
    end
end

--- Cows Logs the current IsoPlayer's grid square coords
---@param mpPlayerID number
---@return IsoGridSquare
function PZNS_DebuggerUtils.PZNS_LogPlayerCellGridSquare(mpPlayerID)
    local isLoggingLocalFunction = true;
    local localPlayerID = 0;
    local playerSurvivor = getSpecificPlayer(localPlayerID);
    --
    if (mpPlayerID ~= nil) then
        localPlayerID = mpPlayerID;
    end
    --
    PZNS_DebuggerUtils.CreateLogLine("PZNS_DebuggerUtils", isLoggingLocalFunction,
        "playerX: " .. tostring(playerSurvivor:getX()) ..
        " | playerY: " .. tostring(playerSurvivor:getY()) ..
        " | playerZ: " .. tostring(playerSurvivor:getZ())
    );
    --
    local gridSquare = getCell():getGridSquare(
        playerSurvivor:getX(),
        playerSurvivor:getY(),
        playerSurvivor:getZ()
    );
    return gridSquare;
end

--- Cows Logs the current player's customized isoplayer avatar.
---@param mpPlayerID number
function PZNS_DebuggerUtils.PZNS_LogPlayerCustomization(mpPlayerID)
    local isLoggingLocalFunction = true;
    local localPlayerID = 0;
    local playerSurvivor = getSpecificPlayer(localPlayerID);
    --
    if (mpPlayerID ~= nil) then
        localPlayerID = mpPlayerID;
    end
    --
    PZNS_DebuggerUtils.CreateLogLine("PZNS_DebuggerUtils", isLoggingLocalFunction,
        "hairModel: " .. tostring(playerSurvivor:getHumanVisual():getHairModel())
    );
    --
    PZNS_DebuggerUtils.CreateLogLine("PZNS_DebuggerUtils", isLoggingLocalFunction,
        "hairColor: " .. tostring(playerSurvivor:getHumanVisual():getHairColor())
    );
    --
    PZNS_DebuggerUtils.CreateLogLine("PZNS_DebuggerUtils", isLoggingLocalFunction,
        "skinColor: " .. tostring(playerSurvivor:getHumanVisual():getSkinColor())
    );
    --
    PZNS_DebuggerUtils.CreateLogLine("PZNS_DebuggerUtils", isLoggingLocalFunction,
        "skinTextureIndex: " .. tostring(playerSurvivor:getHumanVisual():getSkinTextureIndex())
    );
    --
    PZNS_DebuggerUtils.CreateLogLine("PZNS_DebuggerUtils", isLoggingLocalFunction,
        "skinTexture: " .. tostring(playerSurvivor:getHumanVisual():getSkinTexture())
    );
end

return PZNS_DebuggerUtils;
