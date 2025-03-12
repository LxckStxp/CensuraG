-- CensuraG/src/ui/WindowManager.lua (improved minimize animation and added SetSize)
local WindowManager = {}
WindowManager.__index = WindowManager

local Config = _G.CensuraG.Config

function WindowManager.new(title)
    local self = setmetatable({}, WindowManager)
    
    -- Create the window using the component
    if not _G.CensuraG.Components or not _G.CensuraG.Components.window then
        _G.CensuraG.Logger:error("Window component not loaded properly")
        return nil
    end
    
    local windowComponent = _G.CensuraG.Components.window(title)
    if not windowComponent then
        _G.CensuraG.Logger:error("Failed to create window component")
        return nil
    end
    
    -- Store the entire window component
    self.Window = windowComponent
    
    -- For compatibility, store direct references to commonly used properties
    self.Frame = windowComponent.Frame
    self.TitleBar = windowComponent.TitleBar
    self.TitleText = windowComponent.TitleText
    self.MinimizeButton = windowComponent.MinimizeButton
    self.ContentFrame = windowComponent.ContentFrame
    
    self.IsMinimized = false
    self.Title = title
    self.OriginalPosition = self.Frame.Position
    
    -- Connect minimize button to toggle method
    if self.MinimizeButton then
        self.MinimizeButton.MouseButton1Click:Connect(function()
            self:ToggleMinimize()
        end)
    end
    
    _G.CensuraG.Logger:info("Created window: " .. title)
    return self
end

function WindowManager:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    
    if self.IsMinimized then
        -- Store the current position before minimizing
        self.OriginalPosition = self.Frame.Position
        self.OriginalSize = self.Frame.Size
        
        -- Find corresponding taskbar button position
        local targetButton = nil
        local targetPosition = UDim2.new(0.5, 0, 1, -Config.Math.TaskbarHeight / 2)
        
        if _G.CensuraG.Taskbar and _G.CensuraG.Taskbar.Instance then
            -- Find the taskbar button for this window
            local windowIndex = nil
            for i, window in ipairs(_G.CensuraG.Windows) do
                if window == self then
                    windowIndex = i
                    break
                end
            end
            
            if windowIndex then
                -- Find the corresponding button in the taskbar
                for _, button in ipairs(_G.CensuraG.Taskbar.Instance.Buttons or {}) do
                    if button:GetAttribute("WindowIndex") == windowIndex then
                        targetButton = button
                        break
                    end
                end
            end
        end
        
        if targetButton then
            -- Calculate the position of the button in screen space
            local buttonPos = targetButton.AbsolutePosition
            local buttonSize = targetButton.AbsoluteSize
            
            -- Calculate the center of the button in screen space
            local buttonCenterX = buttonPos.X + buttonSize.X / 2
            local buttonCenterY = buttonPos.Y + buttonSize.Y / 2
            
            -- Calculate the target position relative to the screen
            local screenSize = game.Workspace.CurrentCamera.ViewportSize
            targetPosition = UDim2.new(
                buttonCenterX / screenSize.X, 
                0, 
                buttonCenterY / screenSize.Y, 
                0
            )
            
            _G.CensuraG.Logger:info("Minimizing window to button position: " .. 
                tostring(targetPosition.X.Scale) .. ", " .. tostring(targetPosition.Y.Scale))
        else
            _G.CensuraG.Logger:warn("No taskbar button found for window, using default position")
        end
        
        -- Minimize animation - move to the taskbar button position
        _G.CensuraG.AnimationManager:Tween(self.Frame, {
            Position = targetPosition,
            Size = UDim2.new(0, self.Frame.AbsoluteSize.X * 0.1, 0, self.Frame.AbsoluteSize.Y * 0.1),
            BackgroundTransparency = 0.9
        }, Config.Animations.FadeDuration)
        
        -- Delay making invisible to allow animation to complete
        task.delay(Config.Animations.FadeDuration, function()
            if self.IsMinimized then -- Check if still minimized
                self.Frame.Visible = false
            end
        end)
    else
        -- Make visible first before animating
        self.Frame.Visible = true
        
        -- Restore animation
        _G.CensuraG.AnimationManager:Tween(self.Frame, {
            Position = self.OriginalPosition or UDim2.fromOffset(100, 100),
            Size = self.OriginalSize or UDim2.fromOffset(Config.Math.DefaultWindowSize.X, Config.Math.DefaultWindowSize.Y),
            BackgroundTransparency = 0.15
        }, Config.Animations.SlideDuration)
    end
    
    -- Update taskbar
    if _G.CensuraG.TaskbarManager and _G.CensuraG.TaskbarManager.UpdateTaskbar then
        _G.CensuraG.TaskbarManager:UpdateTaskbar()
    end
    
    _G.CensuraG.Logger:info("Window " .. (self.IsMinimized and "minimized" or "restored") .. ": " .. self.Title)
end

function WindowManager:AddComponent(component)
    if component and component.Instance then
        component.Instance.Parent = self.ContentFrame
        component.Instance.LayoutOrder = #self.ContentFrame:GetChildren() - 3 -- Adjust for layout and padding
        _G.CensuraG.Logger:info("Added component to window")
    else
        _G.CensuraG.Logger:warn("Invalid component provided to window")
    end
end

function WindowManager:Refresh()
    _G.CensuraG.Methods:RefreshComponent("window", self)
    
    -- Also update the taskbar button for this window
    if _G.CensuraG.TaskbarManager and _G.CensuraG.TaskbarManager.UpdateTaskbar then
        _G.CensuraG.TaskbarManager:UpdateTaskbar()
    end
end

function WindowManager:GetTitle()
    return self.Title
end

-- Add SetSize method to delegate to the inner Window component
function WindowManager:SetSize(width, height)
    if self.Window and self.Window.SetSize then
        self.Window:SetSize(width, height)
        _G.CensuraG.Logger:info("Set window size to " .. width .. "x" .. height .. " for: " .. self.Title)
    else
        _G.CensuraG.Logger:error("Failed to set size: Window component missing SetSize method")
    end
end

return WindowManager
