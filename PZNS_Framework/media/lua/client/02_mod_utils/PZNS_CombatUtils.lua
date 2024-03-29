local PZNS_UtilsDataNPCs = require("02_mod_utils/PZNS_UtilsDataNPCs");
local PZNS_UtilsNPCs = require("02_mod_utils/PZNS_UtilsNPCs");
local PZNS_PresetsSpeeches = require("03_mod_core/PZNS_PresetsSpeeches");

local PZNS_CombatUtils = {};

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

--- Cows: Toggle (active) to attack NPCs or (inactive) prevent friendly fire.
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
    -- Cows: Check the the wielder or victim are IsoPlayer. We don't care about zombies in this function.
    if (instanceof(wielder, "IsoPlayer") ~= true or instanceof(victim, "IsoPlayer") ~= true) then
        return;
    end
    -- Cows: Check if the victim is an NPC and calculate how much damage the npc will take from the weapon.
    if (victim:getIsNPC()) then
        if (victim:getModData().survivorID ~= nil) then
            local activeNPCs = PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData();
            local npcSurvivor = activeNPCs[victim:getModData().survivorID];
            local playerGroupID = "Player" .. tostring(0) .. "Group";
            npcSurvivor.attackTicks = 0; -- Cows: Force reset the NPC attack ticks when they're hit, this prevents them from piling on damage.
            -- Cows; Check if the npc struck is in the playerGroup.
            if (npcSurvivor.groupID ~= playerGroupID) then
                -- Cows: After reaching <= 0 affection
                if (npcSurvivor.affection <= 0) then
                    PZNS_UtilsNPCs.PZNS_UseNPCSpeechTable(
                        npcSurvivor, PZNS_PresetsSpeeches.PZNS_HostileHit, "Hostile"
                    );
                else
                    if (wielder == getSpecificPlayer(0)) then
                        npcSurvivor.affection = npcSurvivor.affection - 25; -- Cows: Reduce affection whenever hit.
                    end
                    -- Cows: First time handling <= 0 affection
                    if (npcSurvivor.affection <= 0) then
                        PZNS_UtilsNPCs.PZNS_UseNPCSpeechTable(
                            npcSurvivor, PZNS_PresetsSpeeches.PZNS_NeutralRevenge, "Hostile"
                        );
                    else
                        -- Cows: Else complain about getting hit
                        PZNS_UtilsNPCs.PZNS_UseNPCSpeechTable(
                            npcSurvivor, PZNS_PresetsSpeeches.PZNS_NeutralHit, "Negative"
                        );
                    end
                end
            else
                -- Cows: Check if it is friendly fire handling...
                if (wielder == getSpecificPlayer(0)) then
                    npcSurvivor.affection = npcSurvivor.affection - 10; -- Cows: Reduce affection whenever hit.
                    PZNS_UtilsNPCs.PZNS_UseNPCSpeechTable(
                        npcSurvivor, PZNS_PresetsSpeeches.PZNS_FriendlyFire, "Friendly"
                    );
                end
            end
        end
        --
        if (weapon ~= nil) and (not weapon:isAimedFirearm()) and (weapon:getPushBackMod() > 0.3) then
            victim:StopAllActionQueue();
            victim:faceThisObject(wielder);
        end
        local bonusDamage = 0;
        local bodypartIndex = ZombRand(BodyPartType.Hand_L:index(), BodyPartType.MAX:index());  -- Cows: Original code, every bodypart had an equal chance to be hit...
        local injuredBodyParts = 0;
        local isDefensePenetrated = true;
        local isBluntWeapon = false; -- Cows: Blunt Damage Type
        -- https://projectzomboid.com/modding/zombie/characters/IsoGameCharacter.html#getBodyPartClothingDefense(java.lang.Integer,boolean,boolean)
        local isEdgedWeapon = false; -- Cows: Apparently, bladed weapons were treated as "bites" in SS/SSC...
        local isBullet = false;
        -- Cows: Apply bonus damage based on strength... I haven't figure out how to get the weapon-related skill from the weapon...
        bonusDamage = wielder:getPerkLevel(Perks.FromString("Strength"));
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
        -- Cows: Didn't seem right that blunt weapons would create holes on clothes 100% of the time...
        if (isEdgedWeapon) then
            victim:addHole(BloodBodyPartType.FromIndex(bodypartIndex));
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
                victim:addHole(BloodBodyPartType.FromIndex(bodypartIndex));
            else
                bodypart:setScratched(true, true);
            end
        elseif (isBullet) then
            victim:addHole(BloodBodyPartType.FromIndex(bodypartIndex));
            -- Cows: Update bonus damage to be based on aim level...
            bonusDamage = wielder:getPerkLevel(Perks.FromString("Aiming"));
            bodypart:setHaveBullet(true, 0);
        end
        -- Cows: Add bonusDamage to weapon damage...
        local bodypartDamage = weapon:getMaxDamage() + bonusDamage;
        -- Cows: Head and neck takes 4x damage
        if (bodypartIndex == BodyPartType.Head:index()
                or bodypartIndex == BodyPartType.Neck:index()
            )
        then
            bodypartDamage = bodypartDamage * 4.0;
        end
        -- Cows: Groin takes 3x damage
        if (bodypartIndex == BodyPartType.Groin:index()) then
            bodypartDamage = bodypartDamage * 3.0;
        end
        -- Cows: Torso and upper leg takes 2x damage
        if (bodypartIndex == BodyPartType.Torso_Upper:index()
                or bodypartIndex == BodyPartType.UpperLeg_L:index()
                or bodypartIndex == BodyPartType.UpperLeg_R:index()
            )
        then
            bodypartDamage = bodypartDamage * 2.0;
        end
        --
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
