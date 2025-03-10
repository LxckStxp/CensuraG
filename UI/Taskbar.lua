-- UI/Taskbar.lua
-- Optimized taskbar with simplified show/hide functionality and improved organization

local Taskbar = {}
local logger = _G.CensuraG.Logger
local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager
local ErrorHandler = _G.CensuraG.ErrorHandler
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- State tracking
Taskbar.Windows = {}
Taskbar.Visible = false
Taskbar.Height = 40
Taskbar.ButtonWidth = 150
Taskbar.AutoHideEnabled = true
Taskbar.IsAnimating = false
Taskbar.CheckingMouse = false
Taskbar.LastMousePosition = nil
Taskbar.ShowThreshold = 30
Taskbar.HideDelay = 1.0
Taskbar.MouseCheckConnection = nil

-- =============================================
-- Initialization
-- =============================================
function Taskbar:Init()
    if self.Instance then
        logger:warn("Taskbar already initialized")
        return self
    end
    
    logger:info("Initializing Taskbar...")
    
    -- Get screen size with fallback
    local screenSize = Utilities.getScreenSize()
    if screenSize.X == 0 or screenSize.Y == 0 then
        screenSize = Vector2.new(1366, 768)
        logger:warn("Using fallback screen size: %s", tostring(screenSize))
    end
    
    -- Create main taskbar frame
    local taskbar = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Position = UDim2.new(0, 10, 1, 0), -- Start offscreen
        Size = UDim2.new(1, -210, 0, self.Height),
        BackgroundTransparency = Styling.Transparency.ElementBackground,
        ZIndex = 5,
        Name = "Taskbar"
    })
    Styling:Apply(taskbar, "Frame")
    self.Instance = taskbar

    -- Create start button
    self:CreateStartButton()
    
    -- Create button container
    self:CreateButtonContainer()

    -- Create user cluster
    self:CreateCluster()
    
    -- Initialize state
    self.Instance.Visible = false
    self.Visible = false
    self.AutoHideEnabled = _G.CensuraG.Config.AutoHide
    
    -- Set up auto-hide behavior
    self:UpdateAutoHide()
    
    logger:info("Taskbar initialized with AutoHide: %s", tostring(self.AutoHideEnabled))
    return self
end

function Taskbar:CreateStartButton()
    local startButton = Utilities.createInstance("TextButton", {
        Parent = self.Instance,
        Position = UDim2.new(0, 5, 0, 5),
        Size = UDim2.new(0, 40, 0, 30),
        Text = "☰",
        ZIndex = self.Instance.ZIndex + 1,
        Name = "StartButton"
    })
    
    Styling:Apply(startButton, "TextButton")
    Animation:HoverEffect(startButton)
    
    -- Connect click handler
    startButton.MouseButton1Click:Connect(function()
        ErrorHandler:TryCatch(function()
            _G.CensuraG.Settings:Toggle()
        end, "Error toggling settings")
        
        logger:debug("Start button clicked - toggled settings")
    end)
    
    self.StartButton = startButton
end

