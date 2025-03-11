-- WindowManager.lua
local WindowManager = {}
WindowManager.__index = WindowManager

local Config = _G.CensuraG.Config
local ScreenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))

function WindowManager.new(title)
    local self = setmetatable({}, WindowManager)
    
    -- Window Frame
    self.Frame = Instance.new("Frame")
    self.Frame.Size = UDim2.fromOffset(Config.WindowSize.X, Config.WindowSize.Y)
    self.Frame.Position = UDim2.fromOffset(100, 100) -- Default position
    self.Frame.BackgroundColor3 = Config.Theme.PrimaryColor
    self.Frame.BorderSizePixel = 0
    self.Frame.Parent = ScreenGui
    
    -- Title Bar
    self.TitleBar = Instance.new("Frame", self.Frame)
    self.TitleBar.Size = UDim2.new(1, 0, 0, 30)
    self.TitleBar.BackgroundColor3 = Config.Theme.SecondaryColor
    self.TitleBar.BorderSizePixel = 0
    
    self.TitleText = Instance.new("TextLabel", self.TitleBar)
    self.TitleText.Size = UDim2.new(1, -60, 1, 0)
    self.TitleText.Position = UDim2.new(0, 5, 0, 0)
    self.TitleText.BackgroundTransparency = 1
    self.TitleText.Text = title
    self.TitleText.TextColor3 = Config.Theme.TextColor
    self.TitleText.Font = Config.Theme.Font
    self.TitleText.TextSize = 14
    
    -- Minimize Button
    self.MinimizeButton = Instance.new("TextButton", self.TitleBar)
    self.MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    self.MinimizeButton.Position = UDim2.new(1, -55, 0, 2)
    self.MinimizeButton.BackgroundColor3 = Config.Theme.AccentColor
    self.MinimizeButton.Text = "-"
    self.MinimizeButton.TextColor3 = Config.Theme.TextColor
    self.MinimizeButton.Font = Config.Theme.Font
    
    -- State
    self.IsMinimized = false
    
    -- Event Handlers
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    return self
end

function WindowManager:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    self.Frame.Visible = not self.IsMinimized
    _G.CensuraG.TaskbarManager:UpdateTaskbar()
end

return WindowManager
