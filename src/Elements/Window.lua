-- Window.lua: Window class with dragging and minimizing
local Window = setmetatable({}, {__index = require(script.Parent.Parent.UIElement)})
Window.__index = Window

local Utilities = require(script.Parent.Parent.Utilities)
local UserInputService = game:GetService("UserInputService")

function Window.new(title, x, y, width, height)
    local frame = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width, 0, height),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0
    })
    
    local titleBar = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        BorderSizePixel = 0
    })
    
    local minimizeButton = Utilities.createInstance("TextButton", {
        Parent = titleBar,
        Position = UDim2.new(1, -20, 0, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Text = "-",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    })
    
    local self = setmetatable({Instance = frame, Minimized = false}, Window)
    
    -- Dragging Logic
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
        end
    end)
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Minimize Logic
    minimizeButton.MouseButton1Click:Connect(function()
        self:Minimize()
    end)
    
    return self
end

function Window:Minimize()
    if self.Minimized then
        self.Instance.Visible = true
    else
        self.Instance.Visible = false
        _G.CensuraG.Taskbar:AddWindow(self)
    end
    self.Minimized = not self.Minimized
end

return Window
