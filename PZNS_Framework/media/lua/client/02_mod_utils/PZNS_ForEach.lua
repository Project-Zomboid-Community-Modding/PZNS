
-- oZumbiAnalitico : Scrapped from TakeNoPrisoners Raider Mod
-- ... this file contains foreach functions which are alternative to iterators.

--
-- ====================================================================
--           >>> THEORY : should read first before use it <<<

-- Necessary Properties of Inner Function:
-- 1. Inner Functions MUST RETURN nil to continue the loop. So nil means success or continue the loop. True means break of the loop and anything else means break return which return the object found.
-- 2. The ret argument is used for tables or return objects. But is almost unnecessary.
-- 3. If the Inner Function return something DIFFERENT from nil them the loop stops. 
-- 4. The true value returned from Inner Function means a failure, assertion failure, of some event that makes the next loop operations meaningless.
-- 5. You can use less variables in functions for lua, so you can use a function inner_function(index) for a place that expect inner_function(index, value, ret), the remaining variables will be assigned nil.
-- 6. inner_function is a function that encapsulate the iteration of a loop.
-- 7. when an inner_function return true then it will emulate the "break" statement
-- 8. when an inner_function return nil earlier it will emulate the "continue" statement which don't exists in lua
-- --------------------------------------------------------------------
-- For Short: 
-- 1. "return true" means break the loop.
-- 2. "return object" means break and return the object.
-- 3. "return nil" means continue the loop or end of the iteration. 

--[[ Example : Loop Through Cell Objects to find windows

-- Anonymous Function : 
PZNS_ForEach.cellObject( function (obj) 
    if not obj then return nil end -- "continue", the loop
    if obj:getObjectName() == "Window" then return obj end -- "break", and return object
    return nil -- end, of iteration, must return nil to continue the loop !!!
end )

-- Defining the function outside
local function findFirstWindow(obj)
    if not obj then return nil end -- "continue", the loop
    if obj:getObjectName() == "Window" then return obj end -- "break", and return object
    return nil -- end, of iteration
end
PZNS_ForEach.cellObject( findFirstWindow )

-- Creating a New ForEach function
local foreach_cell_window(inner_function)
    local CELL = getCell()
    if not CELL then return nil end
    local function inner2_function(obj)
        if not obj then return nil end -- "continue", the loop in cell objects array
        if obj:getObjectName() ~= "Window" then return nil end -- "continue", the loop in cell objects array
        return inner_function(obj)
    end
    return PZNS_ForEach.cellObject(inner2_function, CELL)
end

foreach_cell_window( function (window) 
    if not window then return nil end -- continue
    if window:isBarricaded() then return window end -- break and return the window
    return nil -- end, of iteration
end )

--]]

--[[ Example : Loop Through Survivors

local closeSurvivor = PZNS_ForEach.activeNPC( function (npcSurvivor) 
    if not PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) then return nil end -- continue, if not valid
    if PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects( npcSurvivor.npcIsoPlayerObject , getSpecificPlayer(0) ) < 5 then 
        return npcSurvivor 
    end -- break and return a npcSurvivor with a distance less than 5 squares
    return nil -- end of iteration
end )


--]]

--
-- ====================================================================
-- >>> This part is optional, or on demand, to understand the annotations <<<

