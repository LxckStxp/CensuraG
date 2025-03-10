-- Slider.lua: Draggable slider
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
        BackgroundColor3 = Styling.Colors.Highlight
    })
    Styling:Apply(fill, "Frame")
    
    local self = setmetatable({Instance = frame, Value = default, Min = min, Max = max, Fill = fill}, Slider)
    
    -- Draggable slider logic
    Draggable:MakeDraggable(frame, frame, nil, function(_, _)
        local mouseX = UserInputService:GetMouseLocation().X - frame.AbsolutePosition.X
        local ratio = math.clamp(mouseX / frame.AbsoluteSize.X, 0, 1)
        self.Value = min + (max - min) * ratio
        Animation:Tween(fill, {Size = UDim2.new(ratio, 0, 1, 0)})
        if callback then callback(self.Value) end
    end)
    
    return self
end

return Slider
