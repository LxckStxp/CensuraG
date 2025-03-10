-- Slider.lua: Simplified slider with miltech styling and constrained knob movement
local Slider = setmetatable({}, {__index = _G.CensuraG.UIElement})
Slider.__index = Slider

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
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
    local height = 15 -- Fixed height for simplicity

    logger:debug("Creating slider with parent: %s, Position: (%d, %d), Width: %d", tostring(parent.Instance), x, y, width)

    -- Create the slider frame
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width, 0, height),
        BackgroundTransparency = 0.8,
        BackgroundColor3 = Styling.Colors.Base,
        ClipsDescendants = true, -- Clip notch to stay within frame
        Visible = true,
        ZIndex = 3
    })
    logger:debug("Slider frame created: Position: %s, Size: %s, ZIndex: %d", tostring(frame.Position), tostring(frame.Size), frame.ZIndex)

    -- Create the fill bar
    local fill = Utilities.createInstance("Frame", {
        Parent = frame,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0), -- Full height of track
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Styling.Colors.Accent,
        BackgroundTransparency = 0.3,
        Visible = true,
        ZIndex = 4
    })
    logger:debug("Slider fill created: Position: %s, Size: %s", tostring(fill.Position), tostring(fill.Size))

    -- Create the notch
    local notchSize = 10 -- Fixed size for simplicity
    local notch = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new((default - min) / (max - min), -(notchSize / 2), 0, -(height / 2)), -- Center notch on track
        Size = UDim2.new(0, notchSize, 0, height),
        BackgroundColor3 = Styling.Colors.Highlight,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Visible = true,
        ZIndex = 5
    })
    logger:debug("Slider notch created: Position: %s, Size: %s", tostring(notch.Position), tostring(notch.Size))

    -- Add a value label if enabled
    local label = options.ShowValue and Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, -20),
        Size = UDim2.new(1, 0, 0, 15),
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
        logger:debug("Slider label created: Position: %s, Size: %s, Text: %s", tostring(label.Position), tostring(label.Size), label.Text)
    end

    -- Initialize the slider object
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
        Connections = {}
    }, Slider)

    -- Update function for the slider value
    function self:UpdateValue(newValue)
        newValue = math.clamp(math.floor(newValue / self.Step) * self.Step, self.Min, self.Max)
        if newValue == self.Value then return end
        self.Value = newValue
        local ratio = (newValue - self.Min) / (max - min)
        if self.Orientation == "Horizontal" then
            Animation:Tween(self.Fill, {Size = UDim2.new(ratio, 0, 1, 0)}, 0.2)
            -- Constrain notch position within frame
            local newX = math.clamp(ratio, 0, 1) -- Ensure ratio stays between 0 and 1
            notch.Position = UDim2.new(newX, -(notchSize / 2), 0, -(height / 2))
        else
            Animation:Tween(self.Fill, {Size = UDim2.new(1, 0, ratio, 0)}, 0.2)
            local newY = math.clamp(ratio, 0, 1)
            notch.Position = UDim2.new(0, -(notchSize / 2), newY, -(height / 2))
        end
        if self.Label then
            self.Label.Text = tostring(newValue)
        end
        if options.OnChanged then
            options.OnChanged(newValue)
        end
        logger:debug("Slider value updated: New Value: %d, Fill Size: %s, Notch Position: %s", newValue, tostring(self.Fill.Size), tostring(notch.Position))
    end

    -- Click handling
    table.insert(self.Connections, frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = input.Position
            local framePos = frame.AbsolutePosition
            local frameSize = frame.AbsoluteSize
            local ratio = self.Orientation == "Horizontal" and math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1) or math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
            self:UpdateValue(self.Min + (self.Max - self.Min) * ratio)
        end
    end))

    -- Dragging handling (simplified, no separate Draggable object)
    table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local mousePos = input.Position
            local framePos = frame.AbsolutePosition
            local frameSize = frame.AbsoluteSize
            local ratio = self.Orientation == "Horizontal" and math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1) or math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
            self:UpdateValue(self.Min + (self.Max - self.Min) * ratio)
        end
    end))

    -- Cleanup method
    function self:Destroy()
        for _, connection in ipairs(self.Connections) do
            connection:Disconnect()
        end
        self.Connections = {}
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
