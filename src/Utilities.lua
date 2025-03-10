-- Utilities.lua: Helper functions for the CensuraG API
local Utilities = {}

function Utilities.createInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

-- Method to create a tapered shadow effect using an ImageLabel
function Utilities.createTaperedShadow(parent, offsetX, offsetY, sizeFactor, transparency)
    local shadow = Utilities.createInstance("ImageLabel", {
        Parent = parent.Parent, -- Parent to ScreenGui for independent movement
        Size = UDim2.new(0, parent.Size.X.Offset + offsetX * 2, 0, parent.Size.Y.Offset + offsetY * 2),
        Position = UDim2.new(0, parent.Position.X.Offset - offsetX, 0, parent.Position.Y.Offset - offsetY),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857472", -- Pre-rendered blurred shadow image (adjust if needed)
        ImageTransparency = transparency or 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 50, 50), -- Defines the stretchable area
        ZIndex = parent.ZIndex - 1 -- Below the window
    })
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0) -- Black shadow color
    return shadow
end

return Utilities
