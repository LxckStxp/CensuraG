-- CensuraG/src/components/window.lua
local Config = _G.CensuraG.Config

return function(title)
    local theme = Config:GetTheme()
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.fromOffset(Config.Math.DefaultWindowSize.X, Config.Math.DefaultWindowSize.Y)
    Frame.Position = UDim2.fromOffset(-Config.Math.DefaultWindowSize.X, 100) -- Start off-screen
    Frame.BackgroundColor3 = theme.PrimaryColor
    Frame.BorderSizePixel = 0
    Frame.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ScreenGui")
    
    local TitleBar = Instance.new("Frame", Frame)
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = theme.SecondaryColor
    TitleBar.BorderSizePixel = 0
    
    local TitleText = Instance.new("TextLabel", TitleBar)
    TitleText.Size = UDim2.new(1, -60, 1, 0)
    TitleText.Position = UDim2.new(0, 5, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = title
    TitleText.TextColor3 = theme.TextColor
    TitleText.Font = theme.Font
    TitleText.TextSize = theme.TextSize
    
    local MinimizeButton = Instance.new("TextButton", TitleBar)
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    MinimizeButton.Position = UDim2.new(1, -55, 0, 2)
    MinimizeButton.BackgroundColor3 = theme.AccentColor
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = theme.TextColor
    MinimizeButton.Font = theme.Font
    
    -- Slide-in animation
    _G.CensuraG.AnimationManager:Tween(Frame, {
        Position = UDim2.fromOffset(100, 100)
    }, Config.Animations.SlideDuration)
    
    return {Frame = Frame, TitleText = TitleText, MinimizeButton = MinimizeButton}
end