--[[

-- Definition [ Path-Logic Notation ] : A logic is a list of linear statements "logical-paths", each statement represent an execution path restricted to an condition. Using the notation below:

-- Example:
-- "for i in iterator() do if condition() then function_call() end end" in path-logic notation will be:
-- & i in iterator() || % condition() || function_call()

-- 1. A || B means that B is inside A, or A calls B, B is inside A structure. Example is a function A() calling a subfunction B()
-- 2. A | B means that B is executed after A, but in same context level of A. Example let C be a function that calls A() and in the next line calls B()
-- 3. % is a conditional control structure
-- 4. & is a loop structure
-- 5. $ is a variable or object construction
-- 6. *% is a conditional checkpoint, often in beginning of function
-- 7. ? A, B, C means a random choice between A, B, C, ...
-- 8. { A, B, C } in the end of statements means that the end part of statement use A, B, C functions or operations in a way decided when implemented.
-- 9. { A, B, C } in beginning of statements means that the statement follows when conditions A, B, C are met. 
-- 10. _function() is not a reference to a real function, is a reference to a concept that could be used in an actual function. That name becomes a suffix to an implemented function.
-- 11. <- is a binary operator that encapsulate the return of a function. A <- B means that A will return the return of B. A <- B || C means is the way to continue the path to B context, C is called in B definition.
-- 12. <custom_operator> is the notation for an binary operator, for example, function_1 <definition> function_2 could mean that function_1 defines function_2, function_1 <callback> function_2 could mean that function_1 register function_2 as a callback for some event. A <operator> B || C is some how equivalent to 1. A(B, ...) 2. B || C

-- Path-Logic Notation for ForEach functions:
-- 1. calling "ForEach(inner_function)" will be conceptually the same as "& variables in container defined in ForEach function || inner_function(variables)"
-- 2. ForEach o inner_function := & variables in container defined in ForEach function || inner_function()
-- 3. ForEach o inner_function || another_function() will be the same as ... 
-- ... & "ForEach" || inner_function() || another_function() ... so the another_function is called inside inner_function definition
-- 4.  A o B is the binary operator foreach. To be similar to function composition.

--]]

-- Requires from PZNS NPC Framework
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_NPCGroupsManager = require("04_data_management/PZNS_NPCGroupsManager");
local PZNS_NPCsManager = require("04_data_management/PZNS_NPCsManager");
local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");
local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs")
local PZNS_PresetsSpeeches = require("03_mod_core/PZNS_PresetsSpeeches");

local PZNS_ForEach = {}

--
-- ====================================================================
--                            >>> GENERAL <<<

--
-- ====================================================================
-- Foreach for Tables

-- Note: There is a foreach for tables in lua language
-- Syntax: foreach(table_reference, function_reference)
-- The foreach defined here are customized for specific purposes.

-- Logic [ ForEach Basic Definition ]
-- 1. Let F the for each function and I the inner function
-- ----------------------------------------------
-- 1. F(I,...) || & || $ R || R <assigned as return of> I
-- 2. F(I,...) || & || $ R | % not R || "continue"
-- 3. F(I,...) || & || $ R | % not R | % "else" || % R == true || "break"
-- 4. F(I,...) || & || $ R | % not R | % "else" || % R == true | % R is object || F <- R

-- inner_function(index, value, array_table, ret) 
function PZNS_ForEach.arrayTable(inner_function, array_table) -- [ok]
    if type(array_table) ~= "table" then return nil end
    if #array_table == 0 then return nil end
    local ret = nil
    for index, value in ipairs(array_table) do
        local inner_function_ret = inner_function(index,value, array_table, ret)
        if inner_function_ret == nil then -- continue
        else -- break or break return
            if inner_function_ret == true then -- break 
                break 
            else -- if false the return false, if any other thing then return this thing
                return inner_function_ret
            end
        end
    end
    return ret
end

function PZNS_ForEach.genericTable(inner_function, generic_table) -- [ok]
    if type(generic_table) ~= "table" then return nil end
    if #generic_table == 0 then return nil end
    local ret = nil
    for index, value in pairs(generic_table) do
        local inner_function_ret = inner_function(index,value, array_table, ret)
        if inner_function_ret == nil then -- continue
        else -- break or break return
            if inner_function_ret == true then -- break 
                break 
            else -- if false the return false, if any other thing then return this thing
                return inner_function_ret
            end
        end
    end
    return ret
end

-- Logic [ PZNS_ForEach.nestedTable_endPoints ]
-- 1. F := PZNS_ForEach.nestedTable_endPoints
-- 2. I := inner_function
-- 3. G := PZNS_ForEach.genericTable
-- ----------------------------------------
-- 1. F(I, ...) := G o inner || % "is table" || %* size zero | F o I
-- 2. F(I, ...) := G o inner || % "is table" | inner <- I

