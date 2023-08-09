PZNS_NPCSurvivor = {};
PZNS_NPCSurvivor.__index = PZNS_NPCSurvivor;

--- Cows: Construct the PZNS_NPCSurvivor.
---@param survivorID any                -- Cows: Unique Identifier for the current NPC
---@param survivorName any              -- Cows: Current NPC's name
---@param npcIsoPlayerObject IsoPlayer  -- Cows: The actual IsoPlayer object the current NPC is spawned in as. NPCUtils will mostly interact with this object.
---@return table
function PZNS_NPCSurvivor:newSurvivor(
    survivorID,
    survivorName,
    npcIsoPlayerObject
)
    local npcSurvivor = {};
    setmetatable(npcSurvivor, self);
    self.__index = self;

    npcSurvivor = {
        survivorID = survivorID,
        survivorName = survivorName,
        groupID = nil,
        affection = 50,                         -- WIP - Cows: Added this value as a check for invite-able NPCs... between 0 and 100? 0 Means 100% hostility and will attack.
        isForcedMoving = false,                 -- Cows: Added this flag to force NPCs to move and disengage from combat/other actions.
        isHoldingInPlace = false,               -- Cows: Prevent current NPC from moving if true
        isMeleeOnly = false,                    -- WIP - Cows: Will eventually be used in more complex combat AI.
        isRaider = false,                       -- WIP - Cows: Used to test raiding NPCs
        isSavedInWorld = false,                 -- Cows: Added so that NPC can be checked and saved when it is off-screen.
        courage = 50,                           -- WIP - Cows: Considered for evaluating when NPCs should "flee" from hostility
        jobName = "Guard",                      -- Cows: Defaults to a job managed by PZNS
        jobSquare = nil,                        -- Cows: The square at which the NPC do its job (pickup item, chop tree, etc.)
        isJobRefreshed = false,                 -- Cows: This is a flag to check for NPCs to "refresh" their job status.
        currentAction = "",                     -- Cows: This is a value to check for NPCs to queue or not queue up more actions.
        isStuckTicks = 0,                       -- Cows: This is a value to check if NPC is "stuck" or doing nothing even though it has a job.
        followTargetID = "",                    -- Cows: Used to follow a specified object managed by PZNS IDs
        speechTable = nil,                      -- Cows: Used when adding speech table(s), if nil, NPCs should use PresetsSpeeches instead.
        lastEquippedMeleeWeapon = "",           -- WIP - Cows: Added so that NPCs can resume using this melee weapon after completing an action.
        lastEquippedRangeWeapon = "",           -- WIP - Cows: Added so that NPCs can resume using this range weapon after completing an action.
        idleTicks = 0,                          -- Cows: Used to track how long an NPC is idle for before they take some general AI stuff.
        actionTicks = 0,                        -- Cows: This is a value used to determine the frequency of an action being called, most notably with multi-stage actions (such as reloading).
        attackTicks = 0,                        -- Cows: I thought it was stupid at first, but after observing an NPC queue up 20+ attacks in a a single frame...
        speechTicks = 0,                        -- Cows: Tracks the ticks between speech text... ticks are inconsistent, but there are currently no other short duration timers.
        aimTarget = "",                         -- Cows: Used to identify the object the NPC is to aim at... but Java API has a "NPCSetAiming()" call which is confusing...
        canAttack = true,                       -- Cows: Added to prevent NPCs from taking attacking actions; Java API has a "NPCSetAttack()" call which is confusing; as it appears to force the NPC to attack.
        canSaveData = true,                     -- WIP - Cows: Added this flag to determine if NPC can be saved via data management.
        textObject = nil,                       -- Cows: This should handle all the text displayed by the NPC.
        ------ IsoPlayer Spawning Related below ------
        isAlive = true,                         -- WIP - Technically part of IsoPlayer; used when PZNS needs to use it before IsoPlayer is loaded.
        isSpawned = true,                       -- WIP - Technically part of IsoPlayer... but "isExistInTheWorld()" seems very inconsistent...
        forename = "",                          -- Cows: Placeholder; technically part of IsoPlayer; used when PZNS needs to use it before IsoPlayer is loaded.
        surname = "",                           -- Cows: Placeholder; technically part of IsoPlayer; used when PZNS needs to use it before IsoPlayer is loaded.
        isFemale = false,                       -- Cows: Placeholder; technically part of IsoPlayer; used when PZNS needs to use it before IsoPlayer is loaded.
        squareX = nil,                          -- Cows: Placeholder; technically part of IsoPlayer; used when PZNS needs to use it before IsoPlayer is loaded.
        squareY = nil,                          -- Cows: Placeholder; technically part of IsoPlayer; used when PZNS needs to use it before IsoPlayer is loaded.
        squareZ = nil,                          -- Cows: Placeholder; technically part of IsoPlayer; used when PZNS needs to use it before IsoPlayer is loaded.
        npcIsoPlayerObject = npcIsoPlayerObject -- Cows: objects cannot be saved to moddata...
    };

    return npcSurvivor;
end
