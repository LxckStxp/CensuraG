-- CensuraG/src/ui/TaskbarManager.lua (fixed nil table error)
local TaskbarManager = {}
TaskbarManager.__index = TaskbarManager

local Config = _G.CensuraG.Config

function TaskbarManager:Initialize()
    local frame, taskbarObject = _G.CensuraG.Components.taskbar()
    self.Frame = frame
    self.TaskbarObject = taskbarObject
    
    -- Find ButtonContainer
    self.ButtonContainer = self.Frame:FindFirstChild("ButtonContainer")
    
    if not self.ButtonContainer then
        -- Create ButtonContainer if it doesn't exist
        self.ButtonContainer = Instance.new("Frame", self.Frame)
        self.ButtonContainer.Name = "ButtonContainer"
        self.ButtonContainer.Size = UDim2.new(1, -120, 1, -10)
        self.ButtonContainer.Position = UDim2.new(0, 110, 0, 5)
        self.ButtonContainer.BackgroundTransparency = 1
        
        -- Add horizontal layout for buttons
        local ButtonLayout = Instance.new("UIListLayout", self.ButtonContainer)
        ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
        ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        ButtonLayout.Padding = UDim.new(0, 5)
        
        _G.CensuraG.Logger:warn("ButtonContainer not found, created new one")
    else
        _G.CensuraG.Logger:info("ButtonContainer found in taskbar")
    end
    
    self.Buttons = {}
    self:UpdateTaskbar()
end

function TaskbarManager:UpdateTaskbar()
    -- Ensure Windows table exists
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
    
    -- Create buttons for each window
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
            
            -- Add corner radius
            local corner = Instance.new("UICorner", button)
            corner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)
            
            -- Add stroke for better visibility
            local stroke = Instance.new("UIStroke", button)
            stroke.Color = theme.BorderColor
            stroke.Transparency = 0.8
            stroke.Thickness = Config.Math.BorderThickness
            
            -- Store reference to the window
            button:SetAttribute("WindowIndex", i)
            
            -- Add hover effects
            button.MouseEnter:Connect(function()
                _G.CensuraG.AnimationManager:Tween(button, {BackgroundTransparency = 0.5}, 0.2)
                _G.CensuraG.AnimationManager:Tween(stroke, {Transparency = 0.6}, 0.2)
            end)
            
            button.MouseLeave:Connect(function()
                _G.CensuraG.AnimationManager:Tween(button, {BackgroundTransparency = 0.7}, 0.2)
                _G.CensuraG.AnimationManager:Tween(stroke, {Transparency = 0.8}, 0.2)
            end)
            
            -- Button press effect
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
                    
                    -- Update button color based on window state
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

-- Refresh method to update taskbar and buttons
function TaskbarManager:Refresh()
    local theme = Config:GetTheme()
    
    -- Update taskbar appearance
    if self.Frame then
        if typeof(self.Frame) == "Instance" then
            _G.CensuraG.AnimationManager:Tween(self.Frame, {
                BackgroundColor3 = theme.PrimaryColor,
                BackgroundTransparency = 0.1
            }, Config.Animations.FadeDuration)
            
            -- Update other taskbar elements if they exist
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
                        TextColor3 = theme.TextColor,
                        Font = theme.Font
                    }, Config.Animations.FadeDuration)
                end
            end
        elseif self.TaskbarObject and self.TaskbarObject.Refresh then
            self.TaskbarObject:Refresh()
        end
    end
    
    -- Update buttons for each window
    if self.Buttons then
        for i, button in ipairs(self.Buttons) do
            if typeof(button) == "Instance" then
                local windowIndex = button:GetAttribute("WindowIndex")
                if windowIndex and _G.CensuraG.Windows[windowIndex] then
                    local isMinimized = _G.CensuraG.Windows[windowIndex].IsMinimized
                    _G.CensuraG.AnimationManager:Tween(button, {
                        BackgroundColor3 = isMinimized and theme.AccentColor or theme.SecondaryColor,
                        TextColor3 = theme.TextColor,
                        Font = theme.Font
                    }, Config.Animations.FadeDuration)
                end
            end
        end
    end
    
    -- Rebuild taskbar if needed
    self:UpdateTaskbar()
end

return TaskbarManager
