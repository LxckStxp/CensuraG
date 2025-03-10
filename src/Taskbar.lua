-- Taskbar.lua: Taskbar management
local Taskbar = {}
Taskbar.Windows = {}

local Utilities = _G.CensuraG.Utilities
local UserInputService = game:GetService("UserInputService")

function Taskbar:Init()
    local taskbar = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Position = UDim2.new(0, 0, 1, -50),
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        Visible = false
    })
    self.Instance = taskbar
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local screenHeight = _G.CensuraG.ScreenGui.AbsoluteSize.Y
            taskbar.Visible = input.Position.Y > screenHeight * 0.9
        end
    end)
end

function Taskbar:AddWindow(window)
    local button = Utilities.createInstance("TextButton", {
        Parent = self.Instance,
        Position = UDim2.new(0, #self.Windows * 100, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        Text = window.Instance:FindFirstChildWhichIsA("TextLabel").Text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    })
    button.MouseButton1Click:Connect(function()
        window:Minimize()
        button:Destroy()
        table.remove(self.Windows, table.find(self.Windows, window))
    end)
    table.insert(self.Windows, window)
end

return Taskbar
