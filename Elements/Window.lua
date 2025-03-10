-- Elements/Window.lua
-- Simplified window using enhanced UIElement base

local Window = {}
Window.__index = Window
setmetatable(Window, { __index = _G.CensuraG.UIElement })

function Window.new(options)
    options = options or {}
    
    -- Set default properties for Window
    options.title = options.title or "Window"
    options.width = options.width or 300
    options.height = options.height or 200
    options.x = options.x or 100
    options.y = options.y or 100
    options.parent = options.parent or _G.CensuraG.ScreenGui
    options.styleType = "Window"
    options.transparent = false
    
    -- Create the base element
    local self = _G.CensuraG.UIElement.new(options.parent, options)
    
    -- Set up shadow if enabled
    local shadow = nil
    if _G.CensuraG.Config.EnableShadows then
        shadow = _G.CensuraG.Utilities.createTaperedShadow(self.Instance, 5, 5, 0.9)
        shadow.ZIndex = self.Instance.ZIndex - 1
    end
    
    -- Create title bar
    local titleBarHeight = 25
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, titleBarHeight)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = _G.CensuraG.Styling.Colors.Secondary
    titleBar.BackgroundTransparency = _G.CensuraG.Styling.Transparency.ElementBackground - 0.1
    titleBar.ZIndex = self.Instance.ZIndex + 1
    titleBar.Parent = self.Instance
    _G.CensuraG.Styling:Apply(titleBar, "Frame")
    
    -- Create title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -80, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.Text = options.title
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.BackgroundTransparency = 1
    titleText.ZIndex = titleBar.ZIndex + 1
    titleText.Parent = titleBar
    _G.CensuraG.Styling:Apply(titleText, "TextLabel")
    
    -- Create buttons
    local buttonSize = titleBarHeight - 6
    
    -- Minimize button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    minimizeButton.Position = UDim2.new(1, -buttonSize*2 - 8, 0, 3)
    minimizeButton.Text = "-"
    minimizeButton.ZIndex = titleBar.ZIndex + 1
    minimizeButton.Parent = titleBar
    _G.CensuraG.Styling:Apply(minimizeButton, "TextButton")
    _G.CensuraG.Animation:HoverEffect(minimizeButton)
    
    -- Maximize button
    local maximizeButton = Instance.new("TextButton")
    maximizeButton.Name = "MaximizeButton"
    maximizeButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    maximizeButton.Position = UDim2.new(1, -buttonSize - 5, 0, 3)
    maximizeButton.Text = "□"
    maximizeButton.ZIndex = titleBar.ZIndex + 1
    maximizeButton.Parent = titleBar
    _G.CensuraG.Styling:Apply(maximizeButton, "TextButton")
    _G.CensuraG.Animation:HoverEffect(maximizeButton)
    
    -- Content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -10, 1, -titleBarHeight-10)
    contentContainer.Position = UDim2.new(0, 5, 0, titleBarHeight+5)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ZIndex = self.Instance.ZIndex + 1
    contentContainer.Parent = self.Instance
    
    -- Set up properties
    self.Shadow = shadow
    self.TitleBar = titleBar
    self.TitleText = titleText
    self.MinimizeButton = minimizeButton
    self.MaximizeButton = maximizeButton
    self.ContentContainer = contentContainer
    self.Minimized = false
    self.Maximized = false
    self.CurrentPosition = self.Instance.Position
    self.OriginalPosition = self.Instance.Position
    self.OriginalSize = self.Instance.Size
    self.Id = _G.CensuraG.Utilities.generateId()
    self.Options = options
    
    -- Set up drag handler
    self.DragHandler = _G.CensuraG.Draggable.new(self.Instance, titleBar, {
        OnDragStart = function() 
            _G.CensuraG.EventManager:FireEvent("WindowDragStart", self) 
        end,
        OnDragEnd = function() 
            _G.CensuraG.EventManager:FireEvent("WindowDragEnd", self) 
        end
    })
    
    -- Register with WindowManager
    if _G.CensuraG.WindowManager then
        _G.CensuraG.WindowManager:AddWindow(self)
    end
    
    -- Set up button handlers
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
    
    -- Set up modal if needed
    if options.modal then 
        self:SetModal(true) 
    end
    
    -- Make resizable if not disabled
    if options.resizable ~= false then 
        self:MakeResizable() 
    end
    
    -- Listen for shadow toggle events
    self:AddConnection(_G.CensuraG.EventManager:SubscribeToEvent("ShadowsToggled", function(state)
        if state and not self.Shadow then
            self.Shadow = _G.CensuraG.Utilities.createTaperedShadow(self.Instance, 5, 5, 0.9)
            self.Shadow.ZIndex = self.Instance.ZIndex - 1
        elseif not state and self.Shadow then
            self.Shadow:Destroy()
            self.Shadow = nil
        end
    end))
    
    -- Set metatable for this instance
    _G.CensuraG.EventManager:FireEvent("WindowCreated", self)
    return setmetatable(self, Window)
