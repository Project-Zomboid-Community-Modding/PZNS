local PZNS_CombatUtils = {};

--- Cows: Toggle (active) to attack NPCs or (inactive) prevent friendly fire.

---comment
---@param targetObject any
---@return boolean
function PZNS_CombatUtils.PZNS_IsTargetInvalidForDamage(targetObject)
    -- Cows: If targetObject is not an IsoPlayer or IsoZombie, it is invalid for damage.
    if not (instanceof(targetObject, "IsoPlayer") == true or instanceof(targetObject, "IsoZombie") == true) then
        return true;
    end

    return false;
end

--- Cows: Call the IsoPlayerCoopPVP API to toggle local isoplayer pvp targeting.
function PZNS_CombatUtils.PZNS_TogglePvP()
    if (IsPVPActive == true) then
        IsPVPActive = false;
        PVPButton:setImage(PVPTextureOff)
    else
        IsPVPActive = true;
        PVPButton:setImage(PVPTextureOn)
    end
    IsoPlayer.setCoopPVP(IsPVPActive);
end

--- Cows: Added this function for calculating hit chance with range weapons
---@param selectedWeapon HandWeapon
---@param aimingLevel number
---@param missModifier number
function PZNS_CombatUtils.PZNS_CalculateHitChance(selectedWeapon, aimingLevel, missModifier)
    local weaponAimingModifier = selectedWeapon:getAimingPerkHitChanceModifier();
    local weaponHitChance = selectedWeapon:getHitChance();
    local skillHitChance = weaponAimingModifier * aimingLevel;
    local actualHitChance = weaponHitChance + skillHitChance - missModifier;

    return actualHitChance;
end

--- Cows: Function is based on "SuperSurvivorPVPHandle()" in "SuperSurvivorUpdate.lua"
---@param wielder IsoPlayer
---@param victim IsoPlayer
---@param weapon HandWeapon
function PZNS_CombatUtils.PZNS_CalculatePlayerDamage(wielder, victim, weapon)
    -- Cows: Check and make sure both the wielder and victim are IsoPlayer, we don't care about zombies in this function.
    if (instanceof(wielder, "IsoPlayer") ~= true or instanceof(victim, "IsoPlayer") ~= true) then
        return;
    end

    -- Cows: Check if the victim is not a local player and calculate how much damage the npc will take from the weapon.
    if not (victim:isLocalPlayer()) then
        --
        if (weapon ~= nil) and (not weapon:isAimedFirearm()) and (weapon:getPushBackMod() > 0.3) then
            victim:StopAllActionQueue();
            victim:faceThisObject(wielder);
        end
        -- 
        if weapon:getType() == "BareHands" then
            return;
        end

        local bodypartIndex = ZombRand(BodyPartType.Hand_L:index(), BodyPartType.MAX:index());
        local injuredBodyParts = 0;
        local isDefensePenetrated = true;
        local isBluntWeapon = false; -- Cows: Blunt Damage Type
        local isEdgedWeapon = false;
        local isBullet = false;
        --
        if (weapon:getCategories():contains("Blunt") or weapon:getCategories():contains("SmallBlunt")) then
            isBluntWeapon = true;
        elseif not (weapon:isAimedFirearm()) then
            injuredBodyParts = 1;
            isEdgedWeapon = true;
        else
            isBullet = true;
            injuredBodyParts = 2;
        end
        --
        local bodydamage = victim:getBodyDamage()
        local bodypart = bodydamage:getBodyPart(BodyPartType.FromIndex(bodypartIndex));
        -- WIP - Cows: So This is why some NPCS can't be killed in SuperbSurvivors... defense penetration is between 0 and 100 vs. whatever defense
        if (ZombRand(0, 100) < victim:getBodyPartClothingDefense(bodypartIndex, isEdgedWeapon, isBullet)) then
            isDefensePenetrated = false;
        end
        --
        if isDefensePenetrated == false then
            return;
        end
        victim:addHole(BloodBodyPartType.FromIndex(bodypartIndex));
        --
        if (isEdgedWeapon) then
            if (ZombRand(0, 6) == 6) then
                bodypart:generateDeepWound();
            elseif (ZombRand(0, 3) == 3) then
                bodypart:setCut(true);
            else
                bodypart:setScratched(true, true);
            end
        elseif (isBluntWeapon) then
            if (ZombRand(0, 4) == 4) then
                bodypart:setCut(true);
            else
                bodypart:setScratched(true, true);
            end
        elseif (isBullet) then
            bodypart:setHaveBullet(true, 0);
        end
        --
        local bodypartDamage = weapon:getMaxDamage();
        --
        if (bodypartIndex == BodyPartType.Head:index()) then
            bodypartDamage = bodypartDamage * 4.0;
        end
        --
        if (bodypartIndex == BodyPartType.Neck:index()) then
            bodypartDamage = bodypartDamage * 4.0;
        end
        --
        if (bodypartIndex == BodyPartType.Torso_Upper:index()) then
            bodypartDamage = bodypartDamage * 2.0;
        end
        bodydamage:AddDamage(bodypartIndex, bodypartDamage);
        local stats = victim:getStats();
        --
        if injuredBodyParts == 0 then
            stats:setPain(stats:getPain() +
                bodydamage:getInitialThumpPain() * BodyPartType.getPainModifyer(bodypartIndex));
        elseif injuredBodyParts == 1 then
            stats:setPain(stats:getPain() +
                bodydamage:getInitialScratchPain() * BodyPartType.getPainModifyer(bodypartIndex));
        elseif injuredBodyParts == 2 then
            stats:setPain(stats:getPain() + bodydamage:getInitialBitePain() * BodyPartType.getPainModifyer(bodypartIndex));
        end
        --
        if stats:getPain() > 100 then
            stats:setPain(100)
        end
    end
end

return PZNS_CombatUtils;
