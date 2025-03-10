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
