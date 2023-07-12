function PZNS_GetSandboxOptions()
    local pzns_options = SandboxVars.PZNS_Framework;
    --
    IsPVPActive = false; -- Cows: Don't need to set it, but it should be a global variable for the mod.
    IsDebugModeActive = pzns_options.IsDebugModeActive;
    IsInfiniteAmmoActive = pzns_options.IsInfiniteAmmoActive;
    IsNPCsNeedsActive = pzns_options.IsNPCsNeedsActive;
    GroupSizeLimit = pzns_options.GroupSizeLimit;
    CompanionFollowRange = pzns_options.CompanionFollowRange;
    CompanionRunRange = pzns_options.CompanionRunRange;
    CompanionIdleTicks = pzns_options.CompanionIdleTicks;
end
