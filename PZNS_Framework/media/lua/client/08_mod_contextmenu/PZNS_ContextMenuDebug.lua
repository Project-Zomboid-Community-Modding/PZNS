local PZNS_DebuggerUtils = require("02_mod_utils/PZNS_DebuggerUtils");
local PZNS_UtilsDataGroups = require("02_mod_utils/PZNS_UtilsDataGroups");
local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_UtilsDataZones = require("02_mod_utils/PZNS_UtilsDataZones");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_PlayerUtils = require("02_mod_utils/PZNS_PlayerUtils");
--
local function addFiveCannedTunasToLocalPlayer()
    local playerSurvivor = getSpecificPlayer(0);
    for i = 1, 5 do
        playerSurvivor:getInventory():AddItem("Base.TunaTin");
    end
end

local function addTenPlanksToLocalPlayer()
    local playerSurvivor = getSpecificPlayer(0);
    for i = 1, 10 do
        playerSurvivor:getInventory():AddItem("Base.Plank");
    end
end

local function addFiveNailsBoxesToLocalPlayer()
    local playerSurvivor = getSpecificPlayer(0);
    for i = 1, 3 do
        playerSurvivor:getInventory():AddItem("Base.NailsBox");
    end
end

local function addFivePropanTanksToLocalPlayer()
    local playerSurvivor = getSpecificPlayer(0);
    for i = 1, 5 do
        playerSurvivor:getInventory():AddItem("Base.PropaneTank");
    end
end

local function addMetalSheetsToLocalPlayer()
    local playerSurvivor = getSpecificPlayer(0);
    for i = 1, 5 do
        playerSurvivor:getInventory():AddItem("Base.SheetMetal");
    end
end

local function addBigPoleFenceGate()
    local playerSurvivor = getSpecificPlayer(0);
    playerSurvivor:getInventory():AddItem("Base.WeldingRods");
    for i = 1, 5 do
        playerSurvivor:getInventory():AddItem("MetalPipe");
    end
    for i = 1, 4 do
        playerSurvivor:getInventory():AddItem("Base.ScrapMetal");
    end
    for i = 1, 2 do
        playerSurvivor:getInventory():AddItem("Base.Hinge");
    end
end
--
local function addBigWiredWallMaterialsToLocalPlayer()
    local playerSurvivor = getSpecificPlayer(0);
    playerSurvivor:getInventory():AddItem("Base.Wire");
    for i = 1, 4 do
        playerSurvivor:getInventory():AddItem("Base.ScrapMetal");
    end
    for i = 1, 3 do
        playerSurvivor:getInventory():AddItem("MetalPipe");
    end
end

local function addToolsToLocalPlayer()
    local playerSurvivor = getSpecificPlayer(0);
    playerSurvivor:getInventory():AddItem("Base.TinOpener");
    playerSurvivor:getInventory():AddItem("Base.Screwdriver");
    playerSurvivor:getInventory():AddItem("Base.Wrench");
    playerSurvivor:getInventory():AddItem("Base.PipeWrench");
    playerSurvivor:getInventory():AddItem("Base.Hammer");
    playerSurvivor:getInventory():AddItem("Base.WeldingMask");
    playerSurvivor:getInventory():AddItem("Base.BlowTorch");
end

local function addBooksToLocalPlayer()
    local playerSurvivor = getSpecificPlayer(0);
    playerSurvivor:getInventory():AddItem("Base.ElectronicsMag4");
    playerSurvivor:getInventory():AddItem("Base.FishingMag1");
    playerSurvivor:getInventory():AddItem("Base.FishingMag2");
    playerSurvivor:getInventory():AddItem("Base.MechanicMag1");
    playerSurvivor:getInventory():AddItem("Base.MechanicMag2");
    playerSurvivor:getInventory():AddItem("Base.MechanicMag3");
end

local function addMedicalToLocalPlayer()
    local playerSurvivor = getSpecificPlayer(0);
    playerSurvivor:getInventory():AddItem("Base.SutureNeedleHolder");
    for i = 1, 3 do
        playerSurvivor:getInventory():AddItem("Base.Antibiotics");
        playerSurvivor:getInventory():AddItem("Base.BathTowel");
        playerSurvivor:getInventory():AddItem("Base.Disinfectant");
        playerSurvivor:getInventory():AddItem("Base.Pills");
        playerSurvivor:getInventory():AddItem("Base.PillsBeta");
        playerSurvivor:getInventory():AddItem("Base.PillsAntiDep");
        playerSurvivor:getInventory():AddItem("Base.PillsSleepingTablets");
        playerSurvivor:getInventory():AddItem("Base.Splint");
    end
    for i = 1, 5 do
        playerSurvivor:getInventory():AddItem("Base.AlcoholBandage");
        playerSurvivor:getInventory():AddItem("Base.SutureNeedle");
    end
end

---comment
---@param targetSquare any
local function spawnZombiesAtSquare(targetSquare)
    local squareX = targetSquare:getX();
    local squareY = targetSquare:getY();
    local squareZ = targetSquare:getZ();
    local hordeSize = 1;
    local outfitString = nil;
    local isFemaleChance = 50;
    local spawnedZombie = addZombiesInOutfit(squareX, squareY, squareZ, hordeSize, outfitString, isFemaleChance);

    return spawnedZombie;
