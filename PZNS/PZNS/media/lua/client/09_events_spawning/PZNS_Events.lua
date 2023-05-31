--- Cows: Key press activated functions.
---@param keyNum number
function PZNS_KeyBindAction(keyNum)
    --- Cows: Intended for Debug and Testing only
    local keyPressed = "k" .. tostring(keyNum);
    local keyMap = {
        k83 = PZNS_DeleteBobTester,
        k156 = PZNS_SpawnBobTester,
        k79 = PZNS_ShowNpcSurvivorInfo -- WIP - Cows: For now, this only prints the info.
    };
    -- Cows: Check if keyPressed value isn't nil then execute the function assigned to key
    if (keyMap[keyPressed] ~= nil) then
        if (keyNum ~= 79) then
            return keyMap[keyPressed](); -- Cows: I'm amazed this even works... but it does.
        else
            return keyMap[keyPressed](PZNS_NPCManager.AciveNPCs["PZNS_BobTester"]);
        end
    end
    return nil;
end

local function PZNS_HotKeyPress()
    Events.OnKeyPressed.Add(PZNS_KeyBindAction);
end

Events.OnGameStart.Add(PZNS_HotKeyPress);
