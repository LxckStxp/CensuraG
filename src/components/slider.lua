-- CensuraG/src/components/slider.lua (updated return and enhancements)
local Config = _G.CensuraG.Config

return function(parent, name, min, max, default, callback)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    
    local SliderFrame = Instance.new("Frame", parent)
    SliderFrame.Size = UDim2.new(0, 150, 0, 40) -- Increased height for labels
    SliderFrame.BackgroundColor3 = theme.PrimaryColor
    SliderFrame.BorderSizePixel = 0
    SliderFrame.BackgroundTransparency = 1
    
    -- Name Label
    local NameLabel = Instance.new("TextLabel", SliderFrame)
    NameLabel.Size = UDim2.new(0.5, -Config.Math.Padding, 0, 15)
    NameLabel.Position = UDim2.new(0, Config.Math.Padding, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = name or "Slider"
    NameLabel.TextColor3 = theme.TextColor
    NameLabel.Font = theme.Font
    NameLabel.TextSize = theme.TextSize
    NameLabel.TextWrapped = true
    NameLabel.TextTransparency = 1
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Value Label
    local ValueLabel = Instance.new("TextLabel", SliderFrame)
    ValueLabel.Size = UDim2.new(0.5, -Config.Math.Padding, 0, 15)
    ValueLabel.Position = UDim2.new(0.5, 0, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default or min)
    ValueLabel.TextColor3 = theme.TextColor
    ValueLabel.Font = theme.Font
    ValueLabel.TextSize = theme.TextSize
    ValueLabel.TextWrapped = true
    ValueLabel.TextTransparency = 1
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Slider Bar
    local Bar = Instance.new("Frame", SliderFrame)
    Bar.Size = UDim2.new(1, -2 * Config.Math.Padding, 0, 5)
    Bar.Position = UDim2.new(0, Config.Math.Padding, 0, 20 + Config.Math.ElementSpacing)
    Bar.BackgroundColor3 = theme.SecondaryColor
    Bar.BorderSizePixel = 0
    
    local Knob = Instance.new("Frame", Bar)
    Knob.Size = UDim2.new(0, 10, 0, 10)
    Knob.BackgroundColor3 = theme.AccentColor
    Knob.BorderSizePixel = 0
    
    min = min or 0
    max = max or 100
    default = default or min
    
    local value = default
    Knob.Position = UDim2.new((default - min) / (max - min), -5, 0, -2.5)
    ValueLabel.Text = string.format("%.1f", value) -- Update initial value display
    
    local dragging = false
    Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    Knob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp(input.Position.X - Bar.AbsolutePosition.X, 0, Bar.AbsoluteSize.X)
            value = min + (relativeX / Bar.AbsoluteSize.X) * (max - min)
            Knob.Position = UDim2.new(relativeX / Bar.AbsoluteSize.X, -5, 0, -2.5)
            ValueLabel.Text = string.format("%.1f", value) -- Update value label
            if callback then callback(value) end
        end
    end)
    
    _G.CensuraG.AnimationManager:Tween(SliderFrame, {BackgroundTransparency = 0}, animConfig.FadeDuration)
    _G.CensuraG.AnimationManager:Tween(NameLabel, {TextTransparency = 0}, animConfig.FadeDuration)
    _G.CensuraG.AnimationManager:Tween(ValueLabel, {TextTransparency = 0}, animConfig.FadeDuration)
    
    local Slider = {
        Instance = SliderFrame,
        Bar = Bar,
        Knob = Knob,
        NameLabel = NameLabel,
        ValueLabel = ValueLabel,
        Value = value,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("slider", self)
        end
    }
    
    _G.CensuraG.Logger:info("Slider created with range " .. min .. " to " .. max)
    return Slider, value
end
