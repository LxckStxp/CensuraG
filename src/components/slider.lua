-- CensuraG/src/components/slider.lua
local Config = _G.CensuraG.Config

return function(parent, min, max, default, callback)
    local theme = Config:GetTheme()
    local SliderFrame = Instance.new("Frame", parent)
    SliderFrame.Size = UDim2.new(0, 150, 0, 20)
    SliderFrame.BackgroundColor3 = theme.PrimaryColor
    SliderFrame.BorderSizePixel = 0
    
    local Bar = Instance.new("Frame", SliderFrame)
    Bar.Size = UDim2.new(1, 0, 0, 5)
    Bar.Position = UDim2.new(0, 0, 0.5, -2.5)
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
            _G.CensuraG.AnimationManager:Tween(Knob, {
                Position = UDim2.new(relativeX / Bar.AbsoluteSize.X, -5, 0, -2.5)
            }, Config.Animations.FadeDuration / 2)
            if callback then callback(value) end
        end
    end)
    
    _G.CensuraG.Logger:info("Slider created with range " .. min .. " to " .. max)
    return SliderFrame, value
end
