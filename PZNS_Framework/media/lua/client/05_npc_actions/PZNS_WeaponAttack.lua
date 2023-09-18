-- oZumbiAnalitico 16092023: In my attempt to understand the AI thing and create hostile npc's for my mod I noticed that:
-- 1. The damage happens before the swing animation and sound.
-- 2. Often there is more damage hits than animation and sound. 
-- 3. Sometimes there is damage and no Animation and no Sound.
-- 4. That problem happens in both melee and ranged weapons.
-- ... First I thought that this problem was caused by the OnRenderTick being too fast, so as I still don't know how to use ticks variables I first tried to use a 1 == ZombRand(1,tick) to emulate a tick period and slow down the frequency of calls. But now I believe that the damage 'calculateNPCDamage' should be called on swing time 'PZNS_WeaponSwing', after the sound trigger, instead of being called right after 'npcIsoPlayer:NPCSetAttack(true)'.
-- The call should be something like this: 
-- ... npcIsoPlayer:NPCSetAttack(true) --> ... --> Trigger OnWeaponSwing Event --> calls PZNS_WeaponSwing() --> Play Sound --> calls calculateNPCDamage()
-- Instead of the original: 
-- ... npcIsoPlayer:NPCSetAttack(true) --> calculateNPCDamage()

local PZNS_CombatUtils = require("02_mod_utils/PZNS_CombatUtils");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_NPCsManager = require("04_data_management/PZNS_NPCsManager");

local meleeTicks = 40;  -- Cows: As ticks are inconsistent between machines... this should be an option user can set for comfort.
local rangedTicks = 60; -- Cows: As ticks are inconsistent between machines... this should be an option user can set for comfort.

--- Cows: Currently, a damage calculation is needed for NPCs... otherwise NPCs do 0 damage to zombies.
---@param npcIsoPlayer any
---@param victim any
local function calculateNPCDamage(npcIsoPlayer, victim)
    if (PZNS_CombatUtils.PZNS_IsTargetInvalidForDamage(victim) == true) then
        return;
    end
    --
    local aimingLevel = npcIsoPlayer:getPerkLevel(Perks.FromString("Aiming"));
    local npcWeapon = npcIsoPlayer:getPrimaryHandItem();
    local actualHitChance = PZNS_CombatUtils.PZNS_CalculateHitChance(npcWeapon, aimingLevel, 0);
    local weaponDamage = npcWeapon:getMaxDamage(); -- Cows: Need to look at redoing weapon damage... otherwise NPC melee weapons will destroy everything at max damage.
    -- Cows: Check if the victim is an IsoPlayer and not an NPC
    if (instanceof(victim, "IsoPlayer") == true and victim:getIsNPC() == false) then
        if (IsPVPActive == false) then
            PZNS_CombatUtils.PZNS_TogglePvP();
        end
    end
    if (npcWeapon:isRanged()) then
        if (actualHitChance > ZombRand(100)) then
            victim:Hit(npcWeapon, npcIsoPlayer, weaponDamage, false, 1.0);
        end
    else
        victim:Hit(npcWeapon, npcIsoPlayer, weaponDamage, false, 1.0);
    end
end

--- Cows: Helper function for NPCs doing melee attack
---@param npcSurvivor any
---@param npcIsoPlayer IsoPlayer
---@param targetObject IsoPlayer | IsoZombie
local function meleeAttack(npcSurvivor, npcIsoPlayer, targetObject) 
    if (npcSurvivor.attackTicks >= meleeTicks) then
        local isTargetAlive = targetObject:isAlive();
        --
        if (isTargetAlive == true) then
            -- PZNS_NPCSpeak(npcSurvivor, "Attacking target");
            npcIsoPlayer:NPCSetAttack(true);
            -- oZumbiAnalitico -- calculateNPCDamage(npcIsoPlayer, targetObject); 
        end
        npcSurvivor.attackTicks = 0;
    end
end

--- Cows: Helper function for NPCs doing ranged attack
---@param npcSurvivor any
---@param npcIsoPlayer IsoPlayer
---@param targetObject IsoPlayer | IsoZombie
local function rangedAttack(npcSurvivor, npcIsoPlayer, targetObject)
    if (npcSurvivor.attackTicks >= rangedTicks) then
        local isTargetAlive = targetObject:isAlive();
        --
        if (isTargetAlive == true) then
            -- PZNS_NPCSpeak(npcSurvivor, "Attacking target");
            npcIsoPlayer:NPCSetAttack(true);
            -- oZumbiAnalitico -- calculateNPCDamage(npcIsoPlayer, targetObject);
        end
        npcSurvivor.attackTicks = 0;
    end
