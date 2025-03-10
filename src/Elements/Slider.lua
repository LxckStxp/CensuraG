-- Slider.lua: Slider class
local Slider = setmetatable({}, {__index = require(script.Parent.Parent.UIElement)})
Slider.__index = Slider

local Utilities = require(script.Parent.Parent.Utilities)

function Slider.new(parent, x, y, width, min, max, default, callback)
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width, 0, 10),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    })
    
    local fill = Utilities.createInstance("Frame", {
        Parent = frame,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    })
    
    local self = setmetatable({Instance = frame, Value = default, Min = min, Max = max}, Slider)
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouseX = input.Position.X - frame.AbsolutePosition.X
            local ratio = math.clamp(mouseX / frame.AbsoluteSize.X, 0, 1)
            self.Value = min + (max - min) * ratio
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            if callback then callback(self.Value) end
        end
    end)
    
    return self
end

return Slider
