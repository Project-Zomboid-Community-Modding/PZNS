local PZNS_UtilsZones = require("02_mod_utils/PZNS_UtilsZones");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_GeneralAI = require("07_npc_ai/PZNS_GeneralAI");
--
local isCellChecked = false;                  -- WIP - Cows: Considered using "npcSurvivor.isJobRefreshed"... but that means there will be multiple refresh which may be very bad
local dropZoneRadius = 15;                    -- WIP - Cows: Perhaps a user option in the future...
--
local isRenderingGrabSquareHighlight = false; -- Cows: This is intended for local debug.
local debugGrabSquare = nil;                  -- Cows: This is intended for local debug.
local debugDropSquare = nil;                  -- Cows: This is intended for local debug.
---comment
---@param inputSquares any
---@return table
local function getCorpseSquares(inputSquares)
    local corpseSquares = {};

    for i = #inputSquares, 1, -1 do
        local square = inputSquares[i];
        local corpses = square:getDeadBodys();

        if (corpses:size() > 0) then
            table.insert(corpseSquares, square);
        end
    end

    return corpseSquares;
end

---comment
---@return table
local function checkCellForCorpseSquares()
    --
    local workZone = PZNS_UtilsZones.PZNS_GetGroupZoneBoundary("Player0Group", "ZoneDropCorpses");
    local isUndertakerActive = PZNS_UtilsNPCs.PZNS_CheckIfJobIsActive("Undertaker");
    local workZoneSquareX = workZone[1];
    local workZoneSquareY = workZone[3];
    local workZoneSquareZ = workZone[5];
    --
    local boundsStartX = workZoneSquareX - dropZoneRadius;
    local boundsStartY = workZoneSquareY - dropZoneRadius;
    local boundsEndX = workZoneSquareX + dropZoneRadius;
    local boundsEndY = workZoneSquareY + dropZoneRadius;
    local cellCorpseSquares = {};
    -- Cows: Check if there is an active undertaker
    if (isUndertakerActive == true) then
        --
        for xOffset = 0, boundsEndX - boundsStartX do
            for yOffset = 0, boundsEndY - boundsStartY do
                local currentSquare = getCell():getGridSquare(boundsStartX + xOffset, boundsStartY + yOffset,
                    workZoneSquareZ);
                table.insert(cellCorpseSquares, currentSquare);
            end
        end
        cellCorpseSquares = getCorpseSquares(cellCorpseSquares);
    end
    return cellCorpseSquares;
end

--- Cows: Only render if the grab square is not nil and on screen.
local function renderGrabSquare()
    if (debugGrabSquare ~= nil) then
        if (debugGrabSquare:IsOnScreen()) then
            debugGrabSquare:getFloor():setHighlightColor(PZNS_ZoneColors["ZoneDropCorpsesColor"]);
            debugGrabSquare:getFloor():setHighlighted(true);
        end
    end
end

--- Cows: Only render if the drop square is not nil and on screen.
local function renderDropSquare()
    if (debugDropSquare ~= nil) then
        if (debugDropSquare:IsOnScreen()) then
            debugDropSquare:getFloor():setHighlightColor(PZNS_ZoneColors["ZoneDropCorpsesColor"]);
            debugDropSquare:getFloor():setHighlighted(true);
        end
    end
end

