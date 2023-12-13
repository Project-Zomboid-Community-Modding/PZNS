--***********************************************************
--**                    THE INDIE STONE                    **
--**				  Author: turbotutone				   **
--***********************************************************

require "ISUI/ISPanel"

---@class PZNS_ISDebugPanelBase : ISPanel
PZNS_ISDebugPanelBase = ISPanel:derive("PZNS_ISDebugPanelBase");

function PZNS_ISDebugPanelBase.OnOpenPanel(_class, _x, _y, _w, _h, _title)
    if _class.instance ~= nil then
        _class.instance:removeFromUIManager();
        _class.instance = nil;
    end
    _class.instance = _class:new(_x, _y, _w, _h, _title);
    _class.instance:setPanel();
    _class.instance:initialise();
    _class.instance:instantiate(); -- createChildren

    ISDebugMenu.RegisterClass(_class);
    _class.instance:createNpcPanels();
    _class.instance:addToUIManager();
    _class.instance:setVisible(true);

    return _class.instance;
end

function PZNS_ISDebugPanelBase:initialise()
    ISPanel.initialise(self);
end

function PZNS_ISDebugPanelBase:createNpcPanels()
    local margin = 10;
    local x, y = 10, self.y + margin;
    local w, h = 180, 20;

    for k, v in ipairs(self.panelInfo) do
        y, obj = ISDebugUtils.addButton(self, v.buttonTitle, x, y, w, h, v.buttonTitle, PZNS_ISDebugPanelBase.onClick);
        v.button = obj;
        y = y + margin;
    end

    x, y = 200, 55;
    w, h = self.width - 210, self.height - y - margin;

    self.panels = {};

    local options;
    for k, v in ipairs(self.panelInfo) do
        options = v.panelClass:new(x, y, w, h);
        options:initialise(v.npcIndex);
        options:instantiate();
        options:setAnchorRight(true);
        options:setAnchorLeft(true);
        options:setAnchorTop(true);
        options:setAnchorBottom(true);
        options.moveWithMouse = true;
        options.doStencilRender = true;
        options:addScrollBars();
        options.vscroll:setVisible(true);
        self:addChild(options);
        options:setScrollChildren(true);
        options.onMouseWheel = ISDebugUtils.onMouseWheel;

        v.panel = options;
        table.insert(self.panels, self.climateOptions);

        if k > 1 then
            options:setEnabled(false);
            options:setVisible(false);
        end
    end
end

function PZNS_ISDebugPanelBase:createChildren()
    ISPanel.createChildren(self);

    local x, y = 20, 10;

    local y, obj = ISDebugUtils.addLabel(self, self.panelTitle, self.width / 2, y, self.panelTitle, UIFont.Medium, true);
    obj.center = true;
    local headerY = y + 10;

    local x, y = 10, headerY;
    local w, h = 180, 20;
    local margin = 10;

    local obj;

    local y, obj = ISDebugUtils.addButton(self, "close", x, y + margin, w, h, getText("IGUI_CraftUI_Close"), PZNS_ISDebugPanelBase.onClick);
    self.y = y
end

function PZNS_ISDebugPanelBase:onClick(_button)
    if _button.customData == "close" then
        self:close();
        return ;
    end
    for k, v in ipairs(self.panelInfo) do
        if v.button == _button then
            v.panel:setEnabled(true);
            v.panel:setVisible(true);
            if v.panel.onMadeActive then
                v.panel:onMadeActive();
            end
        else
            v.panel:setEnabled(false);
            v.panel:setVisible(false);
        end
    end
end

function PZNS_ISDebugPanelBase:onMadeActive()
    for k, v in ipairs(self.panelInfo) do
        if v.panel and v.panel:getIsVisible() and v.panel:isEnabled() and v.panel.onMadeActive then
            v.panel:onMadeActive();
        end
    end
end

function PZNS_ISDebugPanelBase:update()
    ISPanel.update(self);
end

function PZNS_ISDebugPanelBase:close()
    self:setVisible(false);
    self:removeFromUIManager();
    PZNS_ISDebugPanelBase.instance = nil
end

function PZNS_ISDebugPanelBase:new(x, y, width, height, title)
    local o = {};
    o = ISPanel:new(x, y, width, height);
    setmetatable(o, self);
    self.__index = self;
    o.variableColor = { r = 0.9, g = 0.55, b = 0.1, a = 1 };
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 };
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.8 };
    o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 };
    o.zOffsetSmallFont = 25;
    o.moveWithMouse = true;
    o.panelTitle = title;
    self.y = 0
    return o;
end