-- inner_function(index,value, array_table)
function PZNS_ForEach.nestedTable_endPoints(inner_function, nested_table) -- [ok]
    if type(nested_table) ~= "table" then return nil end
    if #nested_table == 0 then return nil end
    local function inner(index,value, array_table)
        if type(value) == 'table' then 
            if #value==0 then return nil end
            PZNS_ForEach.nestedTable_endPoints(inner_function, value) 
        end
        return inner_function(index,value, array_table)
    end
    PZNS_ForEach.genericTable(inner, nested_table)
end

--
-- ====================================================================
-- Foreach ArrayList

-- inner_function(i, arrayList , size, ret)
function PZNS_ForEach.arrayList(inner_function, arrayList)
    local size = arrayList:size()
    if size == 0 then return nil end
    local ret = nil
    for i=0, size-1 do
        -- INNER_FUNCTION_COMPONENT
        local inner_function_return = inner_function(i, arrayList , size, ret)
        -- INNER_FUNCTION_COMPONENT || inner_function return properties
        if inner_function_return == nil then 
            -- nothing : continue the loop
        else
            if inner_function_return == true then
                break
            else
                return inner_function_return
            end
        end
    end
    return ret
end

--
-- ====================================================================
-- Foreach IsoPlayer Related

-- Logic [ PZNS_ForEach.inventoryItem ]
-- 1. F := PZNS_ForEach.inventoryItem
-- 2. I := inner_function
-- 3. A := PZNS_ForEach.arrayList
-- 4. i := inner2_function
-- ----------------------------------------
-- 1. F(I, ...) := A o i || $ item | i <- I(item, i, size, items, inventory, isoplayer, ret)
function PZNS_ForEach.inventoryItem(inner_function, isoplayer) 
    if not isoplayer then return nil end
    local INVENTORY = isoplayer:getInventory()
    if not INVENTORY then return nil end
    local ARRAY = INVENTORY:getItems()
    if not ARRAY then return nil end
    --
    local function inner2_function(i, arrayList , size, ret)
        local item = arrayList:get(i)
        return inner_function(item, i, size, arrayList, INVENTORY, isoplayer, ret)
    end
    return PZNS_ForEach.arrayList(inner2_function, ARRAY)
end

-- inner_function(item, size, i, arrayList, ret)
function PZNS_ForEach.attachedItems(inner_function, isochar)
    local AttachedItems = isochar:getAttachedItems()
    local function inner2_function(i, arrayList , size, ret)
        local item = arrayList:get(i)
        return inner_function(item, size, i, arrayList, ret)
    end
    return PZNS_ForEach.arrayList(inner2_function, AttachedItems)
end

-- inner_function(item, index)
function PZNS_ForEach.handItem(inner_function, isoplayer) 
    -- primary
    local item = isoplayer:getPrimaryHandItem()
    local inner_function_return = inner_function(item, 1)
    if inner_function_return == true then return end
    if inner_function_return ~= nil then
        if inner_function_return == false then
            return 
        else
            return inner_function_return
        end
    end
    -- secondary
    item = isoplayer:getSecondaryHandItem()
    inner_function_return = inner_function(item , 2)
    if inner_function_return == true then return end
    if inner_function_return ~= nil then
        if inner_function_return == false then
            return 
        else
            return inner_function_return
        end
    end
end

-- inner_function(item)
function PZNS_ForEach.clothingItem(inner_function, isoplayer) 
    
    local item = isoplayer:getClothingItem_Hands()
    local inner_function_return = inner_function(item)
    if inner_function_return ~= nil then
        if inner_function_return == false then
            return 
        else
            return inner_function_return
        end
    end
    
    item = isoplayer:getClothingItem_Legs()
    inner_function_return = inner_function(item)
    if inner_function_return ~= nil then
        if inner_function_return == false then
            return 
        else
            return inner_function_return
        end
    end
    
    item = isoplayer:getClothingItem_Head()
    inner_function_return = inner_function(item)
    if inner_function_return ~= nil then
        if inner_function_return == false then
            return 
        else
            return inner_function_return
        end
    end
    
    item = isoplayer:getClothingItem_Back()
    inner_function_return = inner_function(item)
    if inner_function_return ~= nil then
        if inner_function_return == false then
            return 
        else
            return inner_function_return
        end
    end
    
    item = isoplayer:getClothingItem_Feet()
    inner_function_return = inner_function(item)
    if inner_function_return ~= nil then
        if inner_function_return == false then
            return 
        else
            return inner_function_return
        end
    end
    
    item = isoplayer:getClothingItem_Torso()
    inner_function_return = inner_function(item)
    if inner_function_return ~= nil then
        if inner_function_return == false then
            return 
        else
            return inner_function_return
        end
    end
    
end

-- inner_function(bodyPart, i, bodyParts, bodydamage, ret)
function PZNS_ForEach.bodyPart(inner_function, isoplayer)    
    local BODYDAMAGE = isoplayer:getBodyDamage()
    local arrayList = BODYDAMAGE:getBodyParts()
    local function inner2_function(i, arrayList , size, ret)
        local bodyPart = arrayList:get(i)
        return inner_function(bodyPart, i, arrayList, BODYDAMAGE, ret)
    end
    return PZNS_ForEach.arrayList(inner2_function, arrayList)
end

-- inner_function(bodyPart, i, bodyParts, bodydamage, ret)
function PZNS_ForEach.bleedingBodyPary(inner_function, isoplayer) 
    local function inner2_function(bodyPart, i, bodyParts, bodydamage, ret)
        if not bodyPart:bleeding() then return nil end
        return inner_function(bodyPart, i, bodyParts, bodydamage, ret)
    end
    return PZNS_ForEach.bodyPart(inner2_function, isoplayer)
end

-- inner_function(bodyPart, i, bodyParts, bodydamage, ret)
function PZNS_ForEach.untreatedBodyPart(inner_function, isoplayer) 
    local function inner2_function(bodyPart, i, bodyParts, bodydamage, ret)
        if bodyPart:bandaged() then return nil end
        return inner_function(bodyPart, i, bodyParts, bodydamage, ret)
    end
    return PZNS_ForEach.bodyPart(inner2_function, isoplayer)
end

-- inner_function(bodyPart, i, bodyParts, bodydamage, ret)
function PZNS_ForEach.treatedBodyPart(inner_function, isoplayer) 
    local function inner2_function(bodyPart, i, bodyParts, bodydamage, ret)
        if not bodyPart:bandaged() then return nil end
        return inner_function(bodyPart, i, bodyParts, bodydamage, ret)
    end
    return PZNS_ForEach.bodyPart(inner2_function, isoplayer)
end

-- inner_function(weapon, i, size, items, inventory, isoplayer, ret)
function PZNS_ForEach.inventoryWeapon(inner_function, isoplayer) 
    local function inner2_function(item, i, size, items, inventory, isoplayer, ret)
        if not item:IsWeapon() then return nil end
        return inner_function(item, i, size, items, inventory, isoplayer, ret)
    end
    return PZNS_ForEach.inventoryItem(inner2_function, isoplayer) 
end

-- inner_function(weapon, i, size, items, inventory, isoplayer, ret)
function PZNS_ForEach.rangedInventoryWeapon(inner_function, isoplayer)
    local function inner2_function(weapon, i, size, items, inventory, isoplayer, ret)
        if not weapon:isRanged() then return nil end
        return inner_function(weapon, i, size, items, inventory, isoplayer, ret)
    end
    return PZNS_ForEach.inventoryWeapon(inner2_function, isoplayer) 
end

-- inner_function(part,i, arrayList , size, ret)
function PZNS_ForEach.weaponPart(inner_function, weapon) 
    local ARRAY = weapon:getAllWeaponParts()
    local function inner2_function(i, arrayList , size, ret)
        local part = arrayList:get(i)
        return inner_function(part,i, arrayList , size, ret)
    end
    return PZNS_ForEach.arrayList(inner2_function, ARRAY)
end

