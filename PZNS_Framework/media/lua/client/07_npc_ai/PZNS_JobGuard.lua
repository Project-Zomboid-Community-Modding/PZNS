local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_GeneralAI = require("07_npc_ai/PZNS_GeneralAI");
--
local followRange = 3;
local runRange = 5;
local idleActionOnTick = 200;

---comment
---@param npcSurvivor any
function PZNS_JobGuard(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    if (PZNS_GeneralAI.PZNS_IsNPCBusyCombat(npcSurvivor) == true) then
        npcSurvivor.idleTicks = 0;
        return; -- Cows Stop Processing and let the NPC finish its actions.
    end
    -- Cows: Have the guard patrol the paremeter of the ZoneHome if it exists.
    if (npcSurvivor.isHoldingInPlace ~= true) then
        --
    end
    -- Cows: Else have the guard simply hold position where ever it is.
end
