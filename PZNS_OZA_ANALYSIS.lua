
-- oZumbiAnalitico: 
-- 1. ytb channel ; https://www.youtube.com/@oZumbiAnalitico
-- 2. workshop ; https://steamcommunity.com/id/ozumbianalitico/myworkshopfiles/
-- 3. email ; ericyuta@gmail.com

-- This file is for documenting, designing and solving issues analytically.
-- Analytical Approach X Experimental Approach:
-- 1. Empirical: based on, concerned with, or verified by observation or experience.
-- 2. Analytical: based on analysis or logic.
-- Empirical Approach are slower but more reliable, in contrast Analytical Approach is "cheaper" but require more attention.

-- ====================================================================
--[[                  >>> THEORY : Logic Notation <<<

-- Definition [ Path-Logic Notation ] : In this context, a "logic" is a list of linear statements "logical-paths", each statement represent an execution path restricted to an condition. Path-Logic notation is a comment notation to represent a program, a mod, a class, or any program component in logical-paths.
-- --------------------------------------------------------------------
-- 1. The path-logic notation could be used for formal demonstration, but the primary purpose is to document, so there is no "hard" syntax rules, means to be flexible and express the idea of the component.

-- Lua Example:
-- "for i in iterator() do if condition() then function_call() end end" in path-logic notation will be:
-- & i in iterator() || % condition() || function_call()
-- --------------------------------------------------------------------
-- The symbol & means a loop, the symbol % means a conditional structure. 

-- 1. A || B means that B is inside A, or A calls B, B is inside A structure. Example is a function A() calling a subfunction B()
-- 2. A | B means that B is executed after A, but in same context level of A. Example let C be a function that calls A() and in the next line calls B()
-- --------------------------------------------------------------------
-- The symbol | means that the sequence is in the same abstraction level, or same context. The symbol || means a change in the abstraction level, or a context change.

-- 3. & is a loop structure
-- 4. $ is a variable or object construction

-- 5. % is a conditional control structure
-- 6. *% is a conditional checkpoint, often in beginning of function
-- 7. %% is a long if else if else conditional structure, or a "case" structure.
-- 8. % A, B represent "if A else if B"
-- --------------------------------------------------------------------
-- The conditional checkpoint is useful to indicate a premature loop break, or a premature function return.
-- The "% condition | % else" could be used to represent the "if else" structure.

-- 9. ? A, B, C means a random choice between A, B, C, ...
-- 10. { A, B, C } in the end of statements means that the end part of statement use A, B, C functions or operations in a way decided when implemented.
-- 11. { A, B, C } in beginning of statements means that the statement follows when conditions A, B, C are met. 
-- 12. Aditionally, one can add a context, so the Q::{A,B,C} means that A,B,C belongs to a Q library.

-- 13. _function() is not a reference to a real function, is a reference to a concept that could be used in an actual function. That name becomes a suffix to an implemented function.
-- 14. <- is a binary operator that encapsulate the return of a function. A <- B means that A will return the return of B. A <- B || C means is the way to continue the path to B context, C is called in B definition.
-- 15. <custom_operator> is the notation for an binary operator, for example, function_1 <definition> function_2 could mean that function_1 defines function_2, function_1 <callback> function_2 could mean that function_1 register function_2 as a callback for some event. A <operator> B || C is some how equivalent to 1. A(B, ...) 2. B || C

-- Path-Logic Notation for ForEach functions:
-- 1. calling "ForEach(inner_function)" will be conceptually the same as "& variables in container defined in ForEach function || inner_function(variables)"
-- 2. ForEach o inner_function := & variables in container defined in ForEach function || inner_function()
-- 3. ForEach o inner_function || another_function() will be the same as ... 
-- ... & "ForEach" || inner_function() || another_function() ... so the another_function is called inside inner_function definition
-- 4.  A o B is the binary operator foreach. To be similar to function composition.

-- Definition [ Working Set ] : Is a set of functions to be used with {A,B,C} notation. The purpose is to create functions that can use this set.

-- Definition [ Concept ] : Is a informal set of properties for a program or mod followed by the event logic.

-- [ Same Context Commutation ]
-- 1. If A don't changes any variables which B uses then A | B ==_{B} B | A
-- 2. If A changes variables which B uses then A | B ~=_{B} B | A

-- [ Independent Blocks ]
-- 1. A and B are independent if A don't change variables used in B and B don't change variables used in A.
-- 2. A | B ==_{A,B} B | A

-- [ Dependent Block ] A depends on B if B changes variables used in A.

-- [ Insertion ] If C are independent of A,B then A | B ==_{A,B} A | C | B

--]]

