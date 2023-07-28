--[[
    Cows: This file is intended for ALL functions related to the creation, deletion, load,
    and editing of all NPC mod file data and moddata.
--]]
PZNS_ActiveNPCs = {}; -- WIP - Cows: Need to rethink how Global variables are used...
-- Cows: This variable should never be referenced directly, but through the corresponding management functions.
local PZNS_UtilsDataNPCs = {};

--- Cows: Gets or creates the moddata for NPCs
function PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData()
    PZNS_ActiveNPCs = ModData.getOrCreate("PZNS_ActiveNPCs");
    return PZNS_ActiveNPCs;
end

--- Cows: Load NPCs Data
--- Cows: Need to account for inventory, traits, skills, and all the other mod-related data...
--- Cows: This is because objects cannot be saved to moddata, and everything must be reloaded whenever the game starts.
function PZNS_UtilsDataNPCs.PZNS_InitLoadNPCsData()
    --
    if (PZNS_ActiveNPCs) then
        --
        for npcSurvivorID, npcSurvivor in pairs(PZNS_ActiveNPCs) do
            local npcFileName = PZNS_UtilsDataNPCs.PZNS_GetGameSaveDir() .. tostring(npcSurvivorID);
            local isSaveFileValid = fileExists(npcFileName);
            -- Cows: Check if SaveFile is valid
            if (isSaveFileValid) then
                -- Cows: Spawn the npcSurvivor if the npcIsoPlayerObject has not been loaded yet.
                if (npcSurvivor.npcIsoPlayerObject == nil) then
                    PZNS_UtilsDataNPCs.PZNS_SpawnNPCFromModData(npcSurvivor);
                end
            else -- Cows: Else assume the save file was manually deleted and clear it from the moddata table.
                PZNS_ActiveNPCs[npcSurvivorID] = nil;
            end
        end
    end
end

--- Cows: Get the current game's save folder, the output string is used to save IsoPlayer data using the current default IsoPlayer:save() API call
--- https://projectzomboid.com/modding/zombie/characters/IsoPlayer.html#save()
---@return string
function PZNS_UtilsDataNPCs.PZNS_GetGameSaveDir()
    local stringPath = tostring(Core.getMyDocumentFolder() ..
        getFileSeparator() ..
        "Saves" ..
        getFileSeparator() ..
        getWorld():getGameMode() .. getFileSeparator() .. getWorld():getWorld() .. getFileSeparator()
    );
    return stringPath;
end

--- Cows: Create a SurvivorDesc object for NPCSurvivor.npcIsoPlayerObject.
---@param isFemale boolean
---@param surname string | nil
---@param forename string | nil
---@return SurvivorDesc
function PZNS_UtilsDataNPCs.PZNS_CreateNPCSurvivorDescObject(
    isFemale,
    surname,
    forename
)
    ---@diagnostic disable-next-line: param-type-mismatch
    local survivorDescObject = SurvivorFactory.CreateSurvivor(nil, isFemale);

    if (surname) then
        survivorDescObject:setSurname(surname);
    end

    if (forename) then
        survivorDescObject:setForename(forename);
    end

    return survivorDescObject;
end

--- Cows: Save NPC data to moddata and save folder data.
--- Cows: Currently using the Java API for IsoPlayer:save() to save the data to the zomboid/sandbox/save/<folder>
--- https://projectzomboid.com/modding/zombie/characters/IsoPlayer.html#save()
function PZNS_UtilsDataNPCs.PZNS_SaveNPCData(npcSurvivorID, npcSurvivor)
    if (npcSurvivor == nil) then
        return nil;
    end
    local fileName = PZNS_UtilsDataNPCs.PZNS_GetGameSaveDir() .. tostring(npcSurvivorID);
    -- Updated the npcSurvivor attributes/properties as needed before saving.
    --
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    --
    if (npcIsoPlayer ~= nil) then
        npcSurvivor.isAlive = npcIsoPlayer:isAlive();
        npcSurvivor.squareX = npcIsoPlayer:getX();
        npcSurvivor.squareY = npcIsoPlayer:getY();
        npcSurvivor.squareZ = npcIsoPlayer:getZ();
        --
        if (npcIsoPlayer:getModData().survivorID == nil) then
            npcIsoPlayer:getModData().survivorID = npcSurvivor.survivorID;
        end
        npcIsoPlayer:save(fileName);
    end
    -- Actual Saving
    PZNS_ActiveNPCs[npcSurvivorID] = npcSurvivor;
