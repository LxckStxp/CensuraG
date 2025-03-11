-- CensuraG/src/components/window.lua (fixed)
local Config = _G.CensuraG.Config

return function(title)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = playerGui:FindFirstChild("ScreenGui") or Instance.new("ScreenGui", playerGui)
    screenGui.Name = "ScreenGui"

    -- Start with a minimum size for the window
    local Frame = Instance.new("Frame")
    Frame.Name = "WindowFrame"
    Frame.Size = UDim2.fromOffset(Config.Math.DefaultWindowSize.X, Config.Math.DefaultWindowSize.Y)
    Frame.Position = UDim2.fromOffset(100, 100)
    Frame.BackgroundColor3 = theme.PrimaryColor
    Frame.BorderSizePixel = 0
    Frame.Parent = screenGui
    Frame.BackgroundTransparency = 1
    Frame.ClipsDescendants = false -- Allow child elements to overflow (important for dropdowns)
    
    local TitleBar = Instance.new("Frame", Frame)
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = theme.SecondaryColor
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 2 -- Ensure title bar is above content
    
    local TitleText = Instance.new("TextLabel", TitleBar)
    TitleText.Name = "TitleText"
    TitleText.Size = UDim2.new(1, -60, 1, 0)
    TitleText.Position = UDim2.new(0, 5, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = title
    TitleText.TextColor3 = theme.TextColor
    TitleText.Font = theme.Font
    TitleText.TextSize = theme.TextSize
    TitleText.TextWrapped = true
    TitleText.ZIndex = 2
    
    local MinimizeButton = Instance.new("TextButton", TitleBar)
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    MinimizeButton.Position = UDim2.new(1, -30, 0, 2)
    MinimizeButton.BackgroundColor3 = theme.AccentColor
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = theme.TextColor
    MinimizeButton.Font = theme.Font
    MinimizeButton.ZIndex = 2
    
    -- Create a content frame that will hold the grid
    local ContentFrame = Instance.new("Frame", Frame)
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, 0, 1, -30) -- Full width, height minus title bar
    ContentFrame.Position = UDim2.new(0, 0, 0, 30) -- Position below title bar
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ClipsDescendants = false -- Allow dropdowns to show outside
    
    -- Add grid to window
    local Grid = _G.CensuraG.Components.grid(ContentFrame)
    
    -- Track if we're currently resizing to prevent infinite loops
    local isResizing = false
    
    -- Function to update window size based on content
    local function updateWindowSize()
        if isResizing then return end
        isResizing = true
        
        -- Get the content height from the grid
        local contentHeight = Grid:GetContentHeight() or 0
        
        -- Calculate the new window size with padding
        local minHeight = Config.Math.DefaultWindowSize.Y
        local newHeight = math.max(minHeight, contentHeight + 30 + (2 * Config.Math.Padding))
        local newWidth = Config.Math.DefaultWindowSize.X
        
        -- Update window size
        _G.CensuraG.AnimationManager:Tween(Frame, {
            Size = UDim2.new(0, newWidth, 0, newHeight)
        }, animConfig.FadeDuration)
        
        task.delay(animConfig.FadeDuration, function()
            isResizing = false
        end)
    end
    
    -- Watch for content height changes
    ContentFrame:GetAttributeChangedSignal("ContentHeight"):Connect(updateWindowSize)
    
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