-- function PZNS_ForEach.inventoryLiterature(inner_function, isoplayer) end
-- function PZNS_ForEach.journalPage(inner_function, item) end
-- function PZNS_ForEach.inventoryBag(inner_function, isoplayer) end
-- function PZNS_ForEach.equipedItem(inner_function, isoplayer) end
-- function PZNS_ForEach.statsValues(inner_function, isoplayer) end
-- function PZNS_ForEach.isoplayerPerk(inner_function, isoplayer) end

--
-- ====================================================================
-- Foreach Cell Related

-- inner_function(obj, i objects, size, ret)
function PZNS_ForEach.cellObject(inner_function, cell)
    if not cell then cell = getCell() end
    local cell_obj_list = cell:getObjectList()
    local function inner2_function(i, arrayList , size, ret)
        local obj = arrayList:get(i)
        return inner_function(obj, i, arrayList, size, ret)
    end
    return PZNS_ForEach.arrayList(inner2_function, cell_obj_list)
end

-- inner_function(vehicle, i, vehicles, size, ret)
function PZNS_ForEach.cellVehicle(inner_function, cell) 
    local cell_vehicle_list = cell:getVehicles()
    local function inner2_function(i, arrayList , size, ret)
        local obj = arrayList:get(i)
        return inner_function(obj, i, arrayList, size, ret)
    end
    return PZNS_ForEach.arrayList(inner2_function, cell_vehicle_list)
end

-- inner_function(isozombie, i, zombies, size, ret)
function PZNS_ForEach.cellZombie(inner_function, cell) 
    local ARRAY = cell:getZombieList()
    local function inner2_function(i, arrayList , size, ret)
        local isozombie = arrayList:get(i)
        return inner_function(isozombie, i, arrayList, size, ret)
    end
    return PZNS_ForEach.arrayList(inner2_function, ARRAY)
end

-- inner_function(obj, i objects, size, ret)
function PZNS_ForEach.cellIsoPlayer(inner_function, cell) 
    local function inner2_function(obj, i, objects, size, ret)
        if not instanceof(obj, "IsoPlayer") then return nil end
        return inner_function(obj, i, objects, size, ret)
    end
    return PZNS_ForEach.cellObject(inner2_function, cell)
end

-- inner_function(room, i, rooms, size, ret)
function PZNS_ForEach.cellRoom(inner_function, cell) 
    local ARRAY = cell:getRoomList()
    if ARRAY:size() == 0 then return nil end
    local function inner2_function(i, arrayList , size, ret)
        local room = arrayList:get(i)
        return inner_function(room, i, arrayList, size, ret)
    end
    return PZNS_ForEach.arrayList(inner2_function, ARRAY)
end

-- inner_function(building, i, buildings, size, ret)
function PZNS_ForEach.cellBuilding(inner_function, cell) 
    local ARRAY = cell:getBuildingList()
    if ARRAY:size() == 0 then return nil end
    local function inner2_function(i, arrayList , size, ret)
        local building = arrayList:get(i)
        return inner_function(building, i, arrayList, size, ret)
    end
    return PZNS_ForEach.arrayList(inner2_function, ARRAY)
end

--
-- ====================================================================
-- Foreach Room Related

--
-- ====================================================================
-- Foreach Building Related

-- function PZNS_ForEach.buildingRoom(inner_function, building) end
-- function PZNS_ForEach.buildingDoor(inner_function, building) end
-- function PZNS_ForEach.buildingWindow(inner_function, building) end

--
-- ====================================================================
--                            >>> RANDOM <<<

function PZNS_ForEach.rSgn()
    if 1==ZombRand(1,2) then 
        return 1
    else
        return -1
    end
end

-- inner_function(index,value, array_table, ret)
function PZNS_ForEach.arrayTable_random(inner_function, array_table, num_iterations) -- [verified](1)
    if num_iterations == 0 then return nil end
    local len = #array_table
    if len == 0 then return nil end
    local ret = nil
    for i = 1, num_iterations do 
        local index = ZombRand(1,len)
        local value = array_table[index]
        local inner_function_ret = inner_function(index,value, array_table, ret)
        if inner_function_ret == nil then -- continue
        else -- break or break return
            if inner_function_ret == true then -- break 
                break 
            else -- if false the return false, if any other thing then return this thing
                return inner_function_ret
            end
        end
    end
    return ret