end

-- Minimize the window
function Window:Minimize()
    if self.Minimized or self.IsDestroyed then return self end
    
    self.Minimized = true
    self.CurrentPosition = self.Instance.Position
    
    local screenHeight = _G.CensuraG.ScreenGui.AbsoluteSize.Y
    _G.CensuraG.Animation:SlideY(self.Instance, screenHeight+50, 0.3, nil, nil, function()
        self.Instance.Visible = false
        if self.Shadow then 
            self.Shadow.Visible = false 
        end
        self.Minimized = true
        _G.CensuraG.EventManager:FireEvent("WindowMinimized", self)
    end)
    
    if self.Shadow then 
        _G.CensuraG.Animation:SlideY(self.Shadow, screenHeight+45, 0.3) 
    end
    
    if _G.CensuraG.Taskbar then 
        _G.CensuraG.Taskbar:AddWindow(self) 
    end
    
    return self
end

-- Maximize the window
function Window:Maximize()
    if self.Minimized then 
        self:Restore(function() self:Maximize() end)
        return self
    end
    
    if self.Maximized or self.IsDestroyed then return self end
    
    self.OriginalPosition = self.Instance.Position
    self.OriginalSize = self.Instance.Size
    
    local screenSize = _G.CensuraG.Utilities.getScreenSize()
    _G.CensuraG.Animation:Tween(
        self.Instance, 
        { 
            Position = UDim2.new(0, 0, 0, 0), 
            Size = UDim2.new(0, screenSize.X, 0, screenSize.Y-40) 
        }, 
        0.3, 
        nil, 
        nil, 
        function()
            self.Maximized = true
            _G.CensuraG.EventManager:FireEvent("WindowMaximized", self)
        end
    )
    
    if self.Shadow then
        _G.CensuraG.Animation:Tween(
            self.Shadow, 
            { 
                Position = UDim2.new(0, -5, 0, -5), 
                Size = UDim2.new(0, screenSize.X+10, 0, screenSize.Y-30) 
            }, 
            0.3
        )
    end
    
    return self
end

-- Restore the window
function Window:Restore(callback)
    if not self.Minimized and not self.Maximized then return self end
    if self.IsDestroyed then return self end
    
    if self.Minimized then
        self.Instance.Visible = true
        if self.Shadow then 
            self.Shadow.Visible = true 
        end
        
        local targetY = self.CurrentPosition.Y.Offset
        _G.CensuraG.Animation:SlideY(self.Instance, targetY, 0.3, nil, nil, function()
            self.Minimized = false
            _G.CensuraG.EventManager:FireEvent("WindowRestored", self)
            if callback then callback() end
        end)
        
        if self.Shadow then 
            _G.CensuraG.Animation:SlideY(self.Shadow, self.CurrentPosition.Y.Offset-5, 0.3) 
        end
        
        if _G.CensuraG.Taskbar then 
            _G.CensuraG.Taskbar:RemoveWindow(self) 
        end
    elseif self.Maximized then
        _G.CensuraG.Animation:Tween(
            self.Instance, 
            { 
                Position = self.OriginalPosition, 
                Size = self.OriginalSize 
            }, 
            0.3, 
            nil, 
            nil, 
            function()
                self.Maximized = false
                _G.CensuraG.EventManager:FireEvent("WindowRestored", self)
                if callback then callback() end
            end
        )
        
        if self.Shadow then
            _G.CensuraG.Animation:Tween(
                self.Shadow, 
                { 
                    Position = UDim2.new(
                        0, 
                        self.OriginalPosition.X.Offset-5, 
                        0, 
                        self.OriginalPosition.Y.Offset-5
                    ),
                    Size = UDim2.new(
                        0, 
                        self.OriginalSize.X.Offset+10, 
                        0, 
                        self.OriginalSize.Y.Offset+10
                    ) 
                }, 
                0.3
            )
        end
    end
    
    return self
end

