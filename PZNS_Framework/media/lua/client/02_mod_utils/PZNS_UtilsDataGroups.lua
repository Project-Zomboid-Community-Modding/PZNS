--[[
    Cows: This file is intended for ALL functions related to the creation, deletion, load,
    and editing of all groups related moddata.
--]]
PZNS_ActiveGroups = {}; -- WIP - Cows: Need to rethink how Global variables are used...
-- Cows: This variable should never be referenced directly, but through the corresponding management functions.
local PZNS_UtilsDataGroups = {};

--- Cows: Gets or creates the moddata for PZNS Groups
function PZNS_UtilsDataGroups.PZNS_GetCreateActiveGroupsModData()
    PZNS_ActiveGroups = ModData.getOrCreate("PZNS_ActiveGroups");
    return PZNS_ActiveGroups;
end

--- Cows: This will wipe the groups moddata
function PZNS_UtilsDataGroups.PZNS_ClearGroupsModData()
    PZNS_ActiveGroups = {};
    ModData.remove("PZNS_ActiveGroups");
end

return PZNS_UtilsDataGroups;