-- CensuraG/src/ui/WindowManager.lua
local WindowManager = {}
WindowManager.__index = WindowManager

local Config = _G.CensuraG.Config
local ScreenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))

function WindowManager.new(title)
    local self = setmetatable({}, WindowManager)
    
    self.Frame = _G.CensuraG.Components.window(title)
    self.IsMinimized = false
    
    self.Frame.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    _G.CensuraG.Logger:info("Created window: " .. title)
    return self
end

function WindowManager:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    if self.IsMinimized then
        _G.CensuraG.AnimationManager:Tween(self.Frame.Frame, {
            Position = UDim2.new(0, 0, 1, Config.Math.TaskbarHeight), -- Slide down to taskbar
            Transparency = 0.8
        }, Config.Animations.FadeDuration)
    else
        _G.CensuraG.AnimationManager:Tween(self.Frame.Frame, {
            Position = UDim2.fromOffset(100, 100), -- Restore to original position
            Transparency = 0
        }, Config.Animations.SlideDuration)
    end
    self.Frame.Frame.Visible = true -- Keep visible, animate transparency instead
    _G.CensuraG.TaskbarManager:UpdateTaskbar()
    _G.CensuraG.Logger:info("Window " .. (self.IsMinimized and "minimized" or "restored"))
end

return WindowManager
