require("00_references/init")

---@class NPCFaction
---@field factionID factionID Unique faction identifier
---@field name string Faction name
---@field leaderID survivorID NPC ID of faction leader
---@field memberCount integer number of members in faction
---@field members table<survivorID> list of faction members
local NPCFaction = {}


---Creates new faction with provided parameters and puts it to registry
---@param factionID factionID
---@param name string
---@param leaderID? survivorID
---@param members? table<survivorID>
---@return table faction Created faction
function NPCFaction:new(
    factionID,
    name,
    leaderID,
    members
)
    local faction = {}
    setmetatable(faction, self)
    self.__index = self

    faction.factionID = factionID
    faction.name = name
    faction.leaderID = leaderID
    faction.members = members
    faction.memberCount = #faction.members
    return faction
end

---Sets new leader for faction
---@param newLeaderID factionID
function NPCFaction:setLeader(newLeaderID)
    self.leaderID = newLeaderID
end

---Get list of faction members
---@return table<survivorID>
function NPCFaction:getMembers()
    local res = {}
    for i = 1, #self.members do
        res[i] = self.members[i]
    end
    return res
end

---Get number of group members
function NPCFaction:getMemberCount()
    return self.memberCount
end

---Added memberID to faction members
---@param memberID survivorID NPC survivorID of newly added member
function NPCFaction:addMember(memberID)
    if not memberID then return end
    self.members[self.memberCount + 1] = memberID
    self.memberCount = self.memberCount + 1
end

---Removes <memberID> from Faction members
---@param memberID survivorID NPC survivorID of member to remove
function NPCFaction:removeMember(memberID)
    if not memberID then return end
    if memberID == self.leaderID then
        self.leaderID = nil
    end
    for i = 1, #self.members do
        if self.members[i] == memberID then
            table.remove(self.members, i)
            self.memberCount = self.memberCount - 1
            return
        end
    end
end

---Rename group
---@param newName string  New name for group (length<50)
function NPCFaction:setName(newName)
    local limit = 50
    if not newName or newName == "" then error("Name not valid:" .. tostring(newName)) end
    if #newName > limit then error(string.format("Name too long: %d>%d", #newName, limit)) end
    self.name = newName
end

return NPCFaction
