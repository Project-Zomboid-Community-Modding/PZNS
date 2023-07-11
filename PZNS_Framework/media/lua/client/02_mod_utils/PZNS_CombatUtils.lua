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

---comment
function PZNS_CombatUtils.PZNS_TogglePvP()

end

---comment
function PZNS_CombatUtils.PZNS_CalculatePlayerDamage()

end

return PZNS_CombatUtils;
