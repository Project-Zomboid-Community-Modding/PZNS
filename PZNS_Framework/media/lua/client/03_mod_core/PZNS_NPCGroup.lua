require("00_references/init")

---@class Group
---@field groupID groupID           Unique group identifier
---@field name string               Group name
---@field leaderID survivorID       NPC ID of group leader
---@field members table<survivorID> list of group members
---@field memberCount integer       number of members in group
---@field factionID factionID?      Faction this group belongs to
local Group = {}

-- - Cows: can set the group leader later.
--- Creates new group with provided parameters and puts it to registry
---@param groupID groupID
---@param name string
---@param leaderID survivorID
---@param members? table<survivorID>
---@param factionID? factionID
---@return Group
function Group:new(
    groupID,
    name,
    leaderID,
    members,
    factionID
)
    local group = {};
    group.groupID = groupID
    group.name = name
    group.leaderID = leaderID
    group.members = members
    group.factionID = factionID
    group.memberCount = #group.members
    setmetatable(group, self)
    self.__index = self;
    return group;
end

---Sets new leader for group
---@param newLeaderID survivorID survivorID of new leader
function Group:setLeader(newLeaderID)
    self.leaderID = newLeaderID
end

---Get list of members (survivorID)
---@return table<survivorID>
function Group:getMembers()
    local res = {}
    for i = 1, #self.members do
        res[i] = self.members[i]
    end
    return res
end

---Get number of group members
function Group:getMemberCount()
    return self.memberCount
end

---Added memberID to group members
---@param memberID survivorID NPC survivorID of newly added member
function Group:addMember(memberID)
    if not memberID then return end
    self.members[self.memberCount + 1] = memberID
    self.memberCount = self.memberCount + 1
end

---Removes <memberID> from Group members
---@param memberID survivorID NPC survivorID of member to remove
function Group:removeMember(memberID)
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
function Group:setName(newName)
    local limit = 50
    if not newName or newName == "" then error("Name not valid:" .. tostring(newName)) end
    if #newName > limit then error(string.format("Name too long: %d>%d", #newName, limit)) end
    self.name = newName
end

return Group
