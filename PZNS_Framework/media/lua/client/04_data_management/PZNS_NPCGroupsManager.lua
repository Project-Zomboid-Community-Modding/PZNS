require("03_mod_core/init")

local PZNS_NPCGroupsManager = {};
local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs")
local PZNS_UtilsDataGroups = require("02_mod_utils/PZNS_UtilsDataGroups")
local NPC = require("03_mod_core/PZNS_NPCSurvivor")
local Group = require("03_mod_core/PZNS_NPCGroup")

local fmt = string.format



---@return Group?
local function getGroup(groupID)
    local activeGroups = PZNS_UtilsDataGroups.PZNS_GetCreateActiveGroupsModData()
    return activeGroups[groupID]
    -- return PZNS.Core.Group.registry[groupID]
end

---@param survivorID survivorID
---@return NPC?
local function getNPC(survivorID)
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData()
    return activeNPCs[survivorID]
    -- return PZNS.Core.NPC.registry[survivorID]
end

---@param factionID factionID
---@return Faction?
local function getFaction(factionID)
    return
    -- return PZNS.Core.Faction.registry[factionID]
end

local function verifyGroup(groupID, reverse)
    if not reverse then
        assert(getGroup(groupID), fmt("Group not found! ID: %s", groupID))
    else
        assert(not getGroup(groupID), fmt("Group already exist! ID: %s", groupID))
    end
end

