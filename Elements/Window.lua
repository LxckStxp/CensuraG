-- Elements/Window.lua: Enhanced window element
local Window = setmetatable({}, {__index = _G.CensuraG.UIElement})
Window.__index = Window

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local Draggable = _G.CensuraG.Draggable
local EventManager = _G.CensuraG.EventManager
local logger = _G.CensuraG.Logger

-- Create a new window
function Window.new(title, x, y, width, height, options)
    options = options or {}
    width = width or 300
    height = height or 200
    
    -- Create the main frame
    local frame = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Position = UDim2.new(0, x or 100, 0, y or 100),
        Size = UDim2.new(0, width, 0, height),
        ZIndex = 10,
        Name = "Window_" .. (options.Name or title or "Unnamed")
    })
    Styling:Apply(frame, "Window")
    
    -- Create shadow effect
    local shadow = Utilities.createTaperedShadow(frame, 5, 5, 0.9)
    shadow.ZIndex = frame.ZIndex - 1
    
    -- Create title bar
    local titleBarHeight = 25
    local titleBar = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, titleBarHeight),
        BackgroundColor3 = Styling.Colors.Secondary,
        BackgroundTransparency = Styling.Transparency.ElementBackground - 0.1,
        ZIndex = frame.ZIndex + 1,
        Name = "TitleBar"
    })
    Styling:Apply(titleBar, "Frame")
    
    -- Create title text
    local titleText = Utilities.createInstance("TextLabel", {
        Parent = titleBar,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Text = title or "Window",
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        ZIndex = titleBar.ZIndex + 1,
        Name = "TitleText"
    })
    Styling:Apply(titleText, "TextLabel")
    
    -- Create control buttons
    local buttonSize = titleBarHeight - 6
    
    -- Minimize button
    local minimizeButton = Utilities.createInstance("TextButton", {
        Parent = titleBar,
        Position = UDim2.new(1, -buttonSize*2 - 8, 0, 3),
        Size = UDim2.new(0, buttonSize, 0, buttonSize),
        Text = "-",
        ZIndex = titleBar.ZIndex + 1,
        Name = "MinimizeButton"
    })
    Styling:Apply(minimizeButton, "TextButton")
    Animation:HoverEffect(minimizeButton)
    
    -- Maximize/restore button
    local maximizeButton = Utilities.createInstance("TextButton", {
        Parent = titleBar,
        Position = UDim2.new(1, -buttonSize*1 - 5, 0, 3),
        Size = UDim2.new(0, buttonSize, 0, buttonSize),
        Text = "□",
        ZIndex = titleBar.ZIndex + 1,
        Name = "MaximizeButton"
    })
    Styling:Apply(maximizeButton, "TextButton")
    Animation:HoverEffect(maximizeButton)
    
    -- Content container
    local contentContainer = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new(0, 5, 0, titleBarHeight + 5),
        Size = UDim2.new(1, -10, 1, -titleBarHeight - 10),
        BackgroundTransparency = 1,
        ZIndex = frame.ZIndex + 1,
        Name = "ContentContainer"
    })
    
    -- Create self object
    local self = setmetatable({
        Instance = frame,
        Shadow = shadow,
        TitleBar = titleBar,
        TitleText = titleText,
        MinimizeButton = minimizeButton,
        MaximizeButton = maximizeButton,
        ContentContainer = contentContainer,
        Minimized = false,
        Maximized = false,
        CurrentPosition = frame.Position,
        OriginalPosition = frame.Position,
        OriginalSize = frame.Size,
        DragHandler = nil,
        Id = Utilities.generateId(),
        Options = options
    }, Window)
    
    -- Set up dragging
    self.DragHandler = Draggable.new(frame, titleBar, {
        OnDragStart = function()
            EventManager:FireEvent("WindowDragStart", self)
        end,
        OnDragEnd = function()
            EventManager:FireEvent("WindowDragEnd", self)
        end
    })
    
    -- Add to window manager
    if _G.CensuraG.WindowManager then
        _G.CensuraG.WindowManager:AddWindow(self)
    end
    
    -- Set up button events
    minimizeButton.MouseButton1Click:Connect(function()
        self:Minimize()
    end)
    
    maximizeButton.MouseButton1Click:Connect(function()
        if self.Maximized then
            self:Restore()
        else
            self:Maximize()
        end
    end)
    
    -- Apply any custom options
    if options.Modal then
        self:SetModal(true)
    end
    
    if options.Resizable ~= false then
        self:MakeResizable()
    end
    
    logger:info("Created window: %s", title or "Unnamed")
    EventManager:FireEvent("WindowCreated", self)
    
    return self
end

