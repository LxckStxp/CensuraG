-- CensuraG/src/Methods.lua (revised to use RefreshManager)
local Methods = {}

-- Create a new window with title
function Methods:CreateWindow(title)
    if not _G.CensuraG.WindowManager then
        _G.CensuraG.Logger:error("WindowManager not loaded")
        return nil
    end
    
    -- Create window and add to global windows table
    local window = _G.CensuraG.WindowManager.new(title)
    if not window then
        _G.CensuraG.Logger:error("Failed to create window")
        return nil
    end
    
    -- Initialize Windows table if it doesn't exist
    _G.CensuraG.Windows = _G.CensuraG.Windows or {}
    table.insert(_G.CensuraG.Windows, window)
    
    -- Update taskbar if available
    if _G.CensuraG.TaskbarManager and _G.CensuraG.TaskbarManager.UpdateTaskbar then
        _G.CensuraG.TaskbarManager:UpdateTaskbar()
    end
    
    _G.CensuraG.Logger:info("Created window: " .. title)
    return window
end

-- Get a configuration value with support for nested paths
function Methods:GetConfigValue(keyPath)
    -- Handle string paths or table paths
    local keys = typeof(keyPath) == "string" and string.split(keyPath, ".") or keyPath
    
    if not keys or #keys == 0 then
        _G.CensuraG.Logger:error("Invalid key path provided")
        return nil
    end
    
    local value = _G.CensuraG.Config
    for _, key in ipairs(keys) do
        if typeof(value) ~= "table" then
            _G.CensuraG.Logger:warn("Config path invalid at: " .. key)
            return nil
        end
        
        value = value[key]
        if value == nil then
            _G.CensuraG.Logger:warn("Config key not found: " .. table.concat(keys, "."))
            return nil
        end
    end
    
    _G.CensuraG.Logger:info("Retrieved config value for " .. table.concat(keys, "."))
    return value
end

-- Set a configuration value with support for nested paths
function Methods:SetConfigValue(keyPath, value)
    -- Handle string paths or table paths
    local keys = typeof(keyPath) == "string" and string.split(keyPath, ".") or keyPath
    
    if not keys or #keys == 0 then
        _G.CensuraG.Logger:error("Invalid key path provided")
        return false
    end
    
    local target = _G.CensuraG.Config
    local lastKey = keys[#keys]
    
    -- Navigate to the correct location in the config
    for i, key in ipairs(keys) do
        if i == #keys then
            -- Set the value at the final key
            target[lastKey] = value
        else
            -- Create path if it doesn't exist
            if target[key] == nil then
                target[key] = {}
            elseif typeof(target[key]) ~= "table" then
                -- If existing value is not a table, we can't go deeper
                target[key] = {}
                _G.CensuraG.Logger:warn("Overwriting non-table value at " .. key)
            end
            target = target[key]
        end
    end
    
    -- Special handling for theme changes
    if keys[1] == "CurrentTheme" and _G.CensuraG.Config.Themes[value] then
        self:RefreshAll()
    end
    
    _G.CensuraG.Logger:info("Set config value for " .. table.concat(keys, ".") .. " to " .. tostring(value))
    return true
end

-- Delegate refresh operations to RefreshManager
function Methods:RefreshComponent(component, instance)
    if _G.CensuraG.RefreshManager then
        _G.CensuraG.RefreshManager:RefreshComponent(component, instance)
    else
        _G.CensuraG.Logger:error("RefreshManager not available")
    end
end

-- Delegate refresh all operations to RefreshManager
function Methods:RefreshAll()
    if _G.CensuraG.RefreshManager then
        _G.CensuraG.RefreshManager:RefreshAll()
    else
        _G.CensuraG.Logger:error("RefreshManager not available")
    end
end

-- Change the theme of all UI elements
function Methods:ChangeTheme(themeName)
    if _G.CensuraG.Config.Themes[themeName] then
        _G.CensuraG.Config.CurrentTheme = themeName
        self:RefreshAll()
        _G.CensuraG.Logger:info("Theme changed to: " .. themeName)
    else
        _G.CensuraG.Logger:error("Theme not found: " .. themeName)
    end
end

-- Component creation shortcuts
function Methods:CreateLabel(parent, text)
    if not _G.CensuraG.Components.textlabel then
        _G.CensuraG.Logger:error("TextLabel component not loaded")
        return nil
    end
    return _G.CensuraG.Components.textlabel(parent, text)
end

function Methods:CreateButton(parent, text, callback)
    if not _G.CensuraG.Components.textbutton then
        _G.CensuraG.Logger:error("TextButton component not loaded")
        return nil
    end
    return _G.CensuraG.Components.textbutton(parent, text, callback)
end

function Methods:CreateSlider(parent, name, min, max, default, callback)
    if not _G.CensuraG.Components.slider then
        _G.CensuraG.Logger:error("Slider component not loaded")
        return nil
    end
    return _G.CensuraG.Components.slider(parent, name, min, max, default, callback)
end

function Methods:CreateSwitch(parent, title, default, callback)
    if not _G.CensuraG.Components.switch then
        _G.CensuraG.Logger:error("Switch component not loaded")
        return nil
    end
    return _G.CensuraG.Components.switch(parent, title, default, callback)
end

function Methods:CreateDropdown(parent, title, options, callback)
    if not _G.CensuraG.Components.dropdown then
        _G.CensuraG.Logger:error("Dropdown component not loaded")
        return nil
    end
    return _G.CensuraG.Components.dropdown(parent, title, options, callback)
end

function Methods:CreateGrid(parent)
    if not _G.CensuraG.Components.grid then
        _G.CensuraG.Logger:error("Grid component not loaded")
        return nil
    end
    return _G.CensuraG.Components.grid(parent)
end

function Methods:CreateImage(parent, imageId)
    if not _G.CensuraG.Components.imagelabel then
        _G.CensuraG.Logger:error("ImageLabel component not loaded")
        return nil
    end
    return _G.CensuraG.Components.imagelabel(parent, imageId)
end

-- Utility method to destroy all UI elements
function Methods:DestroyAll()
    -- Destroy all windows
    if _G.CensuraG.Windows then
        for _, window in ipairs(_G.CensuraG.Windows) do
            if window and window.Frame then
                window.Frame:Destroy()
            end
        end
        _G.CensuraG.Windows = {}
    end
    
    -- Destroy taskbar
    if _G.CensuraG.Taskbar and _G.CensuraG.Taskbar.Instance and _G.CensuraG.Taskbar.Instance.Frame then
        _G.CensuraG.Taskbar.Instance.Frame:Destroy()
    end
    
    _G.CensuraG.Logger:info("All UI elements destroyed")
end

return Methods
