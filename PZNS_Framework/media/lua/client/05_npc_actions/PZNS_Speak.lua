local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");

---Cows: Perhaps reset the speech text based on the npc's affection value? Higher = friendlier
---@param npcSurvivor any
local function resetSpeechText(npcSurvivor)
    if (npcSurvivor.affection <= 0 or npcSurvivor.isRaider == true) then
        npcSurvivor.textObject:setDefaultColors(225, 0, 0, 0.8);     -- Red text
    else
        npcSurvivor.textObject:setDefaultColors(230, 230, 230, 0.8); -- White text
    end
    npcSurvivor.textObject:ReadString(
        npcSurvivor.survivorName
    );
    npcSurvivor.speechTicks = 0;
end

--- Cows: Based on SuperSurvivor:renderName()
---@param npcSurvivor any
local function drawSpeechText(npcSurvivor)
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local sx = IsoUtils.XToScreen(
        npcIsoPlayer:getX(),
        npcIsoPlayer:getY(),
        npcIsoPlayer:getZ(),
        0
    );
    local sy = IsoUtils.YToScreen(
        npcIsoPlayer:getX(),
        npcIsoPlayer:getY(),
        npcIsoPlayer:getZ(),
        0
    );
    sx = sx - IsoCamera.getOffX() - npcIsoPlayer:getOffsetX();
    sy = sy - IsoCamera.getOffY() - npcIsoPlayer:getOffsetY();

    sy = sy - 128;

    sx = sx / getCore():getZoom(0);
    sy = sy / getCore():getZoom(0);

    sy = sy - npcSurvivor.textObject:getHeight();
    npcSurvivor.textObject:AddBatchedDraw(sx, sy, true);
end

--- Cows: PZNS_NPCSpeak() renders the text above their character
---@param npcSurvivor any
---@param text any
function PZNS_NPCSpeak(npcSurvivor, text, intention)
    if (npcSurvivor ~= nil) then
        -- Cows: Colored text based on intention.
        npcSurvivor.textObject:setOutlineColors(0, 0, 0, 255); -- Black text outline
        -- Cows: NPCs with affection <= 0 and Raiders are always hostile with red text,
        if (npcSurvivor.affection <= 0 or npcSurvivor.isRaider == true) then
            npcSurvivor.textObject:setDefaultColors(225, 0, 0, 0.8); -- Red
        else
            if (intention == nil or intention == "InfoOnly") then
                npcSurvivor.textObject:setDefaultColors(230, 230, 230, 0.8); -- White
            elseif (intention == "Friendly") then
                npcSurvivor.textObject:setDefaultColors(0, 225, 0, 0.8);     -- Green
            elseif (intention == "Hostile") then
                npcSurvivor.textObject:setDefaultColors(225, 0, 0, 0.8);     -- Red
            elseif (intention == "Positive") then
                npcSurvivor.textObject:setDefaultColors(0, 0, 225, 0.8);     -- Blue
            elseif (intention == "Negative") then
                npcSurvivor.textObject:setDefaultColors(250, 100, 0, 0.8);   -- Orange
            elseif (intention == "Neutral") then
                npcSurvivor.textObject:setDefaultColors(230, 230, 0, 0.8);   -- Yellow
            end
        end
        npcSurvivor.speechTicks = 0; -- Cows: Reset speechTicks so the text stays rendered.
        npcSurvivor.textObject:ReadString(
            text .. "\n" .. npcSurvivor.survivorName
        );
    end
end

--- Cows: PZNS_RenderNPCsText() updates the text above ALL NPC characters.
function PZNS_RenderNPCsText()
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    if (activeNPCs == nil) then
        return;
    end
    --
    for survivorID, v in pairs(activeNPCs) do
        local npcSurvivor = activeNPCs[survivorID];
        if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == true) then
            if (npcSurvivor.textObject) then
                -- Cows: Clear any speech text if over 300 ticks.
                if (npcSurvivor.speechTicks > 300) then
                    resetSpeechText(npcSurvivor);
                end
                npcSurvivor.speechTicks = npcSurvivor.speechTicks + 1;
                drawSpeechText(npcSurvivor);
            end
        end
    end -- Cows: End for-loop Active NPCs
end
