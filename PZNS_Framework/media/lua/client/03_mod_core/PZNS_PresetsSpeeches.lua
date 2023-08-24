-- Cows: Upon further considerations, I think preset speeches should be limited to order and job acknowledgements... for now.
local PZNS_PresetsSpeeches = {};

PZNS_PresetsSpeeches.PZNS_OrderConfirmed = {
    getText("IGUI_PZNS_Speech_Preset_Confirm_01"),
    getText("IGUI_PZNS_Speech_Preset_Confirm_02"),
    getText("IGUI_PZNS_Speech_Preset_Confirm_03"),
};

PZNS_PresetsSpeeches.PZNS_OrderSpeechHoldPosition = {
    getText("IGUI_PZNS_Speech_Preset_HoldPosition_01"),
    getText("IGUI_PZNS_Speech_Preset_HoldPosition_02"),
    getText("IGUI_PZNS_Speech_Preset_HoldPosition_03"),
};

PZNS_PresetsSpeeches.PZNS_OrderSpeechFollow = {
    getText("IGUI_PZNS_Speech_Preset_Follow_01"),
    getText("IGUI_PZNS_Speech_Preset_Follow_02"),
    getText("IGUI_PZNS_Speech_Preset_Follow_03"),
};

PZNS_PresetsSpeeches.PZNS_JobSpeechRemoveFromGroup = {
    getText("IGUI_PZNS_Speech_Preset_RemoveFromGroup_01"),
    getText("IGUI_PZNS_Speech_Preset_RemoveFromGroup_02"),
    getText("IGUI_PZNS_Speech_Preset_RemoveFromGroup_03"),
};

PZNS_PresetsSpeeches.PZNS_JobSpeechIdle = {
    getText("IGUI_PZNS_Speech_Preset_JobSpeechIdle_01"),
    getText("IGUI_PZNS_Speech_Preset_JobSpeechIdle_02"),
    getText("IGUI_PZNS_Speech_Preset_JobSpeechIdle_03"),
};

PZNS_PresetsSpeeches.PZNS_FriendlyFire = {
    getText("IGUI_PZNS_Speech_Preset_FriendlyFire_01"),
    getText("IGUI_PZNS_Speech_Preset_FriendlyFire_02"),
};

PZNS_PresetsSpeeches.PZNS_NeutralHit = {
    getText("IGUI_PZNS_Speech_Preset_NeutralHit_01"),
    getText("IGUI_PZNS_Speech_Preset_NeutralHit_02"),
};

PZNS_PresetsSpeeches.PZNS_NeutralRevenge = {
    getText("IGUI_PZNS_Speech_Preset_NeutralRevenge_01"),
};

PZNS_PresetsSpeeches.PZNS_HostileHit = {
    getText("IGUI_PZNS_Speech_Preset_HostileHit_01"),
    getText("IGUI_PZNS_Speech_Preset_HostileHit_02"),
    getText("IGUI_PZNS_Speech_Preset_HostileHit_03"),
};

return PZNS_PresetsSpeeches;
