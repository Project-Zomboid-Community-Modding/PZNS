PZNS_NPCSurvivor = {};
PZNS_NPCSurvivor.__index = PZNS_NPCSurvivor;

--- Cows: Construct the PZNS_NPCSurvivor.
---@param survivorID any                -- Cows: Unique Identifier for the current NPC
---@param groupID any                   -- Cows: nil or Unique Group Identifier for the current NPC
---@param isFollowing boolean           -- Cows: Flag for checking if NPC is following, which may prevent other actions or task from triggering...
---@param isHoldingInPlace boolean      -- Cows: Flag for checking is NPC is holding in place; true to prevent further movement until it is false.
---@param affection number              -- Cows: Placeholder, how the current NPC perceives the player
---@param courage number                -- Cows: Placeholder, how the current NPC may respond under certain conditions. Might be useless given moodles in the game...
---@param behaviorName string           -- Cows: A reference to a set of behaviors the current NPC could be act with.
---@param jobName string                -- Cows: A reference to a set of jobs the current NPC is working in.
---@param npcIsoPlayerObject IsoPlayer  -- Cows: The actual IsoPlayer object the current NPC is spawned in as. NPCUtils will mostly interact with this object.
---@return table
function PZNS_NPCSurvivor:newSurvivor(
    survivorID,
    groupID,
    isFollowing,
    isHoldingInPlace,
    affection,
    courage,
    behaviorName,
    jobName,
    npcIsoPlayerObject
)
    local NPCSurvivor = {};
    setmetatable(NPCSurvivor, self)
    self.__index = self;

    NPCSurvivor = {
        survivorID = survivorID,
        groupID = groupID,
        isFollowing = isFollowing,
        isHoldingInPlace = isHoldingInPlace,
        affection = affection,
        courage = courage,
        behaviorName = behaviorName,
        jobName = jobName,
        npcIsoPlayerObject = npcIsoPlayerObject
    };

    return NPCSurvivor;
end

--- Cows: Start the Setters and Getters. ---

function PZNS_NPCSurvivor:setSurvivorID(inputVal)
    self.survivorID = inputVal;
end

---comment
---@return any
function PZNS_NPCSurvivor:getSurvivorID()
    return self.survivorID;
end

function PZNS_NPCSurvivor:setGroupID(inputVal)
    self.groupID = inputVal;
end

---comment
---@return boolean
function PZNS_NPCSurvivor:getGroupID()
    return self.groupID;
end

function PZNS_NPCSurvivor:setIsFollowing(inputVal)
    self.isFollowing = inputVal;
end

---comment
---@return boolean
function PZNS_NPCSurvivor:getIsFollowing()
    return self.isFollowing;
end

function PZNS_NPCSurvivor:setIsHoldingInPlace(inputVal)
    self.isHoldingInPlace = inputVal;
end

---comment
---@return boolean
function PZNS_NPCSurvivor:getIsHoldingInPlace()
    return self.isHoldingInPlace;
end

function PZNS_NPCSurvivor:setAffection(inputVal)
    self.affection = inputVal;
end

---comment
---@return number
function PZNS_NPCSurvivor:getAffection()
    return self.affection;
end

function PZNS_NPCSurvivor:setCourage(inputVal)
    self.courage = inputVal;
end

---comment
---@return number
function PZNS_NPCSurvivor:getCourage()
    return self.courage;
end

function PZNS_NPCSurvivor:setBehaviorName(inputVal)
    self.behaviorName = inputVal;
end

---comment
---@return string
function PZNS_NPCSurvivor:getBehaviorName()
    return self.behaviorName;
end

function PZNS_NPCSurvivor:setJobName(inputVal)
    self.jobName = inputVal;
end

---comment
---@return string
function PZNS_NPCSurvivor:getJobName()
    return self.jobName;
end

function PZNS_NPCSurvivor:setnpcIsoPlayerObject(inputVal)
    self.npcIsoPlayerObject = inputVal;
end

---comment
---@return IsoPlayer
function PZNS_NPCSurvivor:getnpcIsoPlayerObject()
    return self.npcIsoPlayerObject;
end

--- Cows: End Setters and Getters. ---

--- Cows: Added to streamline location request.
---@return IsoGridSquare
function PZNS_NPCSurvivor:getNPCSquare()
    return self.npcIsoPlayerObject:getSquare();
end
