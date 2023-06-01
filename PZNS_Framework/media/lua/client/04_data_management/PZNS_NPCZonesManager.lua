local PZNS_UtilsDataZones = require("02_mod_utils/PZNS_UtilsDataZones");
local PZNS_NPCZonesManager = {};

---comment
---@param groupID any
---@param zoneType any
---@return table
function PZNS_NPCZonesManager.createZone(
    groupID,
    zoneType
)
    local activeZones = PZNS_UtilsDataZones.PZNS_GetCreateActiveZonesModData();
    local newZone = PZNS_NPCZone:newZone(groupID, zoneType);
    local groupZoneID = groupID .. "_" .. zoneType;
    --
    if (activeZones[groupZoneID] == nil) then
        activeZones[groupZoneID] = newZone;
    end
    return newZone;
end

--- Cows: Get a zone by the input groupID.
---@param groupID string
function PZNS_NPCZonesManager.getZonesByGroupID(groupID)
    local activeZones = PZNS_UtilsDataZones.PZNS_GetCreateActiveZonesModData();
    local groupZones = {};
    --
    if (activeZones ~= nil) then
        --
        for groupZoneID, groupZoneVal in pairs(activeZones) do
            if (groupZoneVal.groupID == groupID) then
                groupZones[groupZoneID] = groupZoneVal;
            end
        end
        return groupZones;
    end
    return nil;
end

--- Cows: Remove a group zone by the input groupID and zoneType.
---@param zoneType any
---@param groupID any
function PZNS_NPCZonesManager.removeZoneByGroupIDZoneType(groupID, zoneType)
    local activeZones = PZNS_UtilsDataZones.PZNS_GetCreateActiveZonesModData();
    --
    if (activeZones == nil) then
        return;
    end
    --
    local groupZoneID = groupID .. "_" .. zoneType;
    local groupZone = activeZones[groupZoneID];
    --
    if (groupZone ~= nil) then
        activeZones[groupZoneID] = nil;
    end
end

return PZNS_NPCZonesManager;
