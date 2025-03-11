-- CensuraG/src/ui/TaskbarManager.lua
local TaskbarManager = {}
TaskbarManager.__index = TaskbarManager

local Config = _G.CensuraG.Config
local ScreenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))

function TaskbarManager:Initialize()
    self.Frame = _G.CensuraG.Components.taskbar()
    self.Buttons = {}
    self:UpdateTaskbar()
end

function TaskbarManager:UpdateTaskbar()
    for _, button in pairs(self.Buttons) do button:Destroy() end
    self.Buttons = {}
    
    local theme = Config:GetTheme()
    local offset = Config.Math.ElementSpacing
    
    for i, window in ipairs(_G.CensuraG.Windows) do
        local button = Instance.new("TextButton", self.Frame)
        button.Size = UDim2.new(0, 100, 0, Config.Math.TaskbarHeight - 10)
        button.Position = UDim2.new(0, offset, 0, 5)
        button.BackgroundColor3 = window.IsMinimized and theme.AccentColor or theme.PrimaryColor
        button.Text = window:GetTitle() -- Use the title directly from the window
        button.TextColor3 = theme.TextColor
        button.Font = theme.Font
        button.TextSize = 12
        button.BackgroundTransparency = 1
        
        _G.CensuraG.AnimationManager:Tween(button, {BackgroundTransparency = 0}, Config.Animations.FadeDuration)
        
        button.MouseButton1Click:Connect(function()
            window:ToggleMinimize()
        end)
        
        table.insert(self.Buttons, button)
        offset = offset + 105 + Config.Math.ElementSpacing
    end
    _G.CensuraG.Logger:info("Taskbar updated with " .. #self.Buttons .. " items")
end

-- Refresh method to update taskbar and buttons
function TaskbarManager:Refresh()
    _G.CensuraG.Methods:RefreshComponent("taskbar", self.Frame)
    self:UpdateTaskbar() -- Rebuild buttons with new theme
end

return TaskbarManager
