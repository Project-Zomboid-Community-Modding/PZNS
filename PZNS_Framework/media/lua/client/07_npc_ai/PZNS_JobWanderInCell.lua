local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_GeneralAI = require("07_npc_ai/PZNS_GeneralAI");

---comment
---@param npcSurvivor any
function PZNS_JobWanderInCell(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    if (PZNS_GeneralAI.PZNS_IsNPCBusyCombat(npcSurvivor) == true) then
        return; -- Cows Stop Processing and let the NPC finish its actions.
    end
    --- Cows: Now we can assume the NPC is valid and not busy in combat below this line ---
end
