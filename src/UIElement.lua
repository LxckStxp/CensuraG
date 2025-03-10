-- UIElement.lua: Base class for UI elements
local UIElement = {}
UIElement.__index = UIElement

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local logger = _G.CensuraG.Logger

function UIElement.new(parent, x, y, width, height)
    if not parent or not parent.Instance then return nil end

    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x or 0, 0, y or 0),
        Size = UDim2.new(0, width or 100, 0, height or 100),
        BackgroundTransparency = Styling.Transparency.ElementBackground,
        ZIndex = parent.Instance.ZIndex + 1
    })
    Styling:Apply(frame, "Frame")

    local self = setmetatable({
        Instance = frame,
        Connections = {}
    }, UIElement)

    table.insert(self.Connections, frame.AncestryChanged:Connect(function()
        if not frame:IsDescendantOf(game) then self:Destroy() end
    end))

    return self
end

function UIElement:Destroy()
    for _, conn in ipairs(self.Connections) do conn:Disconnect() end
    if self.Instance then self.Instance:Destroy() end
    logger:info("UIElement destroyed")
end

return UIElement
