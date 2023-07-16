--- Cows: The code here is based on "SuperSurvivorInfoPanel.lua"

local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_DebuggerUtils = require("02_mod_utils/PZNS_DebuggerUtils");

--- Cows: helper function to get NPC's primary hand item.
---@param npcIsoPlayer any
---@return string
local function getNPCPrimaryHandItem(npcIsoPlayer)
    if (npcIsoPlayer == nil) then
        return "None";
    end
    if (npcIsoPlayer:getPrimaryHandItem() == nil) then
        return "None";
    end
    return npcIsoPlayer:getPrimaryHandItem():getDisplayName();
end

--- Cows: helper function to get text data from npcSurvivor.
---@param npcSurvivor any
---@return string
local function getNPCSurvivorTextInfo(npcSurvivor)
    local isLoggingLocalFunction = true;
    -- Cows: NPC Meta info first...
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local panelTextInfo = npcSurvivor.survivorName .. "\n";
    --#endregion
    if (npcIsoPlayer ~= nil) then
        if (npcIsoPlayer:isAlive() == true) then
            panelTextInfo = panelTextInfo .. "Group: " .. tostring(npcSurvivor.groupID) .. "\n";
            panelTextInfo = panelTextInfo .. "Courage: " .. tostring(npcSurvivor.courage) .. "\n";
            panelTextInfo = panelTextInfo .. "Job: " .. tostring(npcSurvivor.jobName) .. "\n";
            panelTextInfo = panelTextInfo .. "\n";
            -- Cows: Begin Perks (AKA Skills) - Pain in the ass as not all names are consistent... but here are the references for corrections if needed:
            -- Cows: search '-- naming issue' comments
            -- https://projectzomboid.com/modding/zombie/characters/skills/PerkFactory.Perks.html
            -- https://pzwiki.net/wiki/Skills
            -- Passives
            panelTextInfo = panelTextInfo ..
                "Strength: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Strength")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Fitness: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Fitness")) .. "\n";
            -- Agility
            panelTextInfo = panelTextInfo ..
                "Sprinting: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Sprinting")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Lightfoot: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Lightfoot")) .. "\n"; -- naming issue
            panelTextInfo = panelTextInfo ..
                "Nimble: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Nimble")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Sneak: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Sneak")) .. "\n"; -- naming issue
            panelTextInfo = panelTextInfo .. "\n";
            -- Combat
            panelTextInfo = panelTextInfo ..
                "Axe: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Axe")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Long Blunt: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Blunt")) .. "\n"; -- naming issue
            panelTextInfo = panelTextInfo ..
                "Small Blunt: " ..
                tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "SmallBlunt")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Long Blade: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "LongBlade")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Small Blade: " ..
                tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "SmallBlade")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Spear: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Spear")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Maintenance: " ..
                tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Maintenance")) .. "\n";
            panelTextInfo = panelTextInfo .. "\n";
            -- Crafting
            panelTextInfo = panelTextInfo ..
                "Carpentry: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Woodwork")) .. "\n"; -- naming issue
            panelTextInfo = panelTextInfo ..
                "Cooking: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Cooking")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Farming: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Farming")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "First Aid: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Doctor")) .. "\n"; -- naming issue
            panelTextInfo = panelTextInfo ..
                "Electrical: " ..
                tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Electricity")) .. "\n"; -- naming issue
            panelTextInfo = panelTextInfo ..
                "Metalworking: " ..
                tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "MetalWelding")) .. "\n"; -- naming issue
            panelTextInfo = panelTextInfo ..
                "Mechanics: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Mechanics")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Tailoring: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Tailoring")) .. "\n";
            panelTextInfo = panelTextInfo .. "\n";
            -- Firearms
            panelTextInfo = panelTextInfo ..
                "Aiming: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Aiming")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Reloading: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Reloading")) .. "\n";
            -- Survivalist
            panelTextInfo = panelTextInfo ..
                "Fishing: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Fishing")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Trapping: " .. tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "Trapping")) .. "\n";
            panelTextInfo = panelTextInfo ..
                "Foraging: " ..
                tostring(PZNS_UtilsNPCs.PZNS_GetNPCSurvivorPerkLevel(npcSurvivor, "PlantScavenging")) .. "\n"; -- naming issue
            panelTextInfo = panelTextInfo .. "\n";
            -- Cows: What is in the npcSurvivor hands
            panelTextInfo = panelTextInfo ..
                "Primary Hand: " .. tostring(getNPCPrimaryHandItem(npcIsoPlayer));
            panelTextInfo = panelTextInfo .. "\n";
        else -- Cows: Else npcSurvivor is dead.
            return "";
        end
    else -- Cows: Else npcSurvivor does not exist.
        return "";
    end
    -- WIP - Cows: Now show the panel

    PZNS_DebuggerUtils.CreateLogLine("PZNS_PanelWindows", isLoggingLocalFunction,
        "panelTextInfo: " .. panelTextInfo
    );
    return panelTextInfo;
