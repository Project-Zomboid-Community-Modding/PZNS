PZNS_NPCZone = {};
PZNS_NPCZone.__index = PZNS_NPCZone;

---comment
---@param groupID any
---@param zoneType any
---@return table
function PZNS_NPCZone:newZone(
    groupID,
    zoneType
)
    local npcZone = {};
    setmetatable(npcZone, self)
    self.__index = self;

    npcZone = {
        zoneID = groupID .. "_" .. zoneType,
        groupID = groupID,
        zoneType = zoneType,
        zoneBoundaryX1 = 0,
        zoneBoundaryX2 = 0,
        zoneBoundaryY1 = 0,
        zoneBoundaryY2 = 0,
        zoneBoundaryZ = 0,
    };

    return npcZone;
end
