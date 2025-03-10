-- Elements/Slider.lua
-- Modern slider component

local Slider = setmetatable({}, { __index = _G.CensuraG.UIElement })
Slider.__index = Slider

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager
local UserInputService = game:GetService("UserInputService")
local logger = _G.CensuraG.Logger

function Slider.new(parent, x, y, width, min, max, default, options)
    if not parent or not parent.Instance then return nil end
    options = options or {}
    min = min or 0
    max = max or 100
    default = math.clamp(default or min, min, max)
    width = width or 200
    
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width + 80, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = parent.Instance.ZIndex + 1,
        Name = "Slider_" .. (options.LabelText or "Slider")
    })
    
    local label = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 60, 0, 30),
        Text = options.LabelText or "Slider",
        ZIndex = frame.ZIndex + 1,
        Name = "Label"
    })
    Styling:Apply(label, "TextLabel")
    
    local track = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new(0, 65, 0, 12),
        Size = UDim2.new(0, width - 65, 0, 6),
        ZIndex = frame.ZIndex + 1,
        Name = "Track"
    })
    Styling:Apply(track, "Frame")
    
    local ratio = (default - min) / (max - min)
    local fill = Utilities.createInstance("Frame", {
        Parent = track,
        Size = UDim2.new(ratio, 0, 1, 0),
        BackgroundColor3 = Styling.Colors.Accent,
        ZIndex = track.ZIndex + 1,
        Name = "Fill"
    })
    Styling:Apply(fill, "Frame")
    
    local knob = Utilities.createInstance("Frame", {
        Parent = track,
        Position = UDim2.new(ratio, -10, -0.5, 0),
        Size = UDim2.new(0, 20, 0, 20),
        ZIndex = track.ZIndex + 2,
        Name = "Knob"
    })
    Styling:Apply(knob, "Frame")
    Animation:HoverEffect(knob, { Size = UDim2.new(0, 24, 0, 24) }, { Size = UDim2.new(0, 20, 0, 20) })
    
    local labelValue = options.ShowValue and Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, width + 5, 0, 0),
        Size = UDim2.new(0, 40, 0, 30),
        Text = tostring(default),
        ZIndex = frame.ZIndex + 1,
        Name = "ValueLabel"
    })
    if labelValue then Styling:Apply(labelValue, "TextLabel") end
    
    local self = setmetatable({
        Instance = frame,
        Label = label,
        Track = track,
        Fill = fill,
        Knob = knob,
        LabelValue = labelValue,
        Value = default,
        Min = min,
        Max = max,
        Step = options.Step or 1,
        OnChanged = options.OnChanged,
        IsDragging = false,
        Connections = {}
    }, Slider)
    
    function self:UpdateValue(newValue, animate)
        newValue = math.clamp(math.floor((newValue / self.Step) + 0.5) * self.Step, self.Min, self.Max)
        if newValue == self.Value then return self end
        self.Value = newValue
        local ratio = (newValue - self.Min) / (self.Max - self.Min)
        if animate then
            Animation:Tween(self.Fill, { Size = UDim2.new(ratio, 0, 1, 0) }, 0.2 / _G.CensuraG.Config.AnimationSpeed)
            Animation:Tween(self.Knob, { Position = UDim2.new(ratio, -10, -0.5, 0) }, 0.2 / _G.CensuraG.Config.AnimationSpeed)
        else
            self.Fill.Size = UDim2.new(ratio, 0, 1, 0)
            self.Knob.Position = UDim2.new(ratio, -10, -0.5, 0)
        end
        if self.LabelValue then self.LabelValue.Text = tostring(newValue) end
        if self.OnChanged then self.OnChanged(newValue) end
        EventManager:FireEvent("SliderChanged", self, newValue)
        return self
    end
    
    table.insert(self.Connections, EventManager:Connect(knob.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then self.IsDragging = true end
    end))
    table.insert(self.Connections, EventManager:Connect(track.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local ratio = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            self:UpdateValue(self.Min + (self.Max - self.Min) * ratio, true)
        end
    end))
    table.insert(self.Connections, EventManager:Connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then self.IsDragging = false end
    end))
    table.insert(self.Connections, EventManager:Connect(UserInputService.InputChanged, function(input)
        if self.IsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local ratio = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            self:UpdateValue(self.Min + (self.Max - self.Min) * ratio, false)
        end
    end))
    
    function self:Destroy()
        for _, conn in ipairs(self.Connections) do conn:Disconnect() end
        self.Connections = {}
        if self.Instance then self.Instance:Destroy() end
        logger:info("Slider destroyed: %s", self.Label.Text)
    end
    
    return self
end

return Slider
