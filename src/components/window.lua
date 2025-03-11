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
    Frame.BackgroundTransparency = 1
    
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
    TitleText.TextWrapped = true
    
    local MinimizeButton = Instance.new("TextButton", TitleBar)
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    MinimizeButton.Position = UDim2.new(1, -55, 0, 2)
    MinimizeButton.BackgroundColor3 = theme.AccentColor
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = theme.TextColor
    MinimizeButton.Font = theme.Font
    
    -- Dragging functionality
    local dragging = false
    local dragStartPos, frameStartPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartPos = input.Position
            frameStartPos = Frame.Position
        end
    end)
    
    TitleBar.InputEnded:Connect(function(input)
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
            _G.CensuraG.AnimationManager:Tween(Frame, {Position = newPos}, 0.1)
        end
    end)
    
    -- Add grid to window
    local Grid = _G.CensuraG.Components.grid(Frame)
    
    _G.CensuraG.AnimationManager:Tween(Frame, {BackgroundTransparency = 0, Position = UDim2.fromOffset(100, 100)}, animConfig.SlideDuration)
    
    local Window = {
        Frame = Frame,
        TitleBar = TitleBar,
        TitleText = TitleText,
        MinimizeButton = MinimizeButton,
        Grid = Grid,
        AddComponent = function(self, component)
            self.Grid:AddComponent(component)
        end,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("window", self)
            self.Grid:Refresh()
        end
    }
    
    _G.CensuraG.Logger:info("Window created: " .. title)
    return Window
end
