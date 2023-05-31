--- Cows: Probably for a framework... but leaving it here for now as a placeholder.
---@return any
function Get_PZNS_NPCBehaviorOptions_Sandbox()
    local PZNS_NPCBehaviorOptions = SandboxVars.PZNS;

    PZNS_NPCBehaviorOptions = {
        ScanRange = 30;
        PursueRange = 30;
        TickRate = 2;
    };

    return PZNS_NPCBehaviorOptions;
end

Events.OnInitGlobalModData.Add(Get_PZNS_NPCBehaviorOptions_Sandbox);
