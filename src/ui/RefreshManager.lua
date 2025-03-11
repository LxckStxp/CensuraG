-- CensuraG/src/ui/RefreshManager.lua
local RefreshManager = {}
RefreshManager.__index = RefreshManager

function RefreshManager:Initialize()
    _G.CensuraG.Logger:info("RefreshManager initialized")
end

-- Refresh a specific component
function RefreshManager:RefreshComponent(component, instance)
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
                
                -- Set Font directly
                instance.TitleText.Font = theme.Font
            end
            
            if instance.MinimizeButton then
                _G.CensuraG.AnimationManager:Tween(instance.MinimizeButton, {
                    BackgroundColor3 = theme.AccentColor,
                    TextColor3 = theme.TextColor
                }, animConfig.FadeDuration)
                
                -- Set Font directly
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
                
                -- Set Font directly
                instance.Label.Font = theme.Font
            end
            
            if instance.TextShadow then
                _G.CensuraG.AnimationManager:Tween(instance.TextShadow, {
                    TextColor3 = theme.PrimaryColor,
                    TextSize = theme.TextSize
                }, animConfig.FadeDuration)
                
                -- Set Font directly
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
            
            -- Set Font directly
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
                
                -- Set Font directly
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
            
            -- Set Font directly
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
                
                -- Set Font directly
                instance.NameLabel.Font = theme.Font
            end
            
            if instance.ValueLabel then
                _G.CensuraG.AnimationManager:Tween(instance.ValueLabel, {
                    TextColor3 = theme.TextColor,
                    TextSize = theme.TextSize
                }, animConfig.FadeDuration)
                
                -- Set Font directly
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
                
                -- Set Font directly
                instance.SelectedText.Font = theme.Font
            end
            
            if instance.ArrowButton then
                _G.CensuraG.AnimationManager:Tween(instance.ArrowButton, {
                    BackgroundColor3 = theme.AccentColor,
                    TextColor3 = theme.TextColor
                }, animConfig.FadeDuration)
                
                -- Set Font directly
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
                        
                        -- Set Font directly
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
                
                -- Set Font directly
                instance.TitleLabel.Font = theme.Font
            end
        end
    end
    
    _G.CensuraG.Logger:info("Refreshed component: " .. component)
end

-- Refresh a single UI element based on its type
function RefreshManager:RefreshUIElement(element, theme)
    if not element or not theme then return end
    
    local animConfig = _G.CensuraG.Config.Animations
    
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
            }, animConfig.FadeDuration)
            
            -- Refresh children
            for _, child in ipairs(element:GetChildren()) do
                self:RefreshUIElement(child, theme)
            end
        end
    elseif element:IsA("TextLabel") then
        _G.CensuraG.AnimationManager:Tween(element, {
            TextColor3 = theme.TextColor,
            TextSize = theme.TextSize
        }, animConfig.FadeDuration)
        
        -- Set Font directly
        element.Font = theme.Font
    elseif element:IsA("TextButton") then
        _G.CensuraG.AnimationManager:Tween(element, {
            BackgroundColor3 = theme.SecondaryColor,
            TextColor3 = theme.TextColor,
            TextSize = theme.TextSize
        }, animConfig.FadeDuration)
        
        -- Set Font directly
        element.Font = theme.Font
        
        -- Refresh stroke if present
        for _, child in ipairs(element:GetChildren()) do
            if child:IsA("UIStroke") then
                _G.CensuraG.AnimationManager:Tween(child, {
                    Color = theme.AccentColor
                }, animConfig.FadeDuration)
            end
        end
    elseif element:IsA("ImageLabel") or element:IsA("ImageButton") then
        -- Only tween if it has a color property that should be themed
        local imagePart = element:GetAttribute("ImagePart")
        if imagePart == "Accent" then
            _G.CensuraG.AnimationManager:Tween(element, {
                ImageColor3 = theme.AccentColor
            }, animConfig.FadeDuration)
        elseif imagePart == "Primary" then
            _G.CensuraG.AnimationManager:Tween(element, {
                ImageColor3 = theme.PrimaryColor
            }, animConfig.FadeDuration)
        end
    elseif element:IsA("ScrollingFrame") then
        _G.CensuraG.AnimationManager:Tween(element, {
            BackgroundColor3 = theme.PrimaryColor,
            ScrollBarImageColor3 = theme.AccentColor
        }, animConfig.FadeDuration)
        
        -- Refresh children
        for _, child in ipairs(element:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                self:RefreshUIElement(child, theme)
            end
        end
    elseif element:IsA("UIStroke") then
        _G.CensuraG.AnimationManager:Tween(element, {
            Color = theme.BorderColor
        }, animConfig.FadeDuration)
    end
    
    -- For any container-like element, recursively refresh its children
    if element:IsA("GuiObject") and not element:IsA("TextLabel") and not element:IsA("TextButton") then
        for _, child in ipairs(element:GetChildren()) do
            self:RefreshUIElement(child, theme)
        end
    end
end

-- Refresh all UI elements
function RefreshManager:RefreshAll()
    local theme = _G.CensuraG.Config:GetTheme()
    _G.CensuraG.Logger:info("Refreshing all UI elements with theme: " .. _G.CensuraG.Config.CurrentTheme)
    
    -- 1. First, refresh all windows
    if _G.CensuraG.Windows then
        for i, window in ipairs(_G.CensuraG.Windows) do
            if window and typeof(window) == "table" then
                -- Refresh the window frame
                if window.Frame then
                    self:RefreshUIElement(window.Frame, theme)
                end
                
                -- Refresh content frame
                if window.ContentFrame then
                    self:RefreshUIElement(window.ContentFrame, theme)
                    
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

return RefreshManager
