-- Taskbar.lua: Enhanced taskbar with scrolling
local Taskbar = {}
Taskbar.Windows = {}

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local UserInputService = game:GetService("UserInputService")
local logger = _G.CensuraG.Logger

function Taskbar:Init()
    if not self.Instance then
        local taskbar = Utilities.createInstance("Frame", {
            Parent = _G.CensuraG.ScreenGui,
            Position = UDim2.new(0, 10, 1, 40),
            Size = UDim2.new(1, -210, 0, 40),
            BackgroundTransparency = Styling.Transparency.ElementBackground,
            ZIndex = 2
        })
        Styling:Apply(taskbar, "Frame")
        self.Instance = taskbar

        local buttonContainer = Utilities.createInstance("ScrollingFrame", {
            Parent = taskbar,
            Size = UDim2.new(1, -210, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ZIndex = taskbar.ZIndex + 1
        })

        self.Cluster = _G.CensuraG.Cluster.new({Instance = taskbar})
        self:RefreshCluster()

        local isAnimating = false
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseMovement or isAnimating then return end
            local screenHeight = _G.CensuraG.ScreenGui.AbsoluteSize.Y
            local mouseY = input.Position.Y
            if mouseY >= screenHeight - 80 and not taskbar.Visible then
                task.wait(0.2)
                isAnimating = true
                taskbar.Visible = true
                self:RefreshCluster()
                Animation:SlideY(taskbar, -45, 0.3, nil, nil, function()
                    isAnimating = false
                end)
            elseif mouseY < screenHeight - 100 and taskbar.Visible then
                task.wait(0.3)
                isAnimating = true
                Animation:SlideY(taskbar, 40, 0.3, nil, nil, function()
                    taskbar.Visible = false
                    isAnimating = false
                end)
            end
        end)
    end
end

function Taskbar:AddWindow(window)
    if not window or not window.Instance then return end
    local titleLabel = window.Instance:FindFirstChildWhichIsA("TextLabel")
    if not titleLabel then return end

    local buttonWidth = 150
    local button = Utilities.createInstance("TextButton", {
        Parent = self.Instance:FindFirstChild("ScrollingFrame"),
        Position = UDim2.new(0, #self.Windows * (buttonWidth + 5), 0, 5),
        Size = UDim2.new(0, buttonWidth, 0, 30),
        Text = titleLabel.Text,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = self.Instance.ZIndex + 2
    })
    Styling:Apply(button, "TextButton")
    Animation:HoverEffect(button)

    local buttonContainer = self.Instance:FindFirstChild("ScrollingFrame")
    buttonContainer.CanvasSize = UDim2.new(0, (#self.Windows + 1) * (buttonWidth + 5), 0, 0)

    button.MouseButton1Click:Connect(function()
        window:Maximize()
        button:Destroy()
        local index = table.find(self.Windows, window)
        if index then table.remove(self.Windows, index) end
        buttonContainer.CanvasSize = UDim2.new(0, #self.Windows * (buttonWidth + 5), 0, 0)
    end)

    table.insert(self.Windows, window)
end

function Taskbar:RefreshCluster()
    if self.Cluster then
        self.Cluster.Instance.Visible = true
        self.Cluster.AvatarImage.Image.Visible = true
        self.Cluster.DisplayName.Visible = true
        self.Cluster.TimeLabel.Visible = true
    end
end

function Taskbar:Destroy()
    if self.Cluster then self.Cluster:Destroy() end
    if self.Instance then self.Instance:Destroy() end
    logger:info("Taskbar destroyed")
end

return Taskbar
