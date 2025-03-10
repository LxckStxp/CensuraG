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

-- Initialize the taskbar
function Taskbar:Init()
    if self.Instance then
        logger:warn("Taskbar already initialized")
        return self
    end
    
    -- Create the taskbar frame
    local taskbar = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Position = UDim2.new(0, 10, 1, self.Height), -- Start off-screen
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
    
    -- Set up auto-hide/show behavior
    self:SetupAutoHide()
    
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
    EventManager:Connect(UserInputService.InputChanged, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement or isAnimating then return end
        
        local screenHeight = _G.CensuraG.ScreenGui.AbsoluteSize.Y
        local mouseY = input.Position.Y
        
        -- Show taskbar when mouse is near bottom of screen
        if mouseY >= screenHeight - showThreshold and not self.Visible then
            task.wait(0.2) -- Small delay to prevent accidental shows
            isAnimating = true
            self.Instance.Visible = true
            self:RefreshCluster()
            
            Animation:SlideY(self.Instance, -self.Height, 0.3, nil, nil, function()
                isAnimating = false
                self.Visible = true
            end)
        -- Hide taskbar when mouse moves away
        elseif mouseY < screenHeight - self.Height - showThreshold and self.Visible then
            task.wait(0.3) -- Longer delay before hiding
            isAnimating = true
            
            Animation:SlideY(self.Instance, self.Height, 0.3, nil, nil, function()
                self.Instance.Visible = false
                isAnimating = false
                self.Visible = false
            end)
        end
    end)
    
    -- Initially hide the taskbar
    self.Instance.Visible = false
    logger:debug("Taskbar auto-hide behavior set up")
}

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
    local titleLabel = window.Instance:FindFirstChildWhichIsA("TextLabel")
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
    Animation:HoverEffect(button)
    
    -- Update canvas size
    self.ButtonContainer.CanvasSize = UDim2.new(0, (#self.Windows + 1) * (self.ButtonWidth + 5), 0, 0)
    
    -- Handle button click
    button.MouseButton1Click:Connect(function()
        if window.Maximize then
            window:Maximize()
            self:RemoveWindow(window)
        end
    end)
    
    -- Add window to list
    table.insert(self.Windows, window)
    window.TaskbarButton = button
    
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
}

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
    }
}

-- Show the taskbar
function Taskbar:Show(instant)
    if self.Visible then return end
    
    self.Instance.Visible = true
    self:RefreshCluster()
    
    if instant then
        self.Instance.Position = UDim2.new(0, 10, 1, -self.Height)
        self.Visible = true
    else
        Animation:SlideY(self.Instance, -self.Height, 0.3, nil, nil, function()
            self.Visible = true
        })
    end
    
    logger:debug("Taskbar shown")
}

-- Hide the taskbar
function Taskbar:Hide(instant)
    if not self.Visible then return end
    
    if instant then
        self.Instance.Position = UDim2.new(0, 10, 1, self.Height)
        self.Instance.Visible = false
        self.Visible = false
    else
        Animation:SlideY(self.Instance, self.Height, 0.3, nil, nil, function()
            self.Instance.Visible = false
            self.Visible = false
        })
    end
    
    logger:debug("Taskbar hidden")
}

-- Toggle taskbar visibility
function Taskbar:Toggle()
    if self.Visible then
        self:Hide()
    else
        self:Show()
    end
}

-- Clean up resources
function Taskbar:Destroy()
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
}

return Taskbar
