local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_UtilsZones = require("02_mod_utils/PZNS_UtilsZones");
local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");
local PZNS_GeneralAI = require("07_npc_ai/PZNS_GeneralAI");
--
---comment
---@param npcSurvivor any
function PZNS_JobGuard(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    local isNPCArmed = PZNS_GeneralAI.PZNS_IsNPCArmed(npcSurvivor);
    -- Cows: Only engage in combat if NPC has permission to attack and NPC is also armed.
    if (npcSurvivor.canAttack == true and isNPCArmed == true) then
        if (PZNS_GeneralAI.PZNS_IsNPCBusyCombat(npcSurvivor) == true) then
            return; -- Cows Stop Processing and let the NPC finish its actions.
        end
    elseif (isNPCArmed == false) then
        PZNS_NPCSpeak(npcSurvivor, getText("IGUI_PZNS_Speech_Preset_NeedWeapon_01"), "Negative");
    elseif (npcSurvivor.canAttack == false) then
        PZNS_NPCSpeak(npcSurvivor, getText("IGUI_PZNS_Speech_Preset_CannotAttack_01"), "InfoOnly");
    end
    -- Cows: No Group means no zone to guard... for now.
    if (npcSurvivor.groupID == nil) then
        return;
    end
    ---@type IsoPlayer
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    -- Cows: Have the guard patrol the perimeter of the ZoneHome if it exists.
    if (npcSurvivor.isHoldingInPlace ~= true) then
        --
        local zoneType = "ZoneHome";
        local homeZone = PZNS_UtilsZones.PZNS_GetGroupZoneBoundary(npcSurvivor.groupID, zoneType);
        local playerSquare = npcIsoPlayer:getSquare();
        --
        if (npcSurvivor.jobSquare ~= nil) then
            -- Cows: let the guard NPC resume its walking patrol along the zone perimeter.
            npcSurvivor.actionTicks = npcSurvivor.actionTicks + 1;
            if (npcSurvivor.actionTicks >= 30) then
                npcIsoPlayer:NPCSetAiming(false);
                npcIsoPlayer:NPCSetAttack(false);
                local squareX = npcSurvivor.jobSquare:getX();
                local squareY = npcSurvivor.jobSquare:getY();
                local squareZ = npcSurvivor.jobSquare:getZ();
                -- PZNS_NPCSpeak(npcSurvivor,
                --     "Moving to " ..
                --     tostring(squareX) .. ", " ..
                --     tostring(squareY) .. ", " ..
                --     tostring(squareZ),
                --     "InfoOnly"
                -- );
                PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor); -- Cows: Clear the actions queue and start moving.
                PZNS_WalkToSquareXYZ(npcSurvivor, squareX, squareY, squareZ);
                npcSurvivor.actionTicks = 0;
            end
            local distanceFromTarget = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(
                playerSquare,
                npcSurvivor.jobSquare
            );

            if (distanceFromTarget <= 0.25) then
                npcSurvivor.jobSquare = nil;
                return;
            end
        else
            -- Cows: Else assume the guard has no job square.
            if (homeZone) then
                local guardSquare_1 = getCell():getGridSquare(
                    homeZone[1],
                    homeZone[3],
                    homeZone[5] -- Z
                );
                local guardSquare_2 = getCell():getGridSquare(
                    homeZone[2],
                    homeZone[3],
                    homeZone[5] -- Z
                );
                local guardSquare_3 = getCell():getGridSquare(
                    homeZone[2],
                    homeZone[4],
                    homeZone[5]
                );
                local guardSquare_4 = getCell():getGridSquare(
                    homeZone[1],
                    homeZone[4],
                    homeZone[5] -- Z
                );

                local distanceFromSquare1 = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(
                    playerSquare, guardSquare_1
                );
                local distanceFromSquare2 = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(
                    playerSquare, guardSquare_2
                );
                local distanceFromSquare3 = PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects(
                    playerSquare, guardSquare_3
                );

                if (distanceFromSquare1 <= 1) then
                    npcSurvivor.jobSquare = guardSquare_2;
                elseif (distanceFromSquare2 <= 1) then
                    npcSurvivor.jobSquare = guardSquare_3;
                elseif (distanceFromSquare3 <= 1) then
                    npcSurvivor.jobSquare = guardSquare_4;
                else
                    npcSurvivor.jobSquare = guardSquare_1;
                end
            end
        end
    else
        PZNS_GeneralAI.PZNS_WalkToJobSquare(npcSurvivor);
    end
end