end

-- inner_function(index, arrayList , size, ret)
function PZNS_ForEach.arrayList_random(inner_function, arrayList, num_iterations) -- [verified](1)
    if num_iterations == 0 then return nil end
    local size = arrayList:size()
    if size == 0 then return nil end
    local ret = nil
    for i=1, num_iterations do
        local index = ZombRand(0,size-1)
        local inner_function_return = inner_function(index, arrayList , size, ret)
        if inner_function_return == nil then 
            -- nothing : continue the loop
        else
            if inner_function_return == true then
                break
            else
                return inner_function_return
            end
        end
    end
    return ret
end

-- inner_function(object)
function PZNS_ForEach.randomSquareObject(inner_function, square, num_iterations) -- [verified](1)
    local objects = square:getObjects()
    if not objects then return nil end
    if objects:size() == 0 then return nil end
    -- inner_function(index, arrayList , size, ret)
    local function inner2_function(index, arrayList , size, ret)
        local object = arrayList:get(index)
        return inner_function(object)
    end
    return PZNS_ForEach.arrayList_random(inner2_function, objects, num_iterations)
end

-- inner_function(square)
function PZNS_ForEach.randomNearSquare(inner_function, isoplayer, num_iterations, radius) -- [verified](2)
    if num_iterations == 0 then return nil end
    local X = isoplayer:getX()
    local Y = isoplayer:getY()
    local Z = isoplayer:getZ()
    if not X or not Y or not Z then return nil end
    local cell = getCell()
    if not cell then return nil end
    for i=1,num_iterations do 
        local square = cell:getGridSquare(
            X + PZNS_ForEach.rSgn()*ZombRand(0,radius), 
            Y + PZNS_ForEach.rSgn()*ZombRand(0,radius), 
            Z
            )
        --
        local inner_function_ret = inner_function(square)
        if inner_function_ret == nil then -- continue
        else -- break or break return
            if inner_function_ret == true then -- break 
                break 
            else -- if false the return false, if any other thing then return this thing
                return inner_function_ret
            end
        end
    end
end

-- inner_function(square)
function PZNS_ForEach.randomNearSquareFromSquare(inner_function, square, num_iterations, radius) -- [verified](1)
    if num_iterations == 0 then return nil end
    local X = square:getX()
    local Y = square:getY()
    local Z = square:getZ()
    if not X or not Y or not Z then return nil end
    local cell = getCell()
    if not cell then return nil end
    for i=1,num_iterations do 
        local square1 = cell:getGridSquare(
            X + PZNS_ForEach.rSgn()*ZombRand(0,radius), 
            Y + PZNS_ForEach.rSgn()*ZombRand(0,radius), 
            Z
            )
        --
        local inner_function_ret = inner_function(square1)
        if inner_function_ret == nil then -- continue
        else -- break or break return
            if inner_function_ret == true then -- break 
                break 
            else -- if false the return false, if any other thing then return this thing
                return inner_function_ret
            end
        end
    end
end

-- inner_function(square)
function PZNS_ForEach.increasingRadiusRandomNearSquare(inner_function, isoplayer, num_iterations, max_radius, rad_jump) -- [verified](1)
    if rad_jump == nil then rad_jump = 5 end
    if max_radius == nil then max_radius = 20 end
    if num_iterations == 0 then return nil end
    local X = isoplayer:getX()
    local Y = isoplayer:getY()
    local Z = isoplayer:getZ()
    if not X or not Y or not Z then return nil end
    local cell = getCell()
    if not cell then return nil end
    local num_it_per_rad = math.floor( num_iterations/(max_radius/rad_jump) )
    if num_it_per_rad == 0 then return nil end
    
    for i=1,num_it_per_rad do 
        local square = cell:getGridSquare(
            X + PZNS_ForEach.rSgn()*ZombRand(0,1), 
            Y + PZNS_ForEach.rSgn()*ZombRand(0,1), 
            Z
            )
        --
        local inner_function_ret = inner_function(square)
        if inner_function_ret == nil then -- continue
        else -- break or break return
            if inner_function_ret == true then -- break 
                break 
            else -- if false the return false, if any other thing then return this thing
                return inner_function_ret
            end
        end
    end
    
    for radius = rad_jump, max_radius, rad_jump do
        for i=1,num_it_per_rad do 
            local square = cell:getGridSquare(
                X + PZNS_ForEach.rSgn()*ZombRand(0,radius), 
                Y + PZNS_ForEach.rSgn()*ZombRand(0,radius), 
                Z
                )
            --
            local inner_function_ret = inner_function(square)
            if inner_function_ret == nil then -- continue
            else -- break or break return
                if inner_function_ret == true then -- break 
                    break 
                else -- if false the return false, if any other thing then return this thing
                    return inner_function_ret
                end
            end
        end
    end
