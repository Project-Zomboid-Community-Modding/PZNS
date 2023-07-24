local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");

---comment
---@param npcSurvivor any
---@param targetIsoPlayer any
function PZNS_EnterVehicleAsPassenger(npcSurvivor, targetIsoPlayer)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    -- Cows: Check if the npc is alive.
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    if (npcIsoPlayer:isAlive() == false) then
        return;
    end
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

---comment
---@param npcSurvivor any
function PZNS_ExitVehicle(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    --
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local currentVehicle = npcIsoPlayer:getVehicle();
    local currentSeat = npcIsoPlayer:getVehicle():getSeat(npcIsoPlayer);
    local exitCarAction = ISExitVehicle:new(npcIsoPlayer);
    local closeCarDoorAction = ISCloseVehicleDoor:new(npcIsoPlayer, currentVehicle, currentSeat);
    PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, exitCarAction);
    PZNS_UtilsNPCs.PZNS_AddNPCActionToQueue(npcSurvivor, closeCarDoorAction);
end
