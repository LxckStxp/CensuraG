-- CensuraG/src/components/taskbar.lua
local Config = _G.CensuraG.Config

return function()
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, Config.Math.TaskbarHeight)
    Frame.Position = UDim2.new(0, 0, 1, 0) -- Start off-screen
    Frame.BackgroundColor3 = theme.SecondaryColor
    Frame.BorderSizePixel = 0
    Frame.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ScreenGui")
    
    -- Animation
    _G.CensuraG.AnimationManager:Tween(Frame, {Position = UDim2.new(0, 0, 1, -Config.Math.TaskbarHeight)}, animConfig.SlideDuration)
    
    local Taskbar = {
        Frame = Frame,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("taskbar", self.Frame)
        end
    }
    
    _G.CensuraG.Logger:info("Taskbar created")
    return Taskbar.Frame -- Maintain compatibility with TaskbarManager
end
