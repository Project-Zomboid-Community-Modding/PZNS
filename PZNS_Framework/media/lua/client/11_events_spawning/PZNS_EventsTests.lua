local PZNS_NPCsManager = require("04_data_management/PZNS_NPCsManager");
require "11_events_spawning/PZNS_Events";

-- Cows: Make sure the NPC spawning functions come AFTER PZNS_InitLoadNPCsData() to prevent duplicate spawns.
--[[
    Cows: Currently, NPCs cannot spawn off-screen because gridsquare data is not loaded outside of the player's range...
    Need to figure out how to handle gridsquare data loading.
--]]


