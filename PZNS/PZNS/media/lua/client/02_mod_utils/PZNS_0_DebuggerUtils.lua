ModId = "ProjectZomboidNPCSpawner-PZNS";

-- Cows: Use this function to write a line to a text file, this is useful to identify when and how many times a function is called.
---@param fileName any
---@param isEnabled any
---@param newLine any
function CreateLogLine(fileName, isEnabled, newLine)
    if (isEnabled) then
        local timestamp = os.time();
        local formattedTimeDay = os.date("%Y-%m-%d", timestamp);
        local formattedTime = os.date("%Y-%m-%d %H:%M:%S", timestamp);
        local file = getFileWriter(
            ModId .. "/logs/" .. formattedTimeDay .. "_" .. ModId .. "_" .. fileName .. "_Logs.txt", true, true);
        local content = formattedTime .. " : " .. "CreateLogLine called";

        if newLine then
            content = formattedTime .. " : " .. newLine;
        end

        file:write(content .. "\r\n");
        file:close();
    end
end

-- Cows: Use this function to write a line to a text file, this is useful to identify when and how many times a function is called.
---@param fileName any
---@param isEnabled any
---@param table any
function LogTableKVPairs(fileName, isEnabled, table)
    if (isEnabled) then
        for key, value in pairs(table) do
            CreateLogLine(fileName, isEnabled, "key:" .. tostring(key) .. " | value: " .. tostring(value));
        end
    end
end

-- Example usage:
-- CreateLogLine("PZNS_0_DebuggerUtils", true, "Start...");