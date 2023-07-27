local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_GeneralAI = require("07_npc_ai/PZNS_GeneralAI");

--[[
    - WIP - Cows: "Wandering" can be unpredictable and without destination nor end goal... so my intent is to categorize the "wandering" into limited or specified areas to limit potential issues. 
--]]

---comment
---@param npcSurvivor any
function PZNS_JobWanderInZone(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    if (PZNS_GeneralAI.PZNS_IsNPCBusyCombat(npcSurvivor) == true) then
        return; -- Cows Stop Processing and let the NPC finish its actions.
    end
    --- Cows: Now we can assume the NPC is valid and not busy in combat below this line ---
end
