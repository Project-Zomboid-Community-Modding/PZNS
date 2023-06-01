--[[
    Cows: This file is intended for ALL functions related to the creation, deletion, load,
    and editing of all zones related moddata.
--]]
PZNS_ActiveZones = {}; -- Cows: This variable should never be referenced directly, but through the corresponding management functions.
local PZNS_UtilsDataZones = {};

--- Cows: Gets or creates the moddata for PZNS Groups Zones
function PZNS_UtilsDataZones.PZNS_GetCreateActiveZonesModData()
    PZNS_ActiveZones = ModData.getOrCreate("PZNS_ActiveZones");
    return PZNS_ActiveZones;
end

--- Cows: This will wipe the groups moddata
function PZNS_UtilsDataZones.PZNS_ClearZonesData()
    PZNS_ActiveZones = {};
    ModData.remove("PZNS_ActiveZones");
end

return PZNS_UtilsDataZones;
