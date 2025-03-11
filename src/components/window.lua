-- CensuraG/src/components/window.lua
local Config = _G.CensuraG.Config

return function(title)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.fromOffset(Config.WindowSize.X, Config.WindowSize.Y)
    Frame.Position = UDim2.fromOffset(100, 100)
    Frame.BackgroundColor3 = Config.Theme.PrimaryColor
    Frame.BorderSizePixel = 0
    Frame.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ScreenGui")
    
    local TitleBar = Instance.new("Frame", Frame)
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Config.Theme.SecondaryColor
    TitleBar.BorderSizePixel = 0
    
    local TitleText = Instance.new("TextLabel", TitleBar)
    TitleText.Size = UDim2.new(1, -60, 1, 0)
    TitleText.Position = UDim2.new(0, 5, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = title
    TitleText.TextColor3 = Config.Theme.TextColor
    TitleText.Font = Config.Theme.Font
    TitleText.TextSize = 14
    
    local MinimizeButton = Instance.new("TextButton", TitleBar)
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    MinimizeButton.Position = UDim2.new(1, -55, 0, 2)
    MinimizeButton.BackgroundColor3 = Config.Theme.AccentColor
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = Config.Theme.TextColor
    MinimizeButton.Font = Config.Theme.Font
    
    return {Frame = Frame, TitleText = TitleText, MinimizeButton = MinimizeButton}
end