-- ====================================================================
--[[                  >>> PZNS EVENT ANALYSIS <<<

-- Logic [ Events ]
--> Events.OnInitGlobalModData.Add o PZNS_GetSandboxOptions
--> Events.OnGameStart.Add o PZNS_CreateNPCPanelInfo
--> Events.OnGameStart.Add o PZNS_UtilsDataGroups.PZNS_GetCreateActiveGroupsModData
--> Events.OnGameStart.Add o PZNS_CreatePVPButton
--> Events.OnGameStart.Add o PZNS_UtilsDataZones.PZNS_GetCreateActiveZonesModData
--> Events.OnGameStart.Add o PZNS_ResetJillTesterSpeechTable
--> Events.OnGameStart.Add o PZNS_LocalPlayerGroupCreation
--> Events.OnGameStart.Add o PZNS_Events
--> Events.OnGameStart.Add o PZNS_UpdateISWorldMapRender
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--> Events.OnGameStart.Add o PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData
--> Events.OnGameStart.Add o PZNS_UtilsDataNPCs.PZNS_InitLoadNPCsData
--> Events.OnSave.Add o PZNS_UtilsDataNPCs.PZNS_SaveAllNPCData
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--> Events.OnPlayerMove.Add o PZNS_CheckDistToNPCInventory 
--> Events.OnWeaponHitCharacter.Add o PZNS_CombatUtils.PZNS_CalculatePlayerDamage
--> Events.OnWeaponSwing.Add o PZNS_WeaponSwing
--> Events.OnMouseUp.Add o stopRenderMouseSquare
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--> Events.OnRenderTick.Add o selectZoneSquares
--> Events.OnRenderTick.Add o renderDropSquare
--> Events.OnRenderTick.Add o renderZoneSquare
--> Events.OnRenderTick.Add o PZNS_RenderNPCsText
--> Events.OnRenderTick.Add o renderMouseSquare
--> Events.OnRenderTick.Add o renderGrabSquare
--> Events.OnRenderTick.Add o PZNS_UpdateAllJobsRoutines
--> Events.EveryOneMinute.Add o PZNS_WorldUtils.PZNS_SpawnNPCIfSquareIsLoaded
--> Events.EveryHours.Add o PZNS_UtilsNPCs.PZNS_ClearAllNPCsAllNeedsLevel
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--> Events.OnFillInventoryObjectContextMenu.Add o PZNS_NPCInventoryContext
--> Events.OnFillWorldObjectContextMenu.Add o PZNS_ContextMenu.PZNS_OnFillWorldObjectContextMenu
--> Events.OnRefreshInventoryWindowContainers.Add o PZNS_AddNPCInv

--
-- ====================================================================
--

-- Logic [ Save and Load ]
-- 1. Events.OnGameStart.Add o PZNS_UtilsDataNPCs.PZNS_GetCreateActiveNPCsModData || $ PZNS_ActiveNPCs || ModData.getOrCreate()
-- 2. Events.OnGameStart.Add o PZNS_UtilsDataNPCs.PZNS_InitLoadNPCsData || % PZNS_ActiveNPCs || & || % fileExists() || % || PZNS_UtilsDataNPCs.PZNS_SpawnNPCFromModData() || %* | % is npc alive || PZNS_UtilsDataNPCs::{ PZNS_CreateNPCSurvivorDescObject, PZNS_GetGameSaveDir,  } IsoPlayer::{ new, load, setNPC, setSceneCulled } TextDrawObject::{ new, setAllowAnyImage, setDefaultFont, setDefaultColors, ReadString }
-- 3. Events.OnSave.Add o PZNS_UtilsDataNPCs.PZNS_SaveAllNPCData || & || % || PZNS_UtilsDataNPCs.PZNS_SaveNPCData() || PZNS_UtilsDataNPCs.PZNS_SaveNPCData() || { PZNS_UtilsDataNPCs.PZNS_GetGameSaveDir, ISOPLAYER:save }

--
-- ====================================================================
--

-- Problematic Performance Events:
-- 1. Events.OnPlayerMove.Add
-- 2. Events.OnRenderTick.Add
-- 3. Events.OnMouseUp.Add
-- 3. Events.OnWeaponHitCharacter.Add
-- 4. Events.EveryOneMinute.Add
-- 5. Events.OnWeaponSwing.Add
-- 6. Events.OnRefreshInventoryWindowContainers.Add
-- 7. Events.OnKeyPressed.Add

-- Logic [ OnRenderTick ]
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 1. Events.OnRenderTick.Add o PZNS_UpdateAllJobsRoutines || & activeNPCs || PZNS_UpdateNPCJobRoutine() || *% | % job is "Remove" or "Remove From Group" | % job is nil | % can job map || % "Companion" | % else || { PZNS_Jobs }
-- 2. Events.OnRenderTick.Add o PZNS_UpdateAllJobsRoutines || & activeNPCs || PZNS_UpdateNPCJobRoutine() || *% | % job is "Remove" or "Remove From Group" | % job is nil | % can job map | % cannot job map || % is "Wander In Building" || PZNS_JobWanderInBuilding()
-- 3. Events.OnRenderTick.Add o PZNS_UpdateAllJobsRoutines || & activeNPCs || PZNS_UpdateNPCJobRoutine() || *% | % job is "Remove" or "Remove From Group" | % job is nil | % can job map | % cannot job map || % is "Wander In Building" | % is "Wander In Cell" || PZNS_JobWanderInCell()
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 4. Events.OnRenderTick.Add o PZNS_RenderNPCsText || & activeNPCs || % is valid || % npcSurvivor.textObject || % reset speech ticks | update ticks | drawSpeechText() || { IsoUtils, IsoCamera, CORE:getZoom, npcSurvivor.textObject:AddBatchedDraw }
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 5. Events.OnRenderTick.Add o renderMouseSquare() || { ... }

-- Logic [ PZNS_GeneralAI.PZNS_IsNPCBusyCombat ]
-- 1. C := PZNS_GeneralAI.PZNS_IsNPCBusyCombat
-- 2. F := PZNS_GeneralAI.PZNS_NPCFoundThreat
-- 3. A := PZNS_GeneralAI.PZNS_NPCAimAttack
-- --------------------------------------------------------------------
--> _combat_handler() || % C() || <- *
--> C() || *% | _reset_action_tick_count() | _reload_handler() || _check_tick() || PZNS_WeaponReload() | _set_action_tick_to_zero()
--> C() || *% | _reset_action_tick_count() | _reload_handler() || _check_tick() | _set_idle_tick_to_zero() | C <- true
--> C() || *% | _reset_action_tick_count() | _reload_handler() | % F() || A() | _reset_idle_tick() | C <- true
--> C() || *% | _reset_action_tick_count() | _reload_handler() | % F() | _no_threat_reset() || { NPCSetAttack, NPCGetAiming, NPCSetAiming }
--> C() || *% | _reset_action_tick_count() | _reload_handler() | % F() | _no_threat_reset() | C <- false

-- Logic [ PZNS_GeneralAI.PZNS_NPCFoundThreat ]
-- 1. F := PZNS_GeneralAI.PZNS_NPCFoundThreat
-- 2. S := PZNS_GeneralAI.PZNS_CanSeeAimTarget(npcSurvivor)
-- 3. C := PZNS_GeneralAI.PZNS_CheckForThreats(npcSurvivor)
-- ----------------------------------------------
--> F() || *% | % S() || F <- true
--> F() || *% | % S() | % C() || F <- true
--> F() || *% | % S() | % C() | F <- false

--
-- ====================================================================
--

-- Logic [ PZNS_ClearAllNPCsAllNeedsLevel ]
--> PZNS_Events() || ... | % IsNPCsNeedsActive ~= true || Events.EveryHours.Add o PZNS_UtilsNPCs.PZNS_ClearAllNPCsAllNeedsLevel || & activeNPCs || % alive || PZNS_UtilsNPCs.PZNS_ClearNPCAllNeedsLevel()

-- Proposition : IsoPlayer object without npcSurvivor reference will die eventually for npc needs ?
-- ... to address the dying npc
-- --------------------------------------------------------------------
-- 1. Without PZNS_ClearNPCAllNeedsLevel the IsoPlayer object will die for needs.
-- 2. PZNS_UtilsNPCs.PZNS_ClearNPCAllNeedsLevel uses npcSurvivor.
-- --------------------------------------------------------------------
-- As the IsoPlayer without npcSurvivor can't be accessed by PZNS_UtilsNPCs.PZNS_ClearNPCAllNeedsLevel the needs will not be updated, so eventually the IsoPlayer object will die for starvation or any other need.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 1. Events.OnPlayerUpdate.Add o "ClearNPCAllNeedsLevel" || % check time || % check is npc || % IsNPCsNeedsActive ~= true || "Clear the needs"
-- 2. OnPlayerUpdate could be resource intensive.

--]]

