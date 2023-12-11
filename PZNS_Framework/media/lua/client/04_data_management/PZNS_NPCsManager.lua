require("00_references/init")

local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_UtilsDataGroups = require("02_mod_utils/PZNS_UtilsDataGroups")
local PZNS_Utils = require("02_mod_utils/PZNS_Utils")
local PZNS_NPCSurvivor = require("03_mod_core/PZNS_NPCSurvivor")
local PZNS_NPCGroup = require("03_mod_core/PZNS_NPCGroup")


PZNS_ActiveInventoryNPC = {}; -- WIP - Cows: Need to rethink how Global variables are used...

local PZNS_NPCsManager = {};

---Get NPC by its survivorID
---@param survivorID survivorID
---@return PZNS_NPCSurvivor?
function PZNS_NPCsManager.getNPC(survivorID)
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    return activeNPCs[survivorID]
end

---Try to find NPC by its isoObject
---@param isoPlayer IsoPlayer
---@return PZNS_NPCSurvivor?
function PZNS_NPCsManager.findNPCByIsoObject(isoPlayer)
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    for _, npc in pairs(activeNPCs) do
        if npc.npcIsoPlayerObject == isoPlayer then
            return npc
        end
    end
end

---Get Group by its groupID
---@param groupID groupID
---@return PZNS_NPCGroup?
local function getGroup(groupID)
    local activeGroups = PZNS_UtilsDataGroups.PZNS_GetCreateActiveGroupsModData()
    return activeGroups[groupID]
end

---Create IsoPlayer object with provided params at `square`
---@param square IsoGridSquare Square that NPC will spawn on
---@param isFemale boolean
---@param surname string
---@param forename string
---@param survivorID survivorID unique ID, will be set to isoPlayer modData
---@param outfit string Name of the outfit you want to apply
---@return IsoPlayer isoPlayer player object
---@return integer squareZ Z-level that NPC was created at
local function createIsoPlayer(square, isFemale, surname, forename, survivorID, outfit)
    local squareZ = 0;
    -- Cows: It turns out this check is needed, otherwise NPCs may spawn in the air and fall...
    if (square:isSolidFloor()) then
        squareZ = square:getZ();
    end
    --
    local survivorDescObject = PZNS_UtilsDataNPCs.PZNS_CreateNPCSurvivorDescObject(isFemale, surname, forename);
    if outfit ~= nil then
        survivorDescObject:dressInNamedOutfit(outfit)
    end
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
    return npcIsoPlayerObject, squareZ
end

--- Cows: The PZNS_NPCSurvivor uses the IsoPlayer from the base game as one of its properties.
--- Best to think of the other properties of PZNS_NPCSurvivor as extended properties for PZNS.
---@param survivorID survivorID -- Cows: Need a way to guarantee this is unique...
---@param isFemale boolean
---@param surname string
---@param forename string
---@param square IsoGridSquare Square that NPC will spawn on
---@param isoPlayer IsoPlayer? if passed - skip IsoPlayer creation
---@param outfit string? Name of the outfit you want to apply
---@return PZNS_NPCSurvivor
function PZNS_NPCsManager.createNPCSurvivor(
    survivorID,
    isFemale,
    surname,
    forename,
    square,
    isoPlayer,
    outfit
)
    -- Cows: Check if the survivorID is present before proceeding.
    if (survivorID == nil) then
        error("survivorID not set")
    end
    local npcSurvivor = nil;
    -- Cows: Now add the npcSurvivor to the PZNS_NPCsManager if the ID does not exist.
    local npc = PZNS_NPCsManager.getNPC(survivorID)
    local squareZ = 0
    if (not npc) then
        local survivorName = forename .. " " .. surname; -- Cows: in case getName() functions break down or can't be used...
        --
        if not isoPlayer then
            isoPlayer, squareZ = createIsoPlayer(square, isFemale, surname, forename, survivorID, outfit)
        else
            if not instanceof(isoPlayer, "IsoPlayer") then
                print(string.format("IsoPlayer is not valid for '%s'! Will create new one", survivorID))
                isoPlayer, squareZ = createIsoPlayer(square, isFemale, surname, forename, survivorID, outfit)
            else
                squareZ = isoPlayer:getSquare():getZ()
            end
        end

        ---@type PZNS_NPCSurvivor
        npcSurvivor = PZNS_NPCSurvivor:new(
            survivorID,
            survivorName,
            isoPlayer
        );
        npcSurvivor.isFemale = isFemale;
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
        print(string.format("NPC already exist! ID: %s", survivorID))
        npcSurvivor = npc
        if not isoPlayer then
            isoPlayer, squareZ = createIsoPlayer(square, isFemale, surname, forename, survivorID, outfit)
        end
        if not npcSurvivor.npcIsoPlayerObject then
            npcSurvivor.npcIsoPlayerObject = isoPlayer
        end
    end
    return npcSurvivor;
end

