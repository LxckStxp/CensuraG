-- Elements/Switch.lua
-- Simplified toggle switch using enhanced UIElement base

local Switch = {}
Switch.__index = Switch
setmetatable(Switch, { __index = _G.CensuraG.UIElement })

function Switch.new(options)
    options = options or {}
    
    -- Set default properties for Switch
    options.width = options.width or 120
    options.height = options.height or 30
    options.labelText = options.labelText or "Switch"
    options.state = options.state or false
    
    -- Create the base element
    local self = _G.CensuraG.UIElement.new(options.parent, options)
    
    -- Calculate dimensions
    local switchWidth = options.switchWidth or 40
    local switchHeight = options.switchHeight or 20
    local knobSize = switchHeight
    
    -- Create label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0, 60, 0, switchHeight)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = options.labelText
    label.BackgroundTransparency = 1
    label.ZIndex = self.Instance.ZIndex + 1
    label.Parent = self.Instance
    _G.CensuraG.Styling:Apply(label, "TextLabel")
    
    -- Create track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(0, switchWidth, 0, switchHeight)
    track.Position = UDim2.new(0, 65, 0, 5)
    track.ZIndex = self.Instance.ZIndex + 1
    track.Parent = self.Instance
    _G.CensuraG.Styling:Apply(track, "Frame")
    
    -- Create knob
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, knobSize, 0, switchHeight)
    knob.Position = options.state 
        and UDim2.new(1, -knobSize, 0, 0)
        or UDim2.new(0, 0, 0, 0)
    knob.ZIndex = track.ZIndex + 1
    knob.Parent = track
    _G.CensuraG.Styling:Apply(knob, "Frame")
    
    -- Create value label if needed
    local valueLabel = nil
    if options.showLabel then
        valueLabel = Instance.new("TextLabel")
        valueLabel.Name = "ValueLabel"
        valueLabel.Size = UDim2.new(0, 30, 0, switchHeight)
        valueLabel.Position = UDim2.new(0, switchWidth + 70, 0, 0)
        valueLabel.Text = options.state and "On" or "Off"
        valueLabel.BackgroundTransparency = 1
        valueLabel.ZIndex = self.Instance.ZIndex + 1
        valueLabel.Parent = self.Instance
        _G.CensuraG.Styling:Apply(valueLabel, "TextLabel")
    end
    
    -- Set up properties
    self.Label = label
    self.Track = track
    self.Knob = knob
    self.ValueLabel = valueLabel
    self.State = options.state
    self.OnToggled = options.onToggled
    self.Debounce = false
    self.KnobSize = knobSize
    
    -- Set up click handlers
    self:OnClick(function() self:Toggle() end)
    
    -- Track and knob also need click handlers
    track:SetAttribute("SwitchParent", self.Id)
    knob:SetAttribute("SwitchParent", self.Id)
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:Toggle()
        end
    end)
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:Toggle()
        end
    end)
    
    -- Set correct track color
    if self.State then
        track.BackgroundColor3 = _G.CensuraG.Styling.Colors.Accent
    end
    
    -- Set metatable for this instance
    return setmetatable(self, Switch)
end

-- Toggle the switch state
function Switch:Toggle(newState)
    if self.IsDestroyed or self.Debounce then return self end
    
    self.Debounce = true
    
    -- Update state
    if newState ~= nil then 
        self.State = newState 
    else 
        self.State = not self.State 
    end
    
    -- Animate knob
    local newPos = self.State 
        and UDim2.new(1, -self.KnobSize, 0, 0) 
        or UDim2.new(0, 0, 0, 0)
    
    _G.CensuraG.Animation:Tween(self.Knob, { Position = newPos }, 0.2, nil, nil, function() 
        self.Debounce = false 
    end)
    
    -- Animate track color
    if self.State then
        _G.CensuraG.Animation:Tween(self.Track, { BackgroundColor3 = _G.CensuraG.Styling.Colors.Accent }, 0.2)
    else
        _G.CensuraG.Animation:Tween(self.Track, { BackgroundColor3 = _G.CensuraG.Styling.Colors.Secondary }, 0.2)
    end
    
    -- Update value label
    if self.ValueLabel then
        self.ValueLabel.Text = self.State and "On" or "Off"
    end
    
    -- Call callback
    if self.OnToggled then
        _G.CensuraG.ErrorHandler:TryCatch(self.OnToggled, "Switch callback error", self.State)
    end
    
    -- Fire event
    _G.CensuraG.EventManager:FireEvent("SwitchToggled", self, self.State)
    
    return self
end

-- Get current state
function Switch:GetState()
    return self.State
end

-- Set callback
function Switch:SetCallback(callback)
    self.OnToggled = callback
    return self
end

-- Set label text
function Switch:SetLabel(text)
    if self.Label then 
        self.Label.Text = text 
    end
    return self
end

return Switch
