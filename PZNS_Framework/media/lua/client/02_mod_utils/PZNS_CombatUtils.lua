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

--- WIP - Cows: Function is based on "SuperSurvivorPVPHandle()" in "SuperSurvivorUpdate.lua"
---@param wielder IsoPlayer
---@param victim IsoPlayer
---@param weapon HandWeapon
function PZNS_CombatUtils.PZNS_CalculatePlayerDamage(wielder, victim, weapon)
    -- Cows: Check and make sure both the wielder and victim are IsoPlayer, we don't care about zombies in this function.
    if (instanceof(wielder, "IsoPlayer") ~= true or instanceof(victim, "IsoPlayer") ~= true) then
        return;
    end
    -- Cows: Check if the wielder/attacker is the local player character.
    local isWielderPlayerSurvivor = false;
    if (wielder:isLocalPlayer()) then
        isWielderPlayerSurvivor = true;
    end
    -- Cows: Check if the victim is not a local player and calculate how much damage the npc will take from the weapon.
    if not (victim:isLocalPlayer()) then
        --
        if (weapon ~= nil) and (not weapon:isAimedFirearm()) and (weapon:getPushBackMod() > 0.3) then
            victim:StopAllActionQueue();
            victim:faceThisObject(wielder);
        end
        local bonusDamage = 0;
        local bodypartIndex = ZombRand(BodyPartType.Hand_L:index(), BodyPartType.MAX:index());
        local injuredBodyParts = 0;
        local isDefensePenetrated = true;
        local isBluntWeapon = false; -- Cows: Blunt Damage Type
        -- https://projectzomboid.com/modding/zombie/characters/IsoGameCharacter.html#getBodyPartClothingDefense(java.lang.Integer,boolean,boolean)
        local isEdgedWeapon = false; -- Cows: Apparently, bladed weapons were treated as "bites" in SS/SSC...
        local isBullet = false;
        -- Cows: Players will get bonus damage based on strength... I haven't figure out how to get the weapon-related skill from the weapon...
        if (isWielderPlayerSurvivor == true) then
            bonusDamage = wielder:getPerkLevel(Perks.FromString("Strength"));
        end
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
        local bodydamage = victim:getBodyDamage();
        local bodypart = bodydamage:getBodyPart(BodyPartType.FromIndex(bodypartIndex));
        -- Cows: Perhaps we need to account for "martial artists" and stomping attacks ...
        if weapon:getType() == "BareHands" then
            return;
        end
        -- Cows: Updated "bite" check to false.
        if (ZombRand(0, 100) < victim:getBodyPartClothingDefense(bodypartIndex, false, isBullet)) then
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
            -- Cows: Update bonus damage to be based on aim level...
            bonusDamage = wielder:getPerkLevel(Perks.FromString("Aiming"));
            bodypart:setHaveBullet(true, 0);
        end
        -- Cows: Add bonusDamage to weapon damage...
        local bodypartDamage = weapon:getMaxDamage() + bonusDamage;
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
        getSpecificPlayer(0):Say(
            "InjuredParts: " .. tostring(injuredBodyParts) ..
            "Damaged bodyPartIndex: " .. tostring(bodypartIndex) ..
            " bodyDamage: " .. tostring(bodypartDamage)
        );
        bodydamage:AddDamage(bodypartIndex, bodypartDamage);
        local stats = victim:getStats();
        --
        if injuredBodyParts == 0 then
            stats:setPain(
                stats:getPain() +
                bodydamage:getInitialThumpPain() * BodyPartType.getPainModifyer(bodypartIndex)
            );
        elseif injuredBodyParts == 1 then
            stats:setPain(
                stats:getPain() +
                bodydamage:getInitialScratchPain() * BodyPartType.getPainModifyer(bodypartIndex)
            );
        elseif injuredBodyParts == 2 then
            stats:setPain(
                stats:getPain() +
                bodydamage:getInitialBitePain() * BodyPartType.getPainModifyer(bodypartIndex)
            );
        end
        --
        if stats:getPain() > 100 then
            stats:setPain(100)
        end
    end
end

return PZNS_CombatUtils;
