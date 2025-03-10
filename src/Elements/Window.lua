-- Window.lua: Enhanced draggable window with miltech styling and Y-axis sliding animation
local Window = setmetatable({}, {__index = _G.CensuraG.UIElement})
Window.__index = Window

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local Draggable = _G.CensuraG.Draggable
local logger = _G.CensuraG.Logger

function Window.new(title, x, y, width, height)
    local frame = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Size = UDim2.new(0, width, 0, height),
        BackgroundTransparency = 0.5,
        ZIndex = 2
    })
    Styling:Apply(frame, "Frame")
    logger:debug("Created window frame: %s, Initial Position: %s, Size: %s, ZIndex: %d, Transparency: %.2f", title, tostring(frame.Position), tostring(frame.Size), frame.ZIndex, frame.BackgroundTransparency)

    local frameStroke = Utilities.createInstance("UIStroke", {
        Parent = frame,
        Thickness = 1,
        Color = Color3.fromRGB(200, 200, 200),
        Transparency = 0.2
    })

    local gradient = Utilities.createInstance("UIGradient", {
        Parent = frame,
        Color = ColorSequence.new(Styling.Colors.Base, Styling.Colors.Highlight),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(1, 0.7)
        }),
        Rotation = 45
    })

    local shadow = Utilities.createTaperedShadow(frame, 5, 5, 0.95)
    logger:debug("Created shadow for window: %s, ZIndex: %d", title, shadow.ZIndex)

    local titleBar = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 20),
        Text = title,
        BackgroundTransparency = 0.3,
        BackgroundColor3 = Styling.Colors.Highlight,
        ZIndex = 3
    })
    Styling:Apply(titleBar, "TextLabel")
    logger:debug("Created title bar for window: %s, Position: %s, Size: %s, ZIndex: %d, Visible: %s", title, tostring(titleBar.Position), tostring(titleBar.Size), titleBar.ZIndex, tostring(titleBar.Visible))

    local minimizeButton = Utilities.createInstance("TextButton", {
        Parent = titleBar,
        Position = UDim2.new(1, -20, 0, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Text = "-",
        BackgroundTransparency = 0.3,
        BackgroundColor3 = Styling.Colors.Highlight,
        ZIndex = 3
    })
    Styling:Apply(minimizeButton, "TextButton")
    logger:debug("Created minimize button for window: %s, Position: %s, Size: %s, ZIndex: %d, Visible: %s", title, tostring(minimizeButton.Position), tostring(minimizeButton.Size), minimizeButton.ZIndex, tostring(minimizeButton.Visible))

    local minimizeStroke = Utilities.createInstance("UIStroke", {
        Parent = minimizeButton,
        Thickness = 1,
        Color = Color3.fromRGB(200, 200, 200),
        Transparency = 0.5
    })

    local self = setmetatable({
        Instance = frame,
        Shadow = shadow,
        Minimized = false,
        CurrentPosition = nil,
        OriginalPosition = nil,
        OriginalZIndex = frame.ZIndex,
        Debounce = false
    }, Window)

    self.DragHandler = Draggable.new(frame, titleBar)

    self.DragHandler.OnDrag = function()
        self.CurrentPosition = self.Instance.Position
        self.Shadow.Position = UDim2.new(0, self.Instance.Position.X.Offset - 5, 0, self.Instance.Position.Y.Offset - 5)
        self.Shadow.Size = UDim2.new(0, self.Instance.Size.X.Offset + 10, 0, self.Instance.Size.Y.Offset + 10)
        logger:debug("Window %s dragged to Position: %s", title, tostring(self.CurrentPosition))
    end

    _G.CensuraG.WindowManager:AddWindow(self)
    self.OriginalPosition = frame.Position
    self.CurrentPosition = self.OriginalPosition
    logger:info("Window %s registered with WindowManager at Position: %s", title, tostring(self.OriginalPosition))

    Animation:HoverEffect(minimizeButton)

    minimizeButton.MouseButton1Click:Connect(function()
        if self.Debounce then return end
        if self.Minimized then
            self:Maximize()
            logger:info("Maximized window: %s", title)
        else
            self:Minimize()
            logger:info("Minimized window: %s", title)
        end
    end)

    return self
end

function Window:Minimize()
    if self.Minimized or self.Debounce then return end
    self.Debounce = true
    self.Minimized = true
    self.CurrentPosition = self.Instance.Position
    local screenHeight = _G.CensuraG.ScreenGui.AbsoluteSize.Y
    local offscreenY = screenHeight + self.Instance.Size.Y.Offset

    Animation:SlideY(self.Instance, offscreenY, 0.3, nil, nil, function()
        self.Instance.Visible = false
        self.Shadow.Visible = false
        self.Debounce = false
        for _, child in pairs(self.Instance:GetChildren()) do
            if child:IsA("GuiObject") then
                child.Visible = false
                logger:debug("Set child %s of window to Visible: false during minimize", child.Name)
            end
        end
    end)
    Animation:SlideY(self.Shadow, offscreenY - 5, 0.3)
    if _G.CensuraG and _G.CensuraG.Taskbar and _G.CensuraG.Taskbar.AddWindow then
        _G.CensuraG.Taskbar:AddWindow(self)
    else
        logger:error("Taskbar or AddWindow method is not available during minimize.")
    end
    _G.CensuraG.WindowManager:RemoveWindow(self)
end

function Window:Maximize()
    if not self.Minimized or self.Debounce then return end
    self.Debounce = true
    self.Minimized = false
    self.Instance.Visible = true
    self.Shadow.Visible = true

    local targetY = (self.CurrentPosition or self.OriginalPosition).Y.Offset
    Animation:SlideY(self.Instance, targetY, 0.3, nil, nil, function()
        self.Debounce = false
    end)
    Animation:SlideY(self.Shadow, targetY - 5, 0.3)
    self.Shadow.Size = UDim2.new(0, self.Instance.Size.X.Offset + 10, 0, self.Instance.Size.Y.Offset + 10)

    for _, child in pairs(self.Instance:GetChildren()) do
        if child:IsA("GuiObject") then
            child.Visible = true
            logger:debug("Set child %s of window to Visible: true during maximize", child.Name)
        end
    end

    for i, taskbarWindow in ipairs(_G.CensuraG.Taskbar.Windows) do
        if taskbarWindow == self then
            local button = _G.CensuraG.Taskbar.Instance:GetChildren()[i]
            if button then
                button:Destroy()
                logger:debug("Removed taskbar button for window during maximize")
            end
            table.remove(_G.CensuraG.Taskbar.Windows, i)
            break
        end
    end

    _G.CensuraG.WindowManager:AddWindow(self)
end

function Window:Destroy()
    self.DragHandler:Destroy()
    self.Shadow:Destroy()
    self.Instance:Destroy()
    logger:info("Destroyed window")
end

return Window
