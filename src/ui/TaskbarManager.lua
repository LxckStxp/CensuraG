-- CensuraG/src/ui/TaskbarManager.lua (updated for new taskbar style)
local TaskbarManager = {}
TaskbarManager.__index = TaskbarManager

local Config = _G.CensuraG.Config
local ScreenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))

function TaskbarManager:Initialize()
    self.Frame = _G.CensuraG.Components.taskbar()
    self.ButtonContainer = self.Frame:FindFirstChild("ButtonContainer")
    self.Buttons = {}
    self:UpdateTaskbar()
end

function TaskbarManager:UpdateTaskbar()
    -- Clear existing buttons
    for _, button in pairs(self.Buttons) do button:Destroy() end
    self.Buttons = {}
    
    local theme = Config:GetTheme()
    
    -- Create buttons for each window
    for i, window in ipairs(_G.CensuraG.Windows) do
        local button = Instance.new("TextButton", self.ButtonContainer)
        button.Size = UDim2.new(0, 100, 0, Config.Math.TaskbarHeight - 15)
        button.BackgroundColor3 = window.IsMinimized and theme.AccentColor or theme.SecondaryColor
        button.BackgroundTransparency = 0.7
        button.Text = window:GetTitle() or "Window"
        button.TextColor3 = theme.TextColor
        button.Font = theme.Font
        button.TextSize = 12
        button.BorderSizePixel = 0
        button.LayoutOrder = i -- For UIListLayout ordering
        
        -- Add corner radius
        local corner = Instance.new("UICorner", button)
        corner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)
        
        -- Add stroke for better visibility
        local stroke = Instance.new("UIStroke", button)
        stroke.Color = theme.BorderColor
        stroke.Transparency = 0.8
        stroke.Thickness = Config.Math.BorderThickness
        
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
            window:ToggleMinimize()
        end)
        
        table.insert(self.Buttons, button)
    end
    
    _G.CensuraG.Logger:info("Taskbar updated with " .. #self.Buttons .. " items")
end

-- Refresh method to update taskbar and buttons
function TaskbarManager:Refresh()
    if self.Frame and self.Frame:FindFirstChild("Refresh") then
        self.Frame:Refresh()
    else
        _G.CensuraG.Methods:RefreshComponent("taskbar", self.Frame)
    end
    self:UpdateTaskbar() -- Rebuild buttons with new theme
end

return TaskbarManager