end

-- PZNS_ForEach.getFirstNearbySquare(returnFirstSquare, npcSurvivor, [ num_iterations, radius ] ) o returnFirstSquare(square)
-- returnFirstSquare is a inner_function which return the desired square or any other object
function PZNS_ForEach.getFirstNearbySquare(returnFirstSquare,npcSurvivor, num_iterations, radius) -- [testing]
    if not num_iterations then num_iterations = 1000 end
    if not radius then radius = 20 end
    local isop = npcSurvivor.npcIsoPlayerObject
    if not isop then return nil end
    return PZNS_ForEach.increasingRadiusRandomNearSquare(returnFirstSquare, isop, num_iterations, radius,3)
end

-- PZNS_ForEach.getFirstWaterSquare(npcSurvivor, [ num_iterations, radius ] )
function PZNS_ForEach.getFirstWaterSquare(npcSurvivor, num_iterations, radius) 
    --> PZNS_ForEach.getFirstWaterSquare := PZNS_ForEach.getFirstNearbySquare o returnFirstWaterSquare
    local function returnFirstWaterSquare(square) 
        if not square then return nil end -- continue
        if square:Is(IsoFlagType.water) then return square end -- break return
        return nil 
    end
    return PZNS_ForEach.getFirstNearbySquare(returnFirstWaterSquare,npcSurvivor, num_iterations, radius)
end

-- PZNS_ForEach.getFirstTreeSquare(npcSurvivor, [ num_iterations, radius ] )
function PZNS_ForEach.getFirstTreeSquare(npcSurvivor, num_iterations, radius) 
    --> PZNS_ForEach.getFirstWaterSquare := PZNS_ForEach.getFirstNearbySquare o findFirstTree
    local function findFirstTree(square)
        local tree = square:getTree()
        if not tree then return nil end -- continue
        return square
    end
    return PZNS_ForEach.getFirstNearbySquare(findFirstTree,npcSurvivor, num_iterations, radius)
end

-- function PZNS_ForEach.getFirstContainerSquare() end

-- could be useful to create builder survivors behaviours
-- function PZNS_ForEach.getItemOrFindOnFloorNearby(item_name, isoplayer) end

--
-- ====================================================================
--                        >>> PZNS Survivors <<<

-- inner_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
function PZNS_ForEach.activeNPC(inner_function)
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    local ret = nil
    for npcSurvivorID, npcSurvivor in pairs(activeNPCs) do
        if npcSurvivor and (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == true) then
            local isNPCSquareLoaded = PZNS_UtilsNPCs.PZNS_GetIsNPCSquareLoaded(npcSurvivor);
            if (isNPCSquareLoaded == true) then
                -- INNER_FUNCTION_COMPONENT
                local inner_function_return = inner_function(npcSurvivor, npcSurvivorID,activeNPCs, ret)
                -- INNER_FUNCTION_COMPONENT || inner_function return properties
                if inner_function_return == nil then 
                    -- nothing : continue the loop
                else
                    if inner_function_return == true then
                        break
                    else
                        return inner_function_return
                    end
                end
            end
        end
    end
    return ret
end

-- inner_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
-- PZNS_ForEach.memberNPC( inner_function, [ player_num ] )
function PZNS_ForEach.memberNPC(inner_function, player_num)
    if not player_num then player_num = 0 end
    local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
    local playerId = "Player" .. tostring(player_num);
    local playerGroupID = playerId .. "Group";
    local groupMembers = PZNS_NPCGroupsManager.getMembers(playerGroupID);
	if #groupMembers == 0 then return nil end
    local ret = nil
    for i = 1, #groupMembers do
        local npcSurvivorID = groupMembers[i]
        local npcSurvivor = activeNPCs[npcSurvivorID]
        if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == true) then
            local isNPCSquareLoaded = PZNS_UtilsNPCs.PZNS_GetIsNPCSquareLoaded(npcSurvivor);
            if (isNPCSquareLoaded == true) then
                -- INNER_FUNCTION_COMPONENT
                local inner_function_return = inner_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
                -- INNER_FUNCTION_COMPONENT || inner_function return properties
                if inner_function_return == nil then 
                    -- nothing : continue the loop
                else
                    if inner_function_return == true then
                        break
                    else
                        return inner_function_return
                    end
                end
            end
        end
    end
    return ret
end

-- inner_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
function PZNS_ForEach.raiderNPC(inner_function)
    -- Logic:
    -- 1. ForEach.raiderNPC o inner_function := ForEach.activeNPC o inner2_function || %* not a raider | inner2_function <- inner_function 
    local function inner2_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
        if not npcSurvivor.isRaider then return nil end -- continue
        return inner_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
    end
    return PZNS_ForEach.activeNPC(inner2_function) 
end

-- Logic:
-- 1. ForEach.companionNPC o inner_function := ForEach.memberNPC o inner2_function || %* not companion | inner2_function <- inner_function

-- inner_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
function PZNS_ForEach.companionNPC(inner_function)
    
    local function inner2_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
        if npcSurvivor.jobName ~= "Companion" then return nil end -- continue
        return inner_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
    end
    return PZNS_ForEach.memberNPC(inner2_function,0) 
end

-- inner_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
function PZNS_ForEach.jobMemberNPC(inner_function, jobName)
    -- Logic:
    -- 1. ForEach.jobMemberNPC o inner_function := ForEach.memberNPC o inner2_function || %* not the job | inner2_function <- inner_function
    local function inner2_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
        if npcSurvivor.jobName ~= jobName then return nil end -- continue
        return inner_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
    end
    return PZNS_ForEach.memberNPC(inner2_function) 
end

-- inner_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
function PZNS_ForEach.wandererMemberNPC(inner_function)
    -- Logic:
    -- 1. ForEach.wandererMemberNPC o inner_function := ForEach.memberNPC o inner2_function || %* not wander job | inner2_function <- inner_function
    local function inner2_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
        if not string.find( npcSurvivor.jobName, "Wander" ) then return nil end -- continue
        return inner_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
    end
    return PZNS_ForEach.memberNPC(inner2_function) 
end

-- inner_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
function PZNS_ForEach.holdPositionMemberNPC(inner_function)
    local function inner2_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
        if npcSurvivor.isHoldingInPlace == false then return nil end -- continue
        return inner_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
    end
    return PZNS_ForEach.memberNPC(inner2_function) 
end

-- inner_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
function PZNS_ForEach.holdPositionCompanionNPC(inner_function)
    local function inner2_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
        if npcSurvivor.isHoldingInPlace == false then return nil end -- continue
        return inner_function(npcSurvivor, npcSurvivorID, activeNPCs, ret)
    end
    return PZNS_ForEach.companionNPC(inner2_function) 
end

-- inner_function(orderKey, orderText, orderCallback)
function PZNS_ForEach.npcOrder(inner_function)
    for orderKey, orderText in pairs(PZNS_NPCOrdersText) do
        local orderCallback = PZNS_NPCOrderActions[orderKey]
        local inner_function_return = inner_function(orderKey, orderText, orderCallback)
        if inner_function_return == nil then 
        else
            if inner_function_return == true then
                break
            else
                return inner_function_return
            end
        end
    end
end

return PZNS_ForEach
