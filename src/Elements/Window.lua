-- Window.lua: Enhanced draggable window with modern miltech styling
local Window = setmetatable({}, {__index = _G.CensuraG.UIElement})
Window.__index = Window

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local Draggable = _G.CensuraG.Draggable
local logger = _G.CensuraG.Logger

function Window.new(title, x, y, width, height)
    x = x or 0
    y = y or 0
    width = width or 300 -- Default width
    height = height or 200 -- Default height

    local frame = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width, 0, height),
        BackgroundTransparency = 1, -- Fully transparent for better visibility
        ZIndex = 2
    })
    Styling:Apply(frame, "Frame")
    logger:debug("Created window frame: %s, Initial Position: %s, Size: %s, ZIndex: %d", title, tostring(frame.Position), tostring(frame.Size), frame.ZIndex)

    local shadow = Utilities.createTaperedShadow(frame, 5, 5, 0.9)
    shadow.ZIndex = frame.ZIndex - 1
    logger:debug("Created shadow for window: %s, ZIndex: %d", title, shadow.ZIndex)

    local titleBarHeight = 20
    local titleBar = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -titleBarHeight - 5, 0, titleBarHeight),
        Text = title,
        BackgroundTransparency = Styling.Transparency.Highlight,
        ZIndex = frame.ZIndex + 1
    })
    Styling:Apply(titleBar, "TextLabel")
    logger:debug("Created title bar for window: %s, Position: %s, Size: %s, ZIndex: %d", title, tostring(titleBar.Position), tostring(titleBar.Size), titleBar.ZIndex)

    local minimizeButton = Utilities.createInstance("TextButton", {
        Parent = frame,
        Position = UDim2.new(1, -titleBarHeight, 0, 0),
        Size = UDim2.new(0, titleBarHeight, 0, titleBarHeight),
        Text = "-",
        BackgroundTransparency = Styling.Transparency.Highlight,
        ZIndex = frame.ZIndex + 1
    })
    Styling:Apply(minimizeButton, "TextButton")
    logger:debug("Created minimize button for window: %s, Position: %s, Size: %s, ZIndex: %d", title, tostring(minimizeButton.Position), tostring(minimizeButton.Size), minimizeButton.ZIndex)

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
end

function Window:Destroy()
    self.DragHandler:Destroy()
    self.Shadow:Destroy()
    self.Instance:Destroy()
    logger:info("Destroyed window")
end

return Window