-- Minimize the window
function Window:Minimize()
    if self.Minimized or self.Debounce then return end
    self.Debounce = true
    self.Minimized = true
    
    -- Store current position
    self.CurrentPosition = self.Instance.Position
    
    -- Calculate target position (off-screen)
    local screenHeight = _G.CensuraG.ScreenGui.AbsoluteSize.Y
    
    -- Animate window off-screen
    Animation:SlideY(self.Instance, screenHeight + 50, 0.3, nil, nil, function()
        self.Instance.Visible = false
        self.Shadow.Visible = false
        self:UpdateChildrenVisibility(false)
        self.Debounce = false
        
        logger:debug("Window minimized: %s", self.TitleText.Text)
        EventManager:FireEvent("WindowMinimized", self)
    end)
    
    -- Animate shadow
    Animation:SlideY(self.Shadow, screenHeight + 45, 0.3)
    
    -- Add to taskbar
    if _G.CensuraG.Taskbar then
        _G.CensuraG.Taskbar:AddWindow(self)
    end
end

-- Maximize the window
function Window:Maximize()
    if self.Minimized then
        -- If minimized, restore first
        self:Restore(function()
            self:Maximize()
        end)
        return
    end
    
    if self.Maximized or self.Debounce then return end
    self.Debounce = true
    
    -- Store original size and position
    self.OriginalPosition = self.Instance.Position
    self.OriginalSize = self.Instance.Size
    
    -- Get screen dimensions
    local screenSize = Utilities.getScreenSize()
    
    -- Animate to full screen
    Animation:Tween(self.Instance, {
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, screenSize.X, 0, screenSize.Y - 40) -- Leave space for taskbar
    }, 0.3, nil, nil, function()
        self.Maximized = true
        self.Debounce = false
        
        -- Update maximize button text
        self.MaximizeButton.Text = "❐"
        
        logger:debug("Window maximized: %s", self.TitleText.Text)
        EventManager:FireEvent("WindowMaximized", self)
    end)
    
    -- Update shadow
    Animation:Tween(self.Shadow, {
        Position = UDim2.new(0, -5, 0, -5),
        Size = UDim2.new(0, screenSize.X + 10, 0, screenSize.Y - 30)
    }, 0.3)
end

-- Restore the window from minimized or maximized state
function Window:Restore(callback)
    if not self.Minimized and not self.Maximized then return end
    
    if self.Minimized then
        self.Debounce = true
        self.Instance.Visible = true
        self.Shadow.Visible = true
        
        local targetY = self.CurrentPosition.Y.Offset
        
        Animation:SlideY(self.Instance, targetY, 0.3, nil, nil, function()
            self:UpdateChildrenVisibility(true)
            self.Minimized = false
            self.Debounce = false
            
            logger:debug("Window restored from minimized: %s", self.TitleText.Text)
            EventManager:FireEvent("WindowRestored", self)
            
            if callback then callback() end
        end)
        
        Animation:SlideY(self.Shadow, targetY - 5, 0.3)
        
        -- Remove from taskbar
        if _G.CensuraG.Taskbar then
            _G.CensuraG.Taskbar:RemoveWindow(self)
        end
    elseif self.Maximized then
        self.Debounce = true
        
        Animation:Tween(self.Instance, {
            Position = self.OriginalPosition,
            Size = self.OriginalSize
        }, 0.3, nil, nil, function()
            self.Maximized = false
            self.Debounce = false
            
            -- Update maximize button text
            self.MaximizeButton.Text = "□"
            
            logger:debug("Window restored from maximized: %s", self.TitleText.Text)
            EventManager:FireEvent("WindowRestored", self)
            
            if callback then callback() end
        end)
        
        -- Update shadow
        Animation:Tween(self.Shadow, {
            Position = UDim2.new(0, self.OriginalPosition.X.Offset - 5, 0, self.OriginalPosition.Y.Offset - 5),
            Size = UDim2.new(0, self.OriginalSize.X.Offset + 10, 0, self.OriginalSize.Y.Offset + 10)
        }, 0.3)
    end
end

-- Update visibility of child elements
function Window:UpdateChildrenVisibility(visible)
    for _, child in pairs(self.Instance:GetChildren()) do
        if child:IsA("GuiObject") then
            child.Visible = visible
        end
    end
end

