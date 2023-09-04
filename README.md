# __**PZNS - Project Zomboid NPC Spawning Framework**__  
A new Lua based framework for managing, spawning, and directing NPCs in Project Zomboid  
  
This is an effort to standardize NPC management and spawning while offering the flexibility to all modders the ability to create and modify NPCs to their content without worry about all the complicated issues such as AI behaviors, data management, and decompiling PZ source code.  

All functions in PZNS will have working examples for modders to follow so that they create and spawn their own npc creations in-game.  

## __**HELP WANTED AND NEEDED**__  
- UI Window for inspecting NPCs.
- UI Window for group management (currently it is all done via context menu).
- Main Menu Options or Sandbox Options (Debug Mode Toggle and key bindings).
- More NPC Actions
- More NPC Orders
- More NPC Jobs
- UI Window for inventory transfers (Mostly done, needs more polish and testing).
- Preset Speech texts for NPCs *(Low priority)*
- Resolving more issues as they become known... (too much unknown at this point).

## __**HOW IS THIS DIFFERENT FROM SS AND OTHER NPC MODS?**__  
- **Rewrote the entire data management process; the overall performance improved in the current state (as of July 4th, 2023) is about 10x-30x better than SS.**  
   - This is a rough estimate, simply because SS had too much shi* going on in the background that so NPCs attack at every 2-3 ticks feels "normal".  
   - If the same attack action is called in PZNS, the attack action will be queued about 10-25 times (Yeah, I got shot about 20 times during testing).  
- **There will be NO loose files in the mod folder; all NPC data are saved in the ``Saves/Sandbox`` folder or saved as ``ModData``**  
  - Also the debug context menu has a WIPE ALL DATA command, meaning all loose files and data will be cleared from the save... which *should* mean the mod will be safe to deactivate and/or remove afterward.  
- There won't be a massive project full of broken things that are tightly coupled and can't be untangled.  
- Subsequent NPC mods can simply reference the framework as a requirement and load after it without needing to write data management code.  
   - NPC Group Example - PZNS Rosewood Police 
     - https://github.com/shadowhunter100/PZNS_RosewoodPolice
   - Standalone NPC Example - Agent Wong
     - https://github.com/shadowhunter100/PZNS_AgentWong

## __**ALL WORK WILL BE CREDITED ACCORDING TO THE PULL REQUESTS ON GITHUB.**__  
- I have zero intention of taking credit for work that is not mine.  
    - The PR process also creates a track record of who has done what. 
- After working on SSC, I have no intention of working alone on something of this scale.  
- If you want something done, do it yourself; the PR reviews are to ensure the code is at least readable and *under the assumption it is tested to some extent*.  
- *Squashed Commits on the main branch will no longer be permitted once the repo goes public*  

# Credits:  
This Project was created using Project Zomboid Studio by Konjima (Discord: Konijima#9279)  
- https://github.com/Konijima/project-zomboid-studio

Candle by Jab (jabdoesthings)  
- https://github.com/asledgehammer/Candle

Umbrella by Jab (jabdoesthings)  
- https://github.com/asledgehammer/Umbrella

The NPC outfits featured in the screenshots and videos are all outfits made by Satispie
- Chris - https://steamcommunity.com/sharedfiles/filedetails/?id=2903317798
- Jill - https://steamcommunity.com/sharedfiles/filedetails/?id=2903870282

Other NPC Mods - Aiteron NPC and SS/SSC GitHub
- https://github.com/shadowhunter100/SuperbSurvivorsSteam20230425
- https://github.com/shadowhunter100/SuperbSurvivorsContinued
- Aiteron NPC - https://github.com/aiteron/NPC

# Special Thanks - Consultations (Discord)
- Aiteron (aiteron)  
- Chuck (chuck)  
- Jab (jabdoesthings)  
- Notloc (notloc) - For a workaround on getting NPCs to run with B41 API.
- Poltergeist (poltergeist_ix)

# Support me on ko-fi!
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/U7U0O1ZTH)
