--- Cows: The code here is mostly based on "SuperSurvivorPVPButton.lua"

require "ISUI/ISLayoutManager";
local ThePVPButton = ISButton:derive("ThePVPButton");
local PZNS_CombatUtils = require("02_mod_utils/PZNS_CombatUtils");

--- Cows: Creates the Toggle button to enable local/client-only players pvp.
function PZNS_CreatePVPButton()
    PVPTextureOn = getTexture("media/textures/PVPOn.png");
    PVPTextureOff = getTexture("media/textures/PVPOff.png");

    PVPButton = ThePVPButton:new(
        getCore():getScreenWidth() - 100, getCore():getScreenHeight() - 50, 25, 25, "", nil,
        PZNS_CombatUtils.PZNS_TogglePvP
    );
    PVPButton:setImage(PVPTextureOff);
    PVPButton:setVisible(true);
    PVPButton:setEnable(true);
    PVPButton:addToUIManager();
end
