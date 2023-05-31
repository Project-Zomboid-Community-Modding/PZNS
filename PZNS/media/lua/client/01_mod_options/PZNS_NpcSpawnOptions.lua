--- Cows: Probably for a framework... but leaving it here for now as a placeholder.
---@return any
function Get_PZNS_NPCConfigOptions_Sandbox()
    local PZNS_NPCConfigOptions = SandboxVars.PZNS;

    SpawnChance = 30;
    SpawnLimit = 20;
    SpawnSizeMin = 1;
    SpawnSizeMax = 4;
    SpawnWithWeaponGun = 50;
    SpawnWithWeaponMelee = 100;

    return PZNS_NPCConfigOptions;
end

Events.OnInitGlobalModData.Add(Get_PZNS_NPCConfigOptions_Sandbox);
