PZNS_NPCGroup = {};
PZNS_NPCGroup.__index = PZNS_NPCGroup;

--- Cows: can set the group leader later.
---@param groupID any
---@return table
function PZNS_NPCGroup:newGroup(
    groupID
)
    local npcGroup = {};
    setmetatable(npcGroup, self)
    self.__index = self;

    npcGroup = {
        groupID = groupID,
        groupLeader = "",  -- Cows: Probably useless... since only the player can actually "lead" by giving commands and designate zones.
        -- groupMembers = "", -- Cows: Probably useless... since we can map npcIDs as keys and values to the group.
        -- groupHomeZone = "" --  Cows: Probably useless... Zones are tied to the groupID.
    };

    return npcGroup;
end
