local PZNS_UtilsDataGroups = require("02_mod_utils/PZNS_UtilsDataGroups");
local PZNS_NPCGroupsManager = {};

--- Cows: Create a new group based on the input groupID.
---@param groupID any
function PZNS_NPCGroupsManager.createGroup(groupID)
    local activeGroups = PZNS_UtilsDataGroups.PZNS_GetCreateActiveGroupsModData();
    local newGroup = PZNS_NPCGroup:newGroup(groupID);
    --
    if (activeGroups[groupID] == nil) then
        activeGroups[groupID] = newGroup;
    end
    --
    return newGroup;
end

--- Cows: Get a group by the input groupID.
---@param groupID any
function PZNS_NPCGroupsManager.getGroupByID(groupID)
    local activeGroups = PZNS_UtilsDataGroups.PZNS_GetCreateActiveGroupsModData();
    --
    if (activeGroups[groupID] ~= nil) then
        return activeGroups[groupID];
    end
    return nil;
end

--- Cows: Add a npcSurvivor to the specified group
---@param npcSurvivor any
---@param groupID any
function PZNS_NPCGroupsManager.addNPCToGroup(npcSurvivor, groupID)
    local survivorID = npcSurvivor.survivorID;
    local group = PZNS_NPCGroupsManager.getGroupByID(groupID);
    --
    if (group ~= nil) then
        group[survivorID] = survivorID; -- Cows: Only need the ID, can get the npcSurvivor Data from moddata PZNS_ActiveNPCs as needed.
    end
end

--- Cows: Remove a npcSurvivor to the specified group
---@param survivorID any
---@param groupID any
function PZNS_NPCGroupsManager.removeNPCFromGroupBySurvivorID(groupID, survivorID)
    local group = PZNS_NPCGroupsManager.getGroupByID(groupID);
    --
    if (group ~= nil) then
        group[survivorID] = nil;
    end
end

--- Cows: Get the group members count by the input groupID.
---@param groupID any
function PZNS_NPCGroupsManager.getGroupMembersCount(groupID)
    local members = PZNS_NPCGroupsManager.getGroupByID(groupID);
    local memberCount = 0;
    --
    if (members ~= nil) then
        for k1, v1 in pairs(members) do
            if not (k1 == "groupID " and k1 == "groupLeader") then
                memberCount = memberCount + 1;
            end
        end
    end
    --
    return memberCount;
end

return PZNS_NPCGroupsManager;
