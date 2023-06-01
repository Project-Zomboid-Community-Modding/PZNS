--[[
    Cows: Note, this is a quick start reference collection for working with the vanilla base game.
    Please check the wiki site or visit the Mod_Development channel in the Official TIS Discord for more help.
    
    https://projectzomboid.com/modding/zombie/characters/IsoGameCharacter.CharacterTraits.html
    https://projectzomboid.com/modding/zombie/characters/skills/PerkFactory.Perks.html 

    https://pzwiki.net/
    https://pzwiki.net/wiki/Clothing
    https://pzwiki.net/wiki/Weapon 
--]]

--[[
    Regarding AI, Actions, and Jobs
    Cows: In my current observations, all player actions in PZ are managed through lua.
    In steam, all the lua code can be found in the game install folder "media\lua\client"
        C:\Program Files (x86)\Steam\steamapps\common\ProjectZomboid\media\lua\client\TimedActions

    There are no clear documentations, so experiement and find out what can and can't be done with the base game code.

    Cows: I have observed that all NPCs IsoPlayer character actions are scheduled in "ISTimedActionQueue.queues".
--]]