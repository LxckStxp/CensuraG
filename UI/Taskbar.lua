-- Enhanced Taskbar with improved auto-hide detection
local Taskbar = {}
local logger = _G.CensuraG.Logger
local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Initialize properties
Taskbar.Windows = {}
Taskbar.Visible = false
Taskbar.Height = 40
Taskbar.ButtonWidth = 150
Taskbar.AutoHideEnabled = true
Taskbar.IsAnimating = false
Taskbar.CheckingMouse = false
Taskbar.LastMousePosition = nil
Taskbar.ShowThreshold = 30 -- pixels from bottom of screen
Taskbar.HideDelay = 1.0 -- seconds before hiding

-- Initialize the taskbar
function Taskbar:Init()
    if self.Instance then
        logger:warn("Taskbar already initialized")
        return self
    end
    
    -- Create the taskbar frame (start off-screen)
    local taskbar = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Position = UDim2.new(0, 10, 1, self.Height),
        Size = UDim2.new(1, -210, 0, self.Height),
        BackgroundTransparency = Styling.Transparency.ElementBackground,
        ZIndex = 5,
        Name = "Taskbar"
    })
    Styling:Apply(taskbar, "Frame")
    self.Instance = taskbar
    
    -- Create the button container (scrolling frame)
    local buttonContainer = Utilities.createInstance("ScrollingFrame", {
        Parent = taskbar,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -210, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ZIndex = taskbar.ZIndex + 1,
        Name = "ButtonContainer"
    })
    self.ButtonContainer = buttonContainer
    
    -- Create the user info cluster
    self.Cluster = _G.CensuraG.Cluster.new({Instance = taskbar})
    self:RefreshCluster()
    
    -- Create debug indicator for taskbar state
    self.DebugLabel = Utilities.createInstance("TextLabel", {
        Parent = taskbar,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(0, 100, 0, 20),
        Text = "Taskbar Ready",
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(0, 255, 0),
        ZIndex = taskbar.ZIndex + 3,
        Visible = false, -- Set to true for debugging
        Name = "DebugLabel"
    })
    
    -- Set up auto-hide/show behavior
    if self.AutoHideEnabled then
        self:SetupAutoHide()
    else
        -- If auto-hide is disabled, show the taskbar immediately
        self:Show(true)
    end
    
    -- Subscribe to window events
    EventManager:SubscribeToEvent("WindowMinimized", function(window)
        self:AddWindow(window)
    end)
    
    EventManager:SubscribeToEvent("WindowClosed", function(window)
        self:RemoveWindow(window)
    end)
    
    -- Manually force show the taskbar when testing
    -- self:ForceShow()
    
    logger:info("Taskbar initialized")
    return self
end

-- Set up auto-hide/show behavior with robust mouse detection
function Taskbar:SetupAutoHide()
    -- Disconnect any existing connections
    if self.AutoHideConnection then
        self.AutoHideConnection:Disconnect()
        self.AutoHideConnection = nil
    end
    
    if self.MouseCheckConnection then
        self.MouseCheckConnection:Disconnect()
        self.MouseCheckConnection = nil
    end
    
    -- Use RenderStepped for reliable mouse position checking
    self.MouseCheckConnection = RunService.RenderStepped:Connect(function()
        if self.CheckingMouse or self.IsAnimating then return end
        
        self.CheckingMouse = true
        local mousePos = UserInputService:GetMouseLocation()
        local screenHeight = _G.CensuraG.ScreenGui.AbsoluteSize.Y
        
        -- Debug output
        if self.DebugLabel and self.DebugLabel.Visible then
            self.DebugLabel.Text = string.format("Y: %d/%d", mousePos.Y, screenHeight)
        end
        
        -- Show taskbar when mouse is near bottom of screen
        if mousePos.Y >= screenHeight - self.ShowThreshold and not self.Visible then
            self:ShowTaskbar()
        -- Hide taskbar when mouse moves away
        elseif mousePos.Y < screenHeight - self.Height - self.ShowThreshold and self.Visible then
            -- Store timestamp for delayed hiding
            if not self.HideTimestamp then
                self.HideTimestamp = tick()
            elseif tick() - self.HideTimestamp > self.HideDelay then
                self:HideTaskbar()
                self.HideTimestamp = nil
            end
        else
            -- Reset hide timestamp if mouse moves back into taskbar area
            self.HideTimestamp = nil
        end
        
        self.LastMousePosition = mousePos
        self.CheckingMouse = false
    end)
    
    -- Initially hide the taskbar
    self.Instance.Visible = false
    self.Visible = false
    
    logger:debug("Taskbar auto-hide behavior set up with enhanced detection")
end

-- Show taskbar with animation
function Taskbar:ShowTaskbar()
    if self.Visible or self.IsAnimating then return end
    
    self.IsAnimating = true
    self.Instance.Visible = true
    self:RefreshCluster()
    
    Animation:SlideY(self.Instance, -self.Height, 0.3, nil, nil, function()
        self.IsAnimating = false
        self.Visible = true
        logger:debug("Taskbar shown by auto-hide")
        
        if self.DebugLabel and self.DebugLabel.Visible then
            self.DebugLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            self.DebugLabel.Text = "Visible"
        end
    end)
end

-- Hide taskbar with animation
function Taskbar:HideTaskbar()
    if not self.Visible or self.IsAnimating then return end
    
    self.IsAnimating = true
    
    Animation:SlideY(self.Instance, self.Height, 0.3, nil, nil, function()
        self.Instance.Visible = false
        self.IsAnimating = false
        self.Visible = false
        logger:debug("Taskbar hidden by auto-hide")
        
        if self.DebugLabel and self.DebugLabel.Visible then
            self.DebugLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            self.DebugLabel.Text = "Hidden"
        end
    end)
end

-- Enable or disable auto-hide
function Taskbar:SetAutoHide(enabled)
    if enabled == self.AutoHideEnabled then return end
    
    self.AutoHideEnabled = enabled
    
    if enabled then
        -- Enable auto-hide
        self:SetupAutoHide()
    else
        -- Disable auto-hide
        if self.AutoHideConnection then
            self.AutoHideConnection:Disconnect()
            self.AutoHideConnection = nil
        end
        
        if self.MouseCheckConnection then
            self.MouseCheckConnection:Disconnect()
            self.MouseCheckConnection = nil
        }
        
        -- Show the taskbar when auto-hide is disabled
        self:Show(true)
    end
    
    logger:info("Taskbar auto-hide %s", enabled and "enabled" or "disabled")
end

-- Add a window to the taskbar
function Taskbar:AddWindow(window)
    if not window or not window.Instance then
        logger:warn("Invalid window in AddWindow")
        return false
    end
    
    -- Check if window is already in taskbar
    for _, w in ipairs(self.Windows) do
        if w == window then
            logger:debug("Window already in taskbar: %s", window.Instance.Name)
            return false
        end
    end
    
    -- Get window title
    local titleLabel = window.TitleText or window.Instance:FindFirstChildWhichIsA("TextLabel")
    local title = titleLabel and titleLabel.Text or "Window"
    
    -- Create button
    local button = Utilities.createInstance("TextButton", {
        Parent = self.ButtonContainer,
        Position = UDim2.new(0, #self.Windows * (self.ButtonWidth + 5), 0, 5),
        Size = UDim2.new(0, self.ButtonWidth, 0, self.Height - 10),
        Text = title,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = self.Instance.ZIndex + 2,
        Name = "TaskbarButton_" .. window.Id
    })
    Styling:Apply(button, "TextButton")
    
    -- Apply hover effect manually to avoid attribute issues
    button.MouseEnter:Connect(function()
        Animation:Tween(button, {
            BackgroundTransparency = Styling.Transparency.ElementBackground - 0.1
        }, 0.1)
    end)
    
    button.MouseLeave:Connect(function()
        Animation:Tween(button, {
            BackgroundTransparency = Styling.Transparency.ElementBackground
        }, 0.1)
    end)
    
    -- Update canvas size
    self.ButtonContainer.CanvasSize = UDim2.new(0, (#self.Windows + 1) * (self.ButtonWidth + 5), 0, 0)
    
    -- Handle button click
    button.MouseButton1Click:Connect(function()
        if window.Restore then
            window:Restore()
            self:RemoveWindow(window)
        end
    end)
    
    -- Add window to list
    table.insert(self.Windows, window)
    window.TaskbarButton = button
    
    -- Show taskbar if it's the first window and currently hidden
    if #self.Windows == 1 and not self.Visible then
        self:ShowTaskbar()
    end
    
    logger:debug("Added window to taskbar: %s", title)
    return true
end

-- Remove a window from the taskbar
function Taskbar:RemoveWindow(window)
    if not window then return false end
    
    for i, w in ipairs(self.Windows) do
        if w == window then
            -- Remove button
            if window.TaskbarButton then
                window.TaskbarButton:Destroy()
                window.TaskbarButton = nil
            end
            
            -- Remove from list
            table.remove(self.Windows, i)
            
            -- Update remaining buttons
            self:UpdateButtonPositions()
            
            -- Hide taskbar if no windows left and auto-hide is enabled
            if #self.Windows == 0 and self.AutoHideEnabled then
                self:HideTaskbar()
            end
            
            logger:debug("Removed window from taskbar: %s", window.Instance.Name)
            return true
        end
    end
    
    logger:warn("Window not found in taskbar")
    return false
end

-- Update button positions after removal
function Taskbar:UpdateButtonPositions()
    for i, window in ipairs(self.Windows) do
        if window.TaskbarButton then
            Animation:Tween(window.TaskbarButton, {
                Position = UDim2.new(0, (i-1) * (self.ButtonWidth + 5), 0, 5)
            }, 0.2)
        end
    end
    
    -- Update canvas size
    self.ButtonContainer.CanvasSize = UDim2.new(0, #self.Windows * (self.ButtonWidth + 5), 0, 0)
end

-- Refresh the user info cluster
function Taskbar:RefreshCluster()
    if self.Cluster then
        self.Cluster.Instance.Visible = true
        
        if self.Cluster.AvatarImage and self.Cluster.AvatarImage.Image then
            self.Cluster.AvatarImage.Image.Visible = true
        end
        
        if self.Cluster.DisplayName then
            self.Cluster.DisplayName.Visible = true
        end
        
        if self.Cluster.TimeLabel then
            self.Cluster.TimeLabel.Visible = true
            self.Cluster.TimeLabel.Text = os.date("%H:%M")
        end
    end
end

-- Show the taskbar (public method)
function Taskbar:Show(instant)
    if self.Visible then return end
    
    if instant then
        self.Instance.Visible = true
        self.Instance.Position = UDim2.new(0, 10, 1, -self.Height)
        self.Visible = true
        self:RefreshCluster()
        logger:debug("Taskbar shown instantly")
        
        if self.DebugLabel and self.DebugLabel.Visible then
            self.DebugLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            self.DebugLabel.Text = "Visible (Instant)"
        end
    else
        self:ShowTaskbar()
    end
end

-- Hide the taskbar (public method)
function Taskbar:Hide(instant)
    if not self.Visible then return end
    
    if instant then
        self.Instance.Position = UDim2.new(0, 10, 1, self.Height)
        self.Instance.Visible = false
        self.Visible = false
        logger:debug("Taskbar hidden instantly")
        
        if self.DebugLabel and self.DebugLabel.Visible then
            self.DebugLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            self.DebugLabel.Text = "Hidden (Instant)"
        end
    else
        self:HideTaskbar()
    end
end

-- Toggle taskbar visibility
function Taskbar:Toggle()
    if self.Visible then
        self:Hide()
    else
        self:Show()
    end
    
    return self.Visible
end

-- Force taskbar to appear (for debugging)
function Taskbar:ForceShow()
    -- Disable auto-hide temporarily
    local wasAutoHideEnabled = self.AutoHideEnabled
    self.AutoHideEnabled = false
    
    -- Force show
    self.Instance.Visible = true
    self.Instance.Position = UDim2.new(0, 10, 1, -self.Height)
    self.Visible = true
    self:RefreshCluster()
    
    -- Enable debug label
    if self.DebugLabel then
        self.DebugLabel.Visible = true
        self.DebugLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        self.DebugLabel.Text = "FORCED VISIBLE"
    end
    
    -- Restore auto-hide after 5 seconds
    task.delay(5, function()
        self.AutoHideEnabled = wasAutoHideEnabled
        if self.AutoHideEnabled then
            self:SetupAutoHide()
        end
    end)
    
    logger:info("Taskbar force shown (debug mode)")
    return true
end

-- Clean up resources
function Taskbar:Destroy()
    -- Disconnect auto-hide connection
    if self.AutoHideConnection then
        self.AutoHideConnection:Disconnect()
        self.AutoHideConnection = nil
    end
    
    if self.MouseCheckConnection then
        self.MouseCheckConnection:Disconnect()
        self.MouseCheckConnection = nil
    }
    
    -- Clear windows
    for _, window in ipairs(self.Windows) do
        if window.TaskbarButton then
            window.TaskbarButton:Destroy()
            window.TaskbarButton = nil
        end
    end
    self.Windows = {}
    
    -- Destroy cluster
    if self.Cluster then
        self.Cluster:Destroy()
        self.Cluster = nil
    end
    
    -- Destroy instance
    if self.Instance then
        self.Instance:Destroy()
        self.Instance = nil
    end
    
    logger:info("Taskbar destroyed")
end

return Taskbar
