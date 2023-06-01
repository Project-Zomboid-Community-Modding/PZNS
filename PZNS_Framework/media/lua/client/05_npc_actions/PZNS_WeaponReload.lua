---comment
---@param npcSurvivor any
function PZNS_WeaponReload(npcSurvivor)
    if (npcSurvivor == nil) then
        return nil;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local isLoggingLocalFunction = false;

    PZNS_NPCSpeak(npcSurvivor, "Reloading...");
end
