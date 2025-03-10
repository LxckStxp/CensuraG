-- Slider.lua: Simplified slider with modern miltech styling, proper knob height, and label
local Slider = setmetatable({}, {__index = _G.CensuraG.UIElement})
Slider.__index = Slider

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local UserInputService = game:GetService("UserInputService")
local logger = _G.CensuraG.Logger

function Slider.new(parent, x, y, width, min, max, default, options)
    if not parent or not parent.Instance or not parent.Instance:IsA("GuiObject") then
        logger:error("Invalid parent for slider: %s", tostring(parent))
        return nil
    end
    min = min or 0
    max = max or 100
    if min >= max then
        logger:error("Invalid min/max values for slider: min=%d, max=%d", min, max)
        return nil
    end
    default = math.clamp(default or min, min, max)
    options = options or {}
    width = width or 200
    local height = 15 -- Track height
    local labelText = options.LabelText or "Slider"

    logger:debug("Creating slider with parent: %s, Position: (%d, %d), Width: %d, Label: %s", tostring(parent.Instance), x, y, width, labelText)

    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width + 40, 0, 35),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = true,
        ZIndex = parent.Instance.ZIndex + 1
    })
    logger:debug("Slider frame created: Position: %s, Size: %s, ZIndex: %d", tostring(frame.Position), tostring(frame.Size), frame.ZIndex)

    local label = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, width, 0, 20),
        Text = labelText,
        BackgroundTransparency = 1,
        ZIndex = frame.ZIndex + 2
    })
    Styling:Apply(label, "TextLabel")
    -- Force text visibility
    label.TextTransparency = 0
    label.Visible = true
    logger:debug("Slider label created: Position: %s, Size: %s, Text: %s", tostring(label.Position), tostring(label.Size), label.Text)

    local track = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(0, width, 0, height),
        BackgroundTransparency = Styling.Transparency.ElementBackground,
        ZIndex = frame.ZIndex + 1
    })
    Styling:Apply(track, "Frame")
    logger:debug("Slider track created: Position: %s, Size: %s", tostring(track.Position), tostring(track.Size))

    local fill = Utilities.createInstance("Frame", {
        Parent = track,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = Styling.Transparency.ElementBackground,
        ZIndex = track.ZIndex + 1
    })
    Styling:Apply(fill, "Frame")
    logger:debug("Slider fill created: Position: %s, Size: %s", tostring(fill.Position), tostring(fill.Size))

    local knobSize = height
    local knob = Utilities.createInstance("Frame", {
        Parent = track,
        Position = UDim2.new((default - min) / (max - min), -(knobSize / 2), 0, 0),
        Size = UDim2.new(0, knobSize, 0, height),
        BackgroundTransparency = Styling.Transparency.ElementBackground,
        ZIndex = track.ZIndex + 2
    })
    Styling:Apply(knob, "Frame")
    logger:debug("Slider knob created: Position: %s, Size: %s", tostring(knob.Position), tostring(knob.Size))

    local labelValue = options.ShowValue and Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, width + 5, 0, 20),
        Size = UDim2.new(0, 40, 0, height),
        Text = tostring(default),
        BackgroundTransparency = 1,
        ZIndex = frame.ZIndex + 2
    }) or nil
    if labelValue then
        Styling:Apply(labelValue, "TextLabel")
        -- Force text visibility
        labelValue.TextTransparency = 0
        labelValue.Visible = true
        logger:debug("Slider value label created: Position: %s, Size: %s, Text: %s", tostring(labelValue.Position), tostring(labelValue.Size), labelValue.Text)
    end

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
        Orientation = options.Orientation or "Horizontal",
        Connections = {},
        IsDragging = false
    }, Slider)

    function self:UpdateValue(newValue, animate)
        newValue = math.clamp(math.floor(newValue / self.Step) * self.Step, self.Min, self.Max)
        if newValue == self.Value then return end
        self.Value = newValue
        local ratio = (newValue - self.Min) / (self.Max - self.Min)
        if self.Orientation == "Horizontal" then
            if animate then
                Animation:Tween(self.Fill, {Size = UDim2.new(ratio, 0, 1, 0)}, 0.2)
                Animation:Tween(self.Knob, {Position = UDim2.new(ratio, -(knobSize / 2), 0, 0)}, 0.2)
            else
                self.Fill.Size = UDim2.new(ratio, 0, 1, 0)
                self.Knob.Position = UDim2.new(ratio, -(knobSize / 2), 0, 0)
            end
        else
            if animate then
                Animation:Tween(self.Fill, {Size = UDim2.new(1, 0, ratio, 0)}, 0.2)
                Animation:Tween(self.Knob, {Position = UDim2.new(0, -(knobSize / 2), ratio, 0)}, 0.2)
            else
                self.Fill.Size = UDim2.new(1, 0, ratio, 0)
                self.Knob.Position = UDim2.new(0, -(knobSize / 2), ratio, 0)
            end
        end
        if self.LabelValue then
            self.LabelValue.Text = tostring(newValue)
            self.LabelValue.TextTransparency = 0
            self.LabelValue.Visible = true
        end
        if options.OnChanged then
            options.OnChanged(newValue)
        end
        logger:debug("Slider value updated: New Value: %d, Fill Size: %s, Knob Position: %s", newValue, tostring(self.Fill.Size), tostring(self.Knob.Position))
    end

    table.insert(self.Connections, self.Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = true
            local mousePos = input.Position
            local framePos = track.AbsolutePosition
            local frameSize = track.AbsoluteSize
            local ratio = self.Orientation == "Horizontal" and math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1) or math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
            self:UpdateValue(self.Min + (self.Max - self.Min) * ratio, true)
        end
    end))

    table.insert(self.Connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = false
        end
    end))

    table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and self.IsDragging then
            local mousePos = input.Position
            local framePos = track.AbsolutePosition
            local frameSize = track.AbsoluteSize
            local ratio = self.Orientation == "Horizontal" and math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1) or math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
            self:UpdateValue(self.Min + (self.Max - self.Min) * ratio, false)
        end
    end))

    table.insert(self.Connections, track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = input.Position
            local knobPos = self.Knob.AbsolutePosition
            local knobSize = self.Knob.AbsoluteSize
            if mousePos.X >= knobPos.X and mousePos.X <= knobPos.X + knobSize.X and
               mousePos.Y >= knobPos.Y and mousePos.Y <= knobPos.Y + knobSize.Y then
                return
            end
            local framePos = track.AbsolutePosition
            local frameSize = track.AbsoluteSize
            local ratio = self.Orientation == "Horizontal" and math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1) or math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
            self:UpdateValue(self.Min + (self.Max - self.Min) * ratio, true)
        end
    end))

    function self:Destroy()
        for _, connection in ipairs(self.Connections) do
            connection:Disconnect()
        end
        self.Connections = {}
        self.Instance:Destroy()
        if self.Label then self.Label:Destroy() end
        if self.LabelValue then self.LabelValue:Destroy() end
        logger:info("Slider destroyed")
    end

    self:UpdateValue(default, false)
    return self
end

function Slider:SetValue(value)
    self:UpdateValue(value, true)
end

return Slider
