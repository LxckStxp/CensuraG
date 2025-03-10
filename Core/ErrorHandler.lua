-- Core/ErrorHandler.lua: Simplified error handling
local ErrorHandler = {}

-- Execute a function safely
function ErrorHandler:TryCatch(func, errorMessage, ...)
    local success, result = pcall(func, ...)
    if not success and errorMessage then
        warn(errorMessage, result)
    end
    return success and result or nil
end

return ErrorHandler
