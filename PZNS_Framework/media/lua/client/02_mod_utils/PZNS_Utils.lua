local PZNS_Utils = {}
local fmt = string.format

---@param group PZNS_NPCGroup?
---@param groupID groupID
---@return boolean exist
PZNS_Utils.groupCheck = function(group, groupID)
    if not group then
        print(fmt("Group not found! ID: %s", groupID))
        return false
    end
    return true
end

---@param npc PZNS_NPCSurvivor?
---@param survivorID survivorID
---@return boolean exist
PZNS_Utils.npcCheck = function(npc, survivorID)
    if not npc then
        print(fmt("NPC not found! ID: %s", survivorID))
        return false
    end
    return true
end

return PZNS_Utils
