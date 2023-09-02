require("03_mod_core/init")

local NPCZone = require("03_mod_core/PZNS_NPCZone")
local PZNS_UtilsDataZones = require("02_mod_utils/PZNS_UtilsDataZones");
local PZNS_NPCZonesManager = {};

local function getZones()
    return PZNS_UtilsDataZones.PZNS_GetCreateActiveZonesModData()
end

---comment
---@param groupID groupID
---@param zoneType string
---@return Zone zone
function PZNS_NPCZonesManager.createZone(
    groupID,
    zoneType
)
    local zone
    local zoneID = groupID .. "_" .. zoneType
    local name = zoneID
    local zones = getZones()
    local existingZone = zones[zoneID]
    if not existingZone then
        zone = NPCZone:new(zoneID, name, groupID, zoneType)
        zones[zoneID] = zone
    else
        zone = existingZone
    end
    return zone
end

--- Cows: Get a zone by the input groupID.
---@param groupID groupID
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
