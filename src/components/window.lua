-- CensuraG/src/components/window.lua (updated with dynamic sizing)
local Config = _G.CensuraG.Config

return function(title)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = playerGui:FindFirstChild("ScreenGui") or Instance.new("ScreenGui", playerGui)
    screenGui.Name = "ScreenGui"

    -- Start with a minimum size for the window
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.fromOffset(Config.Math.DefaultWindowSize.X, Config.Math.DefaultWindowSize.Y)
    Frame.Position = UDim2.fromOffset(100, 100)
    Frame.BackgroundColor3 = theme.PrimaryColor
    Frame.BorderSizePixel = 0
    Frame.Parent = screenGui
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
    
    -- Add grid to window
    local Grid = _G.CensuraG.Components.grid(Frame)
    
    -- Create a UIListLayout to track the content size
    local GridPadding = Instance.new("UIPadding", Grid.Instance)
    GridPadding.PaddingTop = UDim.new(0, Config.Math.Padding)
    GridPadding.PaddingBottom = UDim.new(0, Config.Math.Padding)
    GridPadding.PaddingLeft = UDim.new(0, Config.Math.Padding)
    GridPadding.PaddingRight = UDim.new(0, Config.Math.Padding)
    
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
    
    -- Function to resize window based on content
    local function updateWindowSize()
        -- Get the content size from the grid layout
        local contentHeight = 0
        local contentWidth = 0
        
        -- Calculate based on children
        for _, child in ipairs(Grid.Instance:GetChildren()) do
            if child:IsA("GuiObject") and not child:IsA("UIGridLayout") and not child:IsA("UIPadding") then
                local childPos = child.Position
                local childSize = child.Size
                
                -- Convert to absolute size if using scale
                local absChildWidth = childSize.X.Scale * Grid.Instance.AbsoluteSize.X + childSize.X.Offset
                local absChildHeight = childSize.Y.Scale * Grid.Instance.AbsoluteSize.Y + childSize.Y.Offset
                
                -- Calculate position
                local absChildX = childPos.X.Scale * Grid.Instance.AbsoluteSize.X + childPos.X.Offset
                local absChildY = childPos.Y.Scale * Grid.Instance.AbsoluteSize.Y + childPos.Y.Offset
                
                -- Update max dimensions
                contentWidth = math.max(contentWidth, absChildX + absChildWidth)
                contentHeight = math.max(contentHeight, absChildY + absChildHeight)
            end
        end
        
        -- Use GridLayout's ContentSize if available
        if Grid.Layout.AbsoluteContentSize then
            contentWidth = math.max(contentWidth, Grid.Layout.AbsoluteContentSize.X)
            contentHeight = math.max(contentHeight, Grid.Layout.AbsoluteContentSize.Y)
        end
        
        -- Add padding
        contentWidth = contentWidth + 2 * Config.Math.Padding
        contentHeight = contentHeight + 2 * Config.Math.Padding
        
        -- Set minimum dimensions
        contentWidth = math.max(contentWidth, Config.Math.DefaultWindowSize.X)
        contentHeight = math.max(contentHeight, Config.Math.DefaultWindowSize.Y - 30) -- Subtract title bar height
        
        -- Update window size with animation
        local newSize = UDim2.new(0, contentWidth, 0, contentHeight + 30) -- Add title bar height
        _G.CensuraG.AnimationManager:Tween(Frame, {Size = newSize}, animConfig.FadeDuration)
    end
    
    -- Initialize animation
    _G.CensuraG.AnimationManager:Tween(Frame, {BackgroundTransparency = 0}, animConfig.FadeDuration)
    
    local Window = {
        Frame = Frame,
        TitleBar = TitleBar,
        TitleText = TitleText,
        MinimizeButton = MinimizeButton,
        Grid = Grid,
        AddComponent = function(self, component)
            self.Grid:AddComponent(component)
            -- Update size after a short delay to allow component to render
            task.delay(0.1, updateWindowSize)
        end,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("window", self)
            self.Grid:Refresh()
            updateWindowSize()
        end,
        UpdateSize = updateWindowSize -- Expose the update function
    }
    
    _G.CensuraG.Logger:info("Window created: " .. title)
    return Window
end
