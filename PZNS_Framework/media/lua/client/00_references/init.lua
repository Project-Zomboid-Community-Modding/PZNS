PZNS = PZNS or {}
PZNS.Core = PZNS.Core or {}
PZNS.Context = PZNS.Context or {}
PZNS.Context.Debug = PZNS.Context.Debug or {}
PZNS.UI = PZNS.UI or {}

PZNS.Core.NPC = {}
PZNS.Core.Group = {}
PZNS.Core.Faction = {}
PZNS.Core.Zone = {}

---@type table<survivorID, PZNS_NPCSurvivor>
PZNS.Core.NPC.registry = {}
---@type table<groupID, PZNS_NPCGroup>
PZNS.Core.Group.registry = {}
---@type table<factionID, PZNS_NPCFaction>
PZNS.Core.Faction.registry = {}
---@type table<zoneID, PZNS_NPCZone>
PZNS.Core.Zone.registry = {}


---@alias survivorID string Unique identifier for survivor
---@alias groupID string Unique identifier for group
---@alias factionID string Unique identifier for faction
---@alias zoneID string Unique identifier for zone
