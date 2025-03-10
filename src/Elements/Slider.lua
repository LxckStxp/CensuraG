-- Slider.lua: Slider with constrained draggable notch
local Slider = setmetatable({}, {__index = _G.CensuraG.UIElement})
Slider.__index = Slider

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local Draggable = _G.CensuraG.Draggable
local UserInputService = game:GetService("UserInputService")

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
        BackgroundColor3 = Styling.Colors.Highlight
    })
    Styling:Apply(fill, "Frame")
    
    local notch = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new((default - min) / (max - min), -5, 0, -5),
        Size = UDim2.new(0, 10, 0, 20),
        BackgroundColor3 = Styling.Colors.Accent,
        BorderSizePixel = 1,
        BorderColor3 = Styling.Colors.Border
    })
    
    local self = setmetatable({
        Instance = frame,
        Value = default,
        Min = min,
        Max = max,
        Fill = fill,
        Notch = notch
    }, Slider)
    
    -- Draggable notch with constraints
    self.DragHandler = Draggable.new(notch, {
        DragRegion = notch,
        AxisLock = "X", -- Lock to horizontal movement
        Bounds = {
            MinX = -5, -- Notch offset
            MaxX = width - 5, -- Width minus notch offset
            MinY = -5,
            MaxY = -5
        },
        OnDrag = function(_, newPos)
            local relativeX = newPos.X.Offset + 5 -- Adjust for notch offset
            local ratio = math.clamp(relativeX / width, 0, 1)
            self.Value = min + (max - min) * ratio
            Animation:Tween(fill, {Size = UDim2.new(ratio, 0, 1, 0)})
            if callback then callback(self.Value) end
        end
    })
    
    return self
end

return Slider