end

--- Cows: Main function for NPCs attacking
---@param npcSurvivor any
function PZNS_WeaponAttack(npcSurvivor)
    if (PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid(npcSurvivor) == false) then
        return;
    end
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    --
    local npcHandItem = npcIsoPlayer:getPrimaryHandItem();
    if (npcHandItem == nil) then
        return;
    end
    local isNPCHandItemWeapon = npcHandItem:IsWeapon();
    if (isNPCHandItemWeapon == false) then
        PZNS_NPCSpeak(npcSurvivor, getText("IGUI_PZNS_Speech_Preset_NeedWeapon_01"), "Negative");
        npcIsoPlayer:NPCSetAttack(false);
        if (npcIsoPlayer:NPCGetAiming() == true) then
            npcIsoPlayer:NPCSetAiming(false);
        end
    end
    -- Cows: Check if the entity the NPC is aiming at exists
    local targetObject = npcSurvivor.aimTarget;
    if (targetObject == nil) then
        npcIsoPlayer:NPCSetAttack(false);
        npcIsoPlayer:NPCSetAiming(false);
        npcSurvivor.attackTicks = 0;
        return;
    end
    -- Cows: Check if the entity the NPC is aiming at is valid
    if (PZNS_CombatUtils.PZNS_IsTargetInvalidForDamage(targetObject) == true) then
        npcIsoPlayer:NPCSetAttack(false);
        if (npcIsoPlayer:NPCGetAiming() == true) then
            npcIsoPlayer:NPCSetAiming(false);
        end
        return;
    end
    -- Cows: Check if NPC can attack
    local npcCanAttack = npcSurvivor.canAttack;
    if (npcCanAttack ~= true) then
        PZNS_NPCSpeak(npcSurvivor, getText("IGUI_PZNS_Speech_Preset_CannotAttack_01"), "InfoOnly");
        npcIsoPlayer:NPCSetAttack(false);
        if (npcIsoPlayer:NPCGetAiming() == true) then
            npcIsoPlayer:NPCSetAiming(false);
        end
        return;
    end
    -- Cows: Melee and Ranged weapons are handled separately...
    if (npcHandItem:isRanged() == true) then
        rangedAttack(npcSurvivor, npcIsoPlayer, targetObject);
    else
        -- oZumbiAnalitico -- npcIsoPlayer:NPCSetMelee(true); -- I believe this is related to shove thing
        meleeAttack(npcSurvivor, npcIsoPlayer, targetObject);
    end
    --
    npcSurvivor.attackTicks = npcSurvivor.attackTicks + 1;
end

--- Cows: Based on "SuperSurvivorsOnSwing()"
---@param isoPlayer any
---@param playerWeapon  HandWeapon
local function rangeWeaponHandler(isoPlayer, playerWeapon)
    -- Cows: Infinite Ammo check
    if (IsInfiniteAmmoActive == true and playerWeapon:getCurrentAmmoCount() == 0) then
        playerWeapon:setCurrentAmmoCount(playerWeapon:getMaxAmmo());
    end
    --
    if playerWeapon:haveChamber() then
        playerWeapon:setRoundChambered(false);
    end
    -- remove ammo, add one to chamber if we still have ammo after shooting
    if playerWeapon:getCurrentAmmoCount() >= playerWeapon:getAmmoPerShoot() then
        if playerWeapon:haveChamber() then
            playerWeapon:setRoundChambered(true);
        end
        playerWeapon:setCurrentAmmoCount(playerWeapon:getCurrentAmmoCount() - playerWeapon:getAmmoPerShoot());
    end

    if playerWeapon:isRackAfterShoot() then -- shotguns need to be racked after each shot to rechamber round
        isoPlayer:setVariable("RackWeapon", playerWeapon:getWeaponReloadType());
    end
end

