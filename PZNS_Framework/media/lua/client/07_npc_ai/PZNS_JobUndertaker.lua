local PZNS_UtilsZones = require("02_mod_utils/PZNS_UtilsZones");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");

local isCellChecked = false; -- WIP - Cows: Considered using "npcSurvivor.isJobRefreshed"... but that means there will be multiple refresh which may be very bad
local dropZoneRadius = 15;
--
local isRenderingGrabSquareHighlight = false; -- WIP - Cows: This is intended for local debug.
local debugGrabSquare = nil;                  -- WIP - Cows: This is intended for local debug.
local debugDropSquare = nil;                  -- WIP - Cows: This is intended for local debug.
--
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
--
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

---comment
local function renderGrabSquare()
    if (debugGrabSquare ~= nil) then
        debugGrabSquare:getFloor():setHighlightColor(PZNS_ZoneColors["ZoneDropCorpsesColor"]);
        debugGrabSquare:getFloor():setHighlighted(true);
    end
end

---comment
local function renderDropSquare()
    if (debugDropSquare ~= nil) then
        debugDropSquare:getFloor():setHighlightColor(PZNS_ZoneColors["ZoneDropCorpsesColor"]);
        debugDropSquare:getFloor():setHighlighted(true);
    end
end


---comment
---@param npcSurvivor any
function PZNS_JobUndertaker(npcSurvivor)
    --
    if (npcSurvivor == nil) then
        return nil;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local groupDropSquare = PZNS_UtilsZones.PZNS_CheckGroupWorkZoneExists(npcSurvivor.groupID, "ZoneDropCorpses");
    -- Cows: Check if WorkZone exists.
    if (groupDropSquare == nil) then
        PZNS_NPCSpeak(npcSurvivor, "No Workzone for Undertaker...", "Negative");
        return;
    end
    --
    if (npcSurvivor.canAttack == true) then
        --
        local isThreatInSight = PZNS_CanSeeAimTarget(npcSurvivor);
        if (isThreatInSight == true) then
            PZNS_NPCSpeak(npcSurvivor, "Spotted Threat, Attacking", "InfoOnly");
            PZNS_NPCAimAttack(npcSurvivor);
            return; -- Cows: Stop processing and start attacking.
        end
        --
        local isThreatFound = PZNS_CheckZombieThreat(npcSurvivor);
        if (isThreatFound == true) then
            PZNS_NPCSpeak(npcSurvivor, "Found Threat, Attacking", "InfoOnly");
            PZNS_NPCAimAttack(npcSurvivor);
            return; -- Cows: Stop processing and start attacking.
        end
    end
    --
    debugDropSquare = groupDropSquare;
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
        PZNS_NPCSpeak(npcSurvivor, "Walking to dropoff...", "InfoOnly");
        PZNS_MoveToDropItem(npcSurvivor, groupDropSquare, inventoryCorpse);
        -- Cows: Reset the cell check and npc jobSquare
        if (isCellChecked == true) then
            isCellChecked = false;
            npcSurvivor.jobSquare = nil;
            debugGrabSquare = nil;
        end
    else -- Cows: Else the NPC needs to look at nearby squares around ZoneDropCorpses for a corpse to grab.
        PZNS_NPCSpeak(npcSurvivor, "Looking for pickup...", "InfoOnly");
        --
        if (npcSurvivor.jobSquare ~= nil) then
            local squareDeadBodys = npcSurvivor.jobSquare:getDeadBodys();
            --
            if (squareDeadBodys:size() > 0) then
                local deadBody = squareDeadBodys:get(0);
                PZNS_NPCSpeak(npcSurvivor, "Moving to grab corpse...", "InfoOnly");
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
        --
        if (cellCorpseSquares ~= nil) then
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
            end
        end
    end
end
