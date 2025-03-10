-- Utilities.lua: Helper functions for the CensuraG API
local Utilities = {}

function Utilities.createInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

-- Method to create a shadow effect for UI elements
function Utilities.createShadow(parent, offsetX, offsetY, color, transparency)
    local shadow = Utilities.createInstance("Frame", {
        Parent = parent,
        Size = UDim2.new(1, offsetX * 2, 1, offsetY * 2),
        Position = UDim2.new(0, -offsetX, 0, -offsetY),
        BackgroundColor3 = color or Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = transparency or 0.5,
        ZIndex = parent.ZIndex - 1
    })
    return shadow
end

return Utilities
