-- CensuraG/src/components/slider.lua (updated for CensuraDev styling)
local Config = _G.CensuraG.Config

return function(parent, name, min, max, default, callback)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    
    -- Constants from CensuraDev
    local TRACK_HEIGHT = 2
    local KNOB_SIZE = 12
    
    -- Container Frame
    local SliderFrame = Instance.new("Frame", parent)
    SliderFrame.Size = UDim2.new(1, -12, 0, 40)
    SliderFrame.BackgroundColor3 = theme.SecondaryColor
    SliderFrame.BackgroundTransparency = 0.8
    SliderFrame.BorderSizePixel = 0
    
    -- Add corner radius
    local Corner = Instance.new("UICorner", SliderFrame)
    Corner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)
    
    -- Add stroke
    local Stroke = Instance.new("UIStroke", SliderFrame)
    Stroke.Color = theme.AccentColor
    Stroke.Transparency = 0.6
    Stroke.Thickness = Config.Math.BorderThickness
    
    -- Label and Value Display
    local NameLabel = Instance.new("TextLabel", SliderFrame)
    NameLabel.Size = UDim2.new(1, -70, 0, 20)
    NameLabel.Position = UDim2.new(0, 10, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = name or "Slider"
    NameLabel.TextColor3 = theme.TextColor
    NameLabel.Font = theme.Font
    NameLabel.TextSize = theme.TextSize
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Value display
    local ValueFrame = Instance.new("Frame", SliderFrame)
    ValueFrame.Size = UDim2.new(0, 50, 0, 20)
    ValueFrame.Position = UDim2.new(1, -60, 0, 0)
    ValueFrame.BackgroundColor3 = theme.PrimaryColor
    ValueFrame.BackgroundTransparency = 0.8
    
    local ValueCorner = Instance.new("UICorner", ValueFrame)
    ValueCorner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)
    
    local ValueLabel = Instance.new("TextLabel", ValueFrame)
    ValueLabel.Size = UDim2.new(1, 0, 1, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default or min)
    ValueLabel.TextColor3 = theme.TextColor
    ValueLabel.Font = theme.Font
    ValueLabel.TextSize = theme.TextSize
    
    -- Track
    local Track = Instance.new("Frame", SliderFrame)
    Track.Size = UDim2.new(1, -20, 0, TRACK_HEIGHT)
    Track.Position = UDim2.new(0, 10, 0.7, 0)
    Track.BackgroundColor3 = theme.BorderColor
    Track.BackgroundTransparency = 0.5
    
    local TrackCorner = Instance.new("UICorner", Track)
    TrackCorner.CornerRadius = UDim.new(0, 1)
    
    -- Fill (colored part of the track)
    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = theme.EnabledColor
    
    local FillCorner = Instance.new("UICorner", Fill)
    FillCorner.CornerRadius = UDim.new(0, 1)
    
    -- Knob
    local Knob = Instance.new("Frame", Track)
    Knob.Size = UDim2.new(0, KNOB_SIZE, 0, KNOB_SIZE)
    Knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    Knob.BackgroundColor3 = theme.TextColor
    
    local KnobCorner = Instance.new("UICorner", Knob)
    KnobCorner.CornerRadius = UDim.new(1, 0)
    
    local KnobStroke = Instance.new("UIStroke", Knob)
    KnobStroke.Color = theme.AccentColor
    KnobStroke.Transparency = 0.8
    KnobStroke.Thickness = 1
    
    -- Initialize values
    min = min or 0
    max = max or 100
    default = default or min
    
    local value = default
    ValueLabel.Text = string.format("%.1f", value)
    
    -- Dragging logic
    local dragging = false
    
    Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            _G.CensuraG.AnimationManager:Tween(Knob, {Size = UDim2.new(0, KNOB_SIZE + 2, 0, KNOB_SIZE + 2)}, 0.1)
        end
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            _G.CensuraG.AnimationManager:Tween(Knob, {Size = UDim2.new(0, KNOB_SIZE, 0, KNOB_SIZE)}, 0.1)
        end
    end)
    
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Allow clicking on the track to set value
            local relativeX = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, Track.AbsoluteSize.X)
            value = min + (relativeX / Track.AbsoluteSize.X) * (max - min)
            
            -- Update visuals
            local pos = relativeX / Track.AbsoluteSize.X
            _G.CensuraG.AnimationManager:Tween(Knob, {Position = UDim2.new(pos, -6, 0.5, -6)}, 0.1)
            _G.CensuraG.AnimationManager:Tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
            
            ValueLabel.Text = string.format("%.1f", value)
            if callback then callback(value) end
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, Track.AbsoluteSize.X)
            value = min + (relativeX / Track.AbsoluteSize.X) * (max - min)
            
            -- Update visuals
            local pos = relativeX / Track.AbsoluteSize.X
            Knob.Position = UDim2.new(pos, -6, 0.5, -6)
            Fill.Size = UDim2.new(pos, 0, 1, 0)
            
            ValueLabel.Text = string.format("%.1f", value)
            if callback then callback(value) end
        end
    end)
    
    -- Hover effects
    SliderFrame.MouseEnter:Connect(function()
        _G.CensuraG.AnimationManager:Tween(Stroke, {Transparency = 0.2}, 0.2)
        _G.CensuraG.AnimationManager:Tween(ValueFrame, {BackgroundTransparency = 0.6}, 0.2)
    end)
    
    SliderFrame.MouseLeave:Connect(function()
        _G.CensuraG.AnimationManager:Tween(Stroke, {Transparency = 0.6}, 0.2)
        _G.CensuraG.AnimationManager:Tween(ValueFrame, {BackgroundTransparency = 0.8}, 0.2)
    end)
    
    local Slider = {
        Instance = SliderFrame,
        Track = Track,
        Fill = Fill,
        Knob = Knob,
        NameLabel = NameLabel,
        ValueLabel = ValueLabel,
        Value = value,
        SetValue = function(self, newValue, skipCallback)
            value = math.clamp(newValue, min, max)
            local pos = (value - min) / (max - min)
            
            _G.CensuraG.AnimationManager:Tween(self.Knob, {Position = UDim2.new(pos, -6, 0.5, -6)}, 0.1)
            _G.CensuraG.AnimationManager:Tween(self.Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
            
            self.ValueLabel.Text = string.format("%.1f", value)
            self.Value = value
            
            if not skipCallback and callback then
                callback(value)
            end
        end,
        GetValue = function(self)
            return self.Value
        end,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("slider", self)
        end
    }
    
    _G.CensuraG.Logger:info("Slider created with range " .. min .. " to " .. max)
    return Slider, value
end