-- ====================================================================
--[[                  >>> PZNS ISSUES ANALYSIS <<<

-- Issue [ Ghost NPC Logic ]
-- 1. The NPC is invisible, can do things, but don't have collison.
-- 2. The Name is Displayed, yet the object seems to be absent or invisible.
-- 3. The NPC don't move.
-- 4. The NPC can do damage.
-- -------------------------------------------------------------------
-- Proposition : When the NPC is invisible you can get the IsoPlayer position.
-- Proposition : The PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid return true when the NPC is invisible.
-- Question : How to check if the NPC is invisible ?

-- return ((self.char:getCurrentSquare() and self.char:isExistInTheWorld()) or not self.char:getCurrentSquare()) and ( (self.admin:getAccessLevel() == "Admin") or (self.admin:getAccessLevel() == "Moderator" and (self.char:getAccessLevel() == "None" or self.char:getAccessLevel() == "GM" or self.char:getAccessLevel() == "Overseer" or self.char:getAccessLevel() == "Observer")) )

-- Proposition : When the NPC is invisible you can get the IsoPlayer position. ?
-- 1. The drawSpeechText display speak messages when the NPC is invisible
-- 2. drawSpeechText get the position of IsoPlayer object.
-- --------------------------------------------------------------------
-- If you can't get the position of IsoPlayer, then the drawSpeechText should raise exception. So you should get the IsoPlayer position.

-- Proposition : The PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid return true when the NPC is invisible. ?
-- 1. If the IsoPlayer exists and isAlive then PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid
-- --------------------------------------------------------------------
-- As when the NPC is invisible the other conditions checked by PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid is skipped then the IsoPlayer will return true, as the IsoPlayer object exists and is alive.


-- Logic [ PZNS_RenderNPCsText ]
-- 1. R := PZNS_RenderNPCsText
-- 2. NPCs := activeNPCs
-- 3. N := npcSurvivor
-- 4. V := PZNS_UtilsNPCs.IsNPCSurvivorIsoPlayerValid
-- -------------------------------
-- R() || ... | & NPCs || ... | % || % | ... | drawSpeechText(N)
-- R() || $ NPCs | *% | & NPCs || $ N | % V(N) || % has textObject | % check speech ticks | _update_ticks() | drawSpeechText(N) || ISOPLAYER::{getX, getY, getZ, getOffsetX } TEXTOBJECT::{ getHeight, AddBatchedDraw } IsoCamera::{ getOffX, getOffY } IsoUtils::{ XToScreen, YToScreen } CORE::{ getZoom }

--[[
function PZNS_UtilsDataNPCs.PZNS_SpawnNPCFromModData(npcSurvivor)
    if (npcSurvivor == nil) then
        return;
    end

    if (npcSurvivor.isAlive == true) then
        local npcSurvivorDesc = PZNS_UtilsDataNPCs.PZNS_CreateNPCSurvivorDescObject(
            npcSurvivor.isFemale,
            npcSurvivor.surname,
            npcSurvivor.forename
        );
        local npcSurvivorID = npcSurvivor.survivorID;
        local npcFileName = PZNS_UtilsDataNPCs.PZNS_GetGameSaveDir() .. tostring(npcSurvivorID);
        local npcIsoPlayerObject = IsoPlayer.new(
            getWorld():getCell(),
            npcSurvivorDesc,
            npcSurvivor.squareX, npcSurvivor.squareY, npcSurvivor.squareZ
        );
        -- Cows: Reset the ticks counter.
        npcSurvivor.actionTicks = 0;
        npcSurvivor.idleTicks = 0;
        npcSurvivor.isStuckTicks = 0;
        npcSurvivor.jobTicks = 0;
        npcSurvivor.npcIsoPlayerObject = npcIsoPlayerObject;
        npcSurvivor.npcIsoPlayerObject:load(npcFileName);
        npcSurvivor.npcIsoPlayerObject:setNPC(true);
        npcSurvivor.npcIsoPlayerObject:setSceneCulled(false);
        npcSurvivor.textObject = TextDrawObject.new();
        npcSurvivor.textObject:setAllowAnyImage(true);
        npcSurvivor.textObject:setDefaultFont(UIFont.Small);
        npcSurvivor.textObject:setDefaultColors(255, 255, 255);
        npcSurvivor.textObject:ReadString(npcSurvivor.survivorName);
        npcSurvivor.isSavedInWorld = false;
        npcSurvivor.isSpawned = true;
    end
    return npcSurvivor;
end
--]]

-- Logic [ PZNS_UtilsDataNPCs.PZNS_SpawnNPCFromModData ]

--]]

