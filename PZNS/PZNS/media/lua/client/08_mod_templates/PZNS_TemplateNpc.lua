--- Cows: Example of spawning in an NPC. This Npc is "Bob Tester"
function PZNS_SpawnBobTester()
    local npcSurvivorId = "PZNS_BobTester"
    local playerSurvivor = getSpecificPlayer(0);
    local npcSurvivor = PZNS_NPCManager:createNPCSurvivor(
        npcSurvivorId,               -- Unique Identifier for the npc so that it can be managed.
        false,                       -- isFemale
        "Tester",                    -- Surname
        "Bob",                       -- Forename
        playerSurvivor:getSquare()); -- Square to spawn at

    if (npcSurvivor ~= nil) then
        PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Strength", 5);
        PZNS_AddNPCSurvivorPerkLevel(npcSurvivor, "Fitness", 5);
        PZNS_SetNPCSurvivorPerkLevel(npcSurvivor, "Aiming", 5);
        PZNS_SetNPCSurvivorPerkLevel(npcSurvivor, "Reloading", 5);
        PZNS_AddNPCSurvivorTraits(npcSurvivor, "Lucky");
        PZNS_AddEquipClothingNPCSurvivor(npcSurvivor, "Base.Trousers_Denim");
        PZNS_AddEquipClothingNPCSurvivor(npcSurvivor, "Base.Shoes_ArmyBoots");
        PZNS_AddEquipWeaponNPCSurvivor(npcSurvivor, "Base.BaseballBat");
    end
end

function PZNS_DeleteBobTester()
    local npcSurvivorId = "PZNS_BobTester";

    PZNS_NPCManager:deleteActiveNpcBySurvivorId(npcSurvivorId);
end