---comment
---@param npcSurvivor any
function PZNS_JobUndertaker(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    local isNPCArmed = PZNS_GeneralAI.PZNS_IsNPCArmed(npcSurvivor);
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local groupDropSquare = PZNS_UtilsZones.PZNS_CheckGroupWorkZoneExists(npcSurvivor.groupID, "ZoneDropCorpses");
    -- Cows: Check if WorkZone exists.
    if (groupDropSquare == nil) then
        PZNS_NPCSpeak(npcSurvivor, getText("IGUI_PZNS_Speech_Preset_NoWorkZone_Undertaker"), "Negative");
        return;
    end
    -- Cows: Only engage in combat if NPC has permission to attack and NPC is also armed.
    if (npcSurvivor.canAttack == true and isNPCArmed == true) then
        if (PZNS_GeneralAI.PZNS_IsNPCBusyCombat(npcSurvivor) == true) then
            return; -- Cows Stop Processing and let the NPC finish its actions.
        end
    end
    --
    debugDropSquare = groupDropSquare;
    -- Cows: Check the job every 30 ticks or so, which should ease the burden of doing everything every tick.
    npcSurvivor.actionTicks = npcSurvivor.actionTicks + 1;
    if (npcSurvivor.actionTicks >= 30) then
        -- Cows: Check if the NPC has a male corpse in the inventory.
        local inventoryCorpse = npcIsoPlayer:getInventory():FindAndReturn("CorpseMale");
        -- Cows: Then check if there is no corpse in the inventory and look for a female corpse.
        if (not inventoryCorpse) then
            inventoryCorpse = npcIsoPlayer:getInventory():FindAndReturn("CorpseFemale");
        end
        -- Cows: Check if the NPC has a corpse in the inventory.
        if (inventoryCorpse ~= nil) then
            --
            if (isRenderingGrabSquareHighlight == true) then
                Events.OnRenderTick.Add(renderDropSquare);
                Events.OnRenderTick.Remove(renderGrabSquare);
                isRenderingGrabSquareHighlight = false;
            end
            -- PZNS_NPCSpeak(npcSurvivor, "Walking to dropoff...", "InfoOnly");
            PZNS_MoveToDropItem(npcSurvivor, groupDropSquare, inventoryCorpse);
            -- Cows: Reset the cell check and npc jobSquare
            if (isCellChecked == true) then
                isCellChecked = false;
                npcSurvivor.jobSquare = nil;
                debugGrabSquare = nil;
            end
        else -- Cows: Else the NPC needs to look at nearby squares around ZoneDropCorpses for a corpse to grab.
            -- PZNS_NPCSpeak(npcSurvivor, "Looking for pickup...", "InfoOnly");
            --
            if (npcSurvivor.jobSquare ~= nil) then
                local squareDeadBodys = npcSurvivor.jobSquare:getDeadBodys();
                --
                if (squareDeadBodys:size() > 0) then
                    local deadBody = squareDeadBodys:get(0);
                    -- PZNS_NPCSpeak(npcSurvivor, "Moving to grab corpse...", "InfoOnly");
                    PZNS_MoveToGrabCorpse(npcSurvivor, npcSurvivor.jobSquare, deadBody);
                    --
                    if (isRenderingGrabSquareHighlight == false) then
                        Events.OnRenderTick.Add(renderGrabSquare);
                        Events.OnRenderTick.Remove(renderDropSquare);
                        isRenderingGrabSquareHighlight = true;
                    end
                    return; -- Cows: Stop processing, there isn't a need to continue and check for corpses in the cell.
                else
                    -- Cows: Else assume the deadbody is no longer available and move to the next deadbody
                    npcSurvivor.jobSquare = nil;
                end
            end
            local cellCorpseSquares = nil;
            --
            if (isCellChecked == false) then
                cellCorpseSquares = checkCellForCorpseSquares(); -- Cows: Check the cell for corpses.
                isCellChecked = true;
            end
            -- Cows: No Corpses in cell, stop processing.
            if (cellCorpseSquares == nil) then
                return;
            end
            --
            for k, v in pairs(cellCorpseSquares) do
                local currentSquare = cellCorpseSquares[k];
                debugGrabSquare = currentSquare;
                npcSurvivor.jobSquare = currentSquare;
                local squareDeadBodys = npcSurvivor.jobSquare:getDeadBodys();
                -- Cows: Check and make sure currentSquare is not identical to groupDropSquare.
                if (currentSquare ~= groupDropSquare) then
                    if (squareDeadBodys ~= nil) then
                        -- Cows: Verify it is NOT an empty list.
                        if (squareDeadBodys:size() > 0) then
                            break;
                        end
                    end
                end
            end -- Cows: End cellCorpseSquares loop.
        end
        npcSurvivor.actionTicks = 0;
    end
end
