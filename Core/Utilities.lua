-- Core/Utilities.lua: Enhanced helper functions
local Utilities = {}
local logger = _G.CensuraG.Logger

-- Create an instance with properties
function Utilities.createInstance(className, properties)
    local success, instance = pcall(function()
        local inst = Instance.new(className)
        for prop, value in pairs(properties or {}) do
            inst[prop] = value
        end
        return inst
    end)
    
    if not success then
        logger:error("Failed to create %s instance: %s", className, tostring(instance))
        return nil
    end
    
    return instance
end

-- Create a tapered shadow effect
function Utilities.createTaperedShadow(parent, offsetX, offsetY, transparency)
    if not parent then return nil end
    
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

-- Deep copy a table
function Utilities.deepCopy(original)
    local copy
    if type(original) == "table" then
        copy = {}
        for key, value in pairs(original) do
            copy[key] = Utilities.deepCopy(value)
        end
    else
        copy = original
    end
    return copy
end

-- Format number with commas
function Utilities.formatNumber(number)
    local formatted = tostring(number)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Truncate text with ellipsis
function Utilities.truncateText(text, maxLength)
    if string.len(text) <= maxLength then
        return text
    end
    return string.sub(text, 1, maxLength - 3) .. "..."
end

-- Get screen dimensions
function Utilities.getScreenSize()
    if _G.CensuraG and _G.CensuraG.ScreenGui then
        return _G.CensuraG.ScreenGui.AbsoluteSize
    end
    return Vector2.new(1366, 768) -- Default fallback
end

-- Check if point is within a UI element
function Utilities.isPointInElement(element, point)
    if not element or not element.AbsolutePosition or not element.AbsoluteSize then
        return false
    end
    
    local pos = element.AbsolutePosition
    local size = element.AbsoluteSize
    
    return point.X >= pos.X and point.X <= pos.X + size.X and
           point.Y >= pos.Y and point.Y <= pos.Y + size.Y
end

-- Generate a unique ID
function Utilities.generateId()
    return string.format("%x", os.time() + math.random(1, 1000000))
end

-- Safely get player avatar
function Utilities.getPlayerAvatar(userId, size)
    size = size or Enum.ThumbnailSize.Size100x100
    local Players = game:GetService("Players")
    
    local success, result = pcall(function()
        return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.AvatarBust, size)
    end)
    
    if success then
        return result
    else
        logger:warn("Failed to get avatar for user %s: %s", tostring(userId), tostring(result))
        return "rbxassetid://0" -- Default placeholder
    end
end

return Utilities
