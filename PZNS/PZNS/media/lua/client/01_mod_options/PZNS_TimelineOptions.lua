--- Cows: Probably for a framework... but leaving it here for now as a placeholder.
---@return any
function Get_PZNS_TimelineOptions_Sandbox()
    local PZNS_TimelineOptions = SandboxVars.PZNS;

    HostileChanceNPCBase = 5;
    HostileChanceNPCMax = 80;
    HostileChanceIncreasePerDay = 1;
    LivingNPCSpawnFrequencyStart = { "Every Ten Minutes", "Every Hour", "Every Day", "Never" };
    LivingNPCSpawnFrequencyChangesAtDay = 3; -- Cows: 0 for never change
    LivingNPCSpawnFrequencyEndsAtDay = 7;    -- Cows: 0 for never change

    return PZNS_TimelineOptions;
end

Events.OnInitGlobalModData.Add(Get_PZNS_TimelineOptions_Sandbox);
