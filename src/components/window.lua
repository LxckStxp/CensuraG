-- CensuraG/src/components/window.lua (updated for CensuraDev styling)
local Config = _G.CensuraG.Config

return function(title)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = playerGui:FindFirstChild("ScreenGui") or Instance.new("ScreenGui", playerGui)
    screenGui.Name = "ScreenGui"

    -- Main Window Frame
    local Frame = Instance.new("Frame")
    Frame.Name = "WindowFrame"
    Frame.Size = UDim2.fromOffset(Config.Math.DefaultWindowSize.X, Config.Math.DefaultWindowSize.Y)
    Frame.Position = UDim2.fromOffset(100, 100)
    Frame.BackgroundColor3 = theme.PrimaryColor
    Frame.BackgroundTransparency = 0.15 -- Slight transparency
    Frame.BorderSizePixel = 0
    Frame.Parent = screenGui
    Frame.ClipsDescendants = false -- Allow dropdowns to show outside

    -- Add corner radius
    local Corner = Instance.new("UICorner", Frame)
    Corner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)

    -- Add stroke for border
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = theme.BorderColor
    Stroke.Transparency = 0.6
    Stroke.Thickness = Config.Math.BorderThickness

    -- Title Bar
    local TitleBar = Instance.new("Frame", Frame)
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 32)
    TitleBar.BackgroundColor3 = theme.SecondaryColor
    TitleBar.BackgroundTransparency = 0.8
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 2

    local TitleCorner = Instance.new("UICorner", TitleBar)
    TitleCorner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)

    local TitleStroke = Instance.new("UIStroke", TitleBar)
    TitleStroke.Color = theme.BorderColor
    TitleStroke.Transparency = 0.6
    TitleStroke.Thickness = Config.Math.BorderThickness

    local TitleText = Instance.new("TextLabel", TitleBar)
    TitleText.Name = "TitleText"
    TitleText.Size = UDim2.new(1, -40, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = title
    TitleText.TextColor3 = theme.TextColor
    TitleText.Font = theme.Font
    TitleText.TextSize = theme.TextSize
    TitleText.TextWrapped = true
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.ZIndex = 2

    local MinimizeButton = Instance.new("TextButton", TitleBar)
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    MinimizeButton.Position = UDim2.new(1, -30, 0.5, -12.5)
    MinimizeButton.BackgroundColor3 = theme.AccentColor
    MinimizeButton.BackgroundTransparency = 0.7
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = theme.TextColor
    MinimizeButton.Font = theme.Font
    MinimizeButton.TextSize = 18
    MinimizeButton.ZIndex = 2

    local MinimizeCorner = Instance.new("UICorner", MinimizeButton)
    MinimizeCorner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)

    -- Content Container
    local ContentFrame = Instance.new("ScrollingFrame", Frame)
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Position = UDim2.new(0, 6, 0, 36)
    ContentFrame.Size = UDim2.new(1, -12, 1, -42)
    ContentFrame.BackgroundColor3 = theme.PrimaryColor
    ContentFrame.BackgroundTransparency = 0.3
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ScrollBarThickness = 1
    ContentFrame.ScrollBarImageColor3 = theme.AccentColor
    ContentFrame.ScrollBarImageTransparency = 0.3
    ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentFrame.ClipsDescendants = false

    local ContentCorner = Instance.new("UICorner", ContentFrame)
    ContentCorner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)

    -- List layout for components
    local ListLayout = Instance.new("UIListLayout", ContentFrame)
    ListLayout.Padding = UDim.new(0, Config.Math.ElementSpacing)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    -- Add padding
    local Padding = Instance.new("UIPadding", ContentFrame)
    Padding.PaddingTop = UDim.new(0, Config.Math.Padding)
    Padding.PaddingBottom = UDim.new(0, Config.Math.Padding)
    Padding.PaddingLeft = UDim.new(0, Config.Math.Padding)
    Padding.PaddingRight = UDim.new(0, Config.Math.Padding)

    -- Dragging functionality
    local dragging = false
    local dragStartPos, frameStartPos

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStartPos = input.Position
            frameStartPos = Frame.Position
            
            -- Hover effect
            _G.CensuraG.AnimationManager:Tween(TitleStroke, {Transparency = 0.4}, 0.2)
            _G.CensuraG.AnimationManager:Tween(TitleBar, {BackgroundTransparency = 0.7}, 0.2)
        end
    end)

    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            
            -- Return to normal
            _G.CensuraG.AnimationManager:Tween(TitleStroke, {Transparency = 0.6}, 0.2)
            _G.CensuraG.AnimationManager:Tween(TitleBar, {BackgroundTransparency = 0.8}, 0.2)
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
            _G.CensuraG.AnimationManager:Tween(Frame, {Position = newPos}, 0.05)
        end
    end)

    -- Hover effects for title bar
    TitleBar.MouseEnter:Connect(function()
        if not dragging then
            _G.CensuraG.AnimationManager:Tween(TitleStroke, {Transparency = 0.4}, 0.2)
            _G.CensuraG.AnimationManager:Tween(TitleBar, {BackgroundTransparency = 0.7}, 0.2)
        end
    end)

    TitleBar.MouseLeave:Connect(function()
        if not dragging then
            _G.CensuraG.AnimationManager:Tween(TitleStroke, {Transparency = 0.6}, 0.2)
            _G.CensuraG.AnimationManager:Tween(TitleBar, {BackgroundTransparency = 0.8}, 0.2)
        end
    end)

    -- Button hover effects
    MinimizeButton.MouseEnter:Connect(function()
        _G.CensuraG.AnimationManager:Tween(MinimizeButton, {BackgroundTransparency = 0.5}, 0.2)
    end)

    MinimizeButton.MouseLeave:Connect(function()
        _G.CensuraG.AnimationManager:Tween(MinimizeButton, {BackgroundTransparency = 0.7}, 0.2)
    end)

    -- Initialize animation
    Frame.BackgroundTransparency = 1
    _G.CensuraG.AnimationManager:Tween(Frame, {BackgroundTransparency = 0.15}, animConfig.FadeDuration)

    -- Window interface
    local Window = {
        Frame = Frame,
        TitleBar = TitleBar,
        TitleText = TitleText,
        MinimizeButton = MinimizeButton,
        ContentFrame = ContentFrame,
        AddComponent = function(self, component)
            if component and component.Instance then
                component.Instance.Parent = self.ContentFrame
                component.Instance.LayoutOrder = #self.ContentFrame:GetChildren() - 3 -- Adjust for layout and padding
                _G.CensuraG.Logger:info("Added component to window")
                
                -- Update canvas size (although AutomaticCanvasSize should handle this)
                task.delay(0.1, function()
                    self:UpdateSize()
                end)
            else
                _G.CensuraG.Logger:warn("Invalid component provided to window")
            end
        end,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("window", self)
        end,
        UpdateSize = function(self)
            -- Let AutomaticCanvasSize handle the content frame height
            -- But we could manually adjust if needed
        end,
        GetTitle = function(self)
            return title
        end
    }

    _G.CensuraG.Logger:info("Window created: " .. title)
    return Window
end
