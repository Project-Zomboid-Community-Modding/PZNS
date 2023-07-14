PZNS_ActiveInventoryNPC = {}; -- WIP - Cows: Need to rethink how Global variables are used...

local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_NPCsManager = {};

--- Cows: The PZNS_NPCSurvivor uses the IsoPlayer from the base game as one of its properties.
--- Best to think of the other properties of PZNS_NPCSurvivor as extended properties for PZNS.
---@param survivorID any -- Cows: Need a way to guarantee this is unique...
---@param isFemale boolean
---@param surname string
---@param forename string
---@param square IsoGridSquare
---@return unknown
function PZNS_NPCsManager.createNPCSurvivor(
    survivorID,
    isFemale,
    surname,
    forename,
    square
)
    -- Cows: Check if the survivorID is present before proceeding.
    if (survivorID == nil) then
        return nil;
    end
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    local npcSurvivor = nil;
    -- Cows: Now add the npcSurvivor to the PZNS_NPCsManager if the ID does not exist.
    if (activeNPCs[survivorID] == nil) then
        local squareZ = 0;
        -- Cows: It turns out this check is needed, otherwise NPCs may spawn in the air and fall...
        if (square:isSolidFloor()) then
            squareZ = square:getZ();
        end
        --
        local survivorDescObject = PZNS_UtilsDataNPCs.PZNS_CreateNPCSurvivorDescObject(isFemale, surname, forename);
        local npcIsoPlayerObject = IsoPlayer.new(
            getWorld():getCell(),
            survivorDescObject,
            square:getX(),
            square:getY(),
            squareZ
        );
        --
        npcIsoPlayerObject:getModData().survivorID = survivorID;
        --
        npcIsoPlayerObject:setForname(forename); -- Cows: In case forename wasn't set...
        npcIsoPlayerObject:setSurname(surname);  -- Cows: Apparently the surname set at survivorDesc isn't automatically set to IsoPlayer...
        npcIsoPlayerObject:setNPC(true);
        npcIsoPlayerObject:setSceneCulled(false);
        local survivorName = forename .. " " .. surname; -- Cows: in case getName() functions break down or can't be used...
        --
        npcSurvivor = PZNS_NPCSurvivor:newSurvivor(
            survivorID,
            survivorName,
            npcIsoPlayerObject
        );
        npcSurvivor.isFemale = isFemale;
        npcSurvivor.isSpawned = true;
        npcSurvivor.forename = forename;
        npcSurvivor.surname = surname;
        npcSurvivor.squareX = square:getX();
        npcSurvivor.squareY = square:getY();
        npcSurvivor.squareZ = squareZ;
        npcSurvivor.textObject = TextDrawObject.new();
        npcSurvivor.textObject:setAllowAnyImage(true);
        npcSurvivor.textObject:setDefaultFont(UIFont.Small);
        npcSurvivor.textObject:setDefaultColors(255, 255, 255);
        npcSurvivor.textObject:ReadString(survivorName);
    else
        -- WIP - Cows: Alert player the ID is already used and the NPC cannot be created.
    end

    return npcSurvivor;
end

---Cows: Get a npcSurvivor by specified survivorID
---@param survivorID any
---@return any
function PZNS_NPCsManager.getActiveNPCBySurvivorID(survivorID)
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    if (activeNPCs[survivorID] ~= nil) then
        return activeNPCs[survivorID];
    end
    return nil;
end

---Cows: Delete a npcSurvivor by specified survivorID
---@param survivorID any
function PZNS_NPCsManager.deleteActiveNPCBySurvivorID(survivorID)
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    local npcSurvivor = activeNPCs[survivorID];
    -- Cows: Check if npcSurvivor exists
    if (npcSurvivor ~= nil) then
        local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
        -- Cows Check if IsoPlayer object exists.
        if (npcIsoPlayer ~= nil) then
            -- Cows: Remove the IsoPlayer from the world then nil the table key-value data.
            npcIsoPlayer:removeFromWorld();
            npcIsoPlayer:removeFromSquare();
            npcIsoPlayer:removeSaveFile(); -- Cows: Remove the IsoPlayer SaveFile? I am curious about how it tracks the save file...
        end
        activeNPCs[survivorID] = nil;
    end
end

---comment
---@param survivorID any
function PZNS_NPCsManager.setActiveInventoryNPCBySurvivorID(survivorID)
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    local npcSurvivor = activeNPCs[survivorID];
    PZNS_ActiveInventoryNPC = npcSurvivor;
end

return PZNS_NPCsManager;
