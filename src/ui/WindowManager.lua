-- CensuraG/src/ui/WindowManager.lua
local WindowManager = {}
WindowManager.__index = WindowManager

local Config = _G.CensuraG.Config
local ScreenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))

function WindowManager.new(title)
    local self = setmetatable({}, WindowManager)
    
    self.Frame = _G.CensuraG.Utilities.LoadModule("https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/components/window.lua")(title)
    self.IsMinimized = false
    
    self.Frame.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    _G.CensuraG.Logger:info("Created window: " .. title)
    return self
end

function WindowManager:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    self.Frame.Frame.Visible = not self.IsMinimized
    _G.CensuraG.TaskbarManager:UpdateTaskbar()
    _G.CensuraG.Logger:info("Window " .. (self.IsMinimized and "minimized" or "restored"))
end

return WindowManager
