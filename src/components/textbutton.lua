-- CensuraG/src/components/textbutton.lua (enhanced for consistent styling)
local Config = _G.CensuraG.Config

return function(parent, text, callback)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    
    -- Glassmorphic Container Frame
    local ButtonFrame = Instance.new("Frame", parent)
    ButtonFrame.Size = UDim2.new(1, -12, 0, 36) -- Slightly taller for modern look
    ButtonFrame.BackgroundColor3 = theme.SecondaryColor
    ButtonFrame.BackgroundTransparency = theme.GlassTransparency or 0.8
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame:SetAttribute("ComponentType", "textbutton") -- For refresh system
    
    -- Glassmorphic corner radius
    local Corner = Instance.new("UICorner", ButtonFrame)
    Corner.CornerRadius = UDim.new(0, 12) -- More rounded for glassmorphic look
    
    -- Glassmorphic stroke
    local Stroke = Instance.new("UIStroke", ButtonFrame)
    Stroke.Color = theme.BorderColor
    Stroke.Transparency = theme.BorderTransparency or 0.7
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    -- Glassmorphic button (slightly smaller than frame)
    local Button = Instance.new("TextButton", ButtonFrame)
    Button.Size = UDim2.new(1, -4, 1, -4)
    Button.Position = UDim2.new(0, 2, 0, 2)
    Button.BackgroundColor3 = theme.SecondaryColor
    Button.BackgroundTransparency = (theme.GlassTransparency or 0.8) + 0.1 -- Slightly more transparent than frame
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = theme.TextColor
    Button.Font = theme.Font
    Button.TextSize = theme.TextSize
    Button.AutoButtonColor = false -- We'll handle hover effects manually
    Button.ClipsDescendants = true -- For ripple effect if added later
    
    -- Glassmorphic inner corner radius
    local ButtonCorner = Instance.new("UICorner", Button)
    ButtonCorner.CornerRadius = UDim.new(0, 11) -- Match glassmorphic styling
    
    -- Add text shadow for depth
    local TextShadow = Instance.new("TextLabel", Button)
    TextShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    TextShadow.Position = UDim2.new(0.5, 1, 0.5, 1)
    TextShadow.Size = UDim2.new(1, 0, 1, 0)
    TextShadow.BackgroundTransparency = 1
    TextShadow.Text = text
    TextShadow.TextColor3 = theme.PrimaryColor
    TextShadow.TextTransparency = 0.8
    TextShadow.Font = theme.Font
    TextShadow.TextSize = theme.TextSize
    TextShadow.ZIndex = Button.ZIndex - 1
    
    -- Add a subtle glow effect
    local Glow = Instance.new("ImageLabel", ButtonFrame)
    Glow.Name = "Glow"
    Glow.BackgroundTransparency = 1
    Glow.Position = UDim2.new(0, -15, 0, -15)
    Glow.Size = UDim2.new(1, 30, 1, 30)
    Glow.ZIndex = ButtonFrame.ZIndex - 1
    Glow.Image = "rbxassetid://7912134082" -- Bloom image
    Glow.ImageColor3 = theme.AccentColor
    Glow.ImageTransparency = 0.9
    Glow.ScaleType = Enum.ScaleType.Slice
    Glow.SliceCenter = Rect.new(10, 10, 10, 10)
    
    -- Glassmorphic hover and click effects
    Button.MouseEnter:Connect(function()
        local hoverTransparency = (theme.BorderTransparency or 0.7) * 0.5
        local hoverFrameTransparency = (theme.GlassTransparency or 0.8) * 0.8
        local hoverButtonTransparency = hoverFrameTransparency + 0.1
        
        _G.CensuraG.AnimationManager:Tween(Stroke, {
            Transparency = hoverTransparency,
            Color = theme.AccentColor
        }, 0.15)
        _G.CensuraG.AnimationManager:Tween(ButtonFrame, {BackgroundTransparency = hoverFrameTransparency}, 0.15)
        _G.CensuraG.AnimationManager:Tween(Button, {
            BackgroundTransparency = hoverButtonTransparency,
            TextColor3 = theme.AccentColor
        }, 0.15)
        _G.CensuraG.AnimationManager:Tween(Glow, {ImageTransparency = 0.8}, 0.15)
    end)
    
    Button.MouseLeave:Connect(function()
        _G.CensuraG.AnimationManager:Tween(Stroke, {
            Transparency = theme.BorderTransparency or 0.7,
            Color = theme.BorderColor
        }, 0.15)
        _G.CensuraG.AnimationManager:Tween(ButtonFrame, {BackgroundTransparency = theme.GlassTransparency or 0.8}, 0.15)
        _G.CensuraG.AnimationManager:Tween(Button, {
            BackgroundTransparency = (theme.GlassTransparency or 0.8) + 0.1,
            TextColor3 = theme.TextColor
        }, 0.15)
        _G.CensuraG.AnimationManager:Tween(Glow, {ImageTransparency = 0.9}, 0.15)
    end)
    
    Button.MouseButton1Down:Connect(function()
        _G.CensuraG.AnimationManager:Tween(ButtonFrame, {BackgroundTransparency = 0.6}, 0.1)
        _G.CensuraG.AnimationManager:Tween(Button, {BackgroundTransparency = 0.7}, 0.1)
        _G.CensuraG.AnimationManager:Tween(Stroke, {Transparency = 0.1}, 0.1)
        -- Use explicit UDim2 values for size change
        _G.CensuraG.AnimationManager:Tween(ButtonFrame, {Size = UDim2.new(1, -16, 0, 30)}, 0.1)
        -- Move the text down slightly for press effect
        _G.CensuraG.AnimationManager:Tween(Button, {Position = UDim2.new(0, 2, 0, 3)}, 0.1)
    end)
    
    Button.MouseButton1Up:Connect(function()
        _G.CensuraG.AnimationManager:Tween(ButtonFrame, {BackgroundTransparency = 0.7}, 0.2)
        _G.CensuraG.AnimationManager:Tween(Button, {BackgroundTransparency = 0.8}, 0.2)
        _G.CensuraG.AnimationManager:Tween(Stroke, {Transparency = 0.2}, 0.2)
        _G.CensuraG.AnimationManager:Tween(ButtonFrame, {Size = UDim2.new(1, -12, 0, 32)}, 0.2)
        _G.CensuraG.AnimationManager:Tween(Button, {Position = UDim2.new(0, 2, 0, 2)}, 0.2)
        
        if callback then callback() end
    end)
    
    -- Add ripple effect on click
    Button.MouseButton1Down:Connect(function(x, y)
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.Parent = Button
        ripple.BackgroundColor3 = theme.TextColor
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        
        -- Create circle using UICorner
        local rippleCorner = Instance.new("UICorner", ripple)
        rippleCorner.CornerRadius = UDim.new(1, 0)
        
        -- Position the ripple at the mouse position
        local mousePos = game:GetService("UserInputService"):GetMouseLocation()
        local buttonPos = Button.AbsolutePosition
        local relativePos = Vector2.new(mousePos.X - buttonPos.X, mousePos.Y - buttonPos.Y)
        
        ripple.Position = UDim2.new(0, relativePos.X - 5, 0, relativePos.Y - 5)
        ripple.Size = UDim2.new(0, 10, 0, 10)
        
        -- Animate the ripple
        _G.CensuraG.AnimationManager:Tween(ripple, {
            Size = UDim2.new(0, Button.AbsoluteSize.X * 2, 0, Button.AbsoluteSize.X * 2),
            Position = UDim2.new(0, relativePos.X - Button.AbsoluteSize.X, 0, relativePos.Y - Button.AbsoluteSize.X),
            BackgroundTransparency = 1
        }, 0.5)
        
        -- Clean up the ripple after animation
        game:GetService("Debris"):AddItem(ripple, 0.5)
    end)
    
    local TextButton = {
        Instance = ButtonFrame,
        Button = Button,
        TextShadow = TextShadow,
        Stroke = Stroke,
        Glow = Glow,
        SetText = function(self, newText)
            self.Button.Text = newText
            self.TextShadow.Text = newText
        end,
        SetEnabled = function(self, enabled)
            self.Button.Active = enabled
            
            if enabled then
                self.Stroke.Color = theme.AccentColor
                self.Button.TextColor3 = theme.TextColor
                self.Button.BackgroundTransparency = 0.9
                self.Instance.BackgroundTransparency = 0.8
                self.Glow.ImageTransparency = 0.9
            else
                self.Stroke.Color = theme.DisabledColor
                self.Button.TextColor3 = theme.SecondaryTextColor
                self.Button.BackgroundTransparency = 0.95
                self.Instance.BackgroundTransparency = 0.9
                self.Glow.ImageTransparency = 0.95
            end
        end,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("textbutton", self)
        end
    }
    
    _G.CensuraG.Logger:info("TextButton created with text: " .. text)
    return TextButton
end
