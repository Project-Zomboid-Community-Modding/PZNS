--- Cows: Probably for a framework... but leaving it here for now as a placeholder.
---@return any
function Get_PZNS_NPCGroupsOptions_Sandbox()
    local PZNS_NPCGroupsOptions = SandboxVars.PZNS;

    PZNS_NPCGroupsOptions = {
        GroupsLimit = 8,
        GroupsPerSpawn = 4,
        GroupSize = 8,
    };
    return PZNS_NPCGroupsOptions;
end

Events.OnInitGlobalModData.Add(Get_PZNS_NPCGroupsOptions_Sandbox);
