-- Taskbar.lua: Styled and animated taskbar
local Taskbar = {}
Taskbar.Windows = {}

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local UserInputService = game:GetService("UserInputService")

function Taskbar:Init()
    local taskbar = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Position = UDim2.new(0, 0, 1, 0), -- Start offscreen
        Size = UDim2.new(1, 0, 0, 50),
        Visible = false
    })
    Styling:Apply(taskbar, "Frame")
    self.Instance = taskbar
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local screenHeight = _G.CensuraG.ScreenGui.AbsoluteSize.Y
            if input.Position.Y > screenHeight * 0.9 and not taskbar.Visible then
                taskbar.Visible = true
                Animation:Tween(taskbar, {Position = UDim2.new(0, 0, 1, -50)})
            elseif input.Position.Y <= screenHeight * 0.9 and taskbar.Visible then
                Animation:Tween(taskbar, {Position = UDim2.new(0, 0, 1, 0)}, nil, function()
                    taskbar.Visible = false
                end)
            end
        end
    end)
end

function Taskbar:AddWindow(window)
    local button = Utilities.createInstance("TextButton", {
        Parent = self.Instance,
        Position = UDim2.new(0, #self.Windows * 100, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        Text = window.Instance:FindFirstChildWhichIsA("TextLabel").Text
    })
    Styling:Apply(button, "TextButton")
    Animation:HoverEffect(button)
    
    button.MouseButton1Click:Connect(function()
        window:Minimize()
        button:Destroy()
        table.remove(self.Windows, table.find(self.Windows, window))
    end)
    table.insert(self.Windows, window)
end

return Taskbar
