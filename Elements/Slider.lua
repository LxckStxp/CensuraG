-- Elements/Slider.lua
-- Simplified slider using enhanced UIElement base

local Slider = {}
Slider.__index = Slider
setmetatable(Slider, { __index = _G.CensuraG.UIElement })

function Slider.new(options)
    options = options or {}
    
    -- Set default properties for Slider
    options.width = options.width or 200
    options.height = options.height or 30
    options.min = options.min or 0
    options.max = options.max or 100
    options.value = math.clamp(options.value or options.min, options.min, options.max)
    options.step = options.step or 1
    options.labelText = options.labelText or "Slider"
    
    -- Create the base element
    local self = _G.CensuraG.UIElement.new(options.parent, options)
    
    -- Create label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0, 60, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = options.labelText
    label.BackgroundTransparency = 1
    label.ZIndex = self.Instance.ZIndex + 1
    label.Parent = self.Instance
    _G.CensuraG.Styling:Apply(label, "TextLabel")
    
    -- Create track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(0, options.width - 70, 0, 20)
    track.Position = UDim2.new(0, 65, 0, 5)
    track.ZIndex = self.Instance.ZIndex + 1
    track.Parent = self.Instance
    _G.CensuraG.Styling:Apply(track, "Frame")
    
    -- Calculate ratio
    local ratio = (options.value - options.min) / (options.max - options.min)
    
    -- Create fill
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    fill.BackgroundColor3 = _G.CensuraG.Styling.Colors.Accent
    fill.ZIndex = track.ZIndex + 1
    fill.Parent = track
    _G.CensuraG.Styling:Apply(fill, "Frame")
    
    -- Create knob
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(ratio, -10, 0, 0)
    knob.ZIndex = track.ZIndex + 2
    knob.Parent = track
    _G.CensuraG.Styling:Apply(knob, "Frame")
    
    -- Create value label if needed
    local labelValue = nil
    if options.showValue then
        labelValue = Instance.new("TextLabel")
        labelValue.Name = "ValueLabel"
        labelValue.Size = UDim2.new(0, 40, 0, 20)
        labelValue.Position = UDim2.new(0, options.width + 5, 0, 0)
        labelValue.Text = tostring(options.value)
        labelValue.BackgroundTransparency = 1
        labelValue.ZIndex = self.Instance.ZIndex + 1
        labelValue.Parent = self.Instance
        _G.CensuraG.Styling:Apply(labelValue, "TextLabel")
    end
    
    -- Set up properties
    self.Label = label
    self.Track = track
    self.Fill = fill
    self.Knob = knob
    self.LabelValue = labelValue
    self.Value = options.value
    self.Min = options.min
    self.Max = options.max
    self.Step = options.step
    self.OnChanged = options.onChange
    self.IsDragging = false
    
    -- Set up input handlers
    self:AddConnection(_G.CensuraG.EventManager:Connect(knob.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            self.IsDragging = true 
        end
    end))
    
    self:AddConnection(_G.CensuraG.EventManager:Connect(track.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local ratio = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            self:UpdateValue(self.Min + (self.Max - self.Min) * ratio, true)
        end
    end))
    
    self:AddConnection(_G.CensuraG.EventManager:Connect(game:GetService("UserInputService").InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            self.IsDragging = false 
        end
    end))
    
    self:AddConnection(_G.CensuraG.EventManager:Connect(game:GetService("UserInputService").InputChanged, function(input)
        if self.IsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local ratio = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            self:UpdateValue(self.Min + (self.Max - self.Min) * ratio, false)
        end
    end))
    
    -- Set metatable for this instance
    return setmetatable(self, Slider)
end

-- Update the slider value
function Slider:UpdateValue(newValue, animate)
    -- Clamp and step the value
    newValue = math.clamp(
        math.floor((newValue / self.Step) + 0.5) * self.Step, 
        self.Min, 
        self.Max
    )
    
    -- Skip if unchanged
    if newValue == self.Value then 
        return self 
    end
    
    self.Value = newValue
    
    -- Calculate the ratio
    local ratio = (newValue - self.Min) / (self.Max - self.Min)
    
    -- Update UI
    if animate then
        _G.CensuraG.Animation:Tween(self.Fill, { Size = UDim2.new(ratio, 0, 1, 0) }, 0.2)
        _G.CensuraG.Animation:Tween(self.Knob, { Position = UDim2.new(ratio, -10, 0, 0) }, 0.2)
    else
        self.Fill.Size = UDim2.new(ratio, 0, 1, 0)
        self.Knob.Position = UDim2.new(ratio, -10, 0, 0)
    end
    
    -- Update value label
    if self.LabelValue then 
        self.LabelValue.Text = tostring(newValue) 
    end
    
    -- Call callback
    if self.OnChanged then
        _G.CensuraG.ErrorHandler:TryCatch(self.OnChanged, "Slider callback error", newValue)
    end
    
    -- Fire event
    _G.CensuraG.EventManager:FireEvent("SliderChanged", self, newValue)
    
    return self
end

-- Get current value
function Slider:GetValue() 
    return self.Value 
end

-- Set callback
function Slider:SetCallback(callback) 
    self.OnChanged = callback
    return self 
end

-- Set range
function Slider:SetRange(newMin, newMax)
    if newMin >= newMax then
        _G.CensuraG.Logger:warn("Invalid slider range")
        return self
    end
    
    self.Min = newMin
    self.Max = newMax
    self:UpdateValue(math.clamp(self.Value, newMin, newMax), true)
    
    return self
end

-- Set step
function Slider:SetStep(newStep)
    if newStep <= 0 then
        _G.CensuraG.Logger:warn("Invalid slider step")
        return self
    end
    
    self.Step = newStep
    self:UpdateValue(math.floor((self.Value / newStep) + 0.5) * newStep, true)
    
    return self
end

-- Set label
function Slider:SetLabel(text)
    if self.Label then
        self.Label.Text = text
    end
    return self
end

return Slider
