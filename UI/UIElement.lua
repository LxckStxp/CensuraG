-- UI/UIElement.lua: Base class for UI elements
local UIElement = {}
UIElement.__index = UIElement

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local EventManager = _G.CensuraG.EventManager
local logger = _G.CensuraG.Logger

-- Create a new UI element
function UIElement.new(parent, x, y, width, height, options)
    if not parent or not parent.Instance then
        logger:error("Invalid parent for UIElement")
        return nil
    end
    
    options = options or {}
    
    -- Create the frame
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x or 0, 0, y or 0),
        Size = UDim2.new(0, width or 100, 0, height or 100),
        BackgroundTransparency = Styling.Transparency.ElementBackground,
        ZIndex = parent.Instance.ZIndex + 1,
        Name = options.Name or "UIElement"
    })
    
    Styling:Apply(frame, "Frame")
    
    -- Create the self object
    local self = setmetatable({
        Instance = frame,
        Parent = parent,
        Connections = {},
        Children = {},
        Id = Utilities.generateId(),
        Options = options
    }, UIElement)
    
    -- Track ancestry changes to handle cleanup
    table.insert(self.Connections, EventManager:Connect(
        frame.AncestryChanged, 
        function(_, newParent)
            if not newParent then
                self:Destroy()
            end
        end
    ))
    
    -- Subscribe to theme changes
    table.insert(self.Connections, EventManager:SubscribeToEvent(
        "ThemeChanged",
        function()
            self:UpdateTheme()
        end
    ))
    
    return self
end

-- Update the element's theme
function UIElement:UpdateTheme()
    Styling:Apply(self.Instance, "Frame")
    logger:debug("Updated theme for UIElement %s", self.Instance.Name)
end

-- Add a child element
function UIElement:AddChild(child)
    if not child then return false end
    
    table.insert(self.Children, child)
    logger:debug("Added child to %s: %s", self.Instance.Name, child.Instance.Name)
    
    return true
end

-- Remove a child element
function UIElement:RemoveChild(child)
    if not child then return false end
    
    for i, c in ipairs(self.Children) do
        if c == child then
            table.remove(self.Children, i)
            logger:debug("Removed child from %s: %s", self.Instance.Name, child.Instance.Name)
            return true
        end
    end
    
    return false
end

-- Set the element's position
function UIElement:SetPosition(x, y)
    self.Instance.Position = UDim2.new(0, x, 0, y)
    logger:debug("Set position of %s to (%d, %d)", self.Instance.Name, x, y)
end

-- Set the element's size
function UIElement:SetSize(width, height)
    self.Instance.Size = UDim2.new(0, width, 0, height)
    logger:debug("Set size of %s to (%d, %d)", self.Instance.Name, width, height)
end

-- Set the element's visibility
function UIElement:SetVisible(visible)
    self.Instance.Visible = visible
    logger:debug("Set visibility of %s to %s", self.Instance.Name, tostring(visible))
end

-- Set the element's Z-index
function UIElement:SetZIndex(zIndex)
    self.Instance.ZIndex = zIndex
    
    -- Update children Z-indices
    for _, child in ipairs(self.Children) do
        if child.SetZIndex then
            child:SetZIndex(zIndex + 1)
        end
    end
    
    logger:debug("Set ZIndex of %s to %d", self.Instance.Name, zIndex)
end

-- Clean up the element
function UIElement:Destroy()
    -- Destroy children first
    for _, child in ipairs(self.Children) do
        if child.Destroy then
            child:Destroy()
        end
    end
    self.Children = {}
    
    -- Disconnect all connections
    for _, connection in ipairs(self.Connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        elseif type(connection) == "string" then
            -- It's an event subscription ID
            EventManager:UnsubscribeFromEvent("ThemeChanged", connection)
        end
    end
    self.Connections = {}
    
    -- Destroy the instance
    if self.Instance then
        self.Instance:Destroy()
        self.Instance = nil
    end
    
    logger:info("UIElement destroyed: %s", self.Id)
end

return UIElement
