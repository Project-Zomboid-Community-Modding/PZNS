--- Cows: Most of the code in this file is based on "SurvivorWorldMapButton.lua"
local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_NPCGroupsManager = require("04_data_management/PZNS_NPCGroupsManager");

local ButtonShowLocators = ISButton:derive("ButtonShowLocators");
local isShowingGroupMembers = false;

function ButtonShowLocators:initialise()
    ISButton.initialise(self);
end

function ButtonShowLocators:update()
    if ISWorldMap_instance then
        if ISWorldMap_instance:isVisible() then
            self:setVisible(true);
        else
            self:setVisible(false);
        end
    end
    if isShowingGroupMembers then
        self:setTitle("Hide Group");
    else
        self:setTitle("Show Group");
    end
end

function ButtonShowLocators:new(x, y, width, height, title, clicktarget, onclick)
    local o = {};
    o = ISButton:new(x, y, width, height, title, clicktarget, onclick);
    setmetatable(o, self);
    self.__index = self;
    return o;
end

-- Cows: Encapsulate a few items into a single function; since these items are only relevant to world map rendering.
function PZNS_UpdateISWorldMapRender()
    local worldmap_render = ISWorldMap.render;
    --
    local function createButtonShowGroupMembers()
        local btnShowGroupMembersLocation = ButtonShowLocators:new(
            (getCore():getScreenWidth() / 2) - 75, -- x, from the left
            25,                                    -- y, from the top
            150,                                   -- button width
            25,                                    -- button height
            "Show Members",                        -- button text
            nil,                                   -- click target... safe as nil
            function()                             -- onClick behavior
                if isShowingGroupMembers then
                    isShowingGroupMembers = false;
                else
                    isShowingGroupMembers = true;
                end
            end
        )
        btnShowGroupMembersLocation:addToUIManager();
        btnShowGroupMembersLocation:setVisible(false);
        btnShowGroupMembersLocation:setAlwaysOnTop(true);
    end
    createButtonShowGroupMembers();
    -- Cows: Not sure how to feel about the forced override... but it seems to work without any problems.
    ISWorldMap.render = function(self)
        worldmap_render(self);
        --
        if isShowingGroupMembers ~= true then
            return;
        end
        local playerGroupID = "Player0Group";
        local members = PZNS_NPCGroupsManager.getMembers(playerGroupID);
        local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
        -- Cows: check if activeNPCs is not nil and loaded.
        if (activeNPCs == nil or members == {}) then
            return;
        end
        -- Cows: iterate through the survivorIDs of the group.
        for i = 1, #members do
            local survivorID = members[i]
            local npcSurvivor = activeNPCs[survivorID];
            --
            if (npcSurvivor ~= nil) then
                local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
                local survivorName = npcSurvivor.survivorName;
                --
                if (npcIsoPlayer ~= nil) then
                    if (npcIsoPlayer:isAlive() == true) then
                        local x = self.mapAPI:worldToUIX(npcIsoPlayer:getX(), npcIsoPlayer:getY()) - 3;
                        local y = self.mapAPI:worldToUIY(npcIsoPlayer:getX(), npcIsoPlayer:getY()) - 3;
                        self:drawRect(x, y, 6, 6, 1, 0, 0, 1); -- Cows: This draws the square dot on the map.
                        local name_size = getTextManager():MeasureStringX(UIFont.NewSmall, survivorName);
                        self:drawRect(
                            x - 6,         -- y offset, should put the box above the dot and the text in middle.
                            y - 28,        -- y offset, should put the box above the dot and the text in center.
                            name_size + 3, -- Width
                            24,            -- Height
                            0.5,           -- Transparency
                            0,             -- R
                            0,             -- G
                            0              -- B
                        );                 -- Cows: This draws the namebox background
                        self:drawText(survivorName, x - 5, y - (28 + 1), 1, 1, 1, 1, UIFont.NewSmall);
                    end
                elseif (npcSurvivor.isAlive == true) then
                    local x = self.mapAPI:worldToUIX(npcSurvivor.squareX, npcSurvivor.squareY) - 3;
                    local y = self.mapAPI:worldToUIY(npcSurvivor.squareX, npcSurvivor.squareY) - 3;
                    self:drawRect(x, y, 6, 6, 1, 0, 0, 1); -- Cows: This draws the square dot on the map.
                    local name_size = getTextManager():MeasureStringX(UIFont.NewSmall, survivorName);
                    self:drawRect(
                        x - 6,         -- y offset, should put the box above the dot and the text in middle.
                        y - 28,        -- y offset, should put the box above the dot and the text in center.
                        name_size + 3, -- Width
                        24,            -- Height
                        0.5,           -- Transparency
                        0,             -- R
                        0,             -- G
                        0              -- B
                    );                 -- Cows: This draws the namebox background
                    self:drawText(survivorName, x - 5, y - (28 + 1), 1, 1, 1, 1, UIFont.NewSmall);
                end
            end
        end -- Cows: End group for-loop
    end
end
