-- CensuraG/src/Methods.lua (revised to fix Font tweening)
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

-- CensuraG/src/Methods.lua (update the RefreshAll method)
function Methods:RefreshAll()
    local theme = _G.CensuraG.Config:GetTheme()
    _G.CensuraG.Logger:info("Refreshing all UI elements with theme: " .. _G.CensuraG.Config.CurrentTheme)
    
    -- 1. First, refresh all windows
    if _G.CensuraG.Windows then
        for i, window in ipairs(_G.CensuraG.Windows) do
            if window and typeof(window) == "table" then
                -- Refresh the window frame
                if window.Frame then
                    _G.CensuraG.AnimationManager:Tween(window.Frame, {
                        BackgroundColor3 = theme.PrimaryColor,
                        BackgroundTransparency = 0.15
                    }, _G.CensuraG.Config.Animations.FadeDuration)
                    
                    -- Update window border/stroke
                    for _, child in ipairs(window.Frame:GetChildren()) do
                        if child:IsA("UIStroke") then
                            _G.CensuraG.AnimationManager:Tween(child, {
                                Color = theme.BorderColor
                            }, _G.CensuraG.Config.Animations.FadeDuration)
                        end
                    end
                end
                
                -- Refresh title bar
                if window.TitleBar then
                    _G.CensuraG.AnimationManager:Tween(window.TitleBar, {
                        BackgroundColor3 = theme.SecondaryColor,
                        BackgroundTransparency = 0.8
                    }, _G.CensuraG.Config.Animations.FadeDuration)
                    
                    -- Update title bar border/stroke
                    for _, child in ipairs(window.TitleBar:GetChildren()) do
                        if child:IsA("UIStroke") then
                            _G.CensuraG.AnimationManager:Tween(child, {
                                Color = theme.BorderColor
                            }, _G.CensuraG.Config.Animations.FadeDuration)
                        end
                    end
                end
                
                -- Refresh title text
                if window.TitleText then
                    _G.CensuraG.AnimationManager:Tween(window.TitleText, {
                        TextColor3 = theme.TextColor,
                        TextSize = theme.TextSize
                    }, _G.CensuraG.Config.Animations.FadeDuration)
                    
                    -- Set Font directly
                    window.TitleText.Font = theme.Font
                end
                
                -- Refresh minimize button
                if window.MinimizeButton then
                    _G.CensuraG.AnimationManager:Tween(window.MinimizeButton, {
                        BackgroundColor3 = theme.AccentColor,
                        TextColor3 = theme.TextColor
                    }, _G.CensuraG.Config.Animations.FadeDuration)
                    
                    -- Set Font directly
                    window.MinimizeButton.Font = theme.Font
                end
                
                -- Refresh content frame
                if window.ContentFrame then
                    _G.CensuraG.AnimationManager:Tween(window.ContentFrame, {
                        BackgroundColor3 = theme.PrimaryColor,
                        BackgroundTransparency = 0.3,
                        ScrollBarImageColor3 = theme.AccentColor
                    }, _G.CensuraG.Config.Animations.FadeDuration)
                    
                    -- Refresh all components inside content frame
                    for _, child in ipairs(window.ContentFrame:GetChildren()) do
                        -- Skip UIListLayout and UIPadding
                        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                            self:RefreshUIElement(child, theme)
                        end
                    end
                end
            end
        end
    end
    
    -- 2. Refresh taskbar
    if _G.CensuraG.Taskbar and _G.CensuraG.Taskbar.Instance then
        if typeof(_G.CensuraG.Taskbar.Instance) == "table" and _G.CensuraG.Taskbar.Instance.Refresh then
            _G.CensuraG.Taskbar.Instance:Refresh()
        elseif _G.CensuraG.TaskbarManager and _G.CensuraG.TaskbarManager.Refresh then
            _G.CensuraG.TaskbarManager:Refresh()
        end
    end
    
    _G.CensuraG.Logger:info("Refreshed all UI elements")
end

-- New helper method to refresh any UI element based on its type
function Methods:RefreshUIElement(element, theme)
    if not element or not theme then return end
    
    -- Check element type and refresh accordingly
    if element:IsA("Frame") then
        -- Check if this is a container for a custom component
        local componentType = element:GetAttribute("ComponentType")
        if componentType then
            -- Use the RefreshComponent method to refresh this component
            self:RefreshComponent(componentType, element)
        else
            -- Generic frame refresh
            _G.CensuraG.AnimationManager:Tween(element, {
                BackgroundColor3 = theme.SecondaryColor,
                BackgroundTransparency = 0.8
            }, _G.CensuraG.Config.Animations.FadeDuration)
            
            -- Refresh children
            for _, child in ipairs(element:GetChildren()) do
                self:RefreshUIElement(child, theme)
            end
        end
    elseif element:IsA("TextLabel") then
        _G.CensuraG.AnimationManager:Tween(element, {
            TextColor3 = theme.TextColor,
            TextSize = theme.TextSize
        }, _G.CensuraG.Config.Animations.FadeDuration)
        
        -- Set Font directly
        element.Font = theme.Font
    elseif element:IsA("TextButton") then
        _G.CensuraG.AnimationManager:Tween(element, {
            BackgroundColor3 = theme.SecondaryColor,
            TextColor3 = theme.TextColor,
            TextSize = theme.TextSize
        }, _G.CensuraG.Config.Animations.FadeDuration)
        
        -- Set Font directly
        element.Font = theme.Font
        
        -- Refresh stroke if present
        for _, child in ipairs(element:GetChildren()) do
            if child:IsA("UIStroke") then
                _G.CensuraG.AnimationManager:Tween(child, {
                    Color = theme.AccentColor
                }, _G.CensuraG.Config.Animations.FadeDuration)
            end
        end
    elseif element:IsA("ImageLabel") or element:IsA("ImageButton") then
        -- Only tween if it has a color property that should be themed
        local imagePart = element:GetAttribute("ImagePart")
        if imagePart == "Accent" then
            _G.CensuraG.AnimationManager:Tween(element, {
                ImageColor3 = theme.AccentColor
            }, _G.CensuraG.Config.Animations.FadeDuration)
        elseif imagePart == "Primary" then
            _G.CensuraG.AnimationManager:Tween(element, {
                ImageColor3 = theme.PrimaryColor
            }, _G.CensuraG.Config.Animations.FadeDuration)
        end
    elseif element:IsA("ScrollingFrame") then
        _G.CensuraG.AnimationManager:Tween(element, {
            BackgroundColor3 = theme.PrimaryColor,
            ScrollBarImageColor3 = theme.AccentColor
        }, _G.CensuraG.Config.Animations.FadeDuration)
        
        -- Refresh children
        for _, child in ipairs(element:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                self:RefreshUIElement(child, theme)
            end
        end
    elseif element:IsA("UIStroke") then
        _G.CensuraG.AnimationManager:Tween(element, {
            Color = theme.BorderColor
        }, _G.CensuraG.Config.Animations.FadeDuration)
    end
    
    -- For any container-like element, recursively refresh its children
    if element:IsA("GuiObject") and not element:IsA("TextLabel") and not element:IsA("TextButton") then
        for _, child in ipairs(element:GetChildren()) do
            self:RefreshUIElement(child, theme)
        end
    end
end

return Methods