end
--
local PZNS_DebugBuildText = {
    SpawnMedical = "Spawn Medical",
    SpawnBooks = "Spawn Books",
    SpawnCannedTuna = "Spawn 5 Canned Tuna",
    SpawnNails = "Spawn 5 Nails Boxes",
    SpawnPlanks = "Spawn 10 Planks",
    SpawnPropaneTank = "Spawn 5 Propane Tank",
    SpawnMetalSheets = "Spawn 5 Metal Sheets",
    SpawnBigFenceGate = "Spawn 1 Big Fence Gate",
    SpawnBigWiredWall = "Spawn 1 Wired Wall",
    SpawnTools = "Spawn Tools",
};
---
local PZNS_DebugBuild = {
    SpawnMedical = addMedicalToLocalPlayer,
    SpawnBooks = addBooksToLocalPlayer,
    SpawnCannedTuna = addFiveCannedTunasToLocalPlayer,
    SpawnNails = addFiveNailsBoxesToLocalPlayer,
    SpawnPlanks = addTenPlanksToLocalPlayer,
    SpawnPropaneTank = addFivePropanTanksToLocalPlayer,
    SpawnMetalSheets = addMetalSheetsToLocalPlayer,
    SpawnBigFenceGate = addBigPoleFenceGate,
    SpawnBigWiredWall = addBigWiredWallMaterialsToLocalPlayer,
    SpawnTools = addToolsToLocalPlayer,
};

--- Cows: mpPlayerID is a placeholder, it doesn't do anything.
---@param mpPlayerID number
---@param context any
---@param worldobjects any
function PZNS_ContextMenuDebugBuild(mpPlayerID, context, worldobjects)
    if (SandboxVars.PZNS_Framework.IsDebugModeActive ~= true) then
        return;
    end
    --
    local submenu_1 = context:getNew(context);
    local submenu_1_Option = context:addOption(
        getText("PZNS_Debug_Build"),
        worldobjects,
        nil
    );
    context:addSubMenu(submenu_1_Option, submenu_1);
    --
    for debugKey, debugText in pairs(PZNS_DebugBuildText) do
        local callbackFunction = function()
            PZNS_DebugBuild[debugKey]();
        end
        --
        submenu_1:addOption(
            getText(debugText),
            nil,
            callbackFunction
        );
    end
end

-- Cows: Respawn Christ Tester
local function respawnChristTester()
    PZNS_DeleteChrisTester(0);
    PZNS_SpawnChrisTester();
end

-- Cows: Respawn Jill Tester
local function respawnJillTester()
    PZNS_DeleteJillTester(0)
    PZNS_SpawnJillTester();
end

--
local PZNS_DebugWorldText = {
    ClearPlayerNeeds = "Clear Player Needs",
    ClearAllNPCsNeeds = "Clear All NPCs Needs",
    SpawnChris = "(Re)Spawn Chris Tester",
    SpawnJill = "(Re)Spawn Jill Tester",
    SpawnZombie = "Spawn Zombie"
};
---
local PZNS_DebugWorld = {
    ClearPlayerNeeds = PZNS_PlayerUtils.PZNS_ClearPlayerAllNeeds,
    ClearAllNPCsNeeds = PZNS_UtilsNPCs.PZNS_ClearAllNPCsAllNeedsLevel,
    SpawnChris = respawnChristTester,
    SpawnJill = respawnJillTester,
    SpawnZombie = spawnZombiesAtSquare
};

--- Cows: mpPlayerID is a placeholder, it doesn't do anything and defaults to 0 in a local game.
---@param mpPlayerID number
---@param context any
---@param worldobjects any
function PZNS_ContextMenuDebugWorld(mpPlayerID, context, worldobjects)
    if (SandboxVars.PZNS_Framework.IsDebugModeActive ~= true) then
        return;
    end
    local submenu_1 = context:getNew(context);
    local submenu_1_Option = context:addOption(
        getText("PZNS_Debug_World"),
        worldobjects,
        nil
    );
    local square = PZNS_PlayerUtils.PZNS_GetPlayerMouseGridSquare(0);
    context:addSubMenu(submenu_1_Option, submenu_1);
    --
    for debugKey, debugText in pairs(PZNS_DebugWorldText) do
        -- Cows: conditionally set the callback function for the context menu option.
        local callbackFunction = function()
            if (debugKey ~= "SpawnZombie") then
                PZNS_DebugWorld[debugKey]();
            else
                PZNS_DebugWorld[debugKey](square);
            end
        end
        --
        submenu_1:addOption(
            getText(debugText),
            nil,
            callbackFunction
        );
    end
end

--
local PZNS_DebugWipeText = {
    WipeNPCs = "Wipe NPC Data",
    WipeGroups = "Wipe Groups Data",
    WipeZones = "Wipe Zones Data",
    WipeAll = "Wipe All Data"
};
---
local PZNS_DebugWipe = {
    WipeNPCs = PZNS_UtilsDataNPCs.PZNS_ClearNPCModData,
    WipeGroups = PZNS_UtilsDataGroups.PZNS_ClearGroupsModData,
    WipeZones = PZNS_UtilsDataZones.PZNS_ClearZonesData,
    WipeAll = PZNS_DebuggerUtils.PZNS_WipeAllData
};

--- Cows: mpPlayerID is a placeholder, it doesn't do anything.
---@param mpPlayerID number
---@param context any
---@param worldobjects any
function PZNS_ContextMenuDebugWipe(mpPlayerID, context, worldobjects)
    if (SandboxVars.PZNS_Framework.IsDebugModeActive ~= true) then
        return;
    end
    local submenu_1 = context:getNew(context);
    local submenu_1_Option = context:addOption(
        getText("PZNS_Debug_WipeData"),
        worldobjects,
        nil
    );
    context:addSubMenu(submenu_1_Option, submenu_1);
    --
    for debugKey, debugText in pairs(PZNS_DebugWipeText) do
        local callbackFunction = function()
            PZNS_DebugWipe[debugKey]();
        end
        --
        submenu_1:addOption(
            getText(debugText),
            nil,
            callbackFunction
        );
    end
end
