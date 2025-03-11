-- CensuraG/src/Methods.lua
local Methods = {}
local Config = _G.CensuraG.Config

-- Create a new window with title
function Methods:CreateWindow(title)
    if not _G.CensuraG.WindowManager then
        _G.CensuraG.Logger:error("WindowManager not loaded, cannot create window")
        return nil
    end
    
    local window = _G.CensuraG.WindowManager.new(title)
    if not window then
        _G.CensuraG.Logger:error("Failed to create window")
        return nil
    end
    
    -- Add to global windows table
    _G.CensuraG.Windows = _G.CensuraG.Windows or {}
    table.insert(_G.CensuraG.Windows, window)
    
    -- Update taskbar if it exists
    if _G.CensuraG.TaskbarManager and _G.CensuraG.TaskbarManager.UpdateTaskbar then
        _G.CensuraG.TaskbarManager:UpdateTaskbar()
    end
    
    _G.CensuraG.Logger:info("Created window: " .. title)
    return window
end

-- Refresh a specific component
function Methods:RefreshComponent(component, instance)
    if _G.CensuraG.RefreshManager then
        _G.CensuraG.RefreshManager:RefreshComponent(component, instance)
    else
        _G.CensuraG.Logger:warn("RefreshManager not available, using basic refresh")
        
        -- Basic refresh implementation
        local theme = Config:GetTheme()
        local animConfig = Config.Animations
        
        -- Handle different component types
        if component == "window" then
            -- Refresh window component
            if typeof(instance) == "table" then
                if instance.Frame then
                    _G.CensuraG.AnimationManager:Tween(instance.Frame, {
                        BackgroundColor3 = theme.PrimaryColor,
                        BackgroundTransparency = 0.15
                    }, animConfig.FadeDuration)
                end
                
                if instance.TitleBar then
                    _G.CensuraG.AnimationManager:Tween(instance.TitleBar, {
                        BackgroundColor3 = theme.SecondaryColor,
                        BackgroundTransparency = 0.8
                    }, animConfig.FadeDuration)
                end
                
                if instance.TitleText then
                    _G.CensuraG.AnimationManager:Tween(instance.TitleText, {
                        TextColor3 = theme.TextColor,
                        TextSize = theme.TextSize
                    }, animConfig.FadeDuration)
                    instance.TitleText.Font = theme.Font
                end
                
                if instance.ContentFrame then
                    _G.CensuraG.AnimationManager:Tween(instance.ContentFrame, {
                        BackgroundColor3 = theme.PrimaryColor,
                        BackgroundTransparency = 0.3,
                        ScrollBarImageColor3 = theme.AccentColor
                    }, animConfig.FadeDuration)
                end
            end
        elseif component == "textlabel" then
            if typeof(instance) == "table" and instance.Label then
                _G.CensuraG.AnimationManager:Tween(instance.Label, {
                    TextColor3 = theme.TextColor,
                    TextSize = theme.TextSize
                }, animConfig.FadeDuration)
                instance.Label.Font = theme.Font
            end
        elseif component == "textbutton" then
            if typeof(instance) == "table" and instance.Instance then
                _G.CensuraG.AnimationManager:Tween(instance.Instance, {
                    BackgroundColor3 = theme.SecondaryColor,
                    TextColor3 = theme.TextColor,
                    TextSize = theme.TextSize
                }, animConfig.FadeDuration)
                instance.Instance.Font = theme.Font
            end
        elseif component == "switch" or component == "slider" or component == "dropdown" then
            -- These components have more complex refresh logic
            -- Basic implementation for core properties
            if typeof(instance) == "table" and instance.Instance then
                _G.CensuraG.AnimationManager:Tween(instance.Instance, {
                    BackgroundColor3 = theme.SecondaryColor,
                    BackgroundTransparency = 0.8
                }, animConfig.FadeDuration)
            end
        end
    end
end

-- Refresh all UI elements
function Methods:RefreshAll()
    if _G.CensuraG.RefreshManager then
        _G.CensuraG.RefreshManager:RefreshAll()
    else
        _G.CensuraG.Logger:warn("RefreshManager not available, using basic refresh all")
        
        local theme = Config:GetTheme()
        
        -- Refresh windows
        if _G.CensuraG.Windows then
            for _, window in ipairs(_G.CensuraG.Windows) do
                if window and typeof(window) == "table" then
                    self:RefreshComponent("window", window)
                    
                    -- Refresh content
                    if window.ContentFrame then
                        for _, child in ipairs(window.ContentFrame:GetChildren()) do
                            if child:GetAttribute("ComponentType") then
                                self:RefreshComponent(child:GetAttribute("ComponentType"), child)
                            end
                        end
                    end
                end
            end
        end
        
        -- Refresh taskbar
        if _G.CensuraG.Taskbar and _G.CensuraG.Taskbar.Instance then
            if typeof(_G.CensuraG.Taskbar.Instance) == "table" and _G.CensuraG.Taskbar.Instance.Refresh then
                _G.CensuraG.Taskbar.Instance:Refresh()
            elseif _G.CensuraG.TaskbarManager and _G.CensuraG.TaskbarManager.Refresh then
                _G.CensuraG.TaskbarManager:Refresh()
            end
        end
    end
end

-- Change the theme of all UI elements
function Methods:ChangeTheme(themeName)
    if Config.Themes[themeName] then
        Config.CurrentTheme = themeName
        self:RefreshAll()
        _G.CensuraG.Logger:info("Theme changed to: " .. themeName)
    else
        _G.CensuraG.Logger:error("Theme not found: " .. themeName)
    end
end

-- Create UI component shortcuts
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
