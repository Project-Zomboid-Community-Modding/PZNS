local PZNS_WorldUtils = require("02_mod_utils/PZNS_WorldUtils");
--[[
    WIP - Cows: Should add a check for ranged weaponry and if ammo is loaded the gun...
    Currently as-is, damage is done without ammo consideration
--]]
local meleeTicks = 40;  -- Cows: As ticks are inconsistent between machines... this should be an option user can set for comfort.
local rangedTicks = 60; -- Cows: As ticks are inconsistent between machines... this should be an option user can set for comfort.

--- Cows: Currently, a damage calculation is needed for NPCs... otherwise NPCs do 0 damage to zombies.
---@param npcIsoPlayer any
---@param victim any
local function calculateNPCDamage(npcIsoPlayer, victim)
    if (PZNS_WorldUtils.PZNS_IsTargetInvalidForDamage(victim) == true) then
        return;
    end
    --
    local aimingLevel = npcIsoPlayer:getPerkLevel(Perks.FromString("Aiming"));
    local npcWeapon = npcIsoPlayer:getPrimaryHandItem();
    local weaponAimingModifier = npcWeapon:getAimingPerkHitChanceModifier();
    local weaponDamage = npcWeapon:getMaxDamage(); -- Cows: Need to look at redoing weapon damage... otherwise NPC melee weapons will destroy everything.
    local weaponHitChance = npcWeapon:getHitChance();
    local skillHitChance = weaponAimingModifier * aimingLevel;
    local actualHitChance = weaponHitChance + skillHitChance;
    --
    if (npcWeapon:isRanged()) then
        if (actualHitChance > ZombRand(100)) then
            victim:Hit(npcWeapon, npcIsoPlayer, weaponDamage, false, 1.0);
        end
    else
        victim:Hit(npcWeapon, npcIsoPlayer, weaponDamage, false, 1.0);
    end
end

local function meleeAttack(npcSurvivor, npcIsoPlayer, targetObject)
    if (npcSurvivor.attackTicks >= meleeTicks) then
        local isTargetAlive = targetObject:isAlive();
        --
        if (isTargetAlive == true) then
            -- PZNS_NPCSpeak(npcSurvivor, "Attacking target");
            npcIsoPlayer:NPCSetAttack(true);
            calculateNPCDamage(npcIsoPlayer, targetObject);
        else
            -- PZNS_NPCSpeak(npcSurvivor, "Target is dead");
            npcIsoPlayer:NPCSetAttack(false);
        end
        npcSurvivor.attackTicks = 0;
    end
end

local function rangedAttack(npcSurvivor, npcIsoPlayer, targetObject)
    if (npcSurvivor.attackTicks >= rangedTicks) then
        local isTargetAlive = targetObject:isAlive();
        --
        if (isTargetAlive == true) then
            -- PZNS_NPCSpeak(npcSurvivor, "Attacking target");
            npcIsoPlayer:NPCSetAttack(true);
            calculateNPCDamage(npcIsoPlayer, targetObject);
        else
            -- PZNS_NPCSpeak(npcSurvivor, "Target is dead");
            npcIsoPlayer:NPCSetAttack(false);
        end
        npcSurvivor.attackTicks = 0;
    end
end

---comment
---@param npcSurvivor any
function PZNS_WeaponAttack(npcSurvivor)
    --
    if (npcSurvivor == nil) then
        return;
    end
    --
    local targetObject = npcSurvivor.aimTarget;
    local npcCanAttack = npcSurvivor.canAttack;
    local npcIsoPlayer = npcSurvivor.npcIsoPlayerObject;
    local npcHandItem = npcIsoPlayer:getPrimaryHandItem();
    local isNPCHandItemWeapon = npcHandItem:IsWeapon();
    --
    if (targetObject ~= nil) then
        -- Cows: Check if the entity the NPC is aiming at is valid
        if (PZNS_WorldUtils.PZNS_IsTargetInvalidForDamage(targetObject) == true) then
            npcIsoPlayer:NPCSetAttack(false);
            -- PZNS_NPCSpeak(npcSurvivor, "No target to attack");
        else
            -- Cows: Else check if NPC can attack
            if (npcCanAttack) then
                if (isNPCHandItemWeapon == true) then
                    -- Cows: Melee and Ranged weapons are handled separately...
                    if (npcHandItem:isRanged() == true) then
                        rangedAttack(npcSurvivor, npcIsoPlayer, targetObject);
                    else
                        npcIsoPlayer:NPCSetMelee(true);
                        meleeAttack(npcSurvivor, npcIsoPlayer, targetObject);
                    end
                    --
                    npcSurvivor.attackTicks = npcSurvivor.attackTicks + 1;
                else
                    PZNS_NPCSpeak(npcSurvivor, "I don't have a weapon!", "Negative");
                    npcIsoPlayer:NPCSetAttack(false);
                end
            else
                PZNS_NPCSpeak(npcSurvivor, "No Permission to attack", "InfoOnly");
                npcIsoPlayer:NPCSetAttack(false);
            end
        end
    else
        -- PZNS_NPCSpeak(npcSurvivor, "No target to attack");
        npcIsoPlayer:NPCSetAttack(false);
        npcSurvivor.attackTicks = 0;
    end
    --
end

--- Cows: Based on "SuperSurvivorsOnSwing()"
---@param isoPlayer any
---@param playerWeapon any
local function rangeWeaponHandler(isoPlayer, playerWeapon)
    -- Cows: START DEBUG ONLY
    if (playerWeapon:getCurrentAmmoCount() == 0) then
        playerWeapon:setCurrentAmmoCount(5);
    end
    -- Cows: END DEBUG ONLY
    --
    if playerWeapon:haveChamber() then
        playerWeapon:setRoundChambered(false);
    end
    -- remove ammo, add one to chamber if we still have some
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

---comment
---@param isoPlayer any
---@param playerWeapon any
function PZNS_WeaponSwing(isoPlayer, playerWeapon)
    local npcSurvivorID = isoPlayer:getModData().survivorID;
    -- Cows: Only NPCs should have isoPlayer moddata.
    if (npcSurvivorID ~= nil) then
        -- Cows: Ranged Weapon Handler
        if playerWeapon:isRanged() then
            rangeWeaponHandler(isoPlayer, playerWeapon);
        end
        -- Cows: Play the weapon sound if a round is chambered.
        if (playerWeapon:isRoundChambered()) then
            local range = playerWeapon:getSoundRadius();
            local volume = playerWeapon:getSoundVolume();
            addSound(isoPlayer, isoPlayer:getX(), isoPlayer:getY(), isoPlayer:getZ(), range, volume);
            getSoundManager():PlayWorldSound(
                playerWeapon:getSwingSound(), isoPlayer:getCurrentSquare(), 0.5, range, 1.0, false
            );
        end

        isoPlayer:NPCSetAttack(false);
        isoPlayer:NPCSetMelee(false);
    end
end