end

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

--****************************************************
-- DRichTextPanel
--****************************************************
local DRichTextPanel = ISRichTextPanel:derive("DRichTextPanel")

function DRichTextPanel:initialise()
    ISRichTextPanel.initialise(self)
end

function DRichTextPanel:onMouseMove(_, _)
    self.parent.mouseOver = true
end

function DRichTextPanel:onMouseMoveOutside(_, _)
    self.parent.mouseOver = false
end

function DRichTextPanel:onMouseUp(_, _)
    if not self.parent:getIsVisible() then
        return
    end
    self.parent.moving = false
    ISMouseDrag.dragView = nil
end

function DRichTextPanel:onMouseUpOutside(_, _)
    if not self.parent:getIsVisible() then
        return
    end
    self.parent.moving = false
    ISMouseDrag.dragView = nil
end

function DRichTextPanel:onMouseDown(x, y)
    if not self.parent:getIsVisible() then
        return
    end
    self.parent.downX = x
    self.parent.downY = y
    self.parent.moving = true
    self.parent:bringToTop()
end

function DRichTextPanel:new(x, y, width, height, parent)
    local o = {}
    o = ISRichTextPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.parent = parent
    return o
end

--****************************************************
-- PanelSurvivorInfo
--****************************************************
PanelSurvivorInfo = ISPanel:derive("PanelSurvivorInfo")

function PanelSurvivorInfo:initialise()
    ISPanel.initialise(self)
end

function PanelSurvivorInfo:on_click_call()
    -- local group_id = SSM:Get(0):getGroupID()
    -- local group_members = SSGM:GetGroupById(group_id):getMembers()
    -- local member = group_members[self.member_index]
    -- if (member) then
    --     getSpecificPlayer(0):Say(getText("ContextMenu_SS_CallName_Before") ..
    --         member:getName() .. getText("ContextMenu_SS_CallName_After"))
    --     member:getTaskManager():AddToTop(ListenTask:new(member, getSpecificPlayer(0), false))
    -- end
end

function PanelSurvivorInfo:createChildren()
    -- button call
    -- self.button_call = ISButton:new(0, self.text_panel.height + 2, self.width, 25, "call", nil,
    --     function() self:on_click_call() end)
    -- self:addChild(self.button_call)
    -- button close
    self.button_close = ISButton:new(
        0, 2, self.width, 25, "Close", nil,
        function()
            self:setVisible(false);
        end
    );
    self:addChild(self.button_close);
    -- text panel
    self.text_panel = DRichTextPanel:new(0, 30, self.width, self.height - 30, self);
    self.text_panel.clip = true;
    self.text_panel.autosetheight = false;
    self.text_panel:ignoreHeightChange();
    self:addChild(self.text_panel);
end

function PanelSurvivorInfo:onMouseMove(dx, dy)
    self.mouseOver = true
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end

function PanelSurvivorInfo:onMouseMoveOutside(dx, dy)
    self.mouseOver = false
    if self.moving then
        self:setX(self.x + dx)
        self:setY(self.y + dy)
        self:bringToTop()
    end
end

function PanelSurvivorInfo:onMouseUp(_, _)
    if not self:getIsVisible() then
        return
    end
    self.moving = false
    ISMouseDrag.dragView = nil
end

function PanelSurvivorInfo:onMouseUpOutside(_, _)
    if not self:getIsVisible() then
        return
    end
    self.moving = false
    ISMouseDrag.dragView = nil
end

function PanelSurvivorInfo:onMouseDown(x, y)
    if not self:getIsVisible() then
        return
    end
    self.downX = x
    self.downY = y
    self.moving = true
    self:bringToTop()
end

function PanelSurvivorInfo:new(x, y, width, height)
    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.member_index = nil
    return o
end

function PZNS_ShowNPCInfoPanel(text_info)
    PZNS_NPCPanelInfo.text_panel.text = text_info;
    PZNS_NPCPanelInfo.text_panel:paginate();
    PZNS_NPCPanelInfo:setVisible(true);
end

function PZNS_CreateNPCPanelInfo()
    PZNS_NPCPanelInfo = PanelSurvivorInfo:new(100, 150, FONT_HGT_SMALL * 6 + 175, FONT_HGT_SMALL * 10 + 500 + 56)
    PZNS_NPCPanelInfo:addToUIManager()
    PZNS_NPCPanelInfo:setVisible(false)
end

--- Cows: Placeholder for getting and displaying NPC info.
---@param npcSurvivor any
function PZNS_ShowNPCSurvivorInfo(npcSurvivor)
    -- Stop if npcSurvivor is nil
    if (npcSurvivor == nil) then
        return;
    end
    local panelTextInfo = getNPCSurvivorTextInfo(npcSurvivor);
    PZNS_ShowNPCInfoPanel(panelTextInfo);
end
