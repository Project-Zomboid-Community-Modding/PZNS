local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_DebuggerUtils = require("02_mod_utils/PZNS_DebuggerUtils");

--- Cows: helper function to get text data from npcSurvivor.
---@param npcSurvivor any
---@return string
local function getNPCSurvivorTextInfo(npcSurvivor)
    local isLoggingLocalFunction = true;
    -- Cows: NPC Meta info first...
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local panelTextInfo = getText("PZNS_NpcInfo: " .. npcSurvivor.survivorName) .. "\n";

    if (npcIsoPlayer ~= nil) then
        if (npcIsoPlayer:isAlive() == true) then
            panelTextInfo = panelTextInfo .. "Group: " .. tostring(npcSurvivor.groupID) .. "\n";
            panelTextInfo = panelTextInfo .. "Courage: " .. tostring(npcSurvivor.courage) .. "\n";
            panelTextInfo = panelTextInfo .. "Job: " .. tostring(npcSurvivor.jobName) .. "\n";
            panelTextInfo = panelTextInfo .. "\n";
            -- Cows: Begin Perks (AKA Skills) - Pain in the ass as not all names are consistent... but here are the references for corrections if needed:
            -- Cows: search '-- naming issue' comments
            -- https://projectzomboid.com/modding/zombie/characters/skills/PerkFactory.Perks.html
            -- https://pzwiki.net/wiki/Skills
            -- Passives
            panelTextInfo = panelTextInfo ..
                "Strength: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Strength")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Fitness: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Fitness")) .. "\n";
            -- Agility
            panelTextInfo = panelTextInfo ..
                "Sprinting: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Sprinting")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Lightfoot: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Lightfoot")) .. "\n"; -- naming issue
            panelTextInfo = panelTextInfo ..
                "Nimble: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Nimble")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Sneak: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Sneak")) .. "\n"; -- naming issue
            panelTextInfo = panelTextInfo .. "\n";
            -- Combat
            panelTextInfo = panelTextInfo ..
                "Axe: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Axe")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "LongBlade: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "LongBlade")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "SmallBlade: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "SmallBlade")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Blunt: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Blunt")) .. "\n"; -- naming issue
            panelTextInfo = panelTextInfo ..
                "SmallBlunt: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "SmallBlunt")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Spear: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Spear")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Maintenance: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Maintenance")) .. "\n";
            panelTextInfo = panelTextInfo .. "\n";
            -- Firearms
            panelTextInfo = panelTextInfo ..
                "Aiming: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Aiming")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Reloading: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Reloading")) .. "\n";
            -- Crafting
            panelTextInfo = panelTextInfo ..
                "Carpentry: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Woodwork")) .. "\n"; -- naming issue
            panelTextInfo = panelTextInfo ..
                "Cooking: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Cooking")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Farming: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Farming")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "First Aid: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Doctor")) .. "\n";          -- naming issue
            panelTextInfo = panelTextInfo ..
                "Electrical: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Electricity")) .. "\n";    -- naming issue
            panelTextInfo = panelTextInfo ..
                "Metalworking: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "MetalWelding")) .. "\n"; -- naming issue
            panelTextInfo = panelTextInfo ..
                "Mechanics: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Mechanics")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Tailoring: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Tailoring")) .. "\n";
            panelTextInfo = panelTextInfo .. "\n";
            -- Survivalist
            panelTextInfo = panelTextInfo ..
                "Fishing: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Fishing")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Trapping: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Trapping")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Foraging: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "PlantScavenging")) .. "\n"; -- naming issue
            panelTextInfo = panelTextInfo .. "\n";
            -- Cows: What is in the npcSurvivor hands
            panelTextInfo = panelTextInfo ..
                "Primary Hand: " .. tostring(npcIsoPlayer:getPrimaryHandItem():getDisplayName());
            panelTextInfo = panelTextInfo .. "\n";
        else -- Cows: Else npcSurvivor is dead.
            return "";
        end
    else -- Cows: Else npcSurvivor does not exist.
        return "";
    end
    -- WIP - Cows: Now show the panel

    PZNS_DebuggerUtils.CreateLogLine("PZNS_PanelWindows", isLoggingLocalFunction,
        "panelTextInfo: " .. panelTextInfo
    );
    return panelTextInfo;
end

--- Cows: Placeholder for getting and displaying NPC info.
---@param npcSurvivor any
function PZNS_ShowNpcSurvivorInfo(npcSurvivor)
    -- Stop if npcSurvivor is nil
    if (npcSurvivor == nil) then
        return;
    end
    local panelTextInfo = getNPCSurvivorTextInfo(npcSurvivor);
end