end

--- Cows: Save ALL ActiveNPCs Data
function PZNS_UtilsDataNPCs.PZNS_SaveAllNPCData()
    for npcSurvivorID, npcSurvivor in pairs(PZNS_ActiveNPCs) do
        PZNS_UtilsDataNPCs.PZNS_SaveNPCData(npcSurvivorID, npcSurvivor);
    end
end

--- Cows: Spawn the npcs from moddata after loading saved data from the save folder.
---@param npcSurvivor any
---@return any
function PZNS_UtilsDataNPCs.PZNS_SpawnNPCFromModData(npcSurvivor)
    if (npcSurvivor == nil) then
        return;
    end

    if (npcSurvivor.isAlive == true) then
        local npcSurvivorDesc = PZNS_UtilsDataNPCs.PZNS_CreateNPCSurvivorDescObject(
            npcSurvivor.isFemale,
            npcSurvivor.surname,
            npcSurvivor.forename
        );
        local npcSurvivorID = npcSurvivor.survivorID;
        local npcFileName = PZNS_UtilsDataNPCs.PZNS_GetGameSaveDir() .. tostring(npcSurvivorID);
        local npcIsoPlayerObject = IsoPlayer.new(
            getWorld():getCell(),
            npcSurvivorDesc,
            npcSurvivor.squareX, npcSurvivor.squareY, npcSurvivor.squareZ
        );
        --
        npcSurvivor.npcIsoPlayerObject = npcIsoPlayerObject;
        npcSurvivor.npcIsoPlayerObject:load(npcFileName);
        npcSurvivor.npcIsoPlayerObject:setNPC(true);
        npcSurvivor.npcIsoPlayerObject:setSceneCulled(false);
        npcSurvivor.textObject = TextDrawObject.new();
        npcSurvivor.textObject:setAllowAnyImage(true);
        npcSurvivor.textObject:setDefaultFont(UIFont.Small);
        npcSurvivor.textObject:setDefaultColors(255, 255, 255);
        npcSurvivor.textObject:ReadString(npcSurvivor.survivorName);
        npcSurvivor.isSpawned = true;
    end
    return npcSurvivor;
end

---Cows: Helper function for PZNS_ClearModData()
---@param npcSurvivor any
function PZNS_UtilsDataNPCs.PZNS_RemoveNPCSaveFile(npcSurvivor)
    if (npcSurvivor ~= nil) then
        local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
        if (npcIsoPlayer ~= nil) then
            npcIsoPlayer:removeSaveFile();
        end
    end
end

--- Cows: This will wipe the NPC moddata
function PZNS_UtilsDataNPCs.PZNS_ClearNPCModData()
    PZNS_ActiveNPCs = {};
    ModData.remove("PZNS_ActiveNPCs");
end

--- WIP - Cows: Check if the NPC save file exists in the game save directory.
function PZNS_UtilsDataNPCs.PZNS_CheckIfSaveFileExists(npcSurvivorID)
    local npcFileName = PZNS_UtilsDataNPCs.PZNS_GetGameSaveDir() .. tostring(npcSurvivorID);
    return false;
end

--- WIP - Cows: Called to clean up PZNS_ActiveNPCs moddata if save file doesn't exist for the NPC.
function PZNS_UtilsDataNPCs.PZNS_RemoveAllNPCsWithoutSaveFile()
    for npcSurvivorID, npcSurvivor in pairs(PZNS_ActiveNPCs) do
        local isFileExists = PZNS_UtilsDataNPCs.PZNS_CheckIfSaveFileExists(npcSurvivorID);
        if (isFileExists == false) then
            PZNS_ActiveNPCs[npcSurvivorID] = nil;
        end
    end
end

return PZNS_UtilsDataNPCs;
