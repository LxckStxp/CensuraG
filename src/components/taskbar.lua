-- CensuraG/src/components/taskbar.lua
local Config = _G.CensuraG.Config

return function()
    local theme = Config:GetTheme()
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, Config.Math.TaskbarHeight)
    Frame.Position = UDim2.new(0, 0, 1, -Config.Math.TaskbarHeight)
    Frame.BackgroundColor3 = theme.SecondaryColor
    Frame.BorderSizePixel = 0
    Frame.BackgroundTransparency = 1 -- Start transparent
    Frame.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ScreenGui")
    
    -- Fade-in animation
    _G.CensuraG.AnimationManager:Tween(Frame, {
        BackgroundTransparency = 0
    }, Config.Animations.FadeDuration)
    
    return Frame
end
