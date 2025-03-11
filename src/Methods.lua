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
    local theme = _G.CensuraG.Config:GetTheme()
    local animConfig = _G.CensuraG.Config.Animations
    
    if component == "window" then
        instance.BackgroundColor3 = theme.PrimaryColor
        instance.TitleBar.BackgroundColor3 = theme.SecondaryColor
        instance.TitleText.TextColor3 = theme.TextColor
        instance.TitleText.Font = theme.Font
        instance.TitleText.TextSize = theme.TextSize
        instance.MinimizeButton.BackgroundColor3 = theme.AccentColor
        instance.MinimizeButton.TextColor3 = theme.TextColor
        instance.MinimizeButton.Font = theme.Font
    elseif component == "taskbar" then
        instance.BackgroundColor3 = theme.SecondaryColor
    elseif component == "textlabel" then
        instance.TextColor3 = theme.TextColor
        instance.Font = theme.Font
        instance.TextSize = theme.TextSize
    elseif component == "textbutton" then
        instance.BackgroundColor3 = theme.SecondaryColor
        instance.TextColor3 = theme.TextColor
        instance.Font = theme.Font
        instance.TextSize = theme.TextSize
    elseif component == "imagelabel" then
        -- No theme-specific updates for imagelabel yet
    elseif component == "slider" then
        instance.BackgroundColor3 = theme.PrimaryColor
        instance.Bar.BackgroundColor3 = theme.SecondaryColor
        instance.Knob.BackgroundColor3 = theme.AccentColor
    elseif component == "dropdown" then
        instance.BackgroundColor3 = theme.SecondaryColor
        instance.SelectedText.TextColor3 = theme.TextColor
        instance.SelectedText.Font = theme.Font
        instance.SelectedText.TextSize = theme.TextSize
        instance.Arrow.BackgroundColor3 = theme.AccentColor
        instance.Arrow.TextColor3 = theme.TextColor
        instance.Arrow.Font = theme.Font
        instance.OptionList.BackgroundColor3 = theme.PrimaryColor
        for _, button in ipairs(instance.OptionList:GetChildren()) do
            if button:IsA("TextButton") then
                button.BackgroundColor3 = theme.PrimaryColor
                button.TextColor3 = theme.TextColor
                button.Font = theme.Font
                button.TextSize = theme.TextSize
            end
        end
    elseif component == "switch" then
        instance.BackgroundColor3 = theme.PrimaryColor
        instance.Knob.BackgroundColor3 = instance.State and theme.AccentColor or theme.SecondaryColor
    elseif component == "grid" then
        instance.BackgroundColor3 = theme.PrimaryColor
    end
    
    _G.CensuraG.Logger:info("Refreshed component: " .. component)
    _G.CensuraG.AnimationManager:Tween(instance, {Transparency = 0}, animConfig.FadeDuration)
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
