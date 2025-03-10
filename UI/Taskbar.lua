-- UI/Taskbar.lua
-- Enhanced taskbar with auto-hide detection

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
Taskbar.IsAnimating = false
Taskbar.CheckingMouse = false
Taskbar.LastMousePosition = nil
Taskbar.ShowThreshold = 30
Taskbar.HideDelay = 1.0

function Taskbar:Init()
    if self.Instance then
        logger:warn("Taskbar already initialized")
        return self
    end
    local screenSize = Utilities.getScreenSize()
    if screenSize.X == 0 or screenSize.Y == 0 then
        screenSize = Vector2.new(1366, 768) -- Fallback resolution
        logger:warn("Using fallback screen size: %s", tostring(screenSize))
    end
    local taskbar = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Position = UDim2.new(0, 10, 1, 0), -- Start at the bottom edge
        Size = UDim2.new(1, -210, 0, self.Height),
        BackgroundTransparency = Styling.Transparency.ElementBackground,
        ZIndex = 5,
        Name = "Taskbar"
    })
    Styling:Apply(taskbar, "Frame")
    self.Instance = taskbar
    local buttonContainer = Utilities.createInstance("ScrollingFrame", {
        Parent = taskbar,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -210, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ZIndex = taskbar.ZIndex + 1,
        Name = "ButtonContainer"
    })
    self.ButtonContainer = buttonContainer
    self.Cluster = _G.CensuraG.Cluster.new({ Instance = taskbar })
    self:RefreshCluster()
    self.MouseCheckConnection = RunService.RenderStepped:Connect(function()
        if self.CheckingMouse or self.IsAnimating then return end
        self.CheckingMouse = true
        local mousePos = UserInputService:GetMouseLocation()
        local screenHeight = Utilities.getScreenSize().Y
        --logger:debug("Mouse Y: %d, Screen Height: %d, Taskbar Y: %d", mousePos.Y, screenHeight, self.Instance.Position.Y.Offset)
        if mousePos.Y >= screenHeight - self.ShowThreshold and not self.Visible then
            self:ShowTaskbar()
        elseif mousePos.Y < screenHeight - self.Height - self.ShowThreshold and self.Visible then
            if not self.HideTimestamp then
                self.HideTimestamp = tick()
            elseif tick() - self.HideTimestamp > self.HideDelay then
                self:HideTaskbar()
                self.HideTimestamp = nil
            end
        else
            self.HideTimestamp = nil
        end
        self.LastMousePosition = mousePos
        self.CheckingMouse = false
    end)
    self.Instance.Visible = false
    self.Visible = false
    logger:info("Taskbar initialized")
    return self
end

function Taskbar:ShowTaskbar()
    if self.Visible or self.IsAnimating then return end
    self.IsAnimating = true
    self.Instance.Visible = true
    self:RefreshCluster()
    local screenHeight = Utilities.getScreenSize().Y
    Animation:SlideY(self.Instance, screenHeight - self.Height, 0.3, nil, nil, function()
        self.IsAnimating = false
        self.Visible = true
        logger:debug("Taskbar shown at Y: %d", self.Instance.Position.Y.Offset)
    end)
end

function Taskbar:HideTaskbar()
    if not self.Visible or self.IsAnimating then return end
    self.IsAnimating = true
    local screenHeight = Utilities.getScreenSize().Y
    Animation:SlideY(self.Instance, screenHeight, 0.3, nil, nil, function()
        self.Instance.Visible = false
        self.IsAnimating = false
        self.Visible = false
        logger:debug("Taskbar hidden")
    end)
end

function Taskbar:SetAutoHide(enabled)
    if enabled == self.AutoHideEnabled then return end
    self.AutoHideEnabled = enabled
    if enabled then
        self:Init()
    else
        if self.MouseCheckConnection then self.MouseCheckConnection:Disconnect() end
        self:Show(true)
    end
    logger:info("Taskbar auto-hide %s", enabled and "enabled" or "disabled")
end

