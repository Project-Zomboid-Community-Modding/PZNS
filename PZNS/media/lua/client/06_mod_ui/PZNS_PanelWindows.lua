--- Cows: Placeholder for getting and displaying NPC info.
---@param npcSurvivor any
function PZNS_ShowNpcSurvivorInfo(npcSurvivor)
    local isLoggingLocalFunction = true;
    if (npcSurvivor == nil) then
        return;
    end
    -- Cows: NPC Meta info first...
    local isoPlayerObject = npcSurvivor.npcIsoPlayerObject;
    local panelTextInfo = getText("PZNS_NpcInfo: " ..
        isoPlayerObject:getForname() .. " " .. isoPlayerObject:getSurname() .. "\n"
    );
    panelTextInfo = panelTextInfo .. "Group: " .. tostring(npcSurvivor.groupID) .. "\n";
    panelTextInfo = panelTextInfo .. "Job: " .. tostring(npcSurvivor.jobName) .. "\n";
    panelTextInfo = panelTextInfo .. "Behavior: " .. tostring(npcSurvivor.behaviorName) .. "\n";
    panelTextInfo = panelTextInfo .. "Affect: " .. tostring(npcSurvivor.affection) .. "\n";
    panelTextInfo = panelTextInfo .. "Courage: " .. tostring(npcSurvivor.courage) .. "\n";
    panelTextInfo = panelTextInfo .. "Behavior: " .. tostring(npcSurvivor.behaviorName) .. "\n";
    panelTextInfo = panelTextInfo .. "\n";
    -- Cows: Begin Perks (AKA Skills) - Pain in the ass as not all names are consistent... but here are the references for corrections if needed:
    -- Cows: search '-- naming issue' comments
    -- https://projectzomboid.com/modding/zombie/characters/skills/PerkFactory.Perks.html
    -- https://pzwiki.net/wiki/Skills
    -- Passives
    panelTextInfo = panelTextInfo .. "Strength: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Strength")) .. "\n";
    panelTextInfo = panelTextInfo .. "Fitness: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Fitness")) .. "\n";
    -- Agility
    panelTextInfo = panelTextInfo .. "Sprinting: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Sprinting")) .. "\n";
    panelTextInfo = panelTextInfo .. "Lightfoot: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Lightfoot")) .. "\n"; -- naming issue
    panelTextInfo = panelTextInfo .. "Nimble: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Nimble")) .. "\n";
    panelTextInfo = panelTextInfo .. "Sneak: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Sneak")) .. "\n";         -- naming issue
    panelTextInfo = panelTextInfo .. "\n";
    -- Combat
    panelTextInfo = panelTextInfo .. "Axe: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Axe")) .. "\n";
    panelTextInfo = panelTextInfo .. "LongBlade: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "LongBlade")) .. "\n";
    panelTextInfo = panelTextInfo .. "SmallBlade: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "SmallBlade")) .. "\n";
    panelTextInfo = panelTextInfo .. "Blunt: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Blunt")) .. "\n"; -- naming issue
    panelTextInfo = panelTextInfo .. "SmallBlunt: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "SmallBlunt")) .. "\n";
    panelTextInfo = panelTextInfo .. "Spear: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Spear")) .. "\n";
    panelTextInfo = panelTextInfo ..
        "Maintenance: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Maintenance")) .. "\n";
    panelTextInfo = panelTextInfo .. "\n";
    -- Firearms
    panelTextInfo = panelTextInfo .. "Aiming: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Aiming")) .. "\n";
    panelTextInfo = panelTextInfo .. "Reloading: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Reloading")) .. "\n";
    -- Crafting
    panelTextInfo = panelTextInfo .. "Carpentry: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Woodwork")) .. "\n"; -- naming issue
    panelTextInfo = panelTextInfo .. "Cooking: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Cooking")) .. "\n";
    panelTextInfo = panelTextInfo .. "Farming: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Farming")) .. "\n";
    panelTextInfo = panelTextInfo .. "First Aid: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Doctor")) .. "\n";       -- naming issue
    panelTextInfo = panelTextInfo .. "Electrical: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Electricity")) .. "\n"; -- naming issue
    panelTextInfo = panelTextInfo ..
        "Metalworking: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "MetalWelding")) .. "\n";                   -- naming issue
    panelTextInfo = panelTextInfo .. "Mechanics: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Mechanics")) .. "\n";
    panelTextInfo = panelTextInfo .. "Tailoring: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Tailoring")) .. "\n";
    panelTextInfo = panelTextInfo .. "\n";
    -- Survivalist
    panelTextInfo = panelTextInfo .. "Fishing: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Fishing")) .. "\n";
    panelTextInfo = panelTextInfo .. "Trapping: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Trapping")) .. "\n";
    panelTextInfo = panelTextInfo ..
        "Foraging: " .. tostring(PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "PlantScavenging")) .. "\n"; -- naming issue
    panelTextInfo = panelTextInfo .. "\n";
    -- Cows: What is in the npc hands
    panelTextInfo = panelTextInfo .. "Primary Hand: " .. tostring(isoPlayerObject:getPrimaryHandItem():getDisplayName());
    panelTextInfo = panelTextInfo .. "\n";
    -- WIP - Cows: Now show the panel

    CreateLogLine("PZNS_PanelWindows", isLoggingLocalFunction,
        "panelTextInfo: " .. panelTextInfo
    );
end
