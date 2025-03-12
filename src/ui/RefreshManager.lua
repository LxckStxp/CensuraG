-- CensuraG/src/ui/RefreshManager.lua (Simplified version with full functionality)
local RefreshManager = {}
RefreshManager.__index = RefreshManager

local function tween(obj, props, duration)
    if obj then
        _G.CensuraG.AnimationManager:Tween(obj, props, duration or _G.CensuraG.Config.Animations.FadeDuration)
    end
end

function RefreshManager:Initialize()
    _G.CensuraG.Logger:info("RefreshManager initialized")
end

-- Helper to apply common text properties
local function refreshText(obj, theme)
    tween(obj, {TextColor3 = theme.TextColor, TextSize = theme.TextSize})
    obj.Font = theme.Font
end

-- Helper to refresh strokes
local function refreshStroke(obj, color)
    tween(obj, {Color = color})
end

function RefreshManager:RefreshComponent(component, instance)
    if not component or typeof(component) ~= "string" then
        _G.CensuraG.Logger:error("Invalid component type: " .. tostring(component))
        return
    end
    if not instance then
        _G.CensuraG.Logger:error("Nil instance for component: " .. component)
        return
    end

    local target = typeof(instance) == "table" and (instance.Instance or instance) or instance
    if typeof(target) ~= "Instance" and typeof(target) ~= "table" then
        _G.CensuraG.Logger:error("Cannot refresh invalid component: " .. tostring(instance))
        return
    end

    local theme = _G.CensuraG.Config:GetTheme()
    local success, err = pcall(function()
        if component == "window" and typeof(instance) == "table" then
            tween(instance.Frame, {BackgroundColor3 = theme.PrimaryColor, BackgroundTransparency = 0.15})
            tween(instance.TitleBar, {BackgroundColor3 = theme.SecondaryColor, BackgroundTransparency = 0.8})
            refreshText(instance.TitleText, theme)
            tween(instance.MinimizeButton, {BackgroundColor3 = theme.AccentColor, TextColor3 = theme.TextColor})
            instance.MinimizeButton.Font = theme.Font
            tween(instance.ContentFrame, {BackgroundColor3 = theme.PrimaryColor, BackgroundTransparency = 0.3, ScrollBarImageColor3 = theme.AccentColor})
            
            for _, child in pairs(instance.Frame:GetChildren()) do
                if child:IsA("UIStroke") then refreshStroke(child, theme.BorderColor) end
            end
            for _, child in pairs(instance.TitleBar:GetChildren()) do
                if child:IsA("UIStroke") then refreshStroke(child, theme.BorderColor) end
            end
            for _, child in ipairs(instance.ContentFrame:GetChildren()) do
                if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                    self:RefreshUIElement(child, theme)
                end
            end

        elseif component == "taskbar" then
            tween(target, {BackgroundColor3 = theme.SecondaryColor})

        elseif component == "textlabel" then
            if typeof(instance) == "table" then
                refreshText(instance.Label, theme)
                tween(instance.TextShadow, {TextColor3 = theme.PrimaryColor, TextSize = theme.TextSize})
                instance.TextShadow.Font = theme.Font
                tween(instance.Instance, {BackgroundColor3 = theme.SecondaryColor, BackgroundTransparency = 0.9})
            else
                refreshText(target, theme)
            end

        elseif component == "textbutton" then
            if typeof(instance) == "table" then
                tween(instance.Instance, {BackgroundColor3 = theme.SecondaryColor, BackgroundTransparency = 0.8})
                refreshText(instance.Instance, theme)
                refreshStroke(instance.Stroke, theme.AccentColor)
                tween(instance.TextShadow, {TextColor3 = theme.PrimaryColor, TextSize = theme.TextSize})
                instance.TextShadow.Font = theme.Font
            else
                tween(target, {BackgroundColor3 = theme.SecondaryColor, TextColor3 = theme.TextColor, TextSize = theme.TextSize})
                target.Font = theme.Font
            end

        elseif component == "imagelabel" then
            -- No theme-specific updates yet

        elseif component == "slider" and typeof(instance) == "table" then
            tween(instance.Instance, {BackgroundColor3 = theme.SecondaryColor, BackgroundTransparency = 0.8})
            tween(instance.Track, {BackgroundColor3 = theme.BorderColor, BackgroundTransparency = 0.5})
            tween(instance.Fill, {BackgroundColor3 = theme.EnabledColor})
            tween(instance.Knob, {BackgroundColor3 = theme.TextColor})
            refreshText(instance.NameLabel, theme)
            refreshText(instance.ValueLabel, theme)

        elseif component == "dropdown" and typeof(instance) == "table" then
            tween(instance.Instance, {BackgroundColor3 = theme.SecondaryColor, BackgroundTransparency = 0.8})
            tween(instance.SelectedDisplay, {BackgroundColor3 = theme.PrimaryColor, BackgroundTransparency = 0.5})
            refreshText(instance.SelectedText, theme)
            tween(instance.ArrowButton, {BackgroundColor3 = theme.AccentColor, TextColor3 = theme.TextColor})
            instance.ArrowButton.Font = theme.Font
            tween(instance.OptionList, {BackgroundColor3 = theme.PrimaryColor, BackgroundTransparency = 0.2})
            for _, child in pairs(instance.OptionList:GetChildren()) do
                if child:IsA("TextButton") then
                    tween(child, {BackgroundColor3 = theme.SecondaryColor, BackgroundTransparency = 0.8, TextColor3 = theme.TextColor, TextSize = theme.TextSize})
                    child.Font = theme.Font
                end
            end

        elseif component == "switch" and typeof(instance) == "table" then
            tween(instance.Instance, {BackgroundColor3 = theme.SecondaryColor, BackgroundTransparency = 0.8})
            tween(instance.Track, {BackgroundColor3 = instance.State and theme.EnabledColor or theme.PrimaryColor, BackgroundTransparency = 0.5})
            tween(instance.Knob, {BackgroundColor3 = theme.TextColor})
            refreshText(instance.TitleLabel, theme)

        elseif component == "grid" and typeof(instance) == "table" then
            tween(instance.Instance, {BackgroundColor3 = theme.PrimaryColor, BackgroundTransparency = 0.8})
            for _, child in ipairs(instance.Instance:GetChildren()) do
                if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                    self:RefreshUIElement(child, theme)
                end
            end

        elseif component == "systemtray" and typeof(instance) == "table" then
            tween(instance.Instance, {BackgroundColor3 = theme.SecondaryColor, BackgroundTransparency = 0.7})
            refreshText(instance.Instance:FindFirstChild("TextLabel"), theme) -- DisplayName
            tween(instance.Panel, {BackgroundColor3 = theme.PrimaryColor, BackgroundTransparency = 0.2})
            for _, child in ipairs(instance.Panel:GetChildren()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    tween(child, {TextColor3 = theme.TextColor, BackgroundColor3 = child:IsA("TextButton") and theme.AccentColor or child.BackgroundColor3})
                    child.Font = theme.Font
                end
                if child:IsA("UIStroke") then refreshStroke(child, theme.AccentColor) end
            end

        else
            _G.CensuraG.Logger:debug("Refreshing unknown component: " .. component)
            if target:IsA("TextLabel") or target:IsA("TextButton") or target:IsA("TextBox") then
                refreshText(target, theme)
            end
            if target:IsA("Frame") or target:IsA("TextButton") or target:IsA("TextBox") then
                tween(target, {BackgroundColor3 = theme.SecondaryColor, BackgroundTransparency = 0.8})
            end
        end
    end)

    if not success then
        _G.CensuraG.Logger:warn("Error refreshing component " .. component .. ": " .. err)
    else
        _G.CensuraG.Logger:info("Refreshed component: " .. component)
    end
end

function RefreshManager:RefreshUIElement(element, theme)
    if not element or not element:IsA("Instance") then return end

    local success, err = pcall(function()
        if element:IsA("Frame") then
            local componentType = element:GetAttribute("ComponentType")
            if componentType then
                self:RefreshComponent(componentType, element)
            else
                tween(element, {BackgroundColor3 = theme.SecondaryColor, BackgroundTransparency = 0.8})
                for _, child in ipairs(element:GetChildren()) do
                    self:RefreshUIElement(child, theme)
                end
            end
        elseif element:IsA("TextLabel") or element:IsA("TextButton") then
            refreshText(element, theme)
            if element:IsA("TextButton") then
                tween(element, {BackgroundColor3 = theme.SecondaryColor})
            end
            for _, child in ipairs(element:GetChildren()) do
                if child:IsA("UIStroke") then refreshStroke(child, theme.AccentColor) end
            end
        elseif element:IsA("ImageLabel") or element:IsA("ImageButton") then
            local imagePart = element:GetAttribute("ImagePart")
            if imagePart == "Accent" then tween(element, {ImageColor3 = theme.AccentColor})
            elseif imagePart == "Primary" then tween(element, {ImageColor3 = theme.PrimaryColor}) end
        elseif element:IsA("ScrollingFrame") then
            tween(element, {BackgroundColor3 = theme.PrimaryColor, ScrollBarImageColor3 = theme.AccentColor})
            for _, child in ipairs(element:GetChildren()) do
                if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                    self:RefreshUIElement(child, theme)
                end
            end
        elseif element:IsA("UIStroke") then
            refreshStroke(element, theme.BorderColor)
        end
    end)

    if not success then
        _G.CensuraG.Logger:debug("Error refreshing element: " .. err)
    end
end

function RefreshManager:RefreshAll()
    local theme = _G.CensuraG.Config:GetTheme()
    _G.CensuraG.Logger:info("Refreshing all UI elements with theme: " .. _G.CensuraG.Config.CurrentTheme)

    pcall(function()
        if _G.CensuraG.Windows then
            for _, window in ipairs(_G.CensuraG.Windows) do
                if window and typeof(window) == "table" then
                    if typeof(window.Refresh) == "function" then
                        pcall(window.Refresh, window)
                    elseif window.Frame then
                        self:RefreshUIElement(window.Frame, theme)
                        if window.ContentFrame then
                            self:RefreshUIElement(window.ContentFrame, theme)
                            for _, child in ipairs(window.ContentFrame:GetChildren()) do
                                if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                                    self:RefreshUIElement(child, theme)
                                end
                            end
                        end
                    end
                end
            end
        end

        if _G.CensuraG.Taskbar and _G.CensuraG.Taskbar.Instance then
            if typeof(_G.CensuraG.Taskbar.Instance) == "table" and _G.CensuraG.Taskbar.Instance.Refresh then
                pcall(_G.CensuraG.Taskbar.Instance.Refresh, _G.CensuraG.Taskbar.Instance)
            end
        end
    end)

    _G.CensuraG.Logger:info("Refreshed all UI elements")
end

return RefreshManager
