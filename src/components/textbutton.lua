-- CensuraG/src/components/textbutton.lua (updated for CensuraDev styling)
local Config = _G.CensuraG.Config

return function(parent, text, callback)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    
    local Button = Instance.new("TextButton", parent)
    Button.Size = UDim2.new(1, -12, 0, 32)
    Button.BackgroundColor3 = theme.SecondaryColor
    Button.BackgroundTransparency = 0.8 -- Match CensuraDev style
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = theme.TextColor
    Button.Font = theme.Font
    Button.TextSize = theme.TextSize
    Button.AutoButtonColor = false -- We'll handle hover effects manually
    Button.ClipsDescendants = true -- For ripple effect if added later
    
    -- Add corner radius
    local Corner = Instance.new("UICorner", Button)
    Corner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)
    
    -- Add stroke
    local Stroke = Instance.new("UIStroke", Button)
    Stroke.Color = theme.AccentColor
    Stroke.Transparency = 0.6
    Stroke.Thickness = Config.Math.BorderThickness
    
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
    
    -- Hover and click effects
    Button.MouseEnter:Connect(function()
        _G.CensuraG.AnimationManager:Tween(Stroke, {Transparency = 0.2}, 0.2)
        _G.CensuraG.AnimationManager:Tween(Button, {BackgroundTransparency = 0.7}, 0.2)
    end)
    
    Button.MouseLeave:Connect(function()
        _G.CensuraG.AnimationManager:Tween(Stroke, {Transparency = 0.6}, 0.2)
        _G.CensuraG.AnimationManager:Tween(Button, {BackgroundTransparency = 0.8}, 0.2)
    end)
    
    Button.MouseButton1Down:Connect(function()
        _G.CensuraG.AnimationManager:Tween(Button, {BackgroundTransparency = 0.6}, 0.1)
        _G.CensuraG.AnimationManager:Tween(Stroke, {Transparency = 0.1}, 0.1)
        _G.CensuraG.AnimationManager:Tween(Button, {Size = Button.Size * 0.95}, 0.1)
    end)
    
    Button.MouseButton1Up:Connect(function()
        _G.CensuraG.AnimationManager:Tween(Button, {BackgroundTransparency = 0.7}, 0.2)
        _G.CensuraG.AnimationManager:Tween(Stroke, {Transparency = 0.2}, 0.2)
        _G.CensuraG.AnimationManager:Tween(Button, {Size = UDim2.new(1, -12, 0, 32)}, 0.2)
        if callback then callback() end
    end)
    
    local TextButton = {
        Instance = Button,
        TextShadow = TextShadow,
        Stroke = Stroke,
        SetText = function(self, newText)
            self.Instance.Text = newText
            self.TextShadow.Text = newText
        end,
        SetEnabled = function(self, enabled)
            self.Instance.Active = enabled
            
            if enabled then
                self.Stroke.Color = theme.AccentColor
                self.Instance.TextColor3 = theme.TextColor
                self.Instance.BackgroundTransparency = 0.8
            else
                self.Stroke.Color = theme.DisabledColor
                self.Instance.TextColor3 = theme.SecondaryTextColor
                self.Instance.BackgroundTransparency = 0.9
            end
        end,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("textbutton", self.Instance)
        end
    }
    
    _G.CensuraG.Logger:info("TextButton created with text: " .. text)
    return TextButton
end
