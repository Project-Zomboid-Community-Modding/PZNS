PZNS_ContextMenu = PZNS_ContextMenu or {}

function PZNS_ContextMenu.PZNS_CreateContextMenuDebug(mpPlayerID, context, worldobjects)
    if (SandboxVars.PZNS_Framework.IsDebugModeActive ~= true) then
        return
    end
    PZNS_ContextMenu.Debug.BuildOptions(mpPlayerID, context, worldobjects)
    PZNS_ContextMenu.Debug.WorldOptions(mpPlayerID, context, worldobjects)
    PZNS_ContextMenu.Debug.WipeOptions(mpPlayerID, context, worldobjects)
end

function PZNS_ContextMenu.PZNS_CreateContextMenu(mpPlayerID, context, worldobjects)
    PZNS_ContextMenu.ZonesOptions(mpPlayerID, context, worldobjects)
    PZNS_ContextMenu.JobsOptions(mpPlayerID, context, worldobjects)
    PZNS_ContextMenu.OrdersOptions(mpPlayerID, context, worldobjects)
    PZNS_ContextMenu.NPCInventoryOptions(mpPlayerID, context, worldobjects)
    PZNS_ContextMenu.NPCInfoOptions(mpPlayerID, context, worldobjects)
    PZNS_ContextMenu.SquareObjectsOptions(mpPlayerID, context, worldobjects)
    PZNS_ContextMenu.InviteOptions(mpPlayerID, context, worldobjects)
end

function PZNS_ContextMenu.PZNS_OnFillWorldObjectContextMenu(mpPlayerID, context, worldobjects)
    local opt = context:addOption(getText("Sandbox_PZNS_Framework"), worldobjects, nil)
    local PZNSMenu = ISContextMenu:getNew(context)
    context:addSubMenu(opt, PZNSMenu)

    PZNS_ContextMenu.PZNS_CreateContextMenuDebug(mpPlayerID, PZNSMenu, worldobjects)
    PZNS_ContextMenu.PZNS_CreateContextMenu(mpPlayerID, PZNSMenu, worldobjects)
end