---Set `PZNS_NPCSurvivor` group ID to `groupID`
---@param survivorID survivorID
---@param groupID groupID? leave empty to unset group
function PZNS_NPCsManager.setGroupID(survivorID, groupID)
    local npc = PZNS_NPCsManager.getNPC(survivorID)
    if not PZNS_Utils.npcCheck(npc, survivorID) then return end ---@cast npc PZNS_NPCSurvivor
    if groupID then
        local group = getGroup(groupID)
        if not PZNS_Utils.groupCheck(group, groupID) then return end
        if not PZNS_NPCGroup.isMember(group, survivorID) then
            PZNS_NPCGroup.addMember(group, survivorID)
        end
    end
    PZNS_NPCSurvivor.setGroupID(npc, groupID)
end

---Cows: Get a npcSurvivor by specified survivorID
---@param survivorID survivorID
---@return PZNS_NPCSurvivor?
function PZNS_NPCsManager.getActiveNPCBySurvivorID(survivorID)
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    if (activeNPCs[survivorID] ~= nil) then
        return activeNPCs[survivorID];
    end
    return nil;
end

---Cows: Delete a npcSurvivor by specified survivorID
---@param survivorID survivorID
function PZNS_NPCsManager.deleteActiveNPCBySurvivorID(survivorID)
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    local npcSurvivor = activeNPCs[survivorID];
    -- Cows: Check if npcSurvivor exists
    if (npcSurvivor ~= nil) then
        local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
        -- Cows Check if IsoPlayer object exists.
        if (npcIsoPlayer ~= nil) then
            -- Cows: Remove the IsoPlayer from the world then nil the table key-value data.
            npcIsoPlayer:removeFromSquare();
            npcIsoPlayer:removeFromWorld();
            npcIsoPlayer:removeSaveFile(); -- Cows: Remove the IsoPlayer SaveFile? I am curious about how it tracks the save file...
        end
        activeNPCs[survivorID] = nil;
    end
end

---comment
---@param survivorID survivorID
function PZNS_NPCsManager.setActiveInventoryNPCBySurvivorID(survivorID)
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    local npcSurvivor = activeNPCs[survivorID];
    PZNS_ActiveInventoryNPC = npcSurvivor;
end

--- WIP - Cows: Spawn a random raider NPC.
--- Cows: Go make your own random spawns, this is an example for debugging and testing.
---@param targetSquare IsoGridSquare square to spawn NPC on
---@param raiderID string | nil if provided - will be used as survivorID for NPC
---@return PZNS_NPCSurvivor raider created raider NPC
function PZNS_NPCsManager.spawnRandomRaiderSurvivorAtSquare(targetSquare, raiderID)
    local isFemale = ZombRand(100) > 50; -- Cows: 50/50 roll for female spawn
    local raiderForeName = SurvivorFactory.getRandomForename(isFemale);
    local raiderSurname = SurvivorFactory.getRandomSurname();
    local raiderName = raiderForeName .. " " .. raiderSurname;
    local gameTimeStampString = tostring(getTimestampMs());
    -- Cows: I recommend replacing the "PZNS_Raider_" prefix if another modder wants to create their own random spawns. As long as the ID is unique, there shouldn't be a problem
    local raiderSurvivorID = "PZNS_Raider_" .. raiderForeName .. "_" .. raiderSurname .. "_" .. gameTimeStampString;
    if (raiderID ~= nil) then
        raiderSurvivorID = raiderID;
    end
    --
    local raiderSurvivor = PZNS_NPCsManager.createNPCSurvivor(
        raiderSurvivorID,
        isFemale,
        raiderSurname,
        raiderForeName,
        targetSquare
    );
    raiderSurvivor.isRaider = true;                             -- Cows: MAKE SURE THIS FLAG IS SET TO 'true' - DIFFERENTIATE NORMAL NPCS FROM RAIDERS.
    raiderSurvivor.affection = 0;                               -- Cows: Raiders will never hold any love for players.
    raiderSurvivor.textObject:setDefaultColors(225, 0, 0, 0.8); -- Red text
    raiderSurvivor.textObject:ReadString(raiderName);
    raiderSurvivor.canSaveData = false;
    -- Cows: Setup the skills and outfit, plus equipment...
    PZNS_UtilsNPCs.PZNS_SetNPCPerksRandomly(raiderSurvivor);
    -- Cows: Bandanas - https://pzwiki.net/wiki/Bandana#Variants / Balaclava https://pzwiki.net/wiki/Balaclava
    PZNS_UtilsNPCs.PZNS_AddEquipClothingNPCSurvivor(raiderSurvivor, "Base.Hat_BandanaMask"); -- Cows: Bandits and Raiders always wears a mask...
    PZNS_UtilsNPCs.PZNS_AddEquipClothingNPCSurvivor(raiderSurvivor, "Base.Shirt_HawaiianRed");
    PZNS_UtilsNPCs.PZNS_AddEquipClothingNPCSurvivor(raiderSurvivor, "Base.Trousers_Denim");
    PZNS_UtilsNPCs.PZNS_AddEquipClothingNPCSurvivor(raiderSurvivor, "Base.Socks");
    PZNS_UtilsNPCs.PZNS_AddEquipClothingNPCSurvivor(raiderSurvivor, "Base.Shoes_ArmyBoots");
    local spawnWithGun = ZombRand(0, 100) > 50;
    if (spawnWithGun) then
        PZNS_UtilsNPCs.PZNS_AddEquipWeaponNPCSurvivor(raiderSurvivor, "Base.Pistol");
        PZNS_UtilsNPCs.PZNS_SetLoadedGun(raiderSurvivor);
        PZNS_UtilsNPCs.PZNS_AddItemToInventoryNPCSurvivor(raiderSurvivor, "Base.9mmClip");
        PZNS_UtilsNPCs.PZNS_AddItemsToInventoryNPCSurvivor(raiderSurvivor, "Base.Bullets9mm", 15);
        PZNS_UtilsNPCs.PZNS_AddItemsToInventoryNPCSurvivor(raiderSurvivor, "Base.Bullets9mm", 15);
    else
        PZNS_UtilsNPCs.PZNS_AddEquipWeaponNPCSurvivor(raiderSurvivor, "Base.BaseballBat");
    end
    -- Cows: Set the job last, otherwise the NPC will function as if it didn't have a weapon.
    PZNS_UtilsNPCs.PZNS_SetNPCJob(raiderSurvivor, "Wander In Cell")
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    activeNPCs[raiderSurvivorID] = raiderSurvivor; -- Cows: This saves it to modData, which allows the npc to run while in-game, but does not create a save file.
    return raiderSurvivor;
