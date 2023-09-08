local u = {}
local fmt = string.format

---@param group Group?
---@param groupID groupID
---@return boolean exist
u.groupCheck = function(group, groupID)
    if not group then
        print(fmt("Group not found! ID: %s", groupID))
        return false
    end
    return true
end

---@param npc NPC?
---@param survivorID survivorID
---@return boolean exist
u.npcCheck = function(npc, survivorID)
    if not npc then
        print(fmt("NPC not found! ID: %s", survivorID))
        return false
    end
    return true
end

return u
