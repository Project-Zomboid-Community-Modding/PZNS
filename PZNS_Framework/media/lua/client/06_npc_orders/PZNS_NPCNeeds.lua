local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");

function PZNS_DrinkWater(npcSurvivor)
    --
    if (npcSurvivor == nil) then
        return;
    end
end

--
function PZNS_EatObject(npcSurvivor)
    --
    if (npcSurvivor == nil) then
        return;
    end
end

--
function PZNS_GrabItem(npcSurvivor)
    --
    if (npcSurvivor == nil) then
        return;
    end
end

---comment
---@param npcIsoPlayer IsoPlayer
---@return table
local function getSoapFromInventory(npcIsoPlayer)
    local inv = npcIsoPlayer:getInventory()
    local soapList = {};
    local items = inv:getItems();

    if (items) then
        for i = 1, items:size() - 1 do
            local item = items:get(i);

            if string.match(item:getDisplayName(), "Soap") or string.match(item:getDisplayName(), "Cleaning") then
                table.insert(soapList, item);
            end
        end
    end

    return soapList;
end
---comment
---@param npcSurvivor any
---@param targetSquare any
function PZNS_WashClothesAtSquare(npcSurvivor, targetSquare)
    --
    if (npcSurvivor == nil or targetSquare == nil) then
        return;
    end
    --
    npcSurvivor.aimTarget = nil;
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local squareObjects = targetSquare:getObjects();
    local objectsListSize = squareObjects:size() - 1;
    --
    for i = 1, objectsListSize do
        local currentObj = squareObjects:get(i);
        local hasWater = currentObj:hasWater();
        --
        if (hasWater == true) then
            local waterAmount = currentObj:getWaterAmount();
            --
            if (waterAmount >= 50) then
                local soapList = getSoapFromInventory(npcIsoPlayer);
                PZNS_WashClothing(npcSurvivor, currentObj, soapList);
                break;
            end
        end
    end
end

---comment
---@param npcSurvivor any
---@param targetSquare IsoGridSquare
function PZNS_WashSelfAtSquare(npcSurvivor, targetSquare)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false or targetSquare == nil) then
        return;
    end
    --
    npcSurvivor.aimTarget = nil;
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local squareObjects = targetSquare:getObjects();
    local objectsListSize = squareObjects:size() - 1;
    --
    for i = 1, objectsListSize do
        local currentObj = squareObjects:get(i);
        local hasWater = currentObj:hasWater();
        --
        if (hasWater == true) then
            local waterAmount = currentObj:getWaterAmount();
            --
            if (waterAmount >= 50) then
                local soapList = getSoapFromInventory(npcIsoPlayer);
                PZNS_WashSelf(npcSurvivor, currentObj, soapList)
                break;
            end
        end
    end
end
