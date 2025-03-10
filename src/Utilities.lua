-- Utilities.lua: Helper functions
local Utilities = {}

function Utilities.createInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

function Utilities.createTaperedShadow(parent, offsetX, offsetY, transparency)
    local shadow = Utilities.createInstance("Frame", {
        Parent = parent.Parent,
        Size = UDim2.new(0, parent.Size.X.Offset + offsetX * 2, 0, parent.Size.Y.Offset + offsetY * 2),
        Position = UDim2.new(0, parent.Position.X.Offset - offsetX, 0, parent.Position.Y.Offset - offsetY),
        BackgroundTransparency = 1,
        ZIndex = parent.ZIndex - 1
    })

    local gradient = Utilities.createInstance("UIGradient", {
        Parent = shadow,
        Color = ColorSequence.new(Color3.fromRGB(0, 0, 0)),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, transparency or 0.9),
            NumberSequenceKeypoint.new(1, 1)
        }),
        Rotation = 90
    })

    return shadow
end

return Utilities
