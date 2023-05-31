PZNS_NPCManager = {
    AciveNPCs = {}
};
PZNS_NPCManager.__index = PZNS_NPCManager;

--- Cows: Create a SurvivorDesc object for NPCSurvivor.npcIsoPlayerObject.
---@param isFemale boolean
---@param surname string | nil
---@param forename string | nil
---@return SurvivorDesc
function PZNS_NPCManager:createSurvivorDescObject(
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

--- Cows: The PZNS NPC Survivor uses the IsoPlayer from the base game as one of its properties.
--- Best to think of the other properties of PZNS_NPCSurvivor as extended properties for PZNS.
---@param survivorId any -- Cows: Need a way to guarantee this is unique...
---@param isFemale boolean
---@param surname string
---@param forename string
---@param square IsoGridSquare
---@return unknown
function PZNS_NPCManager:createNPCSurvivor(
    survivorId,
    isFemale,
    surname,
    forename,
    square
)
    -- Cows: Check if the survivorId is present before proceeding.
    if (survivorId == nil) then
        return nil;
    end
    local isLoggingLocalFunction = false;
    local playerSurvivor = getSpecificPlayer(0);
    local npcSurvivor;
    -- Cows: Now add the npcSurvivor to the PZNS_NPCManager if the ID does not exist.
    if (self.AciveNPCs[survivorId] == nil) then
        local squareZ = 0;
        -- Cows: It turns out this check is needed, otherwise NPCs may spawn in the air and fall...
        if (square:isSolidFloor()) then
            squareZ = square:getZ();
        end
        local survivorDescObject = self:createSurvivorDescObject(isFemale, surname, forename);
        local npcIsoPlayerObject = IsoPlayer.new(
            getWorld():getCell(),
            survivorDescObject,
            square:getX(),
            square:getY(),
            squareZ
        );
        npcIsoPlayerObject:setForname(forename); -- Cows: In case forename wasn't set...
        npcIsoPlayerObject:setSurname(surname);  -- Cows: Apparently the surname set at survivorDesc isn't automatically set to IsoPlayer...
        npcIsoPlayerObject:setNPC(true);
        npcIsoPlayerObject:setSceneCulled(false);

        npcSurvivor = PZNS_NPCSurvivor:newSurvivor(
            survivorId,
            nil,
            false,
            false,
            50,
            50,
            "",
            "",
            npcIsoPlayerObject
        );
        self.AciveNPCs[survivorId] = npcSurvivor;
        -- Debug Info
        if (isLoggingLocalFunction) then
            CreateLogLine("PZNS_NPCManager", isLoggingLocalFunction,
                "Creating Survivor: " .. tostring(forename) .. " " .. tostring(surname)
            );
            playerSurvivor:Say("Survivor: " .. tostring(forename) .. " " .. tostring(surname) .. " is spawning!");
        end
    else
        -- Cows: Else it's all debug Info
        if (isLoggingLocalFunction) then
            playerSurvivor:Say("Survivor: " .. tostring(forename) .. " " .. tostring(surname) .. " Already exists");
            CreateLogLine("PZNS_NPCManager", isLoggingLocalFunction,
                "Survivor: " .. tostring(forename) .. " " .. tostring(surname) .. " Already exists"
            );
            for k1, v1 in pairs(self.AciveNPCs) do
                CreateLogLine("PZNS_NPCManager", isLoggingLocalFunction,
                    "k1: " .. tostring(k1) .. " | v1: " .. tostring(v1)
                );
                for k2, v2 in pairs(v1) do
                    CreateLogLine("PZNS_NPCManager", isLoggingLocalFunction,
                        "k2: " .. tostring(k2) .. " | v2: " .. tostring(v2)
                    );
                end
            end
        end
        -- WIP - Cows: Alert player the ID is already used and the NPC cannot be created.
    end

    return npcSurvivor;
end

--- Cows: get all managed Active NPCs
---@return table
function PZNS_NPCManager:getAllActiveNpcs()
    return self.AciveNPCs;
end

---comment
---@param survivorId any
---@return any
function PZNS_NPCManager:getActiveNpcBySurvivorId(survivorId)
    if (self.AciveNPCs[survivorId] ~= nil) then
        return self.AciveNPCs[survivorId];
    end
    return nil;
end

---Cows: Delete a NpcSurvivor by specified survivorId
---@param survivorId any
function PZNS_NPCManager:deleteActiveNpcBySurvivorId(survivorId)
    local isLoggingLocalFunction = false;
    local npcSurvivor = self.AciveNPCs[survivorId];
    -- Cows: Check if npcSurvivor exists
    if (npcSurvivor ~= nil) then
        CreateLogLine("PZNS_NPCManager", isLoggingLocalFunction, "Deleting: " .. tostring(survivorId));
        -- Cows: Remove the IsoPlayer from the world then nil the table key-value data.
        npcSurvivor.npcIsoPlayerObject:removeFromWorld();
        npcSurvivor.npcIsoPlayerObject:removeFromSquare();
        self.AciveNPCs[survivorId] = nil;
    end
    -- Cows: Debug info
    if (isLoggingLocalFunction == true) then
        -- Cows: confirm npcSurvivor data is deleted from ActiveNpcs
        CreateLogLine("PZNS_NPCManager", isLoggingLocalFunction,
            "Confirming PZNS_NPCManager.AciveNPCs data deleted npcsurvivor...");
        for k1, v1 in pairs(self.AciveNPCs) do
            CreateLogLine("PZNS_NPCManager", isLoggingLocalFunction,
                "k1: " .. tostring(k1) .. " | v1: " .. tostring(v1)
            );
        end
    end
end
