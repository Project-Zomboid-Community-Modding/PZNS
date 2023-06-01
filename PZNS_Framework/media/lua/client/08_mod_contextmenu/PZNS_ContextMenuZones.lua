local PZNS_UtilsDataZones = require("02_mod_utils/PZNS_UtilsDataZones");
local PZNS_UtilsZones = require("02_mod_utils/PZNS_UtilsZones");
local PZNS_NPCZonesManager = require("04_data_management/PZNS_NPCZonesManager");

local contextMenu_ZoneControlsText = {
    CreateZone = "Create Zone",
    DeleteZone = "Delete Zone",
    CancelZone = "Cancel Zone Selection",
    SetZoneBoundary = "Set Zone Boundary",
    ShowZoneBoundary = "Show Zone Boundary",
    HideZoneBoundary = "Hide Zone Boundary"
};
--- Cows: Need this variable so PZNS_EndSelectingZone() can reference it.
local currentZoneKey = "";

---comment
---@param parentContextMenu any
---@param controlKey any
---@param groupID any
function PZNS_CreateZoneTypesMenu(parentContextMenu, controlKey, groupID)
    local activeZones = PZNS_UtilsDataZones.PZNS_GetCreateActiveZonesModData();
    --
    for zoneKey, zoneName in pairs(PZNS_ZonesText) do
        local groupZoneID = groupID .. "_" .. zoneKey;
        local isGroupZoneActive = activeZones[groupZoneID];
        --
        if (controlKey == "DeleteZone") then
            local callbackFunction = function()
                PZNS_NPCZonesManager.removeZoneByGroupIDZoneType(groupID, zoneKey);
            end
            -- Cows: Only allow deletion of active group zones
            if (isGroupZoneActive ~= nil) then
                parentContextMenu:addOption(
                    getText(zoneName),
                    nil,
                    callbackFunction
                );
            end
        elseif (controlKey == "ShowZoneBoundary") then
            local callbackFunction = function()
                PZNS_UtilsZones.PZNS_ShowGroupZoneSquares(groupID, zoneKey);
            end
            -- Cows: Only show active group zones
            if (isGroupZoneActive ~= nil) then
                parentContextMenu:addOption(
                    getText(zoneName),
                    nil,
                    callbackFunction
                );
            end
        else
            -- Cows: Else default to CreateZone callback
            local callbackFunction = function()
                currentZoneKey = zoneKey;
                PZNS_NPCZonesManager.createZone(groupID, zoneKey);
                PZNS_UtilsZones.PZNS_StartSelectingZone(groupID, zoneKey);
            end
            parentContextMenu:addOption(
                getText(zoneName),
                nil,
                callbackFunction
            );
        end
    end
end

---comment
---@param mpPlayerID number
---@param context any
---@param worldobjects any
function PZNS_ContextMenuZones(mpPlayerID, context, worldobjects)
    local playerGroupID = "Player" .. mpPlayerID .. "Group";
    --
    local zonesSubMenu_1 = context:getNew(context);
    local zonesSubMenu_1_Option = context:addOption(
        getText("PZNS_Zones"),
        worldobjects,
        nil
    );
    --
    context:addSubMenu(zonesSubMenu_1_Option, zonesSubMenu_1);
    -- Cows: Add and display the context menu zone controls conditoinally.
    for controlKey, controlText in pairs(contextMenu_ZoneControlsText) do
        -- Cows: Check if PZNS_IsCreatingZone is true
        if (PZNS_IsCreatingZone == true) then
            -- Cows: Conditionally display the "Cancel" command
            if (controlKey == "CancelZone") then
                local callBackFunction = function()
                    currentZoneKey = "";
                    PZNS_CancelCreatingZone();
                end
                zonesSubMenu_1:addOption(getText(controlText), nil, callBackFunction);
            elseif (controlKey == "SetZoneBoundary") then
                local callBackFunction = function()
                    PZNS_UtilsZones.PZNS_EndSelectingZone(playerGroupID, currentZoneKey);
                end
                zonesSubMenu_1:addOption(getText(controlText), nil, callBackFunction);
            end
            -- Cows: Check if PZNS_IsShowingZone is true
        elseif (PZNS_IsShowingZone == true) then
            -- Cows: Only show the HideZoneBoundary control
            if (controlKey == "HideZoneBoundary") then
                local callBackFunction = function()
                    PZNS_UtilsZones.PZNS_HideGroupZoneSquares();
                end
                zonesSubMenu_1:addOption(getText(controlText), nil, callBackFunction);
            end
        else
            -- Cows: Else render the full zone controls menu.
            local zoneControlSubMenu_2 = zonesSubMenu_1:getNew(context);
            local zonesActiveSubMenu_3 = zoneControlSubMenu_2:getNew(context);
            PZNS_CreateZoneTypesMenu(zonesActiveSubMenu_3, controlKey, playerGroupID);
            --
            if ( -- Cows: But do not include the conditional controls from above.
                    controlKey ~= "CancelZone"
                    and controlKey ~= "SetZoneBoundary"
                    and controlKey ~= "HideZoneBoundary"
                ) then
                local submenu_2_Option = zonesSubMenu_1:addOption(
                    getText(controlText),
                    nil,
                    nil
                );
                zonesSubMenu_1:addSubMenu(submenu_2_Option, zoneControlSubMenu_2);
                zoneControlSubMenu_2:addSubMenu(submenu_2_Option, zonesActiveSubMenu_3);
            end
        end
    end
end