end

--- WIP - Cows: Spawn a random NPC.
--- Cows: Go make your own random spawns, this is an example for debugging and testing.
---@param targetSquare IsoGridSquare square to spawn NPC on
---@param survivorID string | nil if provided - will be used as survivorID for NPC
---@return PZNS_NPCSurvivor survivor created survivor NPC
function PZNS_NPCsManager.spawnRandomNPCSurvivorAtSquare(targetSquare, survivorID)
    local isFemale = ZombRand(100) > 50; -- Cows: 50/50 roll for female spawn
    local npcForeName = SurvivorFactory.getRandomForename(isFemale);
    local npcSurname = SurvivorFactory.getRandomSurname();
    local gameTimeStampString = tostring(getTimestampMs());
    -- Cows: I recommend replacing the "PZNS_Survivor_" prefix if another modder wants to create their own random spawns. As long as the ID is unique, there shouldn't be a problem
    local npcSurvivorID = "PZNS_Survivor_" .. npcForeName .. "_" .. npcSurname .. "_" .. gameTimeStampString;
    if (survivorID ~= nil) then
        npcSurvivorID = survivorID;
    end
    --
    local npcSurvivor = PZNS_NPCsManager.createNPCSurvivor(
        npcSurvivorID,
        isFemale,
        npcSurname,
        npcForeName,
        targetSquare
    );
    npcSurvivor.affection = ZombRand(100); -- Cows: Random between 0 and 100 affection, not everyone will love the player.
    npcSurvivor.canSaveData = false;
    -- Cows: Setup the skills and outfit, plus equipment...
    PZNS_UtilsNPCs.PZNS_SetNPCPerksRandomly(npcSurvivor);
    --
    PZNS_UtilsNPCs.PZNS_AddEquipClothingNPCSurvivor(npcSurvivor, "Base.Tshirt_WhiteTINT");
    PZNS_UtilsNPCs.PZNS_AddEquipClothingNPCSurvivor(npcSurvivor, "Base.Trousers_Denim");
    PZNS_UtilsNPCs.PZNS_AddEquipClothingNPCSurvivor(npcSurvivor, "Base.Socks");
    PZNS_UtilsNPCs.PZNS_AddEquipClothingNPCSurvivor(npcSurvivor, "Base.Shoes");
    local spawnWithGun = ZombRand(0, 100) > 50;
    if (spawnWithGun) then
        PZNS_UtilsNPCs.PZNS_AddEquipWeaponNPCSurvivor(npcSurvivor, "Base.Pistol");
        PZNS_UtilsNPCs.PZNS_SetLoadedGun(npcSurvivor);
        PZNS_UtilsNPCs.PZNS_AddItemToInventoryNPCSurvivor(npcSurvivor, "Base.9mmClip");
        PZNS_UtilsNPCs.PZNS_AddItemsToInventoryNPCSurvivor(npcSurvivor, "Base.Bullets9mm", 15);
        PZNS_UtilsNPCs.PZNS_AddItemsToInventoryNPCSurvivor(npcSurvivor, "Base.Bullets9mm", 15);
    else
        PZNS_UtilsNPCs.PZNS_AddEquipWeaponNPCSurvivor(npcSurvivor, "Base.BaseballBat");
    end
    -- Cows: Set the job last, otherwise the NPC will function as if it didn't have a weapon.
    PZNS_UtilsNPCs.PZNS_SetNPCJob(npcSurvivor, "Wander In Cell")
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    activeNPCs[npcSurvivorID] = npcSurvivor; -- Cows: This saves it to modData, which allows the npc to run while in-game, but does not create a save file.
    return npcSurvivor;
end

return PZNS_NPCsManager;
