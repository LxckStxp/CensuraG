-- CensuraG/src/ui/TaskbarManager.lua (updated with system tray support)
local TaskbarManager = {}
TaskbarManager.__index = TaskbarManager

local Config = _G.CensuraG.Config
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Auto-hide configuration
local AUTO_HIDE = true  -- Set to true to enable auto-hiding
local SHOW_THRESHOLD = 0.8  -- Mouse needs to be in bottom 20% of screen to show taskbar
local HIDE_DELAY = 1.5  -- Seconds to wait before hiding after mouse leaves area
local ANIMATION_SPEED = 0.3  -- Speed of slide animation

function TaskbarManager:Initialize()
    local frame, taskbarObject = _G.CensuraG.Components.taskbar()
    self.Frame = frame
    self.TaskbarObject = taskbarObject
    
    -- Find or create ButtonContainer
    self.ButtonContainer = self.Frame:FindFirstChild("ButtonContainer")
    if not self.ButtonContainer then
        self.ButtonContainer = Instance.new("Frame", self.Frame)
        self.ButtonContainer.Name = "ButtonContainer"
        self.ButtonContainer.Size = UDim2.new(1, -270, 1, -10) -- Adjusted for system tray (150 width + padding)
        self.ButtonContainer.Position = UDim2.new(0, 110, 0, 5)
        self.ButtonContainer.BackgroundTransparency = 1
        
        local ButtonLayout = Instance.new("UIListLayout", self.ButtonContainer)
        ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
        ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        ButtonLayout.Padding = UDim.new(0, 5)
        
        _G.CensuraG.Logger:warn("ButtonContainer not found, created new one")
    else
        -- Adjust existing ButtonContainer to accommodate system tray
        self.ButtonContainer.Size = UDim2.new(1, -270, 1, -10)
        self.ButtonContainer.Position = UDim2.new(0, 110, 0, 5)
        _G.CensuraG.Logger:info("ButtonContainer found and adjusted in taskbar")
    end
    
    -- Initialize taskbar position
    if AUTO_HIDE then
        self.Frame.Position = UDim2.new(0, 0, 1, Config.Math.TaskbarHeight)
        self.IsVisible = false
    else
        self.Frame.Position = UDim2.new(0, 0, 1, -Config.Math.TaskbarHeight)
        self.IsVisible = true
    end
    
    self.Buttons = {}
    self:UpdateTaskbar()
    
    -- Add system tray if not already initialized
    if not _G.CensuraG.SystemTray and _G.CensuraG.Components.systemtray then
        pcall(function()
            _G.CensuraG.SystemTray = _G.CensuraG.Components.systemtray(self.Frame)
            _G.CensuraG.Logger:info("SystemTray initialized within TaskbarManager")
        end)
    end
    
    -- Setup auto-hide functionality
    if AUTO_HIDE then
        self:SetupAutoHide()
    end
end

function TaskbarManager:SetupAutoHide()
    self.HideDelayActive = false
    self.HideTaskbarScheduled = false
    
    local function showTaskbar()
        if not self.IsVisible then
            _G.CensuraG.AnimationManager:Tween(
                self.Frame, 
                {Position = UDim2.new(0, 0, 1, -Config.Math.TaskbarHeight)}, 
                ANIMATION_SPEED
            )
            self.IsVisible = true
        end
        self.HideTaskbarScheduled = false
    end
    
    local function scheduleHideTaskbar()
        if self.IsVisible and not self.HideDelayActive then
            self.HideDelayActive = true
            self.HideTaskbarScheduled = true
            
            task.delay(HIDE_DELAY, function()
                if self.HideTaskbarScheduled then
                    _G.CensuraG.AnimationManager:Tween(
                        self.Frame, 
                        {Position = UDim2.new(0, 0, 1, Config.Math.TaskbarHeight)}, 
                        ANIMATION_SPEED
                    )
                    self.IsVisible = false
                end
                self.HideDelayActive = false
            end)
        end
    end
    
    self.MousePositionConnection = RunService.RenderStepped:Connect(function()
        if not self.Frame then return end
        
        local mousePosition = UserInputService:GetMouseLocation()
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local isInBottomPortion = (mousePosition.Y / viewportSize.Y) > SHOW_THRESHOLD
        
        if isInBottomPortion then
            showTaskbar()
        else
            scheduleHideTaskbar()
        end
    end)
    
    _G.CensuraG.Logger:info("Auto-hide taskbar functionality set up")
end