function Taskbar:CreateButtonContainer()
    local buttonContainer = Utilities.createInstance("ScrollingFrame", {
        Parent = self.Instance,
        Position = UDim2.new(0, 50, 0, 0),
        Size = UDim2.new(1, -260, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ZIndex = self.Instance.ZIndex + 1,
        Name = "ButtonContainer"
    })
    
    self.ButtonContainer = buttonContainer
end

function Taskbar:CreateCluster()
    self.Cluster = _G.CensuraG.Cluster.new({ 
        parent = self.Instance.Instance or self.Instance,
        position = UDim2.new(1, -205, 0, 5),
        width = 195,
        height = 30
    })
    
    self:RefreshCluster()
end


-- =============================================
-- Auto-Hide Functionality
-- =============================================
function Taskbar:UpdateAutoHide()
    -- Clean up existing connection
    if self.MouseCheckConnection then
        self.MouseCheckConnection:Disconnect()
        self.MouseCheckConnection = nil
    end
    
    -- Set up auto-hide behavior if enabled
    if self.AutoHideEnabled then
        self.MouseCheckConnection = RunService.RenderStepped:Connect(function()
            self:CheckMousePosition()
        end)
        
        -- Hide initially if not visible
        if not self.Visible then 
            self:Hide(true) 
        end
    else
        -- Show and keep visible if auto-hide is disabled
        self:Show(true)
    end
end

function Taskbar:CheckMousePosition()
    -- Skip if already checking or animating
    if self.CheckingMouse or self.IsAnimating then return end
    
    self.CheckingMouse = true
    
    local mousePos = UserInputService:GetMouseLocation()
    local screenHeight = Utilities.getScreenSize().Y
    
    -- Show taskbar when mouse is at bottom of screen
    if mousePos.Y >= screenHeight - self.ShowThreshold and not self.Visible then
        self:Show(false)
    -- Hide taskbar when mouse moves away
    elseif mousePos.Y < screenHeight - self.Height - self.ShowThreshold and self.Visible then
        if not self.HideTimestamp then
            self.HideTimestamp = tick()
        elseif tick() - self.HideTimestamp > self.HideDelay then
            self:Hide(false)
            self.HideTimestamp = nil
        end
    else
        self.HideTimestamp = nil
    end
    
    self.LastMousePosition = mousePos
    self.CheckingMouse = false
end

function Taskbar:SetAutoHide(enabled)
    if enabled == self.AutoHideEnabled then return self end
    
    self.AutoHideEnabled = enabled
    _G.CensuraG.Config.AutoHide = enabled
    self:UpdateAutoHide()
    
    logger:info("Taskbar auto-hide set to %s", tostring(enabled))
    return self
end

-- =============================================
-- Show/Hide Methods
-- =============================================
function Taskbar:Show(instant)
    if self.Visible then return self end
    
    local screenHeight = Utilities.getScreenSize().Y
    
    if instant then
        -- Instant show
        self.Instance.Visible = true
        self.Instance.Position = UDim2.new(0, 10, 0, screenHeight - self.Height)
        self.Visible = true
        self:RefreshCluster()
        
        logger:debug("Taskbar shown instantly")
    else
        -- Animated show
        if self.IsAnimating then return self end
        
        self.IsAnimating = true
        self.Instance.Visible = true
        self:RefreshCluster()
        
        Animation:SlideY(self.Instance, screenHeight - self.Height, 0.3, nil, nil, function()
            self.IsAnimating = false
            self.Visible = true
            
            logger:debug("Taskbar shown with animation")
        end)
    end
    
    return self
end

function Taskbar:Hide(instant)
    if not self.Visible then return self end
    
    local screenHeight = Utilities.getScreenSize().Y
    
    if instant then
        -- Instant hide
        self.Instance.Visible = false
        self.Instance.Position = UDim2.new(0, 10, 0, screenHeight)
        self.Visible = false
        
        logger:debug("Taskbar hidden instantly")
    else
        -- Animated hide
        if self.IsAnimating then return self end
        
        self.IsAnimating = true
        
        Animation:SlideY(self.Instance, screenHeight, 0.3, nil, nil, function()
            self.Instance.Visible = false
            self.IsAnimating = false
            self.Visible = false
            
            logger:debug("Taskbar hidden with animation")
        end)
    end
    
    return self
end

function Taskbar:Toggle()
    if self.Visible then 
        self:Hide(false) 
    else 
        self:Show(false) 
    end
    
    return self.Visible
end

function Taskbar:ForceShow(duration)
    -- Remember previous auto-hide state
    local wasAutoHide = self.AutoHideEnabled
    
    -- Disable auto-hide and show taskbar
    self.AutoHideEnabled = false
    self:UpdateAutoHide()
    
    -- Restore original state after duration
    task.delay(duration or 5, function()
        self.AutoHideEnabled = wasAutoHide
        self:UpdateAutoHide()
    end)
    
    logger:info("Taskbar force shown for %s seconds", tostring(duration or 5))
    return true
end

-- =============================================
-- Window Management
-- =============================================
function Taskbar:AddWindow(window)
    if not window or not window.Instance then
        logger:warn("Invalid window in AddWindow")
        return false
    end
    
    -- Check if window is already in taskbar
    for _, w in ipairs(self.Windows) do
        if w == window then return false end
    end
    
    -- Get window title
    local title = window.TitleText and window.TitleText.Text or "Window"
    
    -- Create taskbar button
    local button = self:CreateWindowButton(window, title)
    
    -- Create tooltip
    local tooltip = self:CreateWindowTooltip(window, title)
    
    -- Store references
    table.insert(self.Windows, window)
    window.TaskbarButton = button
    window.TaskbarButtonTooltip = tooltip
    
    -- Update button positions
    self:UpdateButtonPositions()
    
    -- Show taskbar if this is the first window and taskbar is hidden
    if #self.Windows == 1 and not self.Visible then 
        self:Show(false) 
    end
    
    logger:debug("Added window to taskbar: %s", title)
    return true
end

function Taskbar:CreateWindowButton(window, title)
    local button = Utilities.createInstance("TextButton", {
        Parent = self.ButtonContainer,
        Position = UDim2.new(0, #self.Windows * (self.ButtonWidth + 5), 0, 5),
        Size = UDim2.new(0, self.ButtonWidth, 0, self.Height-10),
        Text = Utilities.truncateText(title, 20),
        ZIndex = self.Instance.ZIndex + 2,
        Name = "TaskbarButton_" .. window.Id
    })
    
    Styling:Apply(button, "TextButton")
    
    -- Add hover effect
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
    
    -- Add click handler
    button.MouseButton1Click:Connect(function()
        ErrorHandler:TryCatch(function()
            if window.Restore then window:Restore() end
            self:RemoveWindow(window)
        end, "Error restoring window from taskbar")
    end)
    
    return button
end

function Taskbar:CreateWindowTooltip(window, title)
    local tooltip = Utilities.createInstance("TextLabel", {
        Parent = _G.CensuraG.ScreenGui,
        Size = UDim2.new(0, 200, 0, 20),
        BackgroundTransparency = 0.2,
        Text = title,
        Visible = false,
        ZIndex = self.Instance.ZIndex + 3
    })
    
    Styling:Apply(tooltip, "TextLabel")
    
    -- Connect to window's button hover events
    if window.TaskbarButton then
        window.TaskbarButton.MouseEnter:Connect(function()
            local absPos = window.TaskbarButton.AbsolutePosition
            tooltip.Position = UDim2.new(0, absPos.X, 0, absPos.Y - 25)
            tooltip.Visible = true
        end)
        
        window.TaskbarButton.MouseLeave:Connect(function() 
            tooltip.Visible = false 
        end)
    end
    
    return tooltip
end

function Taskbar:RemoveWindow(window)
    if not window then return false end
    
    for i, w in ipairs(self.Windows) do
        if w == window then
            -- Clean up UI elements
            if window.TaskbarButton then 
                window.TaskbarButton:Destroy() 
            end
            
            if window.TaskbarButtonTooltip then 
                window.TaskbarButtonTooltip:Destroy() 
            end
            
            -- Remove from windows collection
            table.remove(self.Windows, i)
            
            -- Update layout
            self:UpdateButtonPositions()
            
            -- Hide taskbar if no windows and auto-hide is enabled
            if #self.Windows == 0 and self.AutoHideEnabled then
                self:Hide(false)
            end
            
            logger:debug("Removed window from taskbar: %s", window.Instance.Name)
            return true
        end
    end
    
    logger:warn("Window not found in taskbar")
    return false
end

function Taskbar:UpdateButtonPositions()
    local totalWidth = self.ButtonContainer.AbsoluteSize.X
    local buttonCount = #self.Windows
    
    -- Calculate button width based on available space
    local maxButtonWidth = math.min(
        self.ButtonWidth, 
        totalWidth / math.max(1, buttonCount) - 5
    )
    
    -- Update each button's position and size
    for i, window in ipairs(self.Windows) do
        if window.TaskbarButton then
            Animation:Tween(window.TaskbarButton, {
                Position = UDim2.new(0, (i-1)*(maxButtonWidth+5), 0, 5),
                Size = UDim2.new(0, maxButtonWidth, 0, self.Height-10)
            }, 0.2)
        end
    end
    
    -- Update scroll frame's canvas size
    self.ButtonContainer.CanvasSize = UDim2.new(0, buttonCount*(maxButtonWidth+5), 0, 0)
end

-- =============================================
-- Utility Methods
-- =============================================
function Taskbar:RefreshCluster()
    if not self.Cluster then return end
    
    local clusterFrame = self.Cluster.Instance
    if not clusterFrame then return end
    
    -- Update appearance
    clusterFrame.Position = UDim2.new(1, -205, 0, 5)
    clusterFrame.Size = UDim2.new(0, 195, 0, 30)
    clusterFrame.BackgroundTransparency = Styling.Transparency.ElementBackground - 0.1
    Styling:Apply(clusterFrame, "Frame")
    
    -- Update components
    if self.Cluster.AvatarImage and self.Cluster.AvatarImage.Image then
        self.Cluster.AvatarImage.Image.Position = UDim2.new(0, 5, 0, 1)
        self.Cluster.AvatarImage.Image.Visible = true
    end
    
    if self.Cluster.DisplayName then
        self.Cluster.DisplayName.Position = UDim2.new(0, 40, 0, 0)
        self.Cluster.DisplayName.Visible = true
    end
    
    if self.Cluster.TimeLabel then
        self.Cluster.TimeLabel.Position = UDim2.new(0, 150, 0, 0)
        self.Cluster.TimeLabel.Visible = true
        self.Cluster.TimeLabel.Text = os.date("%H:%M")
    end
    
    clusterFrame.Visible = true
end

-- =============================================
-- Cleanup
-- =============================================
function Taskbar:Destroy()
    -- Clean up auto-hide connection
    if self.MouseCheckConnection then 
        self.MouseCheckConnection:Disconnect() 
        self.MouseCheckConnection = nil
    end
    
    -- Clean up window buttons
    for _, window in ipairs(self.Windows) do
        if window.TaskbarButton then 
            window.TaskbarButton:Destroy() 
        end
        
        if window.TaskbarButtonTooltip then 
            window.TaskbarButtonTooltip:Destroy() 
        end
    end
    
    -- Reset state
    self.Windows = {}
    
    -- Destroy UI components
    if self.Cluster then 
        self.Cluster:Destroy() 
    end
    
    if self.Instance then 
        self.Instance:Destroy() 
    end
    
    logger:info("Taskbar destroyed")
end

return Taskbar
