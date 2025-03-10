-- UI/Taskbar.lua
-- Modern taskbar with seamless integration

local Taskbar = {}
local logger = _G.CensuraG.Logger
local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

Taskbar.Windows = {}
Taskbar.Visible = false
Taskbar.Height = 40
Taskbar.ButtonWidth = 150
Taskbar.AutoHideEnabled = true

function Taskbar:Init()
    if self.Instance then return self end
    local screenSize = Utilities.getScreenSize()
    local taskbar = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, self.Height),
        ZIndex = 5,
        Name = "Taskbar"
    })
    Styling:Apply(taskbar, "Frame")
    self.Instance = taskbar
    
    local buttonContainer = Utilities.createInstance("ScrollingFrame", {
        Parent = taskbar,
        Position = UDim2.new(0, Styling.Padding, 0, Styling.Padding),
        Size = UDim2.new(1, -210, 0, self.Height - Styling.Padding * 2),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ZIndex = taskbar.ZIndex + 1,
        Name = "ButtonContainer"
    })
    self.ButtonContainer = buttonContainer
    self.Cluster = _G.CensuraG.Cluster.new({ Instance = taskbar })
    self.Instance.Visible = false
    self.Visible = false
    
    if self.AutoHideEnabled then
        self.MouseCheckConnection = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            local screenHeight = screenSize.Y
            if mousePos.Y >= screenHeight - 30 and not self.Visible then
                self:ShowTaskbar()
            elseif mousePos.Y < screenHeight - self.Height - 30 and self.Visible then
                task.delay(1, function() if self.Visible then self:HideTaskbar() end end)
            end
        end)
    end
    
    logger:info("Taskbar initialized")
    return self
end

function Taskbar:ShowTaskbar()
    if self.Visible then return end
    self.Instance.Visible = true
    Animation:SlideY(self.Instance, Utilities.getScreenSize().Y - self.Height, 0.3 / _G.CensuraG.Config.AnimationSpeed, nil, nil, function()
        self.Visible = true
    end)
end

function Taskbar:HideTaskbar()
    if not self.Visible then return end
    Animation:SlideY(self.Instance, Utilities.getScreenSize().Y, 0.3 / _G.CensuraG.Config.AnimationSpeed, nil, nil, function()
        self.Instance.Visible = false
        self.Visible = false
    end)
end

function Taskbar:SetAutoHide(enabled)
    self.AutoHideEnabled = enabled
    if enabled and not self.MouseCheckConnection then
        self:Init()
    elseif not enabled and self.MouseCheckConnection then
        self.MouseCheckConnection:Disconnect()
        self.MouseCheckConnection = nil
        self:ShowTaskbar()
    end
end

function Taskbar:AddWindow(window)
    if not window then return false end
    for _, w in ipairs(self.Windows) do if w == window then return false end end
    local button = Utilities.createInstance("TextButton", {
        Parent = self.ButtonContainer,
        Position = UDim2.new(0, #self.Windows * (self.ButtonWidth + Styling.Padding), 0, 0),
        Size = UDim2.new(0, self.ButtonWidth, 0, self.Height - Styling.Padding * 2),
        Text = window.TitleText.Text,
        ZIndex = self.Instance.ZIndex + 2,
        Name = "TaskbarButton_"..window.Id
    })
    Styling:Apply(button, "TextButton")
    Animation:HoverEffect(button, { BackgroundTransparency = Styling.Transparency.ElementBackground - 0.2 })
    button.MouseButton1Click:Connect(function()
        window:Restore()
        self:RemoveWindow(window)
    end)
    table.insert(self.Windows, window)
    window.TaskbarButton = button
    self.ButtonContainer.CanvasSize = UDim2.new(0, (#self.Windows + 1) * (self.ButtonWidth + Styling.Padding), 0, 0)
    if #self.Windows == 1 then self:ShowTaskbar() end
    return true
end

function Taskbar:RemoveWindow(window)
    for i, w in ipairs(self.Windows) do
        if w == window then
            if window.TaskbarButton then window.TaskbarButton:Destroy() end
            table.remove(self.Windows, i)
            self:UpdateButtonPositions()
            if #self.Windows == 0 and self.AutoHideEnabled then self:HideTaskbar() end
            return true
        end
    end
    return false
end

function Taskbar:UpdateButtonPositions()
    for i, window in ipairs(self.Windows) do
        if window.TaskbarButton then
            Animation:Tween(window.TaskbarButton, { Position = UDim2.new(0, (i-1) * (self.ButtonWidth + Styling.Padding), 0, 0) }, 0.2 / _G.CensuraG.Config.AnimationSpeed)
        end
    end
    self.ButtonContainer.CanvasSize = UDim2.new(0, #self.Windows * (self.ButtonWidth + Styling.Padding), 0, 0)
end

function Taskbar:RefreshCluster()
    if self.Cluster then
        self.Cluster.Instance.Position = UDim2.new(1, -210, 0, Styling.Padding)
        self.Cluster.Instance.Size = UDim2.new(0, 200, 0, self.Height - Styling.Padding * 2)
        self.Cluster.TimeLabel.Text = os.date("%H:%M")
    end
end

function Taskbar:Destroy()
    if self.MouseCheckConnection then self.MouseCheckConnection:Disconnect() end
    for _, window in ipairs(self.Windows) do if window.TaskbarButton then window.TaskbarButton:Destroy() end end
    self.Windows = {}
    if self.Cluster then self.Cluster:Destroy() end
    if self.Instance then self.Instance:Destroy() end
    logger:info("Taskbar destroyed")
end

return Taskbar
