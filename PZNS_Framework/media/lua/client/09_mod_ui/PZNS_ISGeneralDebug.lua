--***********************************************************
--**                    THE INDIE STONE                    **
--**				  Author: turbotutone				   **
--***********************************************************
require("PZNS_ISDebugPanelBase")
local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");

---@class PZNS_ISGeneralDebug : PZNS_ISDebugPanelBase
PZNS_ISGeneralDebug = PZNS_ISDebugPanelBase:derive("PZNS_ISGeneralDebug");
PZNS_ISGeneralDebug.instance = nil;

function PZNS_ISGeneralDebug.OnOpenPanel()
    return PZNS_ISDebugPanelBase.OnOpenPanel(PZNS_ISGeneralDebug, 100, 100, 800, 600, "GENERAL DEBUGGERS");
end

function PZNS_ISGeneralDebug:new(x, y, width, height, title)
    x = getCore():getScreenWidth() / 2 - (width / 2);
    y = getCore():getScreenHeight() / 2 - (height / 2);
    local o = PZNS_ISDebugPanelBase:new(x, y, width, height, title);
    setmetatable(o, self);
    self.__index = self;
    return o;
end

function PZNS_ISGeneralDebug:initialise()
    ISPanel.initialise(self);
end

function PZNS_ISGeneralDebug:setPanel()
    self.panelInfo = {}

    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    for npcIndex, valeur in pairs(activeNPCs) do
        local npcSurvivor = valeur.npcIsoPlayerObject
        if npcSurvivor ~= nil and npcSurvivor:isAlive() then
            table.insert(self.panelInfo, {
                buttonTitle = valeur.survivorName,
                panelClass = PZNS_ISStatsAndBody,
                npcIndex = npcIndex
            });
        end
    end
end
