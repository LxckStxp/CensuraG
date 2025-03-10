-- Core/ErrorHandler.lua: Error handling and recovery system
local ErrorHandler = {}
local logger = _G.CensuraG.Logger

-- Standard error messages
ErrorHandler.ErrorMessages = {
    INITIALIZATION_FAILED = "CensuraG initialization failed: %s",
    MODULE_LOAD_FAILED = "Failed to load module %s: %s",
    ELEMENT_CREATION_FAILED = "Failed to create UI element %s: %s",
    INVALID_PARENT = "Invalid parent for UI element %s",
    SCREEN_GUI_UNAVAILABLE = "ScreenGui is unavailable or inaccessible",
    INVALID_PARAMETERS = "Invalid parameters for %s: %s",
    OPERATION_FAILED = "Operation %s failed: %s"
}

-- Execute a function safely with error handling
function ErrorHandler:TryCatch(func, errorMessage, ...)
    if not func then
        logger:warn("TryCatch called with nil function")
        return nil
    end
    
    local args = {...}
    local success, result = pcall(function()
        return func(unpack(args))
    end)
    
    if not success then
        if errorMessage then
            logger:error(errorMessage, result)
        else
            logger:error("Error in function execution: %s", result)
        end
        return nil
    end
    
    return result
end

-- Safely destroy an instance
function ErrorHandler:SafeDestroy(instance)
    if not instance then return false end
    
    if typeof(instance) == "Instance" then
        local success, err = pcall(function()
            instance:Destroy()
        end)
        
        if not success then
            logger:warn("Failed to destroy instance: %s", err)
            return false
        end
        
        return true
    elseif type(instance) == "table" and instance.Destroy then
        local success, err = pcall(function()
            instance:Destroy()
        end)
        
        if not success then
            logger:warn("Failed to destroy object: %s", err)
            return false
        end
        
        return true
    end
    
    logger:warn("Cannot destroy object of type: %s", typeof(instance))
    return false
end

-- Attempt to recover from errors
function ErrorHandler:Recover()
    logger:info("Attempting to recover from errors...")
    
    -- Clean up any dangling UI elements
    if _G.CensuraG and _G.CensuraG.ScreenGui then
        for _, child in pairs(_G.CensuraG.ScreenGui:GetChildren()) do
            self:SafeDestroy(child)
        end
        logger:debug("Cleaned up ScreenGui children")
    end
    
    -- Reset window manager
    if _G.CensuraG and _G.CensuraG.WindowManager then
        _G.CensuraG.WindowManager:Destroy()
        _G.CensuraG.WindowManager:Init()
        logger:debug("Reset WindowManager")
    end
    
    -- Disconnect all event connections
    if _G.CensuraG and _G.CensuraG.EventManager then
        _G.CensuraG.EventManager:DisconnectAll()
        logger:debug("Disconnected all event connections")
    end
    
    logger:info("Recovery completed")
    return true
end

-- Validate required parameters
function ErrorHandler:ValidateParams(params, required, functionName)
    functionName = functionName or "unknown function"
    
    if not params then
        logger:error("No parameters provided for %s", functionName)
        return false
    end
    
    for _, paramName in ipairs(required) do
        if params[paramName] == nil then
            logger:error("Missing required parameter '%s' for %s", paramName, functionName)
            return false
        end
    end
    
    return true
end

-- Create an error object
function ErrorHandler:CreateError(code, message, details)
    return {
        code = code,
        message = message,
        details = details,
        timestamp = os.time()
    }
end

-- Log an error and return an error object
function ErrorHandler:LogError(code, message, details)
    local errorObj = self:CreateError(code, message, details)
    logger:error("[%s] %s: %s", code, message, details or "")
    return errorObj
end

return ErrorHandler
