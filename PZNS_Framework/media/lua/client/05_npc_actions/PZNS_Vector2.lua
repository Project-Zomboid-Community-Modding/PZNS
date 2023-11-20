
-- oZumbiAnalitico: 
-- ... the purpose of this file is to be used on relative movement, like strafe, pursue and flee from target.
-- ... directly scrapped from TakeNoPrisoners raider npc mod.

local PZNS_Vector2 = {}

-- oZumbiAnalitico: random sign function, -1, 1
function PZNS_Vector2.rSgn()
    if 1==ZombRand(1,2) then 
        return 1
    else
        return -1
    end
end

-- oZumbiAnalitico: generate new Vector2 object
function PZNS_Vector2.newVector(X,Y)
    -- oZumbiAnalitico : This is a workaround, don't know how to create a proper Vector2 from lua
    local PLAYER = getSpecificPlayer(0)
    if not PLAYER then return nil end
    local VECTOR = PLAYER:getLastAngle()
    if not VECTOR then return nil end
    local VECTOR_clone = VECTOR:clone()
    VECTOR_clone:set(X,Y)
    return VECTOR_clone
end

function PZNS_Vector2.vecDiff(vector1, vector2) -- vector1 - vector2
    vector2:scale(-1.0)
    return vector1:add(vector2)
end

function PZNS_Vector2.vecDiff_coords(X,Y,X2,Y2)
    local vector1 = PZNS_Vector2.newVector(X,Y)
    local vector2 = PZNS_Vector2.newVector(X2,Y2)
    if not vector1 or not vector2 then return nil end
    return PZNS_Vector2.vecDiff(vector1, vector2)
end

-- oZumbiAnalitico: create a Vector2 from square position or get a square from Vector2 object
function PZNS_Vector2.vector2square(vector)
    local PLAYER = getSpecificPlayer(0)
    if not PLAYER then return nil end
    local X = vector:getX()
    local Y = vector:getY()
    if X < 0 or Y < 0 then return nil end -- squares only accept positive coords
    local Z = PLAYER:getZ()
    if not X or not Y or not Z then return nil end
    local CELL = getCell()
    if not CELL then return nil end
    return CELL:getGridSquare(X, Y, Z)
end

function PZNS_Vector2.square2vector(square)
    if not square then return nil end
    local X = square:getX()
    local Y = square:getY()
    if not X or not Y then return nil end
    return PZNS_Vector2.newVector(X,Y)
end

-- Inventory [ Vector2 ]
-- https://zomboid-javadoc.com/41.78/zombie/iso/Vector2.html
-- --------------------------------------------------
-- VECTOR:angleBetween(Vector2 vector2) -- Radians
-- VECTOR:rotate(float float1)
-- VECTOR:scale(float float1)
-- VECTOR:normalize()
-- VECTOR:getX()
-- VECTOR:getY()
-- VECTOR:getLength()
-- VECTOR:getLengthSquared()
-- VECTOR:getDirection()
-- VECTOR:set(float float1, float float2)
-- VECTOR:setLength(float float1)
-- VECTOR:setLengthAndDirection(float float1, float float2)

-- oZumbiAnalitico: create a Vector2 from isoplayer object position. 
function PZNS_Vector2.isoplayer2vector(isoplayer)
    if not isoplayer then return nil end
    if not isoplayer.getX then return nil end
    local X = isoplayer:getX()
    local Y = isoplayer:getY()
    if not X or not Y then return nil end
    return PZNS_Vector2.newVector(X,Y)
end

-- oZumbiAnalitico: 
-- minimal usage: 
-- ... local vector = PZNS_Vector2.isoPlayerTargetArrow( TargetIsoPlayer, CurrentIsoPlayer)
-- Vector2, Vector2 <-- PZNS_Vector2.isoPlayerTargetArrow( TargetIsoPlayer, CurrentIsoPlayer, [ Integer, Radians Float] )
-- Pertubation variable applies a random rotation
function PZNS_Vector2.isoPlayerTargetArrow(TargetIsoPlayer, CurrentIsoPlayer, arrow_length_in_squares, Pertubation) 
    if not TargetIsoPlayer or not CurrentIsoPlayer then return nil end
    local head = PZNS_Vector2.isoplayer2vector(TargetIsoPlayer)
    local tail = PZNS_Vector2.isoplayer2vector(CurrentIsoPlayer)
    if not head or not tail then return nil end
    --
    if not arrow_length_in_squares then return PZNS_Vector2.vecDiff( head, tail:clone() ), tail end
    local arrow = PZNS_Vector2.vecDiff( head, tail:clone() )
    arrow:scale(1.0/arrow:getLength())
    arrow:scale( arrow_length_in_squares )
    if not Pertubation then return arrow, tail end
    if Pertubation == true then
        local theta = math.pi/6.0 -- 30 degrees
        theta = PZNS_Vector2.rSgn()*theta*ZombRand(0,100)/100.0
        arrow:rotate(theta)
        return arrow, tail
    else
        Pertubation = PZNS_Vector2.rSgn()*Pertubation*ZombRand(0,100)/100.0
        arrow:rotate(Pertubation)
        return arrow, tail
    end
end

-- oZumbiAnalitico: 
-- minimal usage: 
-- ... local vector = PZNS_Vector2.isoPlayerFleeArrow(TargetIsoPlayer, CurrentIsoPlayer)
-- Vector2, Vector2 <-- PZNS_Vector2.isoPlayerFleeArrow(TargetIsoPlayer, CurrentIsoPlayer, [ Integer, Radians Float] )
-- Pertubation variable applies a random rotation
function PZNS_Vector2.isoPlayerFleeArrow(TargetIsoPlayer, CurrentIsoPlayer, arrow_length_in_squares, Pertubation)
    if not TargetIsoPlayer or not CurrentIsoPlayer then return nil end
    local head = PZNS_Vector2.isoplayer2vector(CurrentIsoPlayer)
    local tail = PZNS_Vector2.isoplayer2vector(TargetIsoPlayer)
    if not head or not tail then return nil end
    --
    if not arrow_length_in_squares then return PZNS_Vector2.vecDiff( head:clone() , tail), head end    
    local arrow = PZNS_Vector2.vecDiff( head:clone() , tail)
    arrow:scale(1.0/arrow:getLength())
    arrow:scale( arrow_length_in_squares )
    if not Pertubation then return arrow, head end
    if Pertubation == true then
        local theta = math.pi/6.0 -- 30 degrees
        theta = PZNS_Vector2.rSgn()*theta*ZombRand(0,100)/100.0
        arrow:rotate(theta)
        return arrow, head
    else
        Pertubation = PZNS_Vector2.rSgn()*Pertubation*ZombRand(0,100)/100.0
        arrow:rotate(Pertubation)
        return arrow, head
    end
end

return PZNS_Vector2
