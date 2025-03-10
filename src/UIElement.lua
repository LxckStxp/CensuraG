-- UIElement.lua: Base class for all UI elements
local UIElement = {}
UIElement.__index = UIElement

function UIElement.new(instance)
    local self = setmetatable({}, UIElement)
    self.Instance = instance
    return self
end

function UIElement:SetPosition(x, y)
    self.Instance.Position = UDim2.new(0, x, 0, y)
end

return UIElement