-- ====================================================================
---[[                  >>> PZNS JOBS ANALYSIS <<<

-- [ Job ] : Is the main function for AI processing.

-- [ Job State ] : 
-- 1. States are independent from each other.
-- 1. A State is a commited path of the Job. 
-- 2. A State must be preserved for sometime, an state must have some stability.
-- 3. A State can be decomposed in substates.
-- --------------------------------------------------------------------
-- 1. Events can trigger state changes.
-- 2. The State Logic can be implemented using npcSurvivor.currentAction as a string storing the information of the current state and conditional control structures.
-- 3. The State Processing must end in a timed action with a tick period control to prevent repeating the action order.

-- Types of State Changes:
-- ------------------------
-- 1. Event Based Changes
-- 2. Timed - Random Changes ~ Using tick function and the control if 1 == ZombRand(1,ticks) then ... end
-- 3. Timed - Periodic Changes ~ Using tick variables if _tick_counter % _ticks == 0 then ... end

-- Logic [ State Change x Processing ]
-- 1. _event_change are forced changes based on special priority circunstances. For example, an attack threat, close zombie, health need.
-- 2. one should take care putting loops on _event_change, Job Function is called OnRenderTick.
-- 3. N := npcSurvivor
-- 4. NPCS := Active NPCs
-- 5. Job State Processing could be used in different Job Functions.
-- -------------------------------------------------------------------
--> Events.OnRenderTick.Add o _AllJobs || & N in NPCS || _JobSelect(N) || %% || _Job(N)
--> _Job() || _state_change() | _state_processing() || %% "state" || { ... }
--> _Job() || _state_change() || % _event_change() || { ... }
--> _Job() || _state_change() || % _event_change(), _timed_change() || _stay(), _change() || { ... }

-- Possible Common Events:
-- 1. Threat 5 Squares Close ; T5SC
-- 2. Threat 2 Squares Close ; T2SC
-- 3. Threat 10 Squares Distant ; T10SD
-- 4. Health Below 10 ; HB10
-- 5. Health Below 50 ; HB50
-- 6. Can Attack Target ; CAT
-- 7. Being Targeted By NPC ; BTN
-- 8. Zombie Bite ; ZB
-- ----------------------------------------
-- ZB > HB10 > T2SC > T5SC > CAT > BTN

-- ...

-- Logic [ Loot Filler ]
-- 1. Using a Backpack the NPC will fill that Backpack with items.
-- 2. J := Job_LootFiller
-- 3. I := ForEachR.increasingRadiusRandomNearSquare
-- 4. _Tick := Check Ticks Before Follow a Path, Random Function
-- -------------------------------------------------------------------
--> J() || _setAction() || %% _setActionFirstItem(), _setActionEndLooting(), _setActionLooting() || { _Tick }
--> J() || _setAction() | %% _isActionFirstItem(), _isActionEndLooting(), _isActionLooting()

-- Logic [ PZNS_JobCompanion ]
-- --------------------------------------------------------------------
-- 1. J := PZNS_JobCompanion
-- 2. N := npcIsoPlayer
-- 3. T := targetIsoPlayer
-- 4. C := PZNS_UtilsNPCs.PZNS_ClearQueuedNPCActions
-- --------------------------------------------------------------------
-- [ Movement ] Follow Behavior based on distance of the target
-- --------------------------------------------------------------------
-- 1. J() || %* | $ N, T | _update_tick_count() | _sneak_handler() | % not _isHoldingInPlace(N) || _vehicle_handler() | % both on foot || % "force moving or not in follow range" || _movement_handler() || % _check_tick() || C() | jobCompanion_Movement()
-- 2. J() || %* | $ N, T | _update_tick_count() | _sneak_handler() | % not _isHoldingInPlace(N) || _vehicle_handler() | % both on foot || % "force moving or not in follow range" || _movement_handler() || % _check_tick() | J <- *
-- --------------------------------------------------------------------
-- [ Combat ] Follow Movement is priority over Combat
-- --------------------------------------------------------------------
-- 3. J() || %* | $ N, T | _update_tick_count() | _sneak_handler() | % not _isHoldingInPlace(N) || _vehicle_handler() | % both on foot || % "force moving or not in follow range", else || _combat_handler() || % PZNS_GeneralAI.PZNS_IsNPCBusyCombat() || J <- *
-- 4. J() || %* | $ N, T | _update_tick_count() | _sneak_handler() | % not _isHoldingInPlace(N) | _isHoldingInPlace(N) || _combat_handler()
-- --------------------------------------------------------------------
-- [ Sneak ] Refinement
-- --------------------------------------------------------------------
-- 5. J() || %* | $ N, T | _update_tick_count() | _sneak_handler() || % _isSneaking(T), not _isSneaking(T) || { :setSneaking(true) }
-- --------------------------------------------------------------------
-- [ Vehicle ] Refinement
-- --------------------------------------------------------------------
-- 6. J() || %* | $ N, T | _update_tick_count() | _sneak_handler() | % not _isHoldingInPlace(N) || _vehicle_handler() || $ isTargetInCar, isSelfInCar | % only T in the car, both in the car, only N in the car || { jobCompanion_EnterCar, PZNS_ExitVehicle, C }
-- --------------------------------------------------------------------
-- [ Jobsquare ] Holding in Place Movement
-- --------------------------------------------------------------------
-- 7. J() || %* | $ N, T | _update_tick_count() | _sneak_handler() | % not _isHoldingInPlace(N) | _isHoldingInPlace(N) || _combat_handler() | _jobsquare_handler() || % jobsquare nil || J <- *
-- 8. J() || %* | $ N, T | _update_tick_count() | _sneak_handler() | % not _isHoldingInPlace(N) | _isHoldingInPlace(N) || _combat_handler() | _jobsquare_handler() || % jobsquare nil | % _check_tick() || { C, PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects, PZNS_RunToSquareXYZ, PZNS_WalkToSquareXYZ }
-- --------------------------------------------------------------------
-- [ Tick Update ] 
-- --------------------------------------------------------------------
-- 9. J() || %* | $ N, T | _update_tick_count() | _sneak_handler() | % not _isHoldingInPlace(N) || _vehicle_handler() | % both on foot || % "force moving or not in follow range", else | _canSeeTarget() | _update_idle_ticks()
-- 10. J() || %* | $ N, T | _update_tick_count() | _sneak_handler() | % not _isHoldingInPlace(N), _isHoldingInPlace(N) | _reset_tick_count()

-- Logic [ PZNS_GeneralAI.PZNS_IsNPCBusyCombat ]
-- 1. C := PZNS_GeneralAI.PZNS_IsNPCBusyCombat
-- 2. F := PZNS_GeneralAI.PZNS_NPCFoundThreat --> Has Zombie List Loop and NPC Loop, so affect performance !!!
-- 3. A := PZNS_GeneralAI.PZNS_NPCAimAttack
-- --------------------------------------------------------------------
--> _combat_handler() || % C() || <- *
--> C() || *% | _reset_action_tick_count() | _reload_handler() || _check_tick() || PZNS_WeaponReload() | _set_action_tick_to_zero()
--> C() || *% | _reset_action_tick_count() | _reload_handler() || _check_tick() | _set_idle_tick_to_zero() | C <- true
--> C() || *% | _reset_action_tick_count() | _reload_handler() | % F() || A() | _reset_idle_tick() | C <- true
--> C() || *% | _reset_action_tick_count() | _reload_handler() | % F() | _no_threat_reset() || { NPCSetAttack, NPCGetAiming, NPCSetAiming }
--> C() || *% | _reset_action_tick_count() | _reload_handler() | % F() | _no_threat_reset() | C <- false

-- Logic [ PZNS_GeneralAI.PZNS_NPCFoundThreat ]
-- 1. F := PZNS_GeneralAI.PZNS_NPCFoundThreat
-- 2. S := PZNS_GeneralAI.PZNS_CanSeeAimTarget(npcSurvivor)
-- 3. C := PZNS_GeneralAI.PZNS_CheckForThreats(npcSurvivor) --> Has Zombie List Loop and NPC Loop, so affect performance !!!
-- ----------------------------------------------
--> F() || *% | % S() || F <- true
--> F() || *% | % S() | % C() || F <- true
--> F() || *% | % S() | % C() | F <- false

-- Logic [ PZNS_GeneralAI.PZNS_CheckForThreats ] --> Has Zombie List Loop and NPC Loop, so affect performance !!!
-- 1. G := PZNS_GeneralAI.PZNS_CheckForThreats
-- ------------------------------------------------
--> G() || *% | $ isNPCHostileToPlayer | $ priorityThreatObject | % priorityThreatObject || % ... || G <- true
--> G() || *% | $ isNPCHostileToPlayer | $ priorityThreatObject | % priorityThreatObject | $ npcWeapon, aimRange | % "attack player" | % "zombie list" || & PZNS_CellZombiesList || % PZNS_WorldUtils.PZNS_IsObjectZombieActive() || { PZNS_WorldUtils.PZNS_GetDistanceBetweenTwoObjects, PZNS_AimAtTarget }
--> G() || *% | $ isNPCHostileToPlayer | $ priorityThreatObject | % priorityThreatObject | $ npcWeapon, aimRange | % "attack player" | % "zombie list" | % "npc list" || & PZNS_CellNPCsList || { ... }


--]]

-- ====================================================================
--





