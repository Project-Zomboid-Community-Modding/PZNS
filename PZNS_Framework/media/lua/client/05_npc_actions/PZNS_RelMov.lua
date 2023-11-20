
-- oZumbiAnalitico: Relative Movement
-- ... scrapped from TakeNoPrisoners mod

require("05_npc_actions/PZNS_WalkTo")
require("05_npc_actions/PZNS_RunTo")
require("05_npc_actions/PZNS_WeaponReload")
local PZNS_Vector2 = require("05_npc_actions/PZNS_Vector2")
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs")
local PZNS_GeneralAI = require("07_npc_ai/PZNS_GeneralAI")

--
local PZNS_RelMov = {}

-- ( npcSurvivor, vector2, [ moveToXYZ_function,  Z ] )
-- ... moveToXYZ_function(npcSurvivor, X,Y,Z)
local function moveToSquareVector2(npcSurvivor, vector, moveToXYZ_function, Z)
    if not vector then return nil end
    if not moveToXYZ_function then moveToXYZ_function = PZNS_RunToSquareXYZ end
    if not Z then 
        return moveToXYZ_function(npcSurvivor, vector:getX(), vector:getY(), npcSurvivor.squareZ )
    end
    moveToXYZ_function(npcSurvivor, math.floor( vector:getX() ), math.floor( vector:getY() ), Z )
end

-- (targetObject, npcSurvivor, [ dist_squares, moveToXYZ_function ] )
-- ... moveToXYZ_function(npcSurvivor, X,Y,Z)
function PZNS_RelMov.PZNS_flee(targetObject, npcSurvivor, dist_squares, moveToXYZ_function)
    if not dist_squares then dist_squares = 10 end
	-- *%
    if not targetObject then return nil end
    if not npcSurvivor then return nil end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject
    if not npcIsoPlayer then return nil end	
    if npcIsoPlayer:isBehaviourMoving() then return nil end
    -- $ head
    -- $ head || $ direction
    local direction, head = PZNS_Vector2.isoPlayerFleeArrow(targetObject, npcIsoPlayer,dist_squares, true)
    if not direction then return nil end
    if not head then return nil end
    -- $ head || $ direction | add()
    head = head:add( direction )
	if not head then return nil end
	-- walkToSquareVector2()
	PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor)
    moveToSquareVector2( npcSurvivor, head, moveToXYZ_function )
end

-- (targetObject, npcSurvivor, [ moveToXYZ_function ])
function PZNS_RelMov.PZNS_pursue(targetObject,npcSurvivor, moveToXYZ_function)
    -- *%
    if not targetObject or not npcSurvivor then return nil end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject
    if not npcIsoPlayer then return nil end
    --
    if PZNS_GeneralAI.PZNS_IsReloadNeeded(npcSurvivor) then -- don't pursue if reload is needed
        PZNS_WeaponReload(npcSurvivor)
        return nil
    end
    --
    if npcIsoPlayer:isBehaviourMoving() then return nil end	
    -- $ head
    local direction, head = PZNS_Vector2.isoPlayerTargetArrow(targetObject, npcIsoPlayer)
    if not direction then return nil end
    if not head then return nil end
	local norm = direction:getLength()
    direction:scale(1.0/norm) -- unitary
    if norm > 7 then 
		direction:scale(norm/2.0)
		local theta = math.pi/3.0 -- 30 degrees
		theta = PZNS_Vector2.rSgn()*theta*ZombRand(0,100)/100.0
		direction:rotate(theta)
	elseif norm <= 1.1 then 
		return nil
	else
		direction:scale(norm/2.0)
	end
    head = head:add( direction )
	if not head then return nil end
	--
	PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor)
    moveToSquareVector2( npcSurvivor, head, moveToXYZ_function, targetObject:getZ() )
end

-- (targetObject, npcSurvivor, [ moveToXYZ_function ])
function PZNS_RelMov.PZNS_direct_pursue(targetObject,npcSurvivor, moveToXYZ_function)
    -- *%
    if not targetObject or not npcSurvivor then return nil end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject
    if not npcIsoPlayer then return nil end
    --
    if PZNS_GeneralAI.PZNS_IsReloadNeeded(npcSurvivor) then -- don't pursue if reload is needed
        PZNS_WeaponReload(npcSurvivor)
        return nil
    end
    --
    if npcIsoPlayer:isBehaviourMoving() then return nil end
    -- $ head
    local direction, head = PZNS_Vector2.isoPlayerTargetArrow(targetObject, npcIsoPlayer)
    if not direction then return nil end
    if not head then return nil end
	local norm = direction:getLength()
    direction:scale(1.0/norm) -- unitary
	direction:scale(norm/2.0)
    head = head:add( direction )
	if not head then return nil end
	--
	PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor)
    moveToSquareVector2( npcSurvivor, head, moveToXYZ_function, targetObject:getZ() )
end

-- ( targetObject, npcSurvivor, [ dist_squares, moveToXYZ_function ] )
function PZNS_RelMov.PZNS_strafe_right(targetObject, npcSurvivor, dist_squares, moveToXYZ_function)
    -- *%
    if not targetObject or not npcSurvivor then return nil end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject
    if not npcIsoPlayer then return nil end
    if npcIsoPlayer:isBehaviourMoving() then return nil end  
    -- $ head
    -- $ head || $ direction
    local direction, head = PZNS_Vector2.isoPlayerTargetArrow(targetObject, npcIsoPlayer)
    if not direction then return nil end
    if not head then return nil end
    direction:scale(1.0/direction:getLength()) -- unitary
    -- $ head || $ direction | # strafe left, strafe right
    direction:rotate(-math.pi/2.0)
    -- $ head || strage 5 squares
    if not dist_squares then 
        if npcIsoPlayer:isOutside() then
            direction:scale(10)
        else
            direction:scale(5)
        end
    else 
        direction:scale(dist_squares)
    end
    head = head:add(direction)
    if not head then return nil end
    PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor)
    moveToSquareVector2( npcSurvivor, head, moveToXYZ_function, targetObject:getZ() )
end

-- ( targetObject, npcSurvivor, [ dist_squares, moveToXYZ_function ] )
function PZNS_RelMov.PZNS_strafe_left(targetObject,npcSurvivor, dist_squares, moveToXYZ_function) 
    -- *%
    if not targetObject or not npcSurvivor then return nil end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject
    if not npcIsoPlayer then return nil end
    if npcIsoPlayer:isBehaviourMoving() then return nil end  
    -- $ head
    -- $ head || $ direction
    local direction, head = PZNS_Vector2.isoPlayerTargetArrow(targetObject, npcIsoPlayer)
    if not direction then return nil end
    if not head then return nil end
    direction:scale(1.0/direction:getLength()) -- unitary
    -- $ head || $ direction | # strafe left, strafe right
    direction:rotate(math.pi/2.0)
    -- $ head || strage 5 squares
    if not dist_squares then 
        if npcIsoPlayer:isOutside() then
            direction:scale(10)
        else
            direction:scale(5)
        end
    else 
        direction:scale(dist_squares)
    end
    head = head:add(direction)
    if not head then return nil end
    PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions(npcSurvivor)
    moveToSquareVector2( npcSurvivor, head, moveToXYZ_function, targetObject:getZ() )
end

return PZNS_RelMov
