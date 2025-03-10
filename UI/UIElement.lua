-- UI/UIElement.lua
-- Enhanced base class for UI elements with common functionality

local UIElement = {}
UIElement.__index = UIElement

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager
local ErrorHandler = _G.CensuraG.ErrorHandler
local logger = _G.CensuraG.Logger

--[[ 
    Creates a new UI element
    @param parent - The parent element or container
    @param options - Configuration table with the following fields:
        - x, y: Position offsets (default: 0)
        - width, height: Size dimensions (default: 100)
        - name: Element name (default: "UIElement")
        - zIndex: Z-index offset from parent (default: 1)
        - visible: Initial visibility (default: true)
        - styleType: Style to apply (default: "Frame")
        - transparent: Whether background should be transparent (default: true)
        - anchorPoint: Element anchor point (default: Vector2.new(0, 0))
        - autoDestroy: Whether to auto-destroy when parent is destroyed (default: true)
        - Any other properties to apply to the instance
    @return The created UIElement object
]]
function UIElement.new(parent, options)
    assert(parent, "Parent cannot be nil")
    
    -- Handle different parent types
    local parentInstance = parent.Instance or parent
    assert(parentInstance:IsA("GuiObject") or parentInstance:IsA("LayerCollector"), 
        "Parent must be a GuiObject or LayerCollector")
    
    -- Process options
    options = options or {}
    local x = options.x or options.X or 0
    local y = options.y or options.Y or 0
    local width = options.width or options.Width or 100
    local height = options.height or options.Height or 100
    local name = options.name or options.Name or "UIElement"
    local zIndex = (options.zIndex or options.ZIndex or 1) + (parentInstance.ZIndex or 0)
    local visible = options.visible ~= false
    local styleType = options.styleType or "Frame"
    local transparent = options.transparent ~= false
    local anchorPoint = options.anchorPoint or Vector2.new(0, 0)
    local autoDestroy = options.autoDestroy ~= false
    
    -- Create base properties for instance
    local instanceProps = {
        Parent = parentInstance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width, 0, height),
        BackgroundTransparency = transparent and 1 or 0,
        ZIndex = zIndex,
        Visible = visible,
        Name = name,
        AnchorPoint = anchorPoint
    }
    
    -- Add any additional properties from options
    for k, v in pairs(options) do
        if instanceProps[k] == nil and 
           k ~= "x" and k ~= "y" and 
           k ~= "width" and k ~= "height" and 
           k ~= "name" and k ~= "zIndex" and 
           k ~= "visible" and k ~= "styleType" and 
           k ~= "transparent" and k ~= "anchorPoint" and
           k ~= "autoDestroy" and k ~= "X" and k ~= "Y" and
           k ~= "Width" and k ~= "Height" and k ~= "Name" and
           k ~= "ZIndex" and k ~= "Visible" and k ~= "StyleType" and
           k ~= "Transparent" and k ~= "AnchorPoint" and
           k ~= "AutoDestroy" then
            instanceProps[k] = v
        end
    end
    
    -- Create frame instance
    local frame = Utilities.createInstance("Frame", instanceProps)
    Styling:Apply(frame, styleType)
    
    -- Create the UIElement object
    local self = setmetatable({
        Instance = frame,
        Parent = parent,
        Children = {},
        Connections = {},
        Id = Utilities.generateId(),
        Options = options,
        ClassName = "UIElement",
        IsDestroyed = false,
        HoverEffects = {},
        ClickHandlers = {}
    }, UIElement)
    
    -- Set up auto-destroy when parent is destroyed
    if autoDestroy then
        table.insert(self.Connections, EventManager:Connect(frame.AncestryChanged, function(_, newParent)
            if not newParent and not self.IsDestroyed then 
                self:Destroy() 
            end
        end))
    end
    
    -- Set up theme change listener
    table.insert(self.Connections, EventManager:SubscribeToEvent("ThemeChanged", function() 
        self:UpdateTheme() 
    end))
    
    return self
end

--[[
    Updates the theme styling for this element
    @param styleType - Optional style type to apply (uses original if not specified)
]]
function UIElement:UpdateTheme(styleType)
    if self.IsDestroyed then return self end
    
    Styling:Apply(self.Instance, styleType or self.Options.styleType or "Frame")
    
    -- Notify children to update their themes too
    for _, child in ipairs(self.Children) do
        if child.UpdateTheme then 
            child:UpdateTheme() 
        end
    end
    
    return self
end

--[[
    Adds a child element to this element
    @param child - The child element to add
    @return self for chaining
]]
function UIElement:AddChild(child)
    if self.IsDestroyed then return self end
    if not child then return self end
    
    table.insert(self.Children, child)
    
    -- If child doesn't already have this as parent, set it
    if child.Instance and child.Instance.Parent ~= self.Instance then
        child.Instance.Parent = self.Instance
        child.Parent = self
    end
    
    return self
end

--[[
    Removes a child element from this element
    @param child - The child element to remove
    @return self for chaining
]]
function UIElement:RemoveChild(child)
    if self.IsDestroyed then return self end
    if not child then return self end
    
    for i, c in ipairs(self.Children) do
        if c == child then 
            table.remove(self.Children, i)
            break
        end
    end
    
    return self
end

--[[
    Sets the position of this element
    @param x - X position offset
    @param y - Y position offset
    @return self for chaining
]]
function UIElement:SetPosition(x, y)
    if self.IsDestroyed then return self end
    
    self.Instance.Position = UDim2.new(0, x, 0, y)
    return self
end

--[[
    Sets the size of this element
    @param width - Width dimension
    @param height - Height dimension
    @return self for chaining
]]
function UIElement:SetSize(width, height)
    if self.IsDestroyed then return self end
    
    self.Instance.Size = UDim2.new(0, width, 0, height)
    return self
end

--[[
    Sets the visibility of this element
    @param visible - Whether the element should be visible
    @param recursive - Whether to apply to children as well (default: false)
    @return self for chaining
]]
function UIElement:SetVisible(visible, recursive)
    if self.IsDestroyed then return self end
    
    self.Instance.Visible = visible
    
    if recursive then
        for _, child in ipairs(self.Children) do
            if child.SetVisible then 
                child:SetVisible(visible, true) 
            elseif child.Instance then
                child.Instance.Visible = visible
            end
        end
    end
    
    return self
end

--[[
    Sets the z-index of this element
    @param zIndex - The new z-index
    @param recursive - Whether to apply to children as well (default: true)
    @return self for chaining
]]
function UIElement:SetZIndex(zIndex, recursive)
    if self.IsDestroyed then return self end
    
    self.Instance.ZIndex = zIndex
    
    if recursive ~= false then
        for _, child in ipairs(self.Children) do
            if child.SetZIndex then 
                child:SetZIndex(zIndex + 1, true) 
            elseif child.Instance then
                child.Instance.ZIndex = zIndex + 1
            end
        end
    end
    
    return self
end

--[[
    Sets a property on the underlying instance
    @param property - The property name
    @param value - The property value
    @return self for chaining
]]
function UIElement:SetProperty(property, value)
    if self.IsDestroyed then return self end
    
    if self.Instance[property] ~= nil then
        self.Instance[property] = value
    else
        logger:warn("Property %s does not exist on %s", property, self.Instance.ClassName)
    end
    
    return self
end

--[[
    Adds a hover effect to this element
    @param enterProps - Properties to tween to on hover
    @param leaveProps - Properties to tween to on leave
    @param options - Additional options (duration, style, etc.)
    @return self for chaining
]]
function UIElement:AddHoverEffect(enterProps, leaveProps, options)
    if self.IsDestroyed then return self end
    
    -- Clean up any existing hover effect
    self:RemoveHoverEffect()
    
    options = options or {}
    local effectId = options.id or "default"
    
    -- Create default props if not specified
    if not enterProps then
        local originalSize = self.Instance.Size
        enterProps = { 
            Size = UDim2.new(
                originalSize.X.Scale * 1.05, 
                originalSize.X.Offset, 
                originalSize.Y.Scale * 1.05, 
                originalSize.Y.Offset
            ),
            BackgroundTransparency = math.max(0, self.Instance.BackgroundTransparency - 0.1)
        }
    end
    
    if not leaveProps then
        leaveProps = {
            Size = self.Instance.Size,
            BackgroundTransparency = self.Instance.BackgroundTransparency
        }
    end
    
    -- Store original properties for restoring on leave
    self.HoverEffects[effectId] = {
        EnterProps = enterProps,
        LeaveProps = leaveProps,
        Connections = {}
    }
    
    -- Set up enter/leave events
    local enterConn = EventManager:Connect(self.Instance.MouseEnter, function()
        Animation:Tween(
            self.Instance, 
            enterProps, 
            options.duration or 0.2, 
            options.enterStyle, 
            options.enterDirection
        )
        if options.onEnter then options.onEnter(self) end
    end)
    
    local leaveConn = EventManager:Connect(self.Instance.MouseLeave, function()
        Animation:Tween(
            self.Instance, 
            leaveProps, 
            options.duration or 0.2, 
            options.leaveStyle, 
            options.leaveDirection
        )
        if options.onLeave then options.onLeave(self) end
    end)
    
    table.insert(self.HoverEffects[effectId].Connections, enterConn)
    table.insert(self.HoverEffects[effectId].Connections, leaveConn)
    
    return self
end

--[[
    Removes a hover effect from this element
    @param id - The ID of the hover effect to remove (default: "default")
    @return self for chaining
]]
function UIElement:RemoveHoverEffect(id)
    if self.IsDestroyed then return self end
    
    id = id or "default"
    
    if self.HoverEffects[id] then
        for _, conn in ipairs(self.HoverEffects[id].Connections) do
            conn:Disconnect()
        end
        self.HoverEffects[id] = nil
    end
    
    return self
end

--[[
    Adds a click handler to this element
    @param callback - Function to call when clicked
    @param options - Additional options (id, rightClick, etc.)
    @return self for chaining
]]
function UIElement:OnClick(callback, options)
    if self.IsDestroyed then return self end
    if not callback then return self end
    
    options = options or {}
    local id = options.id or "default"
    
    -- Remove existing handler with same id
    self:RemoveClickHandler(id)
    
    -- Create a click detector if the element doesn't natively support clicks
    local clickTarget
    if self.Instance:IsA("TextButton") or self.Instance:IsA("ImageButton") then
        clickTarget = self.Instance
    else
        -- Create a transparent button over the element
        clickTarget = Utilities.createInstance("TextButton", {
            Parent = self.Instance,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = self.Instance.ZIndex + 1,
            Name = "ClickDetector"
        })
    end
    
    -- Set up click handler
    local eventName = options.rightClick and "MouseButton2Click" or "MouseButton1Click"
    local connection = EventManager:Connect(clickTarget[eventName], function()
        ErrorHandler:TryCatch(callback, "Error in click handler", self)
        
        -- Add a bounce effect on click if specified
        if options.bounce then
            Animation:Tween(
                self.Instance, 
                { Size = UDim2.new(
                    self.Instance.Size.X.Scale * 1.05, 
                    self.Instance.Size.X.Offset, 
                    self.Instance.Size.Y.Scale * 1.05, 
                    self.Instance.Size.Y.Offset
                )}, 
                0.1, 
                nil, 
                nil, 
                function()
                    Animation:Tween(self.Instance, { Size = self.Instance.Size }, 0.1)
                end
            )
        end
    end)
    
    -- Store the handler information
    self.ClickHandlers[id] = {
        Connection = connection,
        Detector = clickTarget ~= self.Instance and clickTarget or nil
    }
    
    return self
end

--[[
    Removes a click handler from this element
    @param id - The ID of the click handler to remove (default: "default")
    @return self for chaining
]]
function UIElement:RemoveClickHandler(id)
    if self.IsDestroyed then return self end
    
    id = id or "default"
    
    if self.ClickHandlers[id] then
        if self.ClickHandlers[id].Connection then
            self.ClickHandlers[id].Connection:Disconnect()
        end
        
        if self.ClickHandlers[id].Detector then
            self.ClickHandlers[id].Detector:Destroy()
        end
        
        self.ClickHandlers[id] = nil
    end
    
    return self
end

--[[
    Animates this element using a tween
    @param properties - Properties to animate to
    @param duration - Duration of the animation in seconds
    @param easingStyle - Easing style (default: Quad)
    @param easingDirection - Easing direction (default: Out)
    @param callback - Function to call when animation completes
    @return The tween object
]]
function UIElement:Animate(properties, duration, easingStyle, easingDirection, callback)
    if self.IsDestroyed then return nil end
    
    return Animation:Tween(
        self.Instance, 
        properties, 
        duration, 
        easingStyle, 
        easingDirection, 
        callback
    )
end

--[[
    Adds a connection to the element's connections list for automatic cleanup
    @param connection - The connection to add
    @return self for chaining
]]
function UIElement:AddConnection(connection)
    if self.IsDestroyed then return self end
    if not connection then return self end
    
    table.insert(self.Connections, connection)
    return self
end

--[[
    Finds a child element by name
    @param name - The name to search for
    @param recursive - Whether to search recursively (default: false)
    @return The found child or nil
]]
function UIElement:FindChild(name, recursive)
    if self.IsDestroyed then return nil end
    
    -- First check direct Instance children
    local instanceChild = self.Instance:FindFirstChild(name)
    if instanceChild then return instanceChild end
    
    -- Then check our tracked Children table
    for _, child in ipairs(self.Children) do
        if child.Instance and child.Instance.Name == name then
            return child
        end
        
        if recursive and child.FindChild then
            local found = child:FindChild(name, true)
            if found then return found end
        end
    end
    
    return nil
end

--[[
    Destroys this element and cleans up all connections and children
    @param options - Additional destroy options
    @return true if destroyed successfully
]]
function UIElement:Destroy(options)
    if self.IsDestroyed then return true end
    
    options = options or {}
    self.IsDestroyed = true
    
    -- Call onDestroy callback if provided
    if self.OnDestroy then
        ErrorHandler:TryCatch(self.OnDestroy, "Error in OnDestroy callback", self)
    end
    
    -- Disconnect all event connections
    for _, conn in ipairs(self.Connections) do
        if type(conn) == "function" then
            -- Handle EventManager subscription IDs
            EventManager:UnsubscribeFromEvent("ThemeChanged", conn)
        else
            pcall(function() conn:Disconnect() end)
        end
    end
    self.Connections = {}
    
    -- Clean up hover effects
    for id, _ in pairs(self.HoverEffects) do
        self:RemoveHoverEffect(id)
    end
    
    -- Clean up click handlers
    for id, _ in pairs(self.ClickHandlers) do
        self:RemoveClickHandler(id)
    end
    
    -- Destroy all children
    if options.keepChildren ~= true then
        for i = #self.Children, 1, -1 do
            local child = self.Children[i]
            if child and child.Destroy then
                child:Destroy(options)
            end
        end
        self.Children = {}
    end
    
    -- Clean up animation effects
    if Animation and Animation.CleanupHoverEffects then
        Animation:CleanupHoverEffects(self.Instance)
    end
    if Animation and Animation.CancelTweens then
        Animation:CancelTweens(self.Instance)
    end
    
    -- Finally destroy the instance
    if self.Instance then
        ErrorHandler:SafeDestroy(self.Instance)
        self.Instance = nil
    end
    
    logger:debug("%s destroyed: %s", self.ClassName, self.Id)
    return true
end

--[[
    Creates a child element of the specified type
    @param childType - The type of child to create
    @param options - Options for the child
    @return The created child element
]]
function UIElement:CreateChild(childType, options)
    if self.IsDestroyed then return nil end
    
    options = options or {}
    options.parent = self
    
    local childModule = _G.CensuraG[childType]
    if not childModule or not childModule.new then
        logger:warn("Invalid child type: %s", childType)
        return nil
    end
    
    local child = childModule.new(options)
    if child then
        self:AddChild(child)
    end
    
    return child
end

--[[
    Creates a static factory method to simplify creation of UI elements
    @param className - The class name for the element
    @param constructor - The constructor function
    @return The factory function
]]
function UIElement.CreateFactory(className, constructor)
    return function(parent, options)
        options = options or {}
        options.className = className
        
        local element = constructor(parent, options)
        if not element then return nil end
        
        element.ClassName = className
        return element
    end
end

return UIElement
