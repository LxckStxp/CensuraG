-- CensuraG/src/ui/WindowManager.lua
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
    self.Grid = windowComponent.Grid
    
    self.IsMinimized = false
    self.Title = title
    
    -- Connect minimize button to toggle method
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    -- Dragging functionality
    local dragging = false
    local dragStartPos, frameStartPos
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartPos = input.Position
            frameStartPos = self.Frame.Position
        end
    end)
    
    self.TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStartPos
            local newPos = UDim2.new(
                frameStartPos.X.Scale,
                frameStartPos.X.Offset + delta.X,
                frameStartPos.Y.Scale,
                frameStartPos.Y.Offset + delta.Y
            )
            _G.CensuraG.AnimationManager:Tween(self.Frame, {Position = newPos}, 0.1)
        end
    end)
    
    _G.CensuraG.Logger:info("Created window: " .. title)
    return self
end

function WindowManager:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    if self.IsMinimized then
        _G.CensuraG.AnimationManager:Tween(self.Frame, {
            Position = UDim2.new(0, 0, 1, Config.Math.TaskbarHeight), -- Slide down to taskbar
            Transparency = 0.8
        }, Config.Animations.FadeDuration)
    else
        _G.CensuraG.AnimationManager:Tween(self.Frame, {
            Position = UDim2.fromOffset(100, 100), -- Restore to original position
            Transparency = 0
        }, Config.Animations.SlideDuration)
    end
    self.Frame.Visible = true -- Keep visible, animate transparency instead
    self:Refresh() -- Refresh the window state
    _G.CensuraG.TaskbarManager:UpdateTaskbar()
    _G.CensuraG.Logger:info("Window " .. (self.IsMinimized and "minimized" or "restored"))
end

function WindowManager:AddComponent(component)
    if self.Grid then
        self.Grid:AddComponent(component)
    else
        _G.CensuraG.Logger:warn("Grid not found in window")
    end
end

function WindowManager:Refresh()
    _G.CensuraG.Methods:RefreshComponent("window", self)
    if self.Grid then
        self.Grid:Refresh()
    end
end

function WindowManager:GetTitle()
    return self.Title
end

return WindowManager
