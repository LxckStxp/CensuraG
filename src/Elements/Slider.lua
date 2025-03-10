-- Slider.lua: Simplified slider with modern miltech styling and precise knob dragging
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
    local height = 15

    logger:debug("Creating slider with parent: %s, Position: (%d, %d), Width: %d", tostring(parent.Instance), x, y, width)

    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width, 0, height),
        BackgroundTransparency = Styling.Transparency.Background,
        ClipsDescendants = true,
        Visible = true,
        ZIndex = 3
    })
    Styling:Apply(frame, "Frame")
    logger:debug("Slider frame created: Position: %s, Size: %s, ZIndex: %d", tostring(frame.Position), tostring(frame.Size), frame.ZIndex)

    local fill = Utilities.createInstance("Frame", {
        Parent = frame,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = Styling.Transparency.Highlight,
        ZIndex = 4
    })
    Styling:Apply(fill, "Frame")
    logger:debug("Slider fill created: Position: %s, Size: %s", tostring(fill.Position), tostring(fill.Size))

    local notchSize = 10
    local notch = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new((default - min) / (max - min), -(notchSize / 2), 0, -(height / 2)),
        Size = UDim2.new(0, notchSize, 0, height),
        BackgroundTransparency = Styling.Transparency.Highlight,
        ZIndex = 5
    })
    Styling:Apply(notch, "Frame")
    logger:debug("Slider notch created: Position: %s, Size: %s", tostring(notch.Position), tostring(notch.Size))

    local label = options.ShowValue and Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, -20),
        Size = UDim2.new(1, 0, 0, 15),
        Text = tostring(default),
        BackgroundTransparency = 1,
        ZIndex = 4
    }) or nil
    if label then
        Styling:Apply(label, "TextLabel")
        logger:debug("Slider label created: Position: %s, Size: %s, Text: %s", tostring(label.Position), tostring(label.Size), label.Text)
    end

    local self = setmetatable({
        Instance = frame,
        Value = default,
        Min = min,
        Max = max,
        Fill = fill,
        Notch = notch,
        Label = label,
        Step = options.Step or 1,
        Orientation = options.Orientation or "Horizontal",
        Connections = {},
        IsDragging = false -- Track dragging state
    }, Slider)

    function self:UpdateValue(newValue, animate)
        newValue = math.clamp(math.floor(newValue / self.Step) * self.Step, self.Min, self.Max)
        if newValue == self.Value then return end
        self.Value = newValue
        local ratio = (newValue - self.Min) / (self.Max - self.Min)
        if self.Orientation == "Horizontal" then
            if animate then
                Animation:Tween(self.Fill, {Size = UDim2.new(ratio, 0, 1, 0)}, 0.2)
                Animation:Tween(self.Notch, {Position = UDim2.new(ratio, -(notchSize / 2), 0, -(height / 2))}, 0.2)
            else
                -- Update instantly during drag for seamless movement
                self.Fill.Size = UDim2.new(ratio, 0, 1, 0)
                self.Notch.Position = UDim2.new(ratio, -(notchSize / 2), 0, -(height / 2))
            end
        else
            if animate then
                Animation:Tween(self.Fill, {Size = UDim2.new(1, 0, ratio, 0)}, 0.2)
                Animation:Tween(self.Notch, {Position = UDim2.new(0, -(notchSize / 2), ratio, -(height / 2))}, 0.2)
            else
                self.Fill.Size = UDim2.new(1, 0, ratio, 0)
                self.Notch.Position = UDim2.new(0, -(notchSize / 2), ratio, -(height / 2))
            end
        end
        if self.Label then
            self.Label.Text = tostring(newValue)
        end
        if options.OnChanged then
            options.OnChanged(newValue)
        end
        logger:debug("Slider value updated: New Value: %d, Fill Size: %s, Notch Position: %s", newValue, tostring(self.Fill.Size), tostring(self.Notch.Position))
    end

    -- Click handling (only on the notch)
    table.insert(self.Connections, self.Notch.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = true
            local mousePos = input.Position
            local framePos = frame.AbsolutePosition
            local frameSize = frame.AbsoluteSize
            local ratio = self.Orientation == "Horizontal" and math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1) or math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
            self:UpdateValue(self.Min + (self.Max - self.Min) * ratio, true) -- Animate on click
        end
    end))

    -- Stop dragging when mouse button is released
    table.insert(self.Connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = false
        end
    end))

    -- Dragging handling (only when dragging the notch)
    table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and self.IsDragging then
            local mousePos = input.Position
            local framePos = frame.AbsolutePosition
            local frameSize = frame.AbsoluteSize
            local ratio = self.Orientation == "Horizontal" and math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1) or math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
            self:UpdateValue(self.Min + (self.Max - self.Min) * ratio, false) -- No animation during drag
        end
    end))

    -- Click on the track (outside the notch) to animate to position
    table.insert(self.Connections, frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Check if the click was on the notch (already handled above)
            local mousePos = input.Position
            local notchPos = self.Notch.AbsolutePosition
            local notchSize = self.Notch.AbsoluteSize
            if mousePos.X >= notchPos.X and mousePos.X <= notchPos.X + notchSize.X and
               mousePos.Y >= notchPos.Y and mousePos.Y <= notchPos.Y + notchSize.Y then
                return -- Click was on the notch, handled by notch.InputBegan
            end
            -- Click on the track, animate to position
            local framePos = frame.AbsolutePosition
            local frameSize = frame.AbsoluteSize
            local ratio = self.Orientation == "Horizontal" and math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1) or math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
            self:UpdateValue(self.Min + (self.Max - self.Min) * ratio, true) -- Animate on track click
        end
    end))

    function self:Destroy()
        for _, connection in ipairs(self.Connections) do
            connection:Disconnect()
        end
        self.Connections = {}
        self.Instance:Destroy()
        logger:info("Slider destroyed")
    end

    self:UpdateValue(default, false)

    return self
end

function Slider:SetValue(value)
    self:UpdateValue(value, true)
end

return Slider
