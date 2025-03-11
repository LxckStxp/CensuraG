-- CensuraG/src/Methods.lua (fixed syntax error)
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
                    Font = theme.Font,
                    TextSize = theme.TextSize
                }, animConfig.FadeDuration)
            end
            
            if instance.MinimizeButton then
                _G.CensuraG.AnimationManager:Tween(instance.MinimizeButton, {
                    BackgroundColor3 = theme.AccentColor,
                    TextColor3 = theme.TextColor,
                    Font = theme.Font
                }, animConfig.FadeDuration)
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
                    Font = theme.Font,
                    TextSize = theme.TextSize
                }, animConfig.FadeDuration)
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
                Font = theme.Font,
                TextSize = theme.TextSize
            }, animConfig.FadeDuration)
        end
    elseif component == "textbutton" then
        if typeof(instance) == "table" then
            if instance.Instance then
                _G.CensuraG.AnimationManager:Tween(instance.Instance, {
                    BackgroundColor3 = theme.SecondaryColor,
                    BackgroundTransparency = 0.8,
                    TextColor3 = theme.TextColor,
                    Font = theme.Font,
                    TextSize = theme.TextSize
                }, animConfig.FadeDuration)
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
                Font = theme.Font,
                TextSize = theme.TextSize
            }, animConfig.FadeDuration)
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
                    BackgroundColor3 = state and theme.EnabledColor or theme.PrimaryColor,
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
                    Font = theme.Font,
                    TextSize = theme.TextSize
                }, animConfig.FadeDuration)
            end
            
            if instance.ValueLabel then
                _G.CensuraG.AnimationManager:Tween(instance.ValueLabel, {
                    TextColor3 = theme.TextColor,
                    Font = theme.Font,
                    TextSize = theme.TextSize
                }, animConfig.FadeDuration)
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
                    Font = theme.Font,
                    TextSize = theme.TextSize
                }, animConfig.FadeDuration)
            end
            
            if instance.ArrowButton then
                _G.CensuraG.AnimationManager:Tween(instance.ArrowButton, {
                    BackgroundColor3 = theme.AccentColor,
                    TextColor3 = theme.TextColor,
                    Font = theme.Font
                }, animConfig.FadeDuration)
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
                            Font = theme.Font,
                            TextSize = theme.TextSize
                        }, animConfig.FadeDuration)
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
                    Font = theme.Font,
                    TextSize = theme.TextSize
                }, animConfig.FadeDuration)
            end
        end
    end
    
    _G.CensuraG.Logger:info("Refreshed component: " .. component)
end

function Methods:RefreshAll()
    for _, window in ipairs(_G.CensuraG.Windows) do
        window:Refresh()
    end
    if _G.CensuraG.Taskbar and _G.CensuraG.Taskbar.Instance then
        _G.CensuraG.Taskbar.Instance:Refresh()
    end
    _G.CensuraG.Logger:info("Refreshed all UI elements")
end

return Methods
