-- CensuraG/src/ui/WindowManager.lua (updated for new window structure)
local WindowManager = {}
WindowManager.__index = WindowManager

local Config = _G.CensuraG.Config
local ScreenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))

function WindowManager.new(title)
    local self = setmetatable({}, WindowManager)
    
    -- Create the window using the component
    local windowComponent = _G.CensuraG.Components.window(title)
    
    -- Store the entire window component
    self.Window = windowComponent
    
    -- For compatibility, store direct references to commonly used properties
    self.Frame = windowComponent.Frame
    self.TitleBar = windowComponent.TitleBar
    self.TitleText = windowComponent.TitleText
    self.MinimizeButton = windowComponent.MinimizeButton
    self.ContentFrame = windowComponent.ContentFrame -- Use ContentFrame instead of Grid
    
    self.IsMinimized = false
    self.Title = title
    
    -- Connect minimize button to toggle method
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    _G.CensuraG.Logger:info("Created window: " .. title)
    return self
end

function WindowManager:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    if self.IsMinimized then
        _G.CensuraG.AnimationManager:Tween(self.Frame, {
            Position = UDim2.new(0, 0, 1, Config.Math.TaskbarHeight), -- Slide down to taskbar
            BackgroundTransparency = 0.8
        }, Config.Animations.FadeDuration)
    else
        _G.CensuraG.AnimationManager:Tween(self.Frame, {
            Position = UDim2.fromOffset(100, 100), -- Restore to original position
            BackgroundTransparency = 0.15
        }, Config.Animations.SlideDuration)
    end
    self.Frame.Visible = true -- Keep visible, animate transparency instead
    self:Refresh() -- Refresh the window state
    _G.CensuraG.TaskbarManager:UpdateTaskbar()
    _G.CensuraG.Logger:info("Window " .. (self.IsMinimized and "minimized" or "restored"))
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
end

function WindowManager:GetTitle()
    return self.Title
end

return WindowManager