function TaskbarManager:UpdateTaskbar()
    if not _G.CensuraG.Windows then
        _G.CensuraG.Windows = {}
        _G.CensuraG.Logger:warn("Windows table was nil, initialized new table")
    end
    
    -- Clear existing buttons
    if self.Buttons then
        for _, button in pairs(self.Buttons) do
            if button and typeof(button) == "Instance" then
                button:Destroy()
            end
        end
    end
    self.Buttons = {}
    
    if not self.ButtonContainer then
        _G.CensuraG.Logger:error("ButtonContainer not found when updating taskbar")
        return
    end
    
    local theme = Config:GetTheme()
    
    for i, window in ipairs(_G.CensuraG.Windows) do
        if window and window.Frame then
            local button = Instance.new("TextButton", self.ButtonContainer)
            button.Size = UDim2.new(0, 100, 0, Config.Math.TaskbarHeight - 15)
            button.BackgroundColor3 = window.IsMinimized and theme.AccentColor or theme.SecondaryColor
            button.BackgroundTransparency = 0.7
            button.Text = window:GetTitle() or "Window"
            button.TextColor3 = theme.TextColor
            button.Font = theme.Font
            button.TextSize = 12
            button.BorderSizePixel = 0
            button.LayoutOrder = i
            button.Name = "WindowButton_" .. (window:GetTitle() or "Window")
            
            local corner = Instance.new("UICorner", button)
            corner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)
            
            local stroke = Instance.new("UIStroke", button)
            stroke.Color = theme.BorderColor
            stroke.Transparency = 0.8
            stroke.Thickness = Config.Math.BorderThickness
            
            button:SetAttribute("WindowIndex", i)
            
            button.MouseEnter:Connect(function()
                _G.CensuraG.AnimationManager:Tween(button, {BackgroundTransparency = 0.5}, 0.2)
                _G.CensuraG.AnimationManager:Tween(stroke, {Transparency = 0.6}, 0.2)
            end)
            
            button.MouseLeave:Connect(function()
                _G.CensuraG.AnimationManager:Tween(button, {BackgroundTransparency = 0.7}, 0.2)
                _G.CensuraG.AnimationManager:Tween(stroke, {Transparency = 0.8}, 0.2)
            end)
            
            button.MouseButton1Down:Connect(function()
                _G.CensuraG.AnimationManager:Tween(button, {
                    BackgroundTransparency = 0.4,
                    Size = UDim2.new(0, 95, 0, Config.Math.TaskbarHeight - 18)
                }, 0.1)
            end)
            
            button.MouseButton1Up:Connect(function()
                _G.CensuraG.AnimationManager:Tween(button, {
                    BackgroundTransparency = 0.5,
                    Size = UDim2.new(0, 100, 0, Config.Math.TaskbarHeight - 15)
                }, 0.1)
                
                local windowIndex = button:GetAttribute("WindowIndex")
                if windowIndex and _G.CensuraG.Windows[windowIndex] then
                    _G.CensuraG.Windows[windowIndex]:ToggleMinimize()
                    local isMinimized = _G.CensuraG.Windows[windowIndex].IsMinimized
                    _G.CensuraG.AnimationManager:Tween(button, {
                        BackgroundColor3 = isMinimized and theme.AccentColor or theme.SecondaryColor
                    }, 0.2)
                end
            end)
            
            table.insert(self.Buttons, button)
        end
    end
    
    _G.CensuraG.Logger:info("Taskbar updated with " .. #self.Buttons .. " items")
end

function TaskbarManager:Refresh()
    local theme = Config:GetTheme()
    
    if self.Frame then
        if typeof(self.Frame) == "Instance" then
            _G.CensuraG.AnimationManager:Tween(self.Frame, {
                BackgroundColor3 = theme.PrimaryColor,
                BackgroundTransparency = 0.1
            }, Config.Animations.FadeDuration)
            
            for _, child in pairs(self.Frame:GetChildren()) do
                if child.Name == "TopBorder" then
                    _G.CensuraG.AnimationManager:Tween(child, {
                        BackgroundColor3 = theme.AccentColor
                    }, Config.Animations.FadeDuration)
                elseif child.Name == "TopGlow" then
                    _G.CensuraG.AnimationManager:Tween(child, {
                        ImageColor3 = theme.AccentColor
                    }, Config.Animations.FadeDuration)
                elseif child.Name == "Logo" then
                    _G.CensuraG.AnimationManager:Tween(child, {
                        TextColor3 = theme.TextColor
                    }, Config.Animations.FadeDuration)
                    child.Font = theme.Font
                end
            end
        elseif self.TaskbarObject and self.TaskbarObject.Refresh then
            self.TaskbarObject:Refresh()
        end
    end
    
    if self.Buttons then
        for i, button in ipairs(self.Buttons) do
            if typeof(button) == "Instance" then
                local windowIndex = button:GetAttribute("WindowIndex")
                if windowIndex and _G.CensuraG.Windows[windowIndex] then
                    local isMinimized = _G.CensuraG.Windows[windowIndex].IsMinimized
                    _G.CensuraG.AnimationManager:Tween(button, {
                        BackgroundColor3 = isMinimized and theme.AccentColor or theme.SecondaryColor,
                        TextColor3 = theme.TextColor
                    }, Config.Animations.FadeDuration)
                    button.Font = theme.Font
                end
            end
        end
    end
    
    -- Refresh system tray if it exists
    if _G.CensuraG.SystemTray then
        _G.CensuraG.SystemTray:Refresh()
    end
    
    self:UpdateTaskbar()
end

function TaskbarManager:ShowTaskbar()
    self.HideTaskbarScheduled = false
    _G.CensuraG.AnimationManager:Tween(
        self.Frame, 
        {Position = UDim2.new(0, 0, 1, -Config.Math.TaskbarHeight)}, 
        ANIMATION_SPEED
    )
    self.IsVisible = true
    _G.CensuraG.Logger:info("Taskbar manually shown")
end

function TaskbarManager:HideTaskbar()
    _G.CensuraG.AnimationManager:Tween(
        self.Frame, 
        {Position = UDim2.new(0, 0, 1, Config.Math.TaskbarHeight)}, 
        ANIMATION_SPEED
    )
    self.IsVisible = false
    _G.CensuraG.Logger:info("Taskbar manually hidden")
end

function TaskbarManager:SetAutoHide(enabled)
    AUTO_HIDE = enabled
    
    if enabled and not self.MousePositionConnection then
        self:SetupAutoHide()
    elseif not enabled and self.MousePositionConnection then
        self.MousePositionConnection:Disconnect()
        self.MousePositionConnection = nil
        self:ShowTaskbar()
    end
    
    _G.CensuraG.Logger:info("Auto-hide " .. (enabled and "enabled" or "disabled"))
end

function TaskbarManager:Cleanup()
    if self.MousePositionConnection then
        self.MousePositionConnection:Disconnect()
        self.MousePositionConnection = nil
    end
end

return TaskbarManager
