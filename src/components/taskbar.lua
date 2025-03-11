-- CensuraG/src/components/taskbar.lua (fixed for ButtonContainer)
local Config = _G.CensuraG.Config

return function()
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    
    -- Create main taskbar frame
    local Frame = Instance.new("Frame")
    Frame.Name = "Taskbar"
    Frame.Size = UDim2.new(1, 0, 0, Config.Math.TaskbarHeight)
    Frame.Position = UDim2.new(0, 0, 1, 0) -- Start off-screen
    Frame.BackgroundColor3 = theme.PrimaryColor
    Frame.BackgroundTransparency = 0.1 -- More solid than windows
    Frame.BorderSizePixel = 0
    Frame.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ScreenGui") or
                   game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("CensuraGScreenGui")
    
    -- Add corner radius (top corners only)
    local Corner = Instance.new("UICorner", Frame)
    Corner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)
    
    -- Add a top border highlight
    local TopBorder = Instance.new("Frame", Frame)
    TopBorder.Name = "TopBorder"
    TopBorder.Size = UDim2.new(1, 0, 0, 1)
    TopBorder.Position = UDim2.new(0, 0, 0, 0)
    TopBorder.BackgroundColor3 = theme.AccentColor
    TopBorder.BackgroundTransparency = 0.7
    TopBorder.BorderSizePixel = 0
    TopBorder.ZIndex = 2
    
    -- Add glow effect to top border
    local TopGlow = Instance.new("ImageLabel", Frame)
    TopGlow.Name = "TopGlow"
    TopGlow.Size = UDim2.new(1, 0, 0, 8)
    TopGlow.Position = UDim2.new(0, 0, 0, -4)
    TopGlow.BackgroundTransparency = 1
    TopGlow.Image = "rbxassetid://7912134082" -- Bloom image
    TopGlow.ImageColor3 = theme.AccentColor
    TopGlow.ImageTransparency = 0.8
    TopGlow.ScaleType = Enum.ScaleType.Slice
    TopGlow.SliceCenter = Rect.new(4, 4, 4, 4)
    
    -- Add inner shadow
    local Shadow = Instance.new("ImageLabel", Frame)
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 10, 1, 10)
    Shadow.Position = UDim2.new(0, -5, 0, -5)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://7912134082" -- Shadow image
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.6
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    Shadow.ZIndex = 0 -- Place behind taskbar
    
    -- Add a logo/title
    local Logo = Instance.new("TextLabel", Frame)
    Logo.Name = "Logo"
    Logo.Size = UDim2.new(0, 100, 1, 0)
    Logo.Position = UDim2.new(0, 10, 0, 0)
    Logo.BackgroundTransparency = 1
    Logo.Text = "CensuraG"
    Logo.TextColor3 = theme.TextColor
    Logo.Font = theme.Font
    Logo.TextSize = 16
    Logo.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Add button container for window buttons (IMPORTANT - this was missing)
    local ButtonContainer = Instance.new("Frame", Frame)
    ButtonContainer.Name = "ButtonContainer" -- Ensure it has the expected name
    ButtonContainer.Size = UDim2.new(1, -120, 1, -10)
    ButtonContainer.Position = UDim2.new(0, 110, 0, 5)
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
        Logo = Logo,
        TopBorder = TopBorder,
        Shadow = Shadow,
        Refresh = function(self)
            local theme = Config:GetTheme()
            
            _G.CensuraG.AnimationManager:Tween(self.Frame, {
                BackgroundColor3 = theme.PrimaryColor,
                BackgroundTransparency = 0.1
            }, animConfig.FadeDuration)
            
            _G.CensuraG.AnimationManager:Tween(self.TopBorder, {
                BackgroundColor3 = theme.AccentColor
            }, animConfig.FadeDuration)
            
            _G.CensuraG.AnimationManager:Tween(self.TopGlow, {
                ImageColor3 = theme.AccentColor
            }, animConfig.FadeDuration)
            
            _G.CensuraG.AnimationManager:Tween(self.Logo, {
                TextColor3 = theme.TextColor,
                Font = theme.Font
            }, animConfig.FadeDuration)
        end
    }
    
    _G.CensuraG.Logger:info("Taskbar created")
    
    -- Return both the Frame and the Taskbar object
    return Frame, Taskbar
end