-- Make the window resizable
function Window:MakeResizable()
    if self.ResizeHandles or self.IsDestroyed then return self end
    
    local resizeHandleSize = 10
    local minWidth, minHeight = 200, 100
    
    local handles = {
        -- Bottom-right corner handle
        Instance.new("TextButton", self.Instance),
        -- Bottom edge handle
        Instance.new("TextButton", self.Instance),
        -- Right edge handle
        Instance.new("TextButton", self.Instance)
    }
    
    -- Configure handles
    handles[1].Name = "ResizeHandleBR"
    handles[1].Position = UDim2.new(1, -resizeHandleSize, 1, -resizeHandleSize)
    handles[1].Size = UDim2.new(0, resizeHandleSize, 0, resizeHandleSize)
    handles[1].Text = ""
    handles[1].BackgroundTransparency = 1
    handles[1].ZIndex = self.Instance.ZIndex + 2
    
    handles[2].Name = "ResizeHandleB"
    handles[2].Position = UDim2.new(0, resizeHandleSize, 1, -resizeHandleSize)
    handles[2].Size = UDim2.new(1, -resizeHandleSize*2, 0, resizeHandleSize)
    handles[2].Text = ""
    handles[2].BackgroundTransparency = 1
    handles[2].ZIndex = self.Instance.ZIndex + 2
    
    handles[3].Name = "ResizeHandleR"
    handles[3].Position = UDim2.new(1, -resizeHandleSize, 0, resizeHandleSize)
    handles[3].Size = UDim2.new(0, resizeHandleSize, 1, -resizeHandleSize*2)
    handles[3].Text = ""
    handles[3].BackgroundTransparency = 1
    handles[3].ZIndex = self.Instance.ZIndex + 2
    
    for i, handle in ipairs(handles) do
        local isResizing = false
        local startPos, startSize
        
        handle.MouseButton1Down:Connect(function(x, y)
            if self.Maximized then return end
            
            isResizing = true
            startPos = Vector2.new(x, y)
            startSize = self.Instance.Size
            
            if _G.CensuraG.WindowManager then
                _G.CensuraG.WindowManager:BringToFront(self)
            end
            
            _G.CensuraG.EventManager:FireEvent("WindowResizeStart", self)
        end)
        
        handle.MouseButton1Up:Connect(function()
            isResizing = false
            _G.CensuraG.EventManager:FireEvent("WindowResizeEnd", self)
        end)
        
        handle.MouseMoved:Connect(function(x, y)
            if not isResizing then return end
            
            local delta = Vector2.new(x, y) - startPos
            local newSize = startSize
            
            if i == 1 then
                -- Bottom-right corner
                newSize = UDim2.new(
                    0, 
                    math.max(startSize.X.Offset + delta.X, minWidth), 
                    0, 
                    math.max(startSize.Y.Offset + delta.Y, minHeight)
                )
            elseif i == 2 then
                -- Bottom edge
                newSize = UDim2.new(
                    0, 
                    startSize.X.Offset, 
                    0, 
                    math.max(startSize.Y.Offset + delta.Y, minHeight)
                )
            elseif i == 3 then
                -- Right edge
                newSize = UDim2.new(
                    0, 
                    math.max(startSize.X.Offset + delta.X, minWidth), 
                    0, 
                    startSize.Y.Offset
                )
            end
            
            self.Instance.Size = newSize
            
            if self.Shadow then 
                self.Shadow.Size = UDim2.new(0, newSize.X.Offset+10, 0, newSize.Y.Offset+10) 
            end
            
            _G.CensuraG.EventManager:FireEvent("WindowResizing", self)
        end)
        
        handle.MouseEnter:Connect(function()
            if i == 1 then 
                handle.Text = "⤡" 
            elseif i == 2 then 
                handle.Text = "↕" 
            elseif i == 3 then 
                handle.Text = "↔" 
            end
        end)
        
        handle.MouseLeave:Connect(function() 
            handle.Text = ""
            isResizing = false 
        end)
    end
    
    self.ResizeHandles = handles
    return self
end

-- Set modal state
function Window:SetModal(isModal)
    if self.IsDestroyed then return self end
    
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
    if self.IsDestroyed then return self end
    
    if title and self.TitleText then 
        self.TitleText.Text = title 
    end
    
    return self
end

-- Add an element to the window
function Window:AddElement(element)
    if self.IsDestroyed then return self end
    
    if not element or not element.Instance then
        _G.CensuraG.Logger:warn("Invalid element in AddElement")
        return self
    end
    
    element.Instance.Parent = self.ContentContainer
    element.Instance.ZIndex = self.ContentContainer.ZIndex + 1
    
    return self
end

-- Override destroy to handle window-specific cleanup
function Window:Destroy()
    if self.IsDestroyed then return true end
    
    -- Custom cleanup
    if self.DragHandler then 
        self.DragHandler:Destroy() 
    end
    
    if _G.CensuraG.WindowManager then 
        _G.CensuraG.WindowManager:RemoveWindow(self) 
    end
    
    if self.Minimized and _G.CensuraG.Taskbar then 
        _G.CensuraG.Taskbar:RemoveWindow(self) 
    end
    
    if self.Shadow then 
        self.Shadow:Destroy() 
    end
    
    -- Fire event before destroying
    _G.CensuraG.EventManager:FireEvent("WindowClosed", self)
    
    -- Call parent destroy
    return _G.CensuraG.UIElement.Destroy(self)
end

return Window
