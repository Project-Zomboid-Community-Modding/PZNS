require("00_references/init")

---@class NPCZone
---@field zoneID zoneID             Unique zone identifier
---@field name string               Zone name
---@field groupID groupID           associated group ID
---@field zoneType any              list of NPC survivorIDs
---@field zoneBoundaryX1 integer    first corner X
---@field zoneBoundaryX2 integer    first corner Y
---@field zoneBoundaryY1 integer    second corner X
---@field zoneBoundaryY2 integer    second corner Y
---@field zoneBoundaryZ integer     zone Z level
local NPCZone = {}

---Creates new zone
---@param zoneID? string
---@param name? string
---@param groupID groupID
---@param zoneType any
---@return table
function NPCZone:new(
    zoneID,
    name,
    groupID,
    zoneType
)
    local npcZone = {};
    setmetatable(npcZone, self)
    self.__index = self;

    npcZone.name = name
    npcZone.groupID = groupID
    npcZone.zoneType = zoneType
    npcZone.zoneBoundaryX1 = 0
    npcZone.zoneBoundaryX2 = 0
    npcZone.zoneBoundaryY1 = 0
    npcZone.zoneBoundaryY2 = 0
    npcZone.zoneBoundaryZ = 0
    npcZone.zoneID = zoneID or groupID .. "_" .. zoneType

    return npcZone;
end

return NPCZone
