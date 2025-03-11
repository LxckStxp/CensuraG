-- CensuraG/src/ui/WindowManager.lua (fixed minimization)
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
        
        -- Minimize animation - move off screen
        _G.CensuraG.AnimationManager:Tween(self.Frame, {
            Position = UDim2.new(-1, 0, -1, 0), -- Move off-screen
            BackgroundTransparency = 0.8
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

return WindowManager