--- Cows: Create a new group based on the input groupID.
---@param groupID groupID Unique identifier for group
---@param name? string Group name
---@param leaderID? survivorID survivorID of group leader
---@param members? table<survivorID> group members
---@return Group
function PZNS_NPCGroupsManager.createGroup(groupID, name, leaderID, members)
    name = name or groupID
    members = members or {}
    verifyGroup(groupID, true)
    if leaderID then
        local leader = getNPC(leaderID)
        assert(leader, fmt("NPC not found! ID: %s", leaderID))
        -- check that leaderID is not in other group
        assert(not leader.groupID, fmt("NPC is already a member of another group! ID: %s", leaderID))
        table.insert(members, leaderID)
    end
    if members then
        -- check that all members exist
        -- check that none of them are in other group
        local isLeaderIn = false
        for i = 1, #members do
            local member = members[i]
            local npc = getNPC(member)
            assert(npc, fmt("NPC not found! ID: %s", member))
            assert(not npc.groupID, fmt("NPC is already a member of another group! ID: %s", member))
            if leaderID and member == leaderID then isLeaderIn = true end
        end
        -- check that leaderID in members, if not - add
        if leaderID and not isLeaderIn then
            members[#members + 1] = leaderID
        end
    end
    local newGroup = Group:new(groupID, name, leaderID, members)
    -- update members groupID
    for i = 1, #newGroup.members do
        local npc = getNPC(newGroup.members[i])
        if npc then
            NPC.setGroupID(npc, newGroup.groupID)
        end
    end

    local activeGroups = PZNS_UtilsDataGroups.PZNS_GetCreateActiveGroupsModData()
    activeGroups[newGroup.groupID] = newGroup
    -- PZNS.Core.Group.registry[groupID] = newGroup
    --
    return newGroup
end

---Delete group by group ID, unset groupID for all members
---@param groupID groupID
function PZNS_NPCGroupsManager.deleteGroup(groupID)
    local group = getGroup(groupID)
    verifyGroup(groupID)
    if not group then return end
    local members = Group.getMembers(group)
    for i = 1, #members do
        local npc = getNPC(members[i])
        assert(npc, fmt("NPC not found! ID: %s", npc))
        assert(npc.groupID == groupID, fmt("NPC is not in group! ID: %s; groupID: %s", npc, groupID))
        if not npc then return end
        NPC.unsetGroupID(npc)
    end
    if group.factionID then
        print("Not yet implemented")
        -- local faction = getFaction(group.factionID)
        -- assert(faction, fmt("Faction not found! ID: %s; groupID: %s", group.factionID, groupID))
        -- group.factionID = nil
        -- faction:removeGroup(groupID)
    end
    local activeGroups = PZNS_UtilsDataGroups.PZNS_GetCreateActiveGroupsModData()
    activeGroups[groupID] = nil
    -- PZNS.Core.Group.registry[groupID] = nil
end

--- Cows: Get a group by the input groupID.
---@param groupID groupID
---@return Group?
function PZNS_NPCGroupsManager.getGroupByID(groupID)
    return getGroup(groupID)
end

--- Get a group by the input name
---@param name string
---@return Group?
function PZNS_NPCGroupsManager.getGroupByName(name)
    local activeGroups = PZNS_UtilsDataGroups.PZNS_GetCreateActiveGroupsModData()
    -- for _, group in pairs(PZNS.Core.Group.registry) do
    for _, group in pairs(activeGroups) do
        if group.name == name then
            return group
        end
    end
end

--- Cows: Add a npcSurvivor to the specified group
---@param npcSurvivor NPC
---@param groupID groupID
function PZNS_NPCGroupsManager.addNPCToGroup(npcSurvivor, groupID)
    local survivorID = npcSurvivor.survivorID;

    local group = getGroup(groupID)
    verifyGroup(groupID)
    if not group then return end
    assert(not npcSurvivor.groupID, fmt("NPC is already a member of another group! ID: %s", survivorID))
    assert(npcSurvivor.groupID ~= groupID,
        fmt("NPC is already a member of this group! ID: %s", survivorID))
    Group.addMember(group, survivorID)
    NPC.setGroupID(npcSurvivor, groupID)
end

--- Cows: Remove a npcSurvivor to the specified group
---@param groupID groupID
---@param survivorID survivorID
function PZNS_NPCGroupsManager.removeNPCFromGroup(groupID, survivorID)
    local group = getGroup(groupID)
    verifyGroup(groupID)
    if not group then return end
    local npc = getNPC(survivorID)
    assert(npc, fmt("NPC not found! ID: %s", npc))
    assert(npc.groupID == groupID, fmt("NPC is not in group! ID: %s; groupID: %s", npc, groupID))
    --
    if group then
        Group.removeMember(group, survivorID)
        NPC.unsetGroupID(npc)
    end
end

---Get group members
---@param groupID groupID
---@return table<survivorID>
function PZNS_NPCGroupsManager.getMembers(groupID)
    local group = getGroup(groupID)
    verifyGroup(groupID)
    if not group then return {} end
    return Group.getMembers(group)
end

--- Cows: Get the group members count by the input groupID.
---@param groupID groupID
function PZNS_NPCGroupsManager.getGroupMembersCount(groupID)
    local group = getGroup(groupID)
    if group then
        return Group.getMemberCount(group)
    end
end

function PZNS_NPCGroupsManager.setLeader(groupID, leaderID)
    local group = getGroup(groupID)
    verifyGroup(groupID)
    if not group then return end
    local npc = getNPC(leaderID)
    assert(npc, fmt("NPC not found! leaderID: %s; groupID: %s", leaderID, groupID))
    assert(not npc.groupID or npc.groupID == npc.groupID,
        "NPC is already a member of another group! leaderID: %s; groupID: %s", leaderID, groupID)

    if group.leaderID == leaderID then
        print(fmt("NPC is already the leader! leaderID: %s; groupID: %s", leaderID, groupID))
        return
    end
    Group.setLeader(group, leaderID)
end

function PZNS_NPCGroupsManager.setGroupName(groupID, newName)
    local group = getGroup(groupID)
    verifyGroup(groupID)
    if not group then return end
    Group.setName(group, newName)
end

--backward compat
PZNS_NPCGroupsManager.removeNPCFromGroupBySurvivorID = PZNS_NPCGroupsManager.removeNPCFromGroup


return PZNS_NPCGroupsManager;
