-- TaskbarManager.lua
local TaskbarManager = {}
TaskbarManager.__index = TaskbarManager

local Config = _G.CensuraG.Config
local ScreenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))

function TaskbarManager:Initialize()
    self.Frame = Instance.new("Frame", ScreenGui)
    self.Frame.Size = UDim2.new(1, 0, 0, Config.TaskbarHeight)
    self.Frame.Position = UDim2.new(0, 0, 1, -Config.TaskbarHeight)
    self.Frame.BackgroundColor3 = Config.Theme.SecondaryColor
    self.Frame.BorderSizePixel = 0
    
    self.Buttons = {}
    self:UpdateTaskbar()
end

function TaskbarManager:UpdateTaskbar()
    for _, button in pairs(self.Buttons) do button:Destroy() end
    self.Buttons = {}
    
    local offset = 5
    for i, window in ipairs(_G.CensuraG.Windows) do
        local button = Instance.new("TextButton", self.Frame)
        button.Size = UDim2.new(0, 100, 0, Config.TaskbarHeight - 10)
        button.Position = UDim2.new(0, offset, 0, 5)
        button.BackgroundColor3 = window.IsMinimized and Config.Theme.AccentColor or Config.Theme.PrimaryColor
        button.Text = window.TitleText.Text
        button.TextColor3 = Config.Theme.TextColor
        button.Font = Config.Theme.Font
        button.TextSize = 12
        
        button.MouseButton1Click:Connect(function()
            window:ToggleMinimize()
        end)
        
        table.insert(self.Buttons, button)
        offset = offset + 105
    end
end

return TaskbarManager
