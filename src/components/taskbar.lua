-- CensuraG/src/components/taskbar.lua
local Config = _G.CensuraG.Config

return function()
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, Config.TaskbarHeight)
    Frame.Position = UDim2.new(0, 0, 1, -Config.TaskbarHeight)
    Frame.BackgroundColor3 = Config.Theme.SecondaryColor
    Frame.BorderSizePixel = 0
    Frame.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("ScreenGui")
    
    return Frame
end
