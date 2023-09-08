local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_PresetsSpeeches = require("03_mod_core/PZNS_PresetsSpeeches");
local PZNS_NPCGroupsManager = require("04_data_management/PZNS_NPCGroupsManager");

PZNS_ContextMenu = PZNS_ContextMenu or {}

---comment
---@param groupID any
---@param parentContextMenu any
local function PZNS_CreateJobNPCsMenu(parentContextMenu, mpPlayerID, groupID, jobName)
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    local groupMembers = PZNS_NPCGroupsManager.getGroupByID(groupID);
    local followTargetID = "Player" .. mpPlayerID;
    --
    -- Cows: Stop if there are no active npcs. or groupMembers
    if (activeNPCs == nil or groupMembers == nil) then
        return;
    end
    --
    for survivorID, v in pairs(groupMembers) do
        local npcSurvivor = activeNPCs[survivorID];
        -- Cows: conditionally set the callback function for the context menu option.
        local callbackFunction = function()
            npcSurvivor.jobSquare = nil;
            npcSurvivor.isHoldingInPlace = false;
            if (jobName == "Companion") then
                PZNS_JobCompanion(npcSurvivor, followTargetID);
            end
            --
            if (npcSurvivor.speechTable ~= nil) then
                if (npcSurvivor.speechTable.PZNS_OrderConfirmed ~= nil) then
                    PZNS_UtilsNPCs.PZNS_UseNPCSpeechTable(
                        npcSurvivor, npcSurvivor.speechTable.PZNS_OrderConfirmed, "Friendly"
                    );
                else
                    PZNS_UtilsNPCs.PZNS_UseNPCSpeechTable(
                        npcSurvivor, PZNS_PresetsSpeeches.PZNS_OrderConfirmed, "Friendly"
                    );
                end
            else
                PZNS_UtilsNPCs.PZNS_UseNPCSpeechTable(
                    npcSurvivor, PZNS_PresetsSpeeches.PZNS_OrderConfirmed, "Friendly"
                );
            end
            PZNS_UtilsNPCs.PZNS_SetNPCJob(npcSurvivor, jobName);
            parentContextMenu:setVisible(false);
        end
        --
        if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == true) then
            local isNPCSquareLoaded = PZNS_UtilsNPCs.PZNS_GetIsNPCSquareLoaded(npcSurvivor);
            if (isNPCSquareLoaded == true) then
                parentContextMenu:addOption(
                    npcSurvivor.survivorName,
                    nil,
                    callbackFunction
                );
            end
        end
    end -- Cows: End groupMembers for-loop

    return parentContextMenu;
end

---comment
---@param mpPlayerID number
---@param context any
---@param worldobjects any
function PZNS_ContextMenu.JobsOptions(mpPlayerID, context, worldobjects)
    local jobsSubMenu_1 = context:getNew(context);
    local jobsSubMenu_1_Option = context:addOption(
        getText("ContextMenu_PZNS_PZNS_Jobs"),
        worldobjects,
        nil
    );
    context:addSubMenu(jobsSubMenu_1_Option, jobsSubMenu_1);
    --
    local playerGroupID = "Player" .. tostring(mpPlayerID) .. "Group";
    --
    for jobKey, jobText in pairs(PZNS_JobsText) do
        local jobSubMenu_2 = jobsSubMenu_1:getNew(context);
        local jobSubMenu_2_Option = jobsSubMenu_1:addOption(
            jobText[2],
            worldobjects,
            nil
        );
        local npcSubMenu_3 = jobSubMenu_2:getNew(context);
        PZNS_CreateJobNPCsMenu(npcSubMenu_3, mpPlayerID, playerGroupID, jobText[1]);
        --
        jobsSubMenu_1:addSubMenu(jobSubMenu_2_Option, jobSubMenu_2);
        jobSubMenu_2:addSubMenu(jobSubMenu_2_Option, npcSubMenu_3);
    end
end
