PZNS_NpcGroup = {};
PZNS_NpcGroup.__index = PZNS_NpcGroup;

function PZNS_NpcGroup:newGroup(
    groupID,
    groupLeader
)
    local NPCGroup = {};
    setmetatable(NPCGroup, self)
    self.__index = self;

    NPCGroup = {
        groupID = groupID,
        groupLeader = groupLeader,
        groupMembers = {}
    };

    return NPCGroup;
end

function PZNS_NpcGroup:getGroupID()
    return self.groupID;
end

function PZNS_NpcGroup:setGroupLeader(newLeader)
    self.groupLeader = newLeader;
end

function PZNS_NpcGroup:getGroupLeader()
    return self.groupLeader;
end

function PZNS_NpcGroup:addGroupMembers(newMember)
    self.groupMembers = {
        newMember = newMember
    };
end

function PZNS_NpcGroup:getGroupMembers()
    return self.groupMembers;
end
