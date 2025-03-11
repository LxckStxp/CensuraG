-- CensuraG/src/Methods.lua (revised to fix Font tweening and ensure all methods exist)
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

-- Refresh a specific component
function Methods:RefreshComponent(component, instance)
    -- Check if instance is a table with an Instance property or a direct Instance
    local targetInstance
    if typeof(instance) == "table" and instance.Instance then
        targetInstance = instance.Instance
    elseif typeof(instance) == "Instance" then
        targetInstance = instance
    else
        _G.CensuraG.Logger:error("Cannot refresh invalid component: " .. tostring(instance))
        return
    end
    
    local theme = _G.CensuraG.Config:GetTheme()
    local animConfig = _G.CensuraG.Config.Animations
    
    if component == "window" then
        -- Handle window component which could be a WindowManager object
        if typeof(instance) == "table" then
            if instance.Frame then 
                _G.CensuraG.AnimationManager:Tween(instance.Frame, {
                    BackgroundColor3 = theme.PrimaryColor,
                    BackgroundTransparency = 0.15
                }, animConfig.FadeDuration)
                
                -- Update stroke if it exists
                for _, child in pairs(instance.Frame:GetChildren()) do
                    if child:IsA("UIStroke") then
                        _G.CensuraG.AnimationManager:Tween(child, {
                            Color = theme.BorderColor
                        }, animConfig.FadeDuration)
                    end
                end
            end
            
            if instance.TitleBar then
                _G.CensuraG.AnimationManager:Tween(instance.TitleBar, {
                    BackgroundColor3 = theme.SecondaryColor,
                    BackgroundTransparency = 0.8
                }, animConfig.FadeDuration)
                
                -- Update stroke if it exists
                for _, child in pairs(instance.TitleBar:GetChildren()) do
                    if child:IsA("UIStroke") then
                        _G.CensuraG.AnimationManager:Tween(child, {
                            Color = theme.BorderColor
                        }, animConfig.FadeDuration)
                    end
                end
            end
            
            if instance.TitleText then
                _G.CensuraG.AnimationManager:Tween(instance.TitleText, {
                    TextColor3 = theme.TextColor,
                    TextSize = theme.TextSize
                }, animConfig.FadeDuration)
                
                -- Set Font directly instead of tweening
                instance.TitleText.Font = theme.Font
            end
            
            if instance.MinimizeButton then
                _G.CensuraG.AnimationManager:Tween(instance.MinimizeButton, {
                    BackgroundColor3 = theme.AccentColor,
                    TextColor3 = theme.TextColor
                }, animConfig.FadeDuration)
                
                -- Set Font directly instead of tweening
                instance.MinimizeButton.Font = theme.Font
            end
            
            if instance.ContentFrame then
                _G.CensuraG.AnimationManager:Tween(instance.ContentFrame, {
                    BackgroundColor3 = theme.PrimaryColor,
                    BackgroundTransparency = 0.3,
                    ScrollBarImageColor3 = theme.AccentColor
                }, animConfig.FadeDuration)
            end
        end
    elseif component == "taskbar" then
        _G.CensuraG.AnimationManager:Tween(targetInstance, {
            BackgroundColor3 = theme.SecondaryColor
        }, animConfig.FadeDuration)
    elseif component == "textlabel" then
        if typeof(instance) == "table" then
            if instance.Label then
                _G.CensuraG.AnimationManager:Tween(instance.Label, {
                    TextColor3 = theme.TextColor,
                    TextSize = theme.TextSize
                }, animConfig.FadeDuration)
                
                -- Set Font directly instead of tweening
                instance.Label.Font = theme.Font
            end
            
            if instance.TextShadow then
                _G.CensuraG.AnimationManager:Tween(instance.TextShadow, {
                    TextColor3 = theme.PrimaryColor,
                    TextSize = theme.TextSize
                }, animConfig.FadeDuration)
                
                -- Set Font directly instead of tweening
                instance.TextShadow.Font = theme.Font
            end
            
            if instance.Instance then
                _G.CensuraG.AnimationManager:Tween(instance.Instance, {
                    BackgroundColor3 = theme.SecondaryColor,
                    BackgroundTransparency = 0.9
                }, animConfig.FadeDuration)
            end
        else
            _G.CensuraG.AnimationManager:Tween(targetInstance, {
                TextColor3 = theme.TextColor,
                TextSize = theme.TextSize
            }, animConfig.FadeDuration)
            
            -- Set Font directly instead of tweening
            targetInstance.Font = theme.Font
        end
    elseif component == "textbutton" then
        if typeof(instance) == "table" then
            if instance.Instance then
                _G.CensuraG.AnimationManager:Tween(instance.Instance, {
                    BackgroundColor3 = theme.SecondaryColor,
                    BackgroundTransparency = 0.8,
                    TextColor3 = theme.TextColor,
                    TextSize = theme.TextSize
                }, animConfig.FadeDuration)
                
                -- Set Font directly instead of tweening
                instance.Instance.Font = theme.Font
            end
            
            if instance.Stroke then
                _G.CensuraG.AnimationManager:Tween(instance.Stroke, {
                    Color = theme.AccentColor
                }, animConfig.FadeDuration)
            end
        else
            _G.CensuraG.AnimationManager:Tween(targetInstance, {
                BackgroundColor3 = theme.SecondaryColor,
                TextColor3 = theme.TextColor,
                TextSize = theme.TextSize
            }, animConfig.FadeDuration)
            
            -- Set Font directly instead of tweening
            targetInstance.Font = theme.Font
        end
    elseif component == "imagelabel" then
        -- No theme-specific updates for imagelabel yet
    elseif component == "slider" then
        if typeof(instance) == "table" then
            if instance.Instance then
                _G.CensuraG.AnimationManager:Tween(instance.Instance, {
                    BackgroundColor3 = theme.SecondaryColor,
                    BackgroundTransparency = 0.8
                }, animConfig.FadeDuration)
            end
            
            if instance.Track then
                local state = instance.State or false
                _G.CensuraG.AnimationManager:Tween(instance.Track, {
                    BackgroundColor3 = theme.BorderColor,
                    BackgroundTransparency = 0.5
                }, animConfig.FadeDuration)
            end
            
            if instance.Fill then
                _G.CensuraG.AnimationManager:Tween(instance.Fill, {
                    BackgroundColor3 = theme.EnabledColor
                }, animConfig.FadeDuration)
            end
            
            if instance.Knob then
                _G.CensuraG.AnimationManager:Tween(instance.Knob, {
                    BackgroundColor3 = theme.TextColor
                }, animConfig.FadeDuration)
            end
            
            if instance.NameLabel then
                _G.CensuraG.AnimationManager:Tween(instance.NameLabel, {
                    TextColor3 = theme.TextColor,
                    TextSize = theme.TextSize
                }, animConfig.FadeDuration)
                
                -- Set Font directly instead of tweening
                instance.NameLabel.Font = theme.Font
            end
            
            if instance.ValueLabel then
                _G.CensuraG.AnimationManager:Tween(instance.ValueLabel, {
                    TextColor3 = theme.TextColor,
                    TextSize = theme.TextSize
                }, animConfig.FadeDuration)
                
                -- Set Font directly instead of tweening
                instance.ValueLabel.Font = theme.Font
            end
        end
    elseif component == "dropdown" then
        if typeof(instance) == "table" then
            if instance.Instance then
                _G.CensuraG.AnimationManager:Tween(instance.Instance, {
                    BackgroundColor3 = theme.SecondaryColor,
                    BackgroundTransparency = 0.8
                }, animConfig.FadeDuration)
            end
            
            if instance.SelectedDisplay then
                _G.CensuraG.AnimationManager:Tween(instance.SelectedDisplay, {
                    BackgroundColor3 = theme.PrimaryColor,
                    BackgroundTransparency = 0.5
                }, animConfig.FadeDuration)
            end
            
            if instance.SelectedText then
                _G.CensuraG.AnimationManager:Tween(instance.SelectedText, {
                    TextColor3 = theme.TextColor,
                    TextSize = theme.TextSize
                }, animConfig.FadeDuration)
                
                -- Set Font directly instead of tweening
                instance.SelectedText.Font = theme.Font
            end
            
            if instance.ArrowButton then
                _G.CensuraG.AnimationManager:Tween(instance.ArrowButton, {
                    BackgroundColor3 = theme.AccentColor,
                    TextColor3 = theme.TextColor
                }, animConfig.FadeDuration)
                
                -- Set Font directly instead of tweening
                instance.ArrowButton.Font = theme.Font
            end
            
            if instance.OptionList then
                _G.CensuraG.AnimationManager:Tween(instance.OptionList, {
                    BackgroundColor3 = theme.PrimaryColor,
                    BackgroundTransparency = 0.2
                }, animConfig.FadeDuration)
                
                -- Update option buttons
                for _, child in pairs(instance.OptionList:GetChildren()) do
                    if child:IsA("TextButton") then
                        _G.CensuraG.AnimationManager:Tween(child, {
                            BackgroundColor3 = theme.SecondaryColor,
                            BackgroundTransparency = 0.8,
                            TextColor3 = theme.TextColor,
                            TextSize = theme.TextSize
                        }, animConfig.FadeDuration)
                        
                        -- Set Font directly instead of tweening
                        child.Font = theme.Font
                    end
                end
            end
        end
    elseif component == "switch" then
        if typeof(instance) == "table" then
            if instance.Instance then
                _G.CensuraG.AnimationManager:Tween(instance.Instance, {
                    BackgroundColor3 = theme.SecondaryColor,
                    BackgroundTransparency = 0.8
                }, animConfig.FadeDuration)
            end
            
            if instance.Track then
                local state = instance.State or false
                _G.CensuraG.AnimationManager:Tween(instance.Track, {
                    BackgroundColor3 = state and theme.EnabledColor or theme.PrimaryColor,
                    BackgroundTransparency = 0.5
                }, animConfig.FadeDuration)
            end
            
            if instance.Knob then
                _G.CensuraG.AnimationManager:Tween(instance.Knob, {
                    BackgroundColor3 = theme.TextColor
                }, animConfig.FadeDuration)
            end
            
            if instance.TitleLabel then
                _G.CensuraG.AnimationManager:Tween(instance.TitleLabel, {
                    TextColor3 = theme.TextColor,
                    TextSize = theme.TextSize
                }, animConfig.FadeDuration)
                
                -- Set Font directly instead of tweening
                instance.TitleLabel.Font = theme.Font
            end
        end
    end
    
    _G.CensuraG.Logger:info("Refreshed component: " .. component)
end

-- Refresh all UI elements
function Methods:RefreshAll()
    -- Ensure Windows table exists
    if not _G.CensuraG.Windows then
        _G.CensuraG.Windows = {}
        _G.CensuraG.Logger:warn("Windows table was nil, initialized empty table")
    end
    
    -- Refresh all windows
    for _, window in ipairs(_G.CensuraG.Windows) do
        if window and typeof(window) == "table" and window.Refresh then
            window:Refresh()
        end
    end
    
    -- Refresh taskbar if it exists
    if _G.CensuraG.Taskbar and _G.CensuraG.Taskbar.Instance then
        if typeof(_G.CensuraG.Taskbar.Instance) == "table" and _G.CensuraG.Taskbar.Instance.Refresh then
            _G.CensuraG.Taskbar.Instance:Refresh()
        elseif _G.CensuraG.TaskbarManager and _G.CensuraG.TaskbarManager.Refresh then
            _G.CensuraG.TaskbarManager:Refresh()
        end
    end
    
    _G.CensuraG.Logger:info("Refreshed all UI elements")
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

return Methods
