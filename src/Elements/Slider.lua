-- Slider.lua: Enhanced slider with draggable notch, click support, and customization
local Slider = setmetatable({}, {__index = _G.CensuraG.UIElement})
Slider.__index = Slider

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local Draggable = _G.CensuraG.Draggable
local UserInputService = game:GetService("UserInputService")

function Slider.new(parent, x, y, width, min, max, default, options)
    -- Validate inputs
    min = min or 0
    max = max or 100
    default = math.clamp(default or min, min, max)
    options = options or {}

    -- Create slider frame
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width, 0, 10),
        ClipsDescendants = true
    })
    Styling:Apply(frame, "Frame")

    -- Fill bar (more visible)
    local fill = Utilities.createInstance("Frame", {
        Parent = frame,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 120, 215) -- Bright blue for visibility
    })

    -- Draggable notch (distinct styling)
    local notch = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new((default - min) / (max - min), -5, 0, -5),
        Size = UDim2.new(0, 10, 0, 20),
        BackgroundColor3 = Color3.fromRGB(200, 200, 200), -- Light gray for visibility
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(80, 80, 80)
    })

    -- Optional value label
    local label = options.ShowValue and Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, -25),
        Size = UDim2.new(1, 0, 0, 20),
        Text = tostring(default),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.Code,
        TextSize = 12
    }) or nil

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

    -- Update value and visuals (internal method)
    function self:UpdateValue(newValue)
        newValue = math.clamp(math.floor(newValue / self.Step) * self.Step, self.Min, self.Max)
        self.Value = newValue
        local ratio = (newValue - self.Min) / (self.Max - self.Min)
        if self.Orientation == "Horizontal" then
            Animation:Tween(self.Fill, {Size = UDim2.new(ratio, 0, 1, 0)})
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
    end

    -- Click support
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = input.Position
            local framePos = frame.AbsolutePosition
            local frameSize = frame.AbsoluteSize
            local ratio
            if self.Orientation == "Horizontal" then
                ratio = math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1)
            else
                ratio = math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
            end
            self:UpdateValue(self.Min + (self.Max - self.Min) * ratio)
        end
    end)

    -- Draggable notch with bounds
    self.DragHandler = Draggable.new(notch, notch)
    local connection = UserInputService.InputChanged:Connect(function(input)
        if self.DragHandler.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position
            local framePos = frame.AbsolutePosition
            local frameSize = frame.AbsoluteSize
            local ratio
            if self.Orientation == "Horizontal" then
                ratio = math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1)
            else
                ratio = math.clamp((mousePos.Y - framePos.Y) / frameSize.Y, 0, 1)
            end
            self:UpdateValue(self.Min + (self.Max - self.Min) * ratio)
        end
    end)

    -- Cleanup method
    function self:Destroy()
        connection:Disconnect()
        self.DragHandler:Destroy()
        self.Instance:Destroy()
    end

    -- Initial value set
    self:UpdateValue(default)

    return self
end

-- Public method to set value programmatically
function Slider:SetValue(value)
    self:UpdateValue(value) -- Fixed: Call the correct method
end

return Slider
