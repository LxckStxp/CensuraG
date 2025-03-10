-- Core/ErrorHandler.lua
-- Error handling and recovery system

local ErrorHandler = {}
local logger = _G.CensuraG.Logger

ErrorHandler.ErrorMessages = {
	INITIALIZATION_FAILED = "Initialization failed: %s",
	MODULE_LOAD_FAILED = "Module %s load failed: %s",
	INVALID_PARAMETERS = "Invalid parameters for %s: %s",
	OPERATION_FAILED = "Operation %s failed: %s"
}

function ErrorHandler:TryCatch(func, errorMessage, ...)
	if type(func) ~= "function" then
		logger:warn("TryCatch called with non-function value")
		return nil
	end
	local args = { ... }
	local success, result = pcall(function() return func(unpack(args)) end)
	if not success then
		if errorMessage then
			logger:error(errorMessage, result)
		else
			logger:error("Error in execution: %s", result)
		end
		return nil
	end
	return result
end

function ErrorHandler:SafeDestroy(instance)
	if not instance then return false end
	local success, err = pcall(function() instance:Destroy() end)
	if not success then
		logger:warn("Failed to destroy instance: %s", err)
		return false
	end
	return true
end

function ErrorHandler:Recover()
	logger:info("Attempting recovery...")
	-- Here add any recovery procedures (cleanup dangling UI, etc.)
	if _G.CensuraG and _G.CensuraG.EventManager then
		_G.CensuraG.EventManager:DisconnectAll()
	end
	logger:info("Recovery completed")
	return true
end

function ErrorHandler:ValidateParams(params, required, functionName)
	functionName = functionName or "unknown function"
	if type(params) ~= "table" then
		logger:error("No parameters provided for %s", functionName)
		return false
	end
	for _, key in ipairs(required) do
		if params[key] == nil then
			logger:error("Missing parameter '%s' for %s", key, functionName)
			return false
		end
	end
	return true
end

function ErrorHandler:CreateError(code, message, details)
	return { code = code, message = message, details = details, timestamp = os.time() }
end

function ErrorHandler:LogError(code, message, details)
	local errorObj = self:CreateError(code, message, details)
	logger:error("[%s] %s: %s", code, message, details or "")
	return errorObj
end

return ErrorHandler
