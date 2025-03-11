-- CensuraG/src/components/window.lua
local Config = _G.CensuraG.Config

return function(title)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.fromOffset(Config.Math.DefaultWindowSize.X, Config.Math.DefaultWindowSize.Y)
    Frame.Position = UDim2.fromOffset(100, 100)
    Frame.BackgroundColor3 = theme.PrimaryColor
    Frame.BorderSizePixel = 0
    Frame.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ScreenGui")
    Frame.BackgroundTransparency = 1 -- Start hidden for animation
    
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
    
    -- Animation
    _G.CensuraG.AnimationManager:Tween(Frame, {BackgroundTransparency = 0, Position = UDim2.fromOffset(100, 100)}, animConfig.SlideDuration)
    
    local Window = {
        Frame = Frame,
        TitleBar = TitleBar,
        TitleText = TitleText,
        MinimizeButton = MinimizeButton,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("window", self)
        end
    }
    
    _G.CensuraG.Logger:info("Window created: " .. title)
    return Window
end
