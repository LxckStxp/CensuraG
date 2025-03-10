-- UI/Taskbar.lua: Enhanced taskbar with improved functionality
local Taskbar = {}
local logger = _G.CensuraG.Logger
local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager
local UserInputService = game:GetService("UserInputService")

-- Initialize properties
Taskbar.Windows = {}
Taskbar.Visible = false
Taskbar.Height = 40
Taskbar.ButtonWidth = 150
Taskbar.AutoHideEnabled = true

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
    
    logger:info("Taskbar initialized")
    return self
end

-- Set up auto-hide/show behavior
function Taskbar:SetupAutoHide()
    local isAnimating = false
    local showThreshold = 40 -- pixels from bottom of screen
    
    -- Connect to mouse movement
    local connection = EventManager:Connect(UserInputService.InputChanged, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement or isAnimating then return end
        
        local screenHeight = _G.CensuraG.ScreenGui.AbsoluteSize.Y
        local mouseY = input.Position.Y
        
        -- Show taskbar when mouse is near bottom of screen
        if mouseY >= screenHeight - showThreshold and not self.Visible then
            isAnimating = true
            self.Instance.Visible = true
            self:RefreshCluster()
            
            Animation:SlideY(self.Instance, -self.Height, 0.3, nil, nil, function()
                isAnimating = false
                self.Visible = true
                logger:debug("Taskbar shown by auto-hide")
            end)
        -- Hide taskbar when mouse moves away
        elseif mouseY < screenHeight - self.Height - showThreshold and self.Visible then
            task.wait(0.3) -- Delay before hiding
            
            -- Check again after delay to prevent flickering when mouse moves quickly
            local newMouseY = UserInputService:GetMouseLocation().Y
            if newMouseY < screenHeight - self.Height - showThreshold then
                isAnimating = true
                
                Animation:SlideY(self.Instance, self.Height, 0.3, nil, nil, function()
                    self.Instance.Visible = false
                    isAnimating = false
                    self.Visible = false
                    logger:debug("Taskbar hidden by auto-hide")
                end)
            end
        end
    end)
    
    -- Store the connection for cleanup
    self.AutoHideConnection = connection
    
    -- Initially hide the taskbar
    self.Instance.Visible = false
    self.Visible = false
    
    logger:debug("Taskbar auto-hide behavior set up")
end

-- Enable or disable auto-hide
function Taskbar:SetAutoHide(enabled)
    if enabled == self.AutoHideEnabled then return end
    
    self.AutoHideEnabled = enabled
    
    if enabled then
        -- Enable auto-hide
        if not self.AutoHideConnection then
            self:SetupAutoHide()
        end
    else
        -- Disable auto-hide
        if self.AutoHideConnection then
            self.AutoHideConnection:Disconnect()
            self.AutoHideConnection = nil
        end
        -- Show the taskbar when auto-hide is disabled
        self:Show(true)
    end
    
    logger:info("Taskbar auto-hide %s", enabled and "enabled" : "disabled")
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
        self:Show()
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
                self:Hide()
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

-- Show the taskbar
function Taskbar:Show(instant)
    if self.Visible then return end
    
    self.Instance.Visible = true
    self:RefreshCluster()
    
    if instant then
        self.Instance.Position = UDim2.new(0, 10, 1, -self.Height)
        self.Visible = true
        logger:debug("Taskbar shown instantly")
    else
        Animation:SlideY(self.Instance, -self.Height, 0.3, nil, nil, function()
            self.Visible = true
            logger:debug("Taskbar shown with animation")
        end)
    end
end

-- Hide the taskbar
function Taskbar:Hide(instant)
    if not self.Visible then return end
    
    if instant then
        self.Instance.Position = UDim2.new(0, 10, 1, self.Height)
        self.Instance.Visible = false
        self.Visible = false
        logger:debug("Taskbar hidden instantly")
    else
        Animation:SlideY(self.Instance, self.Height, 0.3, nil, nil, function()
            self.Instance.Visible = false
            self.Visible = false
            logger:debug("Taskbar hidden with animation")
        end)
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
    self.Instance.Visible = true
    self.Instance.Position = UDim2.new(0, 10, 1, -self.Height)
    self.Visible = true
    self:RefreshCluster()
    logger:info("Taskbar force shown")
    return true
end

-- Clean up resources
function Taskbar:Destroy()
    -- Disconnect auto-hide connection
    if self.AutoHideConnection then
        self.AutoHideConnection:Disconnect()
        self.AutoHideConnection = nil
    end
    
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