--- Cows: The NPC plays the animation/action of attacking with weapon swing, which triggers the event "OnWeaponSwing".
---@param isoPlayer IsoPlayer
---@param playerWeapon any
function PZNS_WeaponSwing(isoPlayer, playerWeapon)
    -- These weapon swing rules only applies to NPCs.
    if (isoPlayer:getIsNPC() ~= true) then
        return;
    end
    local npcSurvivorID = isoPlayer:getModData().survivorID;
    -- Cows: Only NPCs should have isoPlayer moddata.
    if (npcSurvivorID ~= nil) then
        -- Cows: Ranged Weapon Handler
        if playerWeapon:isRanged() then
            rangeWeaponHandler(isoPlayer, playerWeapon);
        end
        -- Cows: Play the weapon sound if a round is chambered.
		-- oZumbiAnalitico: Here I added "or not playerWeapon:haveChamber()" to play sound for melee weapon
		-- oZumbiAnalitico: Seems that some firearms don't trigger sound effect, like doublebarrel shotgun, must be because some weapons don't have "chamber thing action", like revolvers or the double barrels. Not fixed yet ... 
        if playerWeapon:isRoundChambered() or (not playerWeapon:haveChamber()) or (not playerWeapon:isRanged()) then
            local range = playerWeapon:getSoundRadius();
            local volume = playerWeapon:getSoundVolume();
            addSound(isoPlayer, isoPlayer:getX(), isoPlayer:getY(), isoPlayer:getZ(), range, volume);
            getSoundManager():PlayWorldSound(
                playerWeapon:getSwingSound(), isoPlayer:getCurrentSquare(), 0.5, range, 1.0, false
            );
        end
		-- oZumbiAnalitico: idk if the PlayWorldSound is concurrent, but i believe the damage needs to be after the sound to prevent multiple damages with no animation and sound. 
		-- oZumbiAnalitico: There is another problem, that "multiple-attacks before animation and sound" happens with ranged weapons too, could be an improvement to put the damage here on weapon swing for both.
		
        -- oZumbiAnalitico: Still seems that there is a double call to swing the weapon. The NPC always seems to double-tab. The ZombRand thing is a workaround ...
        local npcSurvivor = PZNS_NPCsManager.getActiveNPCBySurvivorID(npcSurvivorID)
        if npcSurvivor and 1 == ZombRand(1,2) then calculateNPCDamage(isoPlayer, npcSurvivor.aimTarget) end
		
        isoPlayer:NPCSetAttack(false);
        isoPlayer:NPCSetMelee(false);
    end
end

-- Notation:
-- 1. A || B means that B is inside A, or A calls B, B is inside A structure. Example is a function A() calling a subfunction B()
-- 2. A | B means that B is executed after A, but in same context level of A. Example let C be a function that calls A() and in the next line calls B()
-- 3. % is a conditional control structure
-- 4. & is a loop structure
-- 5. $ is a variable or object construction
-- 6. *% is a conditional checkpoint, often in beginning of function
-- 7. ? A, B, C means a random choice between A, B, C, ...
-- 8. { A, B, C } in the end of statements means that the end part of statement use A, B, C functions or operations in a way decided when implemented. Is an abstraction that means "A,B,C will be used in some way".
-- 9. { A, B, C } in beginning of statements means that the statement follows when conditions A, B, C are met. 
-- 10. _function() is not a reference to a real function, is a reference to a concept that could be used in an actual function. That name becomes a suffix to an implemented function.

-- Logic 16092023: PZNS_WeaponAttack() || PZNS_WeaponSwing()

-- Logic [ PZNS_WeaponAttack ] 16092023
-- 1. PZNS_WeaponAttack() || *% | $ npcHandItem | ... | *% | % npcHandItem:isRanged() | % not npcHandItem:isRanged() || meleeAttack()
-- 2. PZNS_WeaponAttack() || *% | $ npcHandItem | ... | *% | % npcHandItem:isRanged() || rangedAttack()
-- 3. meleeAttack() || { npcIsoPlayer:NPCSetAttack(true) }
-- 4. rangedAttack() || { npcIsoPlayer:NPCSetAttack(true) }
-- 5. npcIsoPlayer:NPCSetAttack(true) || Event OnWeapon Swing || PZNS_WeaponSwing()

-- oZumbiAnalitico: I'm assuming NPCSetAttack triggers the weapon swing animation that triggers the event.

-- Logic [ PZNS_WeaponSwing ] 16092023
-- 1. PZNS_WeaponSwing() || *% | % npcSurvivorID || "Ranged Weapon Handler" | "weapon sound" | "Weapon do Damage" || % chance || calculateNPCDamage()
-- 2. PZNS_WeaponSwing() || *% | % npcSurvivorID || "Ranged Weapon Handler" | "weapon sound" || { addSound, PlayWorldSound }
-- 3. PZNS_WeaponSwing() || *% | % npcSurvivorID || "Ranged Weapon Handler" || % || rangeWeaponHandler()