function Taskbar:AddWindow(window)
    if not window or not window.Instance then
        logger:warn("Invalid window in AddWindow")
        return false
    end
    for _, w in ipairs(self.Windows) do
        if w == window then return false end
    end
    local title = window.TitleText and window.TitleText.Text or "Window"
    local button = Utilities.createInstance("TextButton", {
        Parent = self.ButtonContainer,
        Position = UDim2.new(0, #self.Windows * (self.ButtonWidth + 5), 0, 5),
        Size = UDim2.new(0, self.ButtonWidth, 0, self.Height-10),
        Text = title,
        ZIndex = self.Instance.ZIndex + 2,
        Name = "TaskbarButton_"..window.Id
    })
    Styling:Apply(button, "TextButton")
    button.MouseEnter:Connect(function() Animation:Tween(button, { BackgroundTransparency = Styling.Transparency.ElementBackground - 0.1 }, 0.1) end)
    button.MouseLeave:Connect(function() Animation:Tween(button, { BackgroundTransparency = Styling.Transparency.ElementBackground }, 0.1) end)
    self.ButtonContainer.CanvasSize = UDim2.new(0, (#self.Windows+1)*(self.ButtonWidth+5), 0, 0)
    button.MouseButton1Click:Connect(function()
        if window.Restore then window:Restore() end
        self:RemoveWindow(window)
    end)
    table.insert(self.Windows, window)
    window.TaskbarButton = button
    if #self.Windows == 1 and not self.Visible then self:ShowTaskbar() end
    logger:debug("Added window to taskbar: %s", title)
    return true
end

function Taskbar:RemoveWindow(window)
    if not window then return false end
    for i, w in ipairs(self.Windows) do
        if w == window then
            if window.TaskbarButton then window.TaskbarButton:Destroy() end
            table.remove(self.Windows, i)
            self:UpdateButtonPositions()
            if #self.Windows == 0 and self.AutoHideEnabled then
                self:HideTaskbar()
            end
            logger:debug("Removed window from taskbar: %s", window.Instance.Name)
            return true
        end
    end
    logger:warn("Window not found in taskbar")
    return false
end

function Taskbar:UpdateButtonPositions()
    for i, window in ipairs(self.Windows) do
        if window.TaskbarButton then
            Animation:Tween(window.TaskbarButton, { Position = UDim2.new(0, (i-1)*(self.ButtonWidth+5), 0, 5) }, 0.2)
        end
    end
    self.ButtonContainer.CanvasSize = UDim2.new(0, #self.Windows*(self.ButtonWidth+5), 0, 0)
end

function Taskbar:RefreshCluster()
    if self.Cluster then
        self.Cluster.Instance.Visible = true
        if self.Cluster.AvatarImage then self.Cluster.AvatarImage.Image.Visible = true end
        if self.Cluster.DisplayName then self.Cluster.DisplayName.Visible = true end
        if self.Cluster.TimeLabel then self.Cluster.TimeLabel.Visible = true; self.Cluster.TimeLabel.Text = os.date("%H:%M") end
    end
end

function Taskbar:Show(instant)
    if self.Visible then return end
    if instant then
        self.Instance.Visible = true
        local screenHeight = Utilities.getScreenSize().Y
        self.Instance.Position = UDim2.new(0, 10, 1, 0) -- Reset to bottom
        Animation:SlideY(self.Instance, screenHeight - self.Height, 0, nil, nil) -- Instant slide
        self.Visible = true
        self:RefreshCluster()
        logger:debug("Taskbar shown instantly at Y: %d", self.Instance.Position.Y.Offset)
    else
        self:ShowTaskbar()
    end
end

function Taskbar:Hide(instant)
    if not self.Visible then return end
    if instant then
        local screenHeight = Utilities.getScreenSize().Y
        self.Instance.Position = UDim2.new(0, 10, 1, 0) -- Reset to bottom
        self.Instance.Visible = false
        self.Visible = false
        logger:debug("Taskbar hidden instantly")
    else
        self:HideTaskbar()
    end
end

function Taskbar:Toggle()
    if self.Visible then self:Hide() else self:Show() end
    return self.Visible
end

function Taskbar:ForceShow()
    local wasAutoHide = self.AutoHideEnabled
    self.AutoHideEnabled = false
    self.Instance.Visible = true
    local screenHeight = Utilities.getScreenSize().Y
    self.Instance.Position = UDim2.new(0, 10, 1, 0) -- Reset to bottom
    Animation:SlideY(self.Instance, screenHeight - self.Height, 0.3, nil, nil)
    self.Visible = true
    task.delay(5, function()
        self.AutoHideEnabled = wasAutoHide
        if self.AutoHideEnabled then self:Init() end
    end)
    logger:info("Taskbar force shown")
    return true
end

function Taskbar:Destroy()
    if self.MouseCheckConnection then self.MouseCheckConnection:Disconnect() end
    for _, window in ipairs(self.Windows) do
        if window.TaskbarButton then window.TaskbarButton:Destroy() end
    end
    self.Windows = {}
    if self.Cluster then self.Cluster:Destroy() end
    if self.Instance then self.Instance:Destroy() end
    logger:info("Taskbar destroyed")
end

return Taskbar
