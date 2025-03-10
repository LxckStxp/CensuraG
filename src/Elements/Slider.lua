-- Slider.lua: Enhanced slider with miltech styling
local Slider = setmetatable({}, {__index = _G.CensuraG.UIElement})
Slider.__index = Slider

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local Draggable = _G.CensuraG.Draggable
local UserInputService = game:GetService("UserInputService")
local logger = _G.CensuraG.Logger

function Slider.new(parent, x, y, width, min, max, default, options)
    min = min or 0
    max = max or 100
    default = math.clamp(default or min, min, max)
    options = options or {}

    if not parent or not parent.Instance then
        logger:error("Invalid parent for slider: %s", tostring(parent))
        return nil
    end

    logger:debug("Creating slider with parent: %s, Position: (%d, %d), Width: %d", tostring(parent.Instance), x, y, width)

    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width, 0, 15),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = true,
        ZIndex = 3
    })
    Styling:Apply(frame, "Frame")
    logger:debug("Slider frame created: Position: %s, Size: %s, ZIndex: %d, Visible: %s, Parent: %s", tostring(frame.Position), tostring(frame.Size), frame.ZIndex, tostring(frame.Visible), tostring(frame.Parent))

    local fill = Utilities.createInstance("Frame", {
        Parent = frame,
        Size = UDim2.new((default - min) / (max - min), 0, 0.8, 0),
        Position = UDim2.new(0, 0, 0, 2),
        BackgroundColor3 = Styling.Colors.Accent,
        BackgroundTransparency = 0.4,
        Visible = true,
        ZIndex = 4
    })
    logger:debug("Slider fill created: Position: %s, Size: %s, ZIndex: %d, Visible: %s", tostring(fill.Position), tostring(fill.Size), fill.ZIndex, tostring(fill.Visible))

    local notch = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new((default - min) / (max - min), -5, 0, -5),
        Size = UDim2.new(0, 10, 0, 25),
        BackgroundColor3 = Color3.fromRGB(150, 150, 150),
        BorderSizePixel = 0,
        Visible = true,
        ZIndex = 4
    })
    logger:debug("Slider notch created: Position: %s, Size: %s, ZIndex: %d, Visible: %s", tostring(notch.Position), tostring(notch.Size), notch.ZIndex, tostring(notch.Visible))

    local notchStroke = Utilities.createInstance("UIStroke", {
        Parent = notch,
        Thickness = 1,
        Color = Color3.fromRGB(200, 200, 200),
        Transparency = 0.5
    })

    local label = options.ShowValue and Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, -25),
        Size = UDim2.new(1, 0, 0, 20),
        Text = tostring(default),
        BackgroundTransparency = 1,
        TextColor3 = Styling.Colors.Text,
        Font = Enum.Font.Code,
        TextSize = 12,
        Visible = true,
        ZIndex = 4
    }) or nil
    if label then
        logger:debug("Slider label created: Position: %s, Size: %s, ZIndex: %d, Visible: %s, Text: %s", tostring(label.Position), tostring(label.Size), label.ZIndex, tostring(label.Visible), label.Text)
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
        Orientation = options.Orientation or "Horizontal"
    }, Slider)

    function self:UpdateValue(newValue)
        newValue = math.clamp(math.floor(newValue / self.Step) * self.Step, self.Min, self.Max)
        self.Value = newValue
        local ratio = (newValue - self.Min) / (self.Max - self.Min)
        if self.Orientation == "Horizontal" then
            Animation:Tween(self.Fill, {Size = UDim2.new(ratio, 0, 0.8, 0)})
            Animation:Tween(self.Notch, {Position = UDim2.new(ratio, -5, 0, -5)})
        else
            Animation:Tween(self.Fill, {Size = UDim2.new(1, 0, ratio, 0)})
            Animation:Tween(self.Notch, {Position = UDim2.new(0, -5, ratio, -5)})
        end
        if self.Label then
            self.Label.Text = tostring(newValue)
        end
        if options.OnChanged then
            options.OnChanged(newValue)
        end
        logger:debug("Slider value updated: New Value: %d, Fill Size: %s, Notch Position: %s", newValue, tostring(self.Fill.Size), tostring(self.Notch.Position))
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = input.Position
            local framePos = frame.AbsolutePosition
            local frameSize = frame.AbsoluteSize
            local ratio = self.Orientation == "Horizontal" and math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1) or math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
            self:UpdateValue(self.Min + (self.Max - self.Min) * ratio)
            logger:debug("Slider clicked: Mouse Position: (%d, %d), Ratio: %.2f", mousePos.X, mousePos.Y, ratio)
        end
    end)

    self.DragHandler = Draggable.new(notch, notch)
    local connection = UserInputService.InputChanged:Connect(function(input)
        if self.DragHandler.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position
            local framePos = frame.AbsolutePosition
            local frameSize = frame.AbsoluteSize
            local ratio = self.Orientation == "Horizontal" and math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1) or math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
            self:UpdateValue(self.Min + (self.Max - self.Min) * ratio)
            logger:debug("Slider dragged: Mouse Position: (%d, %d), Ratio: %.2f", mousePos.X, mousePos.Y, ratio)
        end
    end)

    function self:Destroy()
        connection:Disconnect()
        self.DragHandler:Destroy()
        self.Instance:Destroy()
        logger:info("Slider destroyed")
    end

    self:UpdateValue(default)

    return self
end

function Slider:SetValue(value)
    self:UpdateValue(value)
end

return Slider
