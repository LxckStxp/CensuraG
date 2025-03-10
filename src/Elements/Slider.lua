-- Slider.lua: Enhanced slider with miltech styling and smooth animations
local Slider = setmetatable({}, {__index = _G.CensuraG.UIElement})
Slider.__index = Slider

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local Draggable = _G.CensuraG.Draggable
local UserInputService = game:GetService("UserInputService")
local logger = _G.CensuraG.Logger

function Slider.new(parent, x, y, width, min, max, default, options)
    -- Input validation
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

    logger:debug("Creating slider with parent: %s, Position: (%d, %d), Width: %d", tostring(parent.Instance), x, y, width)

    -- Create the slider frame
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width, 0, 15),
        BackgroundTransparency = 0.8, -- More transparent to match miltech style
        BackgroundColor3 = Styling.Colors.Base,
        ClipsDescendants = true,
        Visible = true,
        ZIndex = 3
    })
    logger:debug("Slider frame created: Position: %s, Size: %s, ZIndex: %d, Visible: %s, Parent: %s", tostring(frame.Position), tostring(frame.Size), frame.ZIndex, tostring(frame.Visible), tostring(frame.Parent))

    -- Add a border to the frame
    local frameStroke = Utilities.createInstance("UIStroke", {
        Parent = frame,
        Thickness = 1,
        Color = Color3.fromRGB(200, 200, 200),
        Transparency = 0.4
    })

    -- Create the fill bar
    local fill = Utilities.createInstance("Frame", {
        Parent = frame,
        Size = UDim2.new((default - min) / (max - min), 0, 0.8, 0),
        Position = UDim2.new(0, 0, 0.1, 0),
        BackgroundColor3 = Styling.Colors.Accent,
        BackgroundTransparency = 0.3, -- Slightly more opaque for visibility
        Visible = true,
        ZIndex = 4
    })
    logger:debug("Slider fill created: Position: %s, Size: %s, ZIndex: %d, Visible: %s", tostring(fill.Position), tostring(fill.Size), fill.ZIndex, tostring(fill.Visible))

    -- Add a subtle gradient to the fill
    local fillGradient = Utilities.createInstance("UIGradient", {
        Parent = fill,
        Color = ColorSequence.new(Styling.Colors.Accent, Styling.Colors.Highlight),
        Transparency = NumberSequence.new(0.3),
        Rotation = 90
    })

    -- Create the notch
    local notch = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new((default - min) / (max - min), -5, 0, -5),
        Size = UDim2.new(0, 10, 0, 25),
        BackgroundColor3 = Color3.fromRGB(150, 150, 150),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Visible = true,
        ZIndex = 5
    })
    logger:debug("Slider notch created: Position: %s, Size: %s, ZIndex: %d, Visible: %s", tostring(notch.Position), tostring(notch.Size), notch.ZIndex, tostring(notch.Visible))

    local notchStroke = Utilities.createInstance("UIStroke", {
        Parent = notch,
        Thickness = 1,
        Color = Color3.fromRGB(200, 200, 200),
        Transparency = 0.4
    })

    -- Add a shadow to the notch for depth
    local notchShadow = Utilities.createTaperedShadow(notch, 3, 3, 0.95)
    notchShadow.ZIndex = 4

    -- Add a value label if enabled
    local label = options.ShowValue and Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, -25),
        Size = UDim2.new(1, 0, 0, 20),
        Text = tostring(default),
        BackgroundTransparency = 1,
        TextColor3 = Styling.Colors.Text,
        Font = Enum.Font.Code,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center,
        Visible = true,
        ZIndex = 4
    }) or nil
    if label then
        Styling:Apply(label, "TextLabel")
        logger:debug("Slider label created: Position: %s, Size: %s, ZIndex: %d, Visible: %s, Text: %s", tostring(label.Position), tostring(label.Size), label.ZIndex, tostring(label.Visible), label.Text)
    end

    -- Initialize the slider object
    local self = setmetatable({
        Instance = frame,
        Value = default,
        Min = min,
        Max = max,
        Fill = fill,
        Notch = notch,
        NotchShadow = notchShadow,
        Label = label,
        Step = options.Step or 1,
        Orientation = options.Orientation or "Horizontal",
        Connections = {} -- Store connections for cleanup
    }, Slider)

    -- Update function for the slider value
    function self:UpdateValue(newValue)
        newValue = math.clamp(math.floor(newValue / self.Step) * self.Step, self.Min, self.Max)
        if newValue == self.Value then return end -- Avoid unnecessary updates
        self.Value = newValue
        local ratio = (newValue - self.Min) / (self.Max - self.Min)
        if self.Orientation == "Horizontal" then
            Animation:Tween(self.Fill, {Size = UDim2.new(ratio, 0, 0.8, 0)}, 0.2)
            Animation:Tween(self.Notch, {Position = UDim2.new(ratio, -5, 0, -5)}, 0.2)
        else
            Animation:Tween(self.Fill, {Size = UDim2.new(0.8, 0, ratio, 0)}, 0.2)
            Animation:Tween(self.Notch, {Position = UDim2.new(0, -5, ratio, -5)}, 0.2)
        end
        if self.Label then
            self.Label.Text = tostring(newValue)
        end
        if options.OnChanged then
            options.OnChanged(newValue)
        end
        logger:debug("Slider value updated: New Value: %d, Fill Size: %s, Notch Position: %s", newValue, tostring(self.Fill.Size), tostring(self.Notch.Position))
    end

    -- Click handling
    table.insert(self.Connections, frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = input.Position
            local framePos = frame.AbsolutePosition
            local frameSize = frame.AbsoluteSize
            local ratio = self.Orientation == "Horizontal" and math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1) or math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
            self:UpdateValue(self.Min + (self.Max - self.Min) * ratio)
            logger:debug("Slider clicked: Mouse Position: (%d, %d), Ratio: %.2f", mousePos.X, mousePos.Y, ratio)
        end
    end))

    -- Dragging handling
    self.DragHandler = Draggable.new(notch, notch)
    table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
        if self.DragHandler.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position
            local framePos = frame.AbsolutePosition
            local frameSize = frame.AbsoluteSize
            local ratio = self.Orientation == "Horizontal" and math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1) or math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
            self:UpdateValue(self.Min + (self.Max - self.Min) * ratio)
            logger:debug("Slider dragged: Mouse Position: (%d, %d), Ratio: %.2f", mousePos.X, mousePos.Y, ratio)
        end
    end))

    -- Add hover effect to the notch
    Animation:HoverEffect(notch)

    -- Cleanup method
    function self:Destroy()
        for _, connection in ipairs(self.Connections) do
            connection:Disconnect()
        end
        self.Connections = {}
        if self.DragHandler then
            self.DragHandler:Destroy()
        end
        if self.NotchShadow then
            self.NotchShadow:Destroy()
        end
        self.Instance:Destroy()
        logger:info("Slider destroyed")
    end

    -- Set initial value
    self:UpdateValue(default)

    return self
end

function Slider:SetValue(value)
    self:UpdateValue(value)
end

return Slider
