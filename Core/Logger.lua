-- Core/Logger.lua
-- Simple logging system

local Logger = {}
Logger.__index = Logger

local LOG_LEVELS = {
	DEBUG = 1,
	INFO = 2,
	WARN = 3,
	ERROR = 4,
	CRITICAL = 5
}

function Logger.new(options)
	options = options or {}
	local self = setmetatable({
		moduleName = options.moduleName or "Logger",
		minLevel = LOG_LEVELS[options.minLevel or "INFO"],
		history = {},
		maxHistory = options.maxHistory or 1000,
		outputEnabled = options.outputEnabled ~= false
	}, Logger)
	return self
end

function Logger:log(level, message, ...)
	if LOG_LEVELS[level] < self.minLevel then
		return
	end
	local formatted = message
	if select("#", ...) > 0 then
		formatted = string.format(message, ...)
	end
	local timestamp = os.date("%H:%M:%S")
	local entry = { timestamp = timestamp, level = level, module = self.moduleName, message = formatted }
	table.insert(self.history, entry)
	if #self.history > self.maxHistory then
		table.remove(self.history, 1)
	end
	local logStr = string.format("[%s][%s][%s] %s", timestamp, level, self.moduleName, formatted)
	if self.outputEnabled then
		if level == "DEBUG" or level == "INFO" then
			print(logStr)
		else
			warn(logStr)
		end
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
	if not level then return self.history end
	local filtered = {}
	for _, entry in ipairs(self.history) do
		if entry.level == level then table.insert(filtered, entry) end
	end
	return filtered
end

function Logger:clearHistory()
	self.history = {}
end

return Logger
