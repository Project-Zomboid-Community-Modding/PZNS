--***********************************************************
--**                    THE INDIE STONE                    **
--**				  Author: turbotutone				   **
--***********************************************************
require "DebugUIs/DebugMenu/Base/ISDebugSubPanelBase";
local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");

PZNS_ISStatsAndBody = ISDebugSubPanelBase:derive("PZNS_ISStatsAndBody");

function PZNS_ISStatsAndBody:initialise(npcIndex)
    ISPanel.initialise(self);
    self.npcIndex = npcIndex
end

function PZNS_ISStatsAndBody:createChildren()
    ISPanel.createChildren(self);

    local x, y, w, obj = 10, 10, self.width - 30;

    self:initHorzBars(x, w);

    y, obj = ISDebugUtils.addLabel(self, "float_title", x + (w / 2), y, "NPC Stats and Body", UIFont.Medium);
    obj.center = true;
    y, obj = ISDebugUtils.addLabel(self, "float_title", x + (w / 2), y, "(morale can only be adjusted when stress > 0)", UIFont.Small);
    obj.center = true;
    y, obj = ISDebugUtils.addLabel(self, "float_title", x + (w / 2), y, "(pain and sickness cannot be adjusted manually)", UIFont.Small);
    obj.center = true;
    y = ISDebugUtils.addHorzBar(self, y + 5) + 5;

    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    if (activeNPCs[self.npcIndex] == nil) then
        return
    end
    local npcSurvivor = activeNPCs[self.npcIndex]
    local player = npcSurvivor.npcIsoPlayerObject
    local stats = player:getStats();
    local body = player:getBodyDamage();
    local nutrition = player:getNutrition()
    self.sliderOptions = {};
    self.boolOptions = {};

    self:addSliderOption(stats, "Hunger", 0, 1);
    self:addSliderOption(stats, "Thirst", 0, 1);

    self:addSliderOption(stats, "Fatigue", 0, 1);
    self:addSliderOption(stats, "Endurance", 0, 1);
    local op = self:addSliderOption(stats, "Fitness", 0, 2); -- -1 to 1, use applymod due to slider
    op.applyMod = 1;

    self:addSliderOption(stats, "Drunkenness", 0, 100, 1);

    self:addSliderOption(stats, "Anger", 0, 1);
    --self:addSliderOption(stats,"Boredom", 0, 1);
    self:addSliderOption(stats, "Fear", 0, 1);
    self:addSliderOption(stats, "Pain", 0, 100, 1);
    self:addSliderOption(stats, "Panic", 0, 100, 1);
    self:addSliderOption(stats, "Morale", 0, 1);
    self:addSliderOption(stats, "Stress", 0, 1);
    self:addSliderOption(stats, "StressFromCigarettes", 0, stats:getMaxStressFromCigarettes());
    self:addSliderOption(player, "TimeSinceLastSmoke", 0, 10);
    self:addSliderOption(body, "BoredomLevel", 0, 100, 1);
    self:addSliderOption(body, "UnhappynessLevel", 0, 100, 1);
    self:addSliderOption(stats, "Sanity", 0, 1);

    self:addSliderOption(body, "Wetness", 0, 100, 1);
    self:addSliderOption(body, "Temperature", 20, 40, 0.1);
    op = self:addSliderOption(body, "ColdDamageStage", 0, 1);
    op.title = "ColdDamageStage (hypo 4)";

    self:addSliderOption(body, "OverallBodyHealth", 0, 100, 1);
    op = self:addSliderOption(body, "ColdStrength", 0, 100, 1);
    op.title = "CatchAColdStrength";
    self:addSliderOption(stats, "Sickness", 0, 1);
    self:addSliderOption(body, "InfectionLevel", 0, 100, 1);
    self:addSliderOption(body, "FakeInfectionLevel", 0, 100, 1);
    self:addSliderOption(body, "FoodSicknessLevel", 0, 100, 1);
    self:addSliderOption(nutrition, "Calories", -2200, 3700, 1);
    self:addSliderOption(nutrition, "Weight", 30, 130, 1);

    self:addBoolOption(body, "IsInfected", "IsInfected", "setInfected");
    self:addBoolOption(body, "IsFakeInfected", "IsFakeInfected", "setIsFakeInfected");
    self:addBoolOption(body, "IsOnFire", "IsOnFire", "setIsOnFire");
    self:addBoolOption(player, "Ghost", "isGhostMode", "setGhostMode");
    self:addBoolOption(player, "God Mod", "isGodMod", "setGodMod");
    self:addBoolOption(player, "Invisible", "isInvisible", "setInvisible");
    --self:addBoolOption(body,"HasACold", "isHasACold", "setHasACold");

    local barMod = 3;
    local y2, label, value, slider;
    for k, v in ipairs(self.sliderOptions) do
        y2, label = ISDebugUtils.addLabel(self, v, x, y, v.title or v.var, UIFont.Small);

        y2, value = ISDebugUtils.addLabel(self, v, x + (w / 2) - 20, y, "0", UIFont.Small, false);
        y, slider = ISDebugUtils.addSlider(self, v, x + (w / 2), y, w / 2, 18, PZNS_ISStatsAndBody.onSliderChange);
        slider.valueLabel = value;

        v.label = label;
        v.labelValue = value;
        v.slider = slider;
        --slider:setCurrentValue(v.java[v.get](v.java[v.get]));
        slider:setValues(v.min, v.max, v.step, v.step, true);
        local val = v.java[v.get](v.java) + v.applyMod;
        --print(v.var.." = "..tostring(val))
        slider:setCurrentValue(val);

        y = ISDebugUtils.addHorzBar(self, math.max(y, y2) + barMod) + barMod;
    end

    local tickbox;
    for k, v in ipairs(self.boolOptions) do
        y2, label = ISDebugUtils.addLabel(self, v, x, y, v.var, UIFont.Small);

        local tickOptions = {};
        table.insert(tickOptions, { text = "Enabled", ticked = false });
        y, tickbox = ISDebugUtils.addTickBox(self, v, x + (w / 2), y, w / 2, ISDebugUtils.FONT_HGT_SMALL, v.var, tickOptions, PZNS_ISStatsAndBody.onTicked);

        v.label = label;
        v.tickbox = tickbox;

        y = ISDebugUtils.addHorzBar(self, y + barMod) + barMod;
    end

    self:setScrollHeight(y + 10);
end

function PZNS_ISStatsAndBody:addSliderOption(_java, _var, _min, _max, _step, _get, _set)
    local option = {
        java = _java,
        var = _var,
        min = _min,
        max = _max,
        step = _step or 0.01,
        get = _get or "get" .. _var,
        set = _set or "set" .. _var,
        applyMod = 0,
    };
    table.insert(self.sliderOptions, option);
    return option;
end

function PZNS_ISStatsAndBody:addBoolOption(_java, _var, _get, _set)
    local bool = {
        java = _java,
        var = _var,
        get = _get,
        set = _set,
    };
    table.insert(self.boolOptions, bool);
    return bool;
end

function PZNS_ISStatsAndBody:prerender()
    ISDebugSubPanelBase.prerender(self);

    local val;
    for k, v in ipairs(self.sliderOptions) do
        val = v.java[v.get](v.java);
        v.slider.currentValue = val + v.applyMod;

        if v.slider.pretext then
            v.labelValue:setName(v.slider.pretext .. ISDebugUtils.printval(val, 3));
        else
            v.labelValue:setName(ISDebugUtils.printval(val, 3));
        end
    end

    for k, v in ipairs(self.boolOptions) do
        val = v.java[v.get](v.java);
        v.tickbox.selected[1] = val;
    end
end

function PZNS_ISStatsAndBody:onSliderChange(_newval, _slider)
    local v = _slider.customData;

    if v.var == "Fitness" then
        local xp = getPlayer():getXp();
        local val = (_newval / 2) * 10;
        --print("fitness = "..tostring(val))
        xp:setXPToLevel(Perks.Fitness, val);
        getPlayer():setPerkLevelDebug(Perks.Fitness, val);
        return ;
    elseif v.var == "OverallBodyHealth" then
        local b = getPlayer():getBodyDamage();
        if _newval < b:getOverallBodyHealth() then
            b:ReduceGeneralHealth(b:getOverallBodyHealth() - _newval);
        elseif _newval > b:getOverallBodyHealth() then
            b:AddGeneralHealth(_newval - b:getOverallBodyHealth());
        end
        return ;
    elseif v.var == "ColdStrength" then
        local b = getPlayer():getBodyDamage();
        if _newval > 0 then
            b:setHasACold(true);
        else
            b:setHasACold(false);
        end
    end
    v.java[v.set](v.java, _newval - v.applyMod);
end

function PZNS_ISStatsAndBody:onTicked(_index, _selected, _arg1, _arg2, _tickbox)
    local v = _tickbox.customData;
    v.java[v.set](v.java, not v.java[v.get](v.java));
end

function PZNS_ISStatsAndBody:setNpcSurvivor(npcSurvivor)
    self.npcSurvivor = npcSurvivor
end
function PZNS_ISStatsAndBody:update()
    ISPanel.update(self);
end

function PZNS_ISStatsAndBody:new(x, y, width, height, doStencil)
    local o = {};
    o = ISDebugSubPanelBase:new(x, y, width, height, doStencil);
    setmetatable(o, self);
    self.__index = self;
    return o;
end

