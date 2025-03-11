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
            if instance.Frame then targetInstance = instance.Frame end
            if instance.TitleBar then
                _G.CensuraG.AnimationManager:Tween(instance.TitleBar, {BackgroundColor3 = theme.SecondaryColor}, animConfig.FadeDuration)
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
            
            _G.CensuraG.AnimationManager:Tween(targetInstance, {BackgroundColor3 = theme.PrimaryColor}, animConfig.FadeDuration)
        end
    elseif component == "taskbar" then
        _G.CensuraG.AnimationManager:Tween(targetInstance, {BackgroundColor3 = theme.SecondaryColor}, animConfig.FadeDuration)
    elseif component == "textlabel" then
        _G.CensuraG.AnimationManager:Tween(targetInstance, {
            TextColor3 = theme.TextColor,
            Font = theme.Font,
            TextSize = theme.TextSize
        }, animConfig.FadeDuration)
    elseif component == "textbutton" then
        _G.CensuraG.AnimationManager:Tween(targetInstance, {
            BackgroundColor3 = theme.SecondaryColor,
            TextColor3 = theme.TextColor,
            Font = theme.Font,
            TextSize = theme.TextSize
        }, animConfig.FadeDuration)
    elseif component == "imagelabel" then
        -- No theme-specific updates for imagelabel yet
    elseif component == "slider" then
        _G.CensuraG.AnimationManager:Tween(targetInstance, {BackgroundColor3 = theme.PrimaryColor}, animConfig.FadeDuration)
        if instance.Bar then
            _G.CensuraG.AnimationManager:Tween(instance.Bar, {BackgroundColor3 = theme.SecondaryColor}, animConfig.FadeDuration)
        end
        if instance.Knob then
            _G.CensuraG.AnimationManager:Tween(instance.Knob, {BackgroundColor3 = theme.AccentColor}, animConfig.FadeDuration)
        end
    elseif component == "dropdown" then
        _G.CensuraG.AnimationManager:Tween(targetInstance, {BackgroundColor3 = theme.SecondaryColor}, animConfig.FadeDuration)
        if instance.SelectedText then
            _G.CensuraG.AnimationManager:Tween(instance.SelectedText, {
                TextColor3 = theme.TextColor,
                Font = theme.Font,
                TextSize = theme.TextSize
            }, animConfig.FadeDuration)
        end
        if instance.Arrow then
            _G.CensuraG.AnimationManager:Tween(instance.Arrow, {
                BackgroundColor3 = theme.AccentColor,
                TextColor3 = theme.TextColor,
                Font = theme.Font
            }, animConfig.FadeDuration)
        end
        if instance.OptionList then
            _G.CensuraG.AnimationManager:Tween(instance.OptionList, {BackgroundColor3 = theme.PrimaryColor}, animConfig.FadeDuration)
            for _, button in ipairs(instance.OptionList:GetChildren()) do
                if button:IsA("TextButton") then
                    _G.CensuraG.AnimationManager:Tween(button, {
                        BackgroundColor3 = theme.PrimaryColor,
                        TextColor3 = theme.TextColor,
                        Font = theme.Font,
                        TextSize = theme.TextSize
                    }, animConfig.FadeDuration)
                end
            end
        end
    elseif component == "switch" then
        _G.CensuraG.AnimationManager:Tween(targetInstance, {BackgroundColor3 = theme.PrimaryColor}, animConfig.FadeDuration)
        if instance.Knob then
            local knobColor = instance.State and theme.AccentColor or theme.SecondaryColor
            _G.CensuraG.AnimationManager:Tween(instance.Knob, {BackgroundColor3 = knobColor}, animConfig.FadeDuration)
        end
    elseif component == "grid" then
        _G.CensuraG.AnimationManager:Tween(targetInstance, {BackgroundColor3 = theme.PrimaryColor}, animConfig.FadeDuration)
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
