local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_DebuggerUtils = require("02_mod_utils/PZNS_DebuggerUtils");

---comment
---@param npcSurvivor any
---@param targetIsoPlayer any
function PZNS_EnterVehicleAsPassenger(npcSurvivor, targetIsoPlayer)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    -- Cows: Now get the vehicle and the seats it has.
    local driverVehicle = targetIsoPlayer:getVehicle();
    -- local driverSeat = driverVehicle:getSeat(targetIsoPlayer);
    local numOfSeats = driverVehicle:getScript():getPassengerCount();
    -- Cows: Enter the first available seat that is not the driver seat.
    for i = 1, numOfSeats do
        --
        if (driverVehicle:isSeatOccupied(i) ~= true) then
            local enterCarAction = ISEnterVehicle:new(npcIsoPlayer, driverVehicle, i);
            local closeCarDoorAction = ISCloseVehicleDoor:new(npcIsoPlayer, driverVehicle, i);
            PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, enterCarAction);
            PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, closeCarDoorAction);
            break;
        end
    end
end

-- WIP - Cows: Curious, I have observed the exit action seems to lock the player keyboard controls randomly whenever NPCs exit the vehicle...
-- WIP - Cows: The current workaround is to open the context menu, and select "Walk to" a square, which then unlocks the player key inputs.
---@param npcSurvivor any
function PZNS_ExitVehicle(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    ---@type IsoPlayer
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    -- Cows: Check if the RV Interiors is loaded and if the NPC's square is loaded on screen.
    if (PZNS_DebuggerUtils.PZNS_IsModActive("RV_Interior_MP") == true and npcIsoPlayer:getSquare():IsOnScreen() ~= true) then
        -- Cows: RV Interiors works by teleporting the player to a new map (literally)... so the NPC and the vehicle it is in will *most* likely not be on screen.
        PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor); -- Cows: Clear the actions queue, the NPC can't do anything while the player is inside RV interior.
        return;
    else
        -- Cows: Else use vanilla assets, exit the vehicle.
        -- local currentVehicle = npcIsoPlayer:getVehicle();
        -- local currentSeat = npcIsoPlayer:getVehicle():getSeat(npcIsoPlayer);
        local exitCarAction = ISExitVehicle:new(npcIsoPlayer);
        -- local closeCarDoorAction = ISCloseVehicleDoor:new(npcIsoPlayer, currentVehicle, currentSeat);
        PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, exitCarAction);
        -- PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, closeCarDoorAction); -- WIP - Cows: NPCs don't seem to close the door on exit no matter what I try...
    end
end
