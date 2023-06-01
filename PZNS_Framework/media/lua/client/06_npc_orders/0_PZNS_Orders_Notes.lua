--[[
    Cows: Upon further review, I don't think its a good idea to have the APIs called in the orders.
    The orders will set the NPC flags, and the actions will be carried out according to the set flags in the orders.
    API calls in IsoPlayer as will be made in the actions.
    Examples - these APIs will not be called in an Order, but can be called in an Action.
    IsoPlayer:NPCSetAiming()
    IsoPlayer:NPCSetAttack()

    An Order will instead set the flags in npcSurvivor and possibly call npc action(s) which will then call the API.
    npcSurvivor.AimTarget = <object>
    npcSurvivor.canAttack = true/false.
--]]
