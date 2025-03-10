-- Core/Logger.lua: Enhanced logging system
local Logger = {}
Logger.__index = Logger

local LOG_LEVELS = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    CRITICAL = 5
}

local LOG_COLORS = {
    DEBUG = Color3.fromRGB(150, 150, 150),
    INFO = Color3.fromRGB(100, 200, 255),
    WARN = Color3.fromRGB(255, 200, 0),
    ERROR = Color3.fromRGB(255, 100, 100),
    CRITICAL = Color3.fromRGB(255, 0, 0)
}

function Logger.new(options)
    options = options or {}
    
    local self = setmetatable({
        moduleName = options.moduleName or "Logger",
        minLevel = LOG_LEVELS[options.minLevel or "INFO"],
        history = {},
        maxHistory = options.maxHistory or 1000,
        outputEnabled = options.outputEnabled ~= false,
        fileLogging = options.fileLogging or false,
        logFile = options.logFile
    }, Logger)
    
    return self
end

function Logger:log(level, message, ...)
    if LOG_LEVELS[level] < self.minLevel then return end
    
    -- Format message with variable arguments
    local formattedMsg = message
    if ... then
        local args = {...}
        formattedMsg = string.format(message, unpack(args))
    end
    
    -- Create log entry
    local timestamp = os.date("%H:%M:%S")
    local entry = {
        timestamp = timestamp,
        level = level,
        module = self.moduleName,
        message = formattedMsg
    }
    
    -- Add to history
    table.insert(self.history, entry)
    if #self.history > self.maxHistory then
        table.remove(self.history, 1)
    end
    
    -- Output to console if enabled
    if self.outputEnabled then
        local logString = string.format("[%s][%s][%s] %s", 
            timestamp, level, self.moduleName, formattedMsg)
        
        if level == "DEBUG" or level == "INFO" then
            print(logString)
        else
            warn(logString)
        end
    end
    
    -- File logging if enabled
    if self.fileLogging and self.logFile then
        -- Implement file logging here if needed
    end
    
    return entry
end

function Logger:debug(message, ...)
    return self:log("DEBUG", message, ...)
end

function Logger:info(message, ...)
    return self:log("INFO", message, ...)
end

function Logger:warn(message, ...)
    return self:log("WARN", message, ...)
end

function Logger:error(message, ...)
    return self:log("ERROR", message, ...)
end

function Logger:critical(message, ...)
    return self:log("CRITICAL", message, ...)
end

function Logger:getHistory(level)
    if not level then
        return self.history
    end
    
    local filtered = {}
    for _, entry in ipairs(self.history) do
        if entry.level == level then
            table.insert(filtered, entry)
        end
    end
    
    return filtered
end

function Logger:clearHistory()
    self.history = {}
end

return Logger