-- Make the window resizable
function Window:MakeResizable()
    local resizeHandleSize = 10
    local minWidth = 200
    local minHeight = 100
    
    -- Create resize handles
    local handles = {
        -- Bottom right corner
        Utilities.createInstance("TextButton", {
            Parent = self.Instance,
            Position = UDim2.new(1, -resizeHandleSize, 1, -resizeHandleSize),
            Size = UDim2.new(0, resizeHandleSize, 0, resizeHandleSize),
            Text = "",
            BackgroundTransparency = 1,
            ZIndex = self.Instance.ZIndex + 2,
            Name = "ResizeHandleBR"
        }),
        -- Bottom edge
        Utilities.createInstance("TextButton", {
            Parent = self.Instance,
            Position = UDim2.new(0, resizeHandleSize, 1, -resizeHandleSize),
            Size = UDim2.new(1, -resizeHandleSize*2, 0, resizeHandleSize),
            Text = "",
            BackgroundTransparency = 1,
            ZIndex = self.Instance.ZIndex + 2,
            Name = "ResizeHandleB"
        }),
        -- Right edge
        Utilities.createInstance("TextButton", {
            Parent = self.Instance,
            Position = UDim2.new(1, -resizeHandleSize, 0, resizeHandleSize),
            Size = UDim2.new(0, resizeHandleSize, 1, -resizeHandleSize*2),
            Text = "",
            BackgroundTransparency = 1,
            ZIndex = self.Instance.ZIndex + 2,
            Name = "ResizeHandleR"
        })
    }
    
    -- Set up resize functionality
    for i, handle in ipairs(handles) do
        local isResizing = false
        local startPos = nil
        local startSize = nil
        
        handle.MouseButton1Down:Connect(function(x, y)
            if self.Maximized then return end
            
            isResizing = true
            startPos = Vector2.new(x, y)
            startSize = self.Instance.Size
            
            -- Bring window to front when resizing
            if _G.CensuraG.WindowManager then
                _G.CensuraG.WindowManager:BringToFront(self)
            end
            
            EventManager:FireEvent("WindowResizeStart", self)
        end)
        
        handle.MouseButton1Up:Connect(function()
            isResizing = false
            EventManager:FireEvent("WindowResizeEnd", self)
        end)
        
        handle.MouseMoved:Connect(function(x, y)
            if not isResizing then return end
            
            local delta = Vector2.new(x, y) - startPos
            local newSize = startSize
            
            -- Apply resize based on handle type
            if i == 1 then -- Bottom right corner
                newSize = UDim2.new(0, math.max(startSize.X.Offset + delta.X, minWidth), 
                                   0, math.max(startSize.Y.Offset + delta.Y, minHeight))
            elseif i == 2 then -- Bottom edge
                newSize = UDim2.new(0, startSize.X.Offset, 
                                   0, math.max(startSize.Y.Offset + delta.Y, minHeight))
            elseif i == 3 then -- Right edge
                newSize = UDim2.new(0, math.max(startSize.X.Offset + delta.X, minWidth), 
                                   0, startSize.Y.Offset)
            end
            
            -- Update window size
            self.Instance.Size = newSize
            
            -- Update shadow
            self.Shadow.Size = UDim2.new(0, newSize.X.Offset + 10, 0, newSize.Y.Offset + 10)
            
            -- Update content container
            self.ContentContainer.Size = UDim2.new(1, -10, 1, -self.TitleBar.Size.Y.Offset - 10)
            
            EventManager:FireEvent("WindowResizing", self)
        end)
        
        -- Change cursor on hover (visual indicator)
        handle.MouseEnter:Connect(function()
            if i == 1 then -- Bottom right corner
                handle.Text = "⤡"
            elseif i == 2 then -- Bottom edge
                handle.Text = "↕"
            elseif i == 3 then -- Right edge
                handle.Text = "↔"
            end
        end)
        
        handle.MouseLeave:Connect(function()
            handle.Text = ""
            isResizing = false
        end)
    end
    
    self.ResizeHandles = handles
    logger:debug("Made window resizable: %s", self.TitleText.Text)
    return self
end

-- Set window as modal (blocking other interactions)
function Window:SetModal(isModal)
    if isModal then
        if _G.CensuraG.WindowManager then
            _G.CensuraG.WindowManager:ShowModal(self)
        end
    else
        if _G.CensuraG.WindowManager then
            _G.CensuraG.WindowManager:HideModal(self)
        end
    end
    
    return self
end

-- Set window title
function Window:SetTitle(title)
    if not title then return self end
    
    self.TitleText.Text = title
    logger:debug("Set window title: %s", title)
    
    return self
end

-- Add a UI element to the window's content container
function Window:AddElement(element)
    if not element or not element.Instance then
        logger:warn("Cannot add invalid element to window")
        return self
    end
    
    element.Instance.Parent = self.ContentContainer
    
    -- Update element's Z-index to match window hierarchy
    element.Instance.ZIndex = self.ContentContainer.ZIndex + 1
    
    logger:debug("Added element to window: %s", self.TitleText.Text)
    return self
end

-- Clean up resources
function Window:Destroy()
    -- Clean up drag handler
    if self.DragHandler then
        self.DragHandler:Destroy()
    end
    
    -- Remove from window manager
    if _G.CensuraG.WindowManager then
        _G.CensuraG.WindowManager:RemoveWindow(self)
    end
    
    -- Remove from taskbar if minimized
    if self.Minimized and _G.CensuraG.Taskbar then
        _G.CensuraG.Taskbar:RemoveWindow(self)
    end
    
    -- Destroy shadow
    if self.Shadow then
        self.Shadow:Destroy()
    end
    
    -- Destroy main instance
    if self.Instance then
        self.Instance:Destroy()
    end
    
    logger:info("Window destroyed: %s", self.TitleText and self.TitleText.Text or "Unknown")
    EventManager:FireEvent("WindowClosed", self)
end

return Window
