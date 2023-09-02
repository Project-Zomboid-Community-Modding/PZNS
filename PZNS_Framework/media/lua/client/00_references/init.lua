PZNS = PZNS or {}
PZNS.Core = PZNS.Core or {}
PZNS.Context = PZNS.Context or {}
PZNS.Context.Debug = PZNS.Context.Debug or {}
PZNS.UI = PZNS.UI or {}

PZNS.Core.NPC = {}
PZNS.Core.Group = {}
PZNS.Core.Faction = {}
PZNS.Core.Zone = {}

---@type table<survivorID, NPC>
PZNS.Core.NPC.registry = {}
---@type table<groupID, Group>
PZNS.Core.Group.registry = {}
---@type table<factionID, NPCFaction>
PZNS.Core.Faction.registry = {}
---@type table<zoneID, Zone>
PZNS.Core.Zone.registry = {}


---@alias survivorID string Unique identifier for survivor
---@alias groupID string Unique identifier for group
---@alias factionID string Unique identifier for faction
---@alias zoneID string Unique identifier for zone


--NOTE: NPCs share "sitting" state of the player, need to check
