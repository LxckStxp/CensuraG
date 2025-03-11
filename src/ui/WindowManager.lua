-- CensuraG/src/ui/WindowManager.lua
local WindowManager = {}
WindowManager.__index = WindowManager

local Config = _G.CensuraG.Config
local ScreenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))

function WindowManager.new(title)
    local self = setmetatable({}, WindowManager)
    
    -- Create the window using the component and store the full table
    self.Window = _G.CensuraG.Components.window(title)
    self.Frame = self.Window.Frame -- Extract the Frame instance for compatibility
    self.IsMinimized = false
    
    -- Connect minimize button to toggle method
    self.Window.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    -- Dragging functionality (delegate to Window's dragging logic)
    local dragging = false
    local dragStartPos, frameStartPos
    self.Window.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartPos = input.Position
            frameStartPos = self.Frame.Position
        end
    end)
    
    self.Window.TitleBar.InputEnded:Connect(function(input)
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
    self.Window:Refresh() -- Refresh the window state
    _G.CensuraG.TaskbarManager:UpdateTaskbar()
    _G.CensuraG.Logger:info("Window " .. (self.IsMinimized and "minimized" or "restored"))
end

function WindowManager:AddComponent(component)
    self.Window:AddComponent(component)
end

function WindowManager:Refresh()
    self.Window:Refresh()
end

return WindowManager
