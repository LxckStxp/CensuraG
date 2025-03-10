-- Slider.lua: Slider with a constrained draggable notch
local Slider = setmetatable({}, {__index = _G.CensuraG.UIElement})
Slider.__index = Slider

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local Draggable = _G.CensuraG.Draggable

function Slider.new(parent, x, y, width, min, max, default, callback)
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width, 0, 10)
    })
    Styling:Apply(frame, "Frame")

    local fill = Utilities.createInstance("Frame", {
        Parent = frame,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Styling.Colors.Accent
    })

    local notch = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new((default - min) / (max - min), -5, 0, -5),
        Size = UDim2.new(0, 10, 0, 20),
        BackgroundColor3 = Styling.Colors.Highlight
    })

    local self = setmetatable({
        Instance = frame,
        Value = default,
        Min = min,
        Max = max,
        Fill = fill,
        Notch = notch
    }, Slider)

    -- Draggable notch with bounds
    self.DragHandler = Draggable.new(notch, notch)
    local connection = game:GetService("UserInputService").InputChanged:Connect(function(input)
        if self.DragHandler.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local newX = self.DragHandler.StartPos.X.Offset + (input.Position - self.DragHandler.DragStart).X
            newX = math.clamp(newX, -5, width - 5)
            self.Notch.Position = UDim2.new(0, newX, 0, -5)
            local ratio = (newX + 5) / width
            self.Value = min + (max - min) * ratio
            Animation:Tween(fill, {Size = UDim2.new(ratio, 0, 1, 0)})
            if callback then callback(self.Value) end
        end
    end)

    function self:Destroy()
        connection:Disconnect()
        self.DragHandler:Destroy()
    end

    return self
end

return Slider
