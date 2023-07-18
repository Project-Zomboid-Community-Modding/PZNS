local PZNS_NPCsManager = require("04_data_management/PZNS_NPCsManager"); local PZNS_DebuggerUtils = require(
    "02_mod_utils/PZNS_DebuggerUtils");
local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_NPCGroupsManager = require("04_data_management/PZNS_NPCGroupsManager");
require "11_events_spawning/PZNS_Events";

-- Cows: Make sure the NPC spawning functions come AFTER PZNS_InitLoadNPCsData() to prevent duplicate spawns.
--[[
    Cows: Currently, NPCs cannot spawn off-screen because gridsquare data is not loaded outside of the player's range...
    Need to figure out how to handle gridsquare data loading.
--]]

local function orderChrisReload()
    local npcChrisSurvivorID = "PZNS_ChrisTester";
    local chrisSurvivor = PZNS_NPCsManager.getActiveNPCBySurvivorID(npcChrisSurvivorID);
    local chrisIsoPlayer = chrisSurvivor.npcIsoPlayerObject;
    local chrisHandItem = chrisIsoPlayer:getPrimaryHandItem();
    if (chrisHandItem) then
        chrisHandItem:setCurrentAmmoCount(0);
        PZNS_NPCSpeak(chrisSurvivor, "Reloading Gun as Ordered...", "InfoOnly");
        -- Cows: Get Ammo Type.
        local chris_ammoType = chrisHandItem:getAmmoType();
        --
        if chris_ammoType then
            local chris_inventory = chrisIsoPlayer:getInventory();
            local chris_bullets = chris_inventory:getItemCountRecurse(chris_ammoType);
            if (chris_bullets < 15) then
                PZNS_UtilsNPCs.PZNS_AddItemsToInventoryNPCSurvivor(chrisSurvivor, chris_ammoType, 15);
            end
        end
        PZNS_WeaponReload(chrisSurvivor);
    end
end

local function orderJillReload()
    local npcJillSurvivorID = "PZNS_JillTester";
    local jillSurvivor = PZNS_NPCsManager.getActiveNPCBySurvivorID(npcJillSurvivorID);
    local jillIsoPlayer = jillSurvivor.npcIsoPlayerObject;
    local jillHandItem = jillIsoPlayer:getPrimaryHandItem();
    if (jillHandItem) then
        jillHandItem:setCurrentAmmoCount(0);

        PZNS_NPCSpeak(jillSurvivor, "Reloading Gun as Ordered...", "InfoOnly");
        local jill_ammoType = jillHandItem:getAmmoType();
        --
        if jill_ammoType then
            local jill_inventory = jillIsoPlayer:getInventory();
            local jill_bullets = jill_inventory:getItemCountRecurse(jill_ammoType);
            if (jill_bullets < 15) then
                PZNS_UtilsNPCs.PZNS_AddItemsToInventoryNPCSurvivor(jillSurvivor, jill_ammoType, 15);
            end
        end
        -- Cows: WIP - So how can all 3 actions be chained/queued together in one sequence? Also, this reload type doesn't seem apply to shotguns nor single reloads (revolvers)
        PZNS_GunMagazineEject(jillSurvivor);
        PZNS_GunMagazineReload(jillSurvivor);
        PZNS_GunMagazineInsert(jillSurvivor);
    end
end

-- Cows: NPC Order Reload test.
function PZNS_OrderReload(mpPlayerID)
    orderChrisReload();
    orderJillReload();
end
