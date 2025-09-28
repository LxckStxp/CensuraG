-- CensuraG/src/components/taskbar.lua (Glassmorphic Design)
local Config = _G.CensuraG.Config

return function()
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    
    -- Create main glassmorphic taskbar frame
    local Frame = Instance.new("Frame")
    Frame.Name = "Taskbar"
    Frame.Size = UDim2.new(1, 0, 0, Config.Math.TaskbarHeight)
    Frame.Position = UDim2.new(0, 0, 1, 0) -- Start off-screen
    Frame.BackgroundColor3 = theme.PrimaryColor
    Frame.BackgroundTransparency = theme.GlassTransparency or 0.1
    Frame.BorderSizePixel = 0
    Frame.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ScreenGui") or
                   game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("CensuraGScreenGui")
    
    -- Glassmorphic styling
    local Corner = Instance.new("UICorner", Frame)
    Corner.CornerRadius = UDim.new(0, 0) -- Sharp edges for taskbar
    
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = theme.BorderColor
    Stroke.Transparency = theme.BorderTransparency or 0.7
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    -- Top accent line
    local TopBorder = Instance.new("Frame", Frame)
    TopBorder.Name = "TopBorder"
    TopBorder.Size = UDim2.new(1, 0, 0, 1)
    TopBorder.Position = UDim2.new(0, 0, 0, 0)
    TopBorder.BackgroundColor3 = theme.AccentColor
    TopBorder.BackgroundTransparency = 0.3
    TopBorder.BorderSizePixel = 0
    TopBorder.ZIndex = 2
    
    -- Start Button
    local StartButton = Instance.new("TextButton", Frame)
    StartButton.Name = "StartButton"
    StartButton.Size = UDim2.new(0, 80, 1, -8)
    StartButton.Position = UDim2.new(0, 8, 0, 4)
    StartButton.BackgroundColor3 = theme.AccentColor
    StartButton.BackgroundTransparency = 0.8
    StartButton.BorderSizePixel = 0
    StartButton.Text = "Start"
    StartButton.TextColor3 = theme.TextColor
    StartButton.Font = theme.BoldFont or theme.Font
    StartButton.TextSize = theme.TextSize
    StartButton.AutoButtonColor = false
    
    local StartCorner = Instance.new("UICorner", StartButton)
    StartCorner.CornerRadius = UDim.new(0, 8)
    
    local StartStroke = Instance.new("UIStroke", StartButton)
    StartStroke.Color = theme.BorderColor
    StartStroke.Transparency = theme.BorderTransparency or 0.7
    StartStroke.Thickness = 1
    
    -- Start button hover effects
    StartButton.MouseEnter:Connect(function()
        _G.CensuraG.AnimationManager:Tween(StartButton, {
            BackgroundTransparency = 0.6
        }, 0.15)
    end)
    
    StartButton.MouseLeave:Connect(function()
        _G.CensuraG.AnimationManager:Tween(StartButton, {
            BackgroundTransparency = 0.8
        }, 0.15)
    end)
    
    -- Connect start button to desktop manager
    StartButton.MouseButton1Click:Connect(function()
        if _G.CensuraG.Desktop then
            _G.CensuraG.Desktop:ToggleStartMenu()
        end
    end)
    
    -- System tray area
    local SystemTray = Instance.new("Frame", Frame)
    SystemTray.Name = "SystemTray"
    SystemTray.Size = UDim2.new(0, 120, 1, -8)
    SystemTray.Position = UDim2.new(1, -128, 0, 4)
    SystemTray.BackgroundTransparency = 1
    
    -- Add button container for window buttons (adjusted for start button and system tray)
    local ButtonContainer = Instance.new("Frame", Frame)
    ButtonContainer.Name = "ButtonContainer"
    ButtonContainer.Size = UDim2.new(1, -220, 1, -10) -- Account for start button and system tray
    ButtonContainer.Position = UDim2.new(0, 95, 0, 5) -- Start after start button
    ButtonContainer.BackgroundTransparency = 1
    
    -- Add horizontal layout for buttons
    local ButtonLayout = Instance.new("UIListLayout", ButtonContainer)
    ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ButtonLayout.Padding = UDim.new(0, 5)
    
    -- Animation
    _G.CensuraG.AnimationManager:Tween(Frame, {
        Position = UDim2.new(0, 0, 1, -Config.Math.TaskbarHeight)
    }, animConfig.SlideDuration)
    
    -- Create a proper object with methods
    local Taskbar = {
        Frame = Frame,
        ButtonContainer = ButtonContainer,
        StartButton = StartButton,
        SystemTray = SystemTray,
        TopBorder = TopBorder,
        Stroke = Stroke,
        Refresh = function(self)
            local theme = Config:GetTheme()
            
            -- Main frame styling
            _G.CensuraG.AnimationManager:Tween(self.Frame, {
                BackgroundColor3 = theme.PrimaryColor,
                BackgroundTransparency = theme.GlassTransparency or 0.1
            }, animConfig.FadeDuration)
            
            -- Stroke styling
            _G.CensuraG.AnimationManager:Tween(self.Stroke, {
                Color = theme.BorderColor,
                Transparency = theme.BorderTransparency or 0.7
            }, animConfig.FadeDuration)
            
            -- Top border styling
            _G.CensuraG.AnimationManager:Tween(self.TopBorder, {
                BackgroundColor3 = theme.AccentColor
            }, animConfig.FadeDuration)
            
            -- Start button styling
            _G.CensuraG.AnimationManager:Tween(self.StartButton, {
                BackgroundColor3 = theme.AccentColor,
                TextColor3 = theme.TextColor
            }, animConfig.FadeDuration)
            
            self.StartButton.Font = theme.BoldFont or theme.Font
            self.StartButton.TextSize = theme.TextSize
        end
    }
    
    _G.CensuraG.Logger:info("Glassmorphic taskbar created")
    
    -- Return both the Frame and the Taskbar object
    return Frame, Taskbar
end
