-- src/UIElement.lua: Base class for all UI elements with modern miltech styling and enhanced functionality
local UIElement = {}
UIElement.__index = UIElement

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local logger = _G.CensuraG.Logger or print -- Fallback if Logger isn't initialized

-- Constructor for UIElement (to be overridden by derived classes)
function UIElement.new(parent, x, y, width, height)
    if not parent or not parent.Instance or not parent.Instance:IsA("GuiObject") then
        logger("Error: Invalid parent for UIElement: " .. tostring(parent))
        return nil
    end

    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x or 0, 0, y or 0),
        Size = UDim2.new(0, width or 100, 0, height or 100),
        BackgroundTransparency = Styling.Transparency.Background,
        ZIndex = parent.Instance.ZIndex + 1
    })
    if not frame then
        logger("Error: Failed to create Frame for UIElement")
        return nil
    end
    Styling:Apply(frame, "Frame")
    logger("Debug: UIElement frame created: Position: " .. tostring(frame.Position) .. ", Size: " .. tostring(frame.Size) .. ", ZIndex: " .. frame.ZIndex)

    local self = setmetatable({
        Instance = frame,
        Parent = parent.Instance,
        Connections = {},
        ZIndex = frame.ZIndex
    }, UIElement)

    -- Ensure proper cleanup on destruction
    table.insert(self.Connections, frame.AncestryChanged:Connect(function()
        if not frame:IsDescendantOf(game) then
            self:Destroy()
        end
    end))

    return self
end

-- Method to update ZIndex relative to parent
function UIElement:SetZIndex(newZIndex)
    if self.Instance then
        self.ZIndex = math.max(newZIndex or (self.Parent.ZIndex + 1), 2)
        self.Instance.ZIndex = self.ZIndex
        logger("Debug: Updated ZIndex for " .. tostring(self.Instance) .. " to " .. self.ZIndex)
    else
        logger("Warning: Cannot set ZIndex, Instance is nil")
    end
end

-- Method to destroy the UI element and its connections
function UIElement:Destroy()
    if self.Instance then
        for _, connection in ipairs(self.Connections) do
            if connection and typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            end
        end
        self.Connections = {}
        self.Instance:Destroy()
        logger("Info: UIElement destroyed: " .. tostring(self.Instance))
    else
        logger("Warning: Attempted to destroy nil UIElement instance")
    end
end

-- Method to check if the element is valid
function UIElement:IsValid()
    return self.Instance and self.Instance.Parent ~= nil
end

return UIElement
