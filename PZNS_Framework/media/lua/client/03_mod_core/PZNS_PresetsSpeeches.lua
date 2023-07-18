-- Cows: Upon further considerations, I think preset speeches should be limited to order and job acknowledgements... for now.
-- WIP - Cows: So the question is, how can a "personality" be written and added with the current framework?
local PZNS_PresetsSpeeches = {};

PZNS_PresetsSpeeches.PZNS_OrderConfirmed = {
    "Whatever you say.",
    "I'm on it",
    "Alright"
};

PZNS_PresetsSpeeches.PZNS_OrderSpeechHoldPosition = {
    "Understood, I will hold this place.",
    "I am now holding this location...",
    "Guard duty huh..."
};

PZNS_PresetsSpeeches.PZNS_OrderSpeechFollow = {
    "Understood, Following",
    "I got your back",
    "Alright, lead the way."
};

PZNS_PresetsSpeeches.PZNS_JobSpeechRemoveFromGroup = {
    "Why me?",
    "Fine, I'm leaving then",
    "You'll regret this decision!"
};

PZNS_PresetsSpeeches.PZNS_JobSpeechIdle = {
    "I need something to do here...",
    "What is my next task?",
    "It's a slow day at work..."
};

--- Cows: In case a table is used instead of a list. Keep in mind this can be a slow process because it has to count each k-v entry in the table.
---@param table any
---@return number
function PZNS_PresetsSpeeches.PZNS_GetSpeechTableSize(table)
    local size = 0;

    if (table == nil) then
        return 0;
    end

    for _ in pairs(table) do
        size = size + 1;
    end
    return size;
end

return PZNS_PresetsSpeeches;
