-- Slider.lua: Styled slider with consistent layout
local Slider = setmetatable({}, {__index = _G.CensuraG.UIElement})
Slider.__index = Slider

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
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
        ZIndex = parent.Instance.ZIndex + 1
    })

    local label = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 60, 0, 20),
        Text = options.LabelText or "Slider",
        ZIndex = frame.ZIndex + 1
    })
    Styling:Apply(label, "TextLabel")

    local track = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new(0, 65, 0, 5),
        Size = UDim2.new(0, width - 70, 0, 20),
        ZIndex = frame.ZIndex + 1
    })
    Styling:Apply(track, "Frame")

    local fill = Utilities.createInstance("Frame", {
        Parent = track,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        ZIndex = track.ZIndex + 1
    })
    Styling:Apply(fill, "Frame")

    local knob = Utilities.createInstance("Frame", {
        Parent = track,
        Position = UDim2.new((default - min) / (max - min), -10, 0, 0),
        Size = UDim2.new(0, 20, 0, 20),
        ZIndex = track.ZIndex + 2
    })
    Styling:Apply(knob, "Frame")

    local labelValue = options.ShowValue and Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, width + 5, 0, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Text = tostring(default),
        ZIndex = frame.ZIndex + 1
    }) or nil
    if labelValue then Styling:Apply(labelValue, "TextLabel") end

    local self = setmetatable({
        Instance = frame,
        Value = default,
        Min = min,
        Max = max,
        Fill = fill,
        Knob = knob,
        Label = label,
        LabelValue = labelValue,
        Step = options.Step or 1,
        Connections = {}
    }, Slider)

    function self:UpdateValue(newValue, animate)
        newValue = math.clamp(math.floor(newValue / self.Step) * self.Step, self.Min, self.Max)
        if newValue == self.Value then return end
        self.Value = newValue
        local ratio = (newValue - self.Min) / (self.Max - self.Min)
        local props = {Size = UDim2.new(ratio, 0, 1, 0)}
        local knobPos = UDim2.new(ratio, -10, 0, 0)
        if animate then
            Animation:Tween(self.Fill, props, 0.2)
            Animation:Tween(self.Knob, {Position = knobPos}, 0.2)
        else
            self.Fill.Size = props.Size
            self.Knob.Position = knobPos
        end
        if self.LabelValue then self.LabelValue.Text = tostring(newValue) end
        if options.OnChanged then options.OnChanged(newValue) end
    end

    self.Connections = {
        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.IsDragging = true
            end
        end),
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.IsDragging = false
            end
        end),
        UserInputService.InputChanged:Connect(function(input)
            if self.IsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local ratio = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                self:UpdateValue(self.Min + (self.Max - self.Min) * ratio, false)
            end
        end)
    }

    function self:Destroy()
        for _, conn in ipairs(self.Connections) do conn:Disconnect() end
        self.Instance:Destroy()
        logger:info("Slider destroyed")
    end

    self:UpdateValue(default, false)
    return self
end

return Slider
