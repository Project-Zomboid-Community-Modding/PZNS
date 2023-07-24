local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");

---comment
---@param npcSurvivor any
---@param targetItem IsoObject
---@param soapList any
function PZNS_WashClothing(npcSurvivor, targetItem, soapList)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    --
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local inventoryItems = npcIsoPlayer:getInventory():getItems();
    if (inventoryItems == nil) then
        return;
    end
    --
    local waterRemaining = targetItem:getWaterAmount();
    local soapRemaining = ISWashClothing.GetSoapRemaining(soapList);
    --
    for i = 0, inventoryItems:size() - 1 do
        local currentItem = inventoryItems:get(i);
        local bloodAmount = 0;
        local dirtAmount = 0;
        --
        if instanceof(currentItem, "Clothing") then
            if BloodClothingType.getCoveredParts(currentItem:getBloodClothingType()) then
                local coveredParts = BloodClothingType.getCoveredParts(currentItem:getBloodClothingType());
                --
                for j = 0, coveredParts:size() - 1 do
                    local thisPart = coveredParts:get(j)
                    bloodAmount = bloodAmount + currentItem:getBlood(thisPart);
                end
            end
            --
            if currentItem:getDirtyness() > 0 then
                dirtAmount = dirtAmount + currentItem:getDirtyness();
            end
        elseif instanceof(currentItem, "Weapon") then
            bloodAmount = bloodAmount + currentItem:getBloodLevel();
        end

        if (bloodAmount > 0 or dirtAmount > 0) then
            if waterRemaining > ISWashClothing.GetRequiredWater(currentItem) then
                waterRemaining = waterRemaining - ISWashClothing.GetRequiredWater(currentItem);
                --
                local noSoap = true;
                if soapRemaining > ISWashClothing.GetRequiredSoap(currentItem) then
                    soapRemaining = soapRemaining - ISWashClothing.GetRequiredSoap(currentItem);
                    noSoap = false;
                end
                local washAction =
                    ISWashClothing:new(
                        npcIsoPlayer,
                        targetItem,
                        soapList,
                        currentItem,
                        bloodAmount,
                        dirtAmount,
                        noSoap
                    );
                PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, washAction);
            end
        end
    end
end
