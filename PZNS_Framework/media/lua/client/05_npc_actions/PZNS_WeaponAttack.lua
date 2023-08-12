local PZNS_CombatUtils = require("02_mod_utils/PZNS_CombatUtils");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");

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
    -- Cows: If the victim not an NPC, activate PVP.
    if (victim:getIsNPC() == false) then
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
            calculateNPCDamage(npcIsoPlayer, targetObject);
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
            calculateNPCDamage(npcIsoPlayer, targetObject);
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
        npcIsoPlayer:NPCSetMelee(true);
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
