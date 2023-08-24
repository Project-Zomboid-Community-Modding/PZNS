--- Cows: Key press activated functions.
local PZNS_DebuggerUtils = require("02_mod_utils/PZNS_DebuggerUtils");
local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");

local function doNothing()
end
---@param keyNum number
function PZNS_KeyBindAction(keyNum)
    --- Cows: Intended for Debug and Testing only
    local keyPressed = "k" .. tostring(keyNum);
    local keyMap = {
        k55 = PZNS_WorldUtils.PZNS_SpawnNPCIfSquareIsLoaded,   -- numpad *
        k71 = PZNS_DebuggerUtils.PZNS_GetAllObjectsInCell,     -- numpad 7
        k72 = PZNS_DebuggerUtils.PZNS_LogPlayerCellGridSquare, -- numpad 8
        k73 = PZNS_DebuggerUtils.PZNS_LogPlayerCustomization,  -- numpad 9
        k74 = doNothing,                                       -- numpad -
        k75 = PZNS_DebuggerUtils.LogNPCGroupsModData,          -- numpad 4
        k76 = PZNS_DebuggerUtils.LogNPCsModData,               -- numpad 5
        k77 = PZNS_DebuggerUtils.LogZonesModData,              -- numpad 6
        k78 = doNothing,                                       -- numpad +
        k79 = doNothing,                                       -- numpad 1
        k80 = doNothing,                                       -- numpad 2
        k81 = doNothing,                                       -- numpad 3
        -- k82 = doNothing,                    -- numpad 0 -- Cows: Do not use this key for now, it is used in "Proximity Inventory" https://steamcommunity.com/sharedfiles/filedetails/?id=2847184718
        k83 = doNothing,                                       -- numpad .
        k156 = doNothing,                                      -- numpad enter
    };
    -- Cows: Check if keyPressed value isn't nil then execute the function assigned to key
    if (keyMap[keyPressed] ~= nil) then
        if (keyNum ~= 72) then
            return keyMap[keyPressed](); -- Cows: I'm amazed this even works... but it does.
        else
            return keyMap[keyPressed](0);
        end
    end
    return nil;
end
