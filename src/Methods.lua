-- CensuraG/src/Methods.lua
local Methods = {}

function Methods:CreateWindow(title)
    if not _G.CensuraG.WindowManager then
        _G.CensuraG.Logger:error("WindowManager not loaded")
        return nil
    end
    local window = _G.CensuraG.WindowManager.new(title)
    table.insert(_G.CensuraG.Windows, window)
    _G.CensuraG.TaskbarManager:UpdateTaskbar()
    return window
end

-- Get a value from the Config table
function Methods:GetConfigValue(keyPath)
    local keys = typeof(keyPath) == "string" and keyPath:split(".") or keyPath
    local value = _G.CensuraG.Config
    
    for _, key in ipairs(keys) do
        value = value[key]
        if value == nil then
            _G.CensuraG.Logger:warn("Config key not found: " .. table.concat(keys, "."))
            return nil
        end
    end
    
    _G.CensuraG.Logger:info("Retrieved config value for " .. table.concat(keys, "."))
    return value
end

-- Set a value in the Config table
function Methods:SetConfigValue(keyPath, value)
    local keys = typeof(keyPath) == "string" and keyPath:split(".") or keyPath
    local target = _G.CensuraG.Config
    local lastKey = keys[#keys]
    
    for i, key in ipairs(keys) do
        if i == #keys then
            target[lastKey] = value
        elseif not target[key] then
            target[key] = {}
        end
        target = target[key]
    end
    
    _G.CensuraG.Logger:info("Set config value for " .. table.concat(keys, ".") .. " to " .. tostring(value))
end

return Methods
