-- Elements/Window.lua
local Window = setmetatable({}, { __index = _G.CensuraG.UIElement })
Window.__index = Window

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local Draggable = _G.CensuraG.Draggable
local EventManager = _G.CensuraG.EventManager
local logger = _G.CensuraG.Logger

function Window.new(title, x, y, width, height, options)
    options = options or {}
    width = width or 300
    height = height or 200
    
    local frame = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Position = UDim2.new(0, x or 100, 0, y or 100),
        Size = UDim2.new(0, width, 0, height),
        ZIndex = (_G.CensuraG.ZIndexManager and _G.CensuraG.ZIndexManager.BaseZIndex) or 100,
        Name = "Window_"..(options.Name or title or "Unnamed")
    })
    Styling:Apply(frame, "Window")
    
    local shadow = _G.CensuraG.Config.EnableShadows and Utilities.createTaperedShadow(frame, 5, 5, 0.9)
    if shadow then shadow.ZIndex = frame.ZIndex - 1 end
    
    local titleBarHeight = 30
    local titleBar = Utilities.createInstance("Frame", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, titleBarHeight),
        ZIndex = frame.ZIndex + 1,
        Name = "TitleBar"
    })
    Styling:Apply(titleBar, "Frame")
    
    local titleText = Utilities.createInstance("TextLabel", {
        Parent = titleBar,
        Position = UDim2.new(0, Styling.Padding, 0, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Text = title or "Window",
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = titleBar.ZIndex + 1,
        Name = "TitleText"
    })
    Styling:Apply(titleText, "TextLabel")
    
    local buttonSize = titleBarHeight - 8
    local minimizeButton = Utilities.createInstance("TextButton", {
        Parent = titleBar,
        Position = UDim2.new(1, -buttonSize * 2 - 10, 0, 4),
        Size = UDim2.new(0, buttonSize, 0, buttonSize),
        Text = "−",
        ZIndex = titleBar.ZIndex + 1,
        Name = "MinimizeButton"
    })
    Styling:Apply(minimizeButton, "TextButton")
    Animation:HoverEffect(minimizeButton)
    
    local closeButton = Utilities.createInstance("TextButton", {
        Parent = titleBar,
        Position = UDim2.new(1, -buttonSize - 5, 0, 4),
        Size = UDim2.new(0, buttonSize, 0, buttonSize),
        Text = "×",
        ZIndex = titleBar.ZIndex + 1,
        Name = "CloseButton"
    })
    Styling:Apply(closeButton, "TextButton")
    Animation:HoverEffect(closeButton)
    
    local contentContainer = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new(0, Styling.Padding, 0, titleBarHeight + Styling.Padding),
        Size = UDim2.new(1, -Styling.Padding * 2, 1, -titleBarHeight - Styling.Padding * 2),
        BackgroundTransparency = 1,
        ZIndex = frame.ZIndex + 1,
        Name = "ContentContainer"
    })
    Styling:Apply(contentContainer, "Frame")
    logger:debug("Created ContentContainer for window: %s", title or "Unnamed")

    local self = setmetatable({
        Instance = frame,
        Shadow = shadow,
        TitleBar = titleBar,
        TitleText = titleText,
        MinimizeButton = minimizeButton,
        CloseButton = closeButton,
        ContentContainer = contentContainer,
        Minimized = false,
        DragHandler = nil,
        Id = Utilities.generateId(),
        Options = options
    }, Window)
    
    self.DragHandler = Draggable.new(frame, titleBar)
    
    if _G.CensuraG.WindowManager then
        _G.CensuraG.WindowManager:AddWindow(self)
    end
    
    minimizeButton.MouseButton1Click:Connect(function() self:Minimize() end)
    closeButton.MouseButton1Click:Connect(function() self:Destroy() end)
    
    logger:info("Created window: %s", title or "Unnamed")
    EventManager:FireEvent("WindowCreated", self)
    return self
end

function Window:Minimize()
    if self.Minimized then return end
    self.Minimized = true
    self.CurrentPosition = self.Instance.Position
    local screenHeight = _G.CensuraG.ScreenGui.AbsoluteSize.Y
    Animation:SlideY(self.Instance, screenHeight + 50, 0.3 / _G.CensuraG.Config.AnimationSpeed, nil, nil, function()
        self.Instance.Visible = false
        if self.Shadow then self.Shadow.Visible = false end
        EventManager:FireEvent("WindowMinimized", self)
    end)
    if self.Shadow then Animation:SlideY(self.Shadow, screenHeight + 45, 0.3 / _G.CensuraG.Config.AnimationSpeed) end
    if _G.CensuraG.Taskbar then _G.CensuraG.Taskbar:AddWindow(self) end
end

function Window:Restore()
    if not self.Minimized then return end
    self.Instance.Visible = true
    if self.Shadow then self.Shadow.Visible = _G.CensuraG.Config.EnableShadows end
    Animation:SlideY(self.Instance, self.CurrentPosition.Y.Offset, 0.3 / _G.CensuraG.Config.AnimationSpeed, nil, nil, function()
        self.Minimized = false
        EventManager:FireEvent("WindowRestored", self)
    end)
    if self.Shadow then Animation:SlideY(self.Shadow, self.CurrentPosition.Y.Offset - 5, 0.3 / _G.CensuraG.Config.AnimationSpeed) end
    if _G.CensuraG.Taskbar then _G.CensuraG.Taskbar:RemoveWindow(self) end
end

function Window:Destroy()
    if self.DragHandler then self.DragHandler:Destroy() end
    if _G.CensuraG.WindowManager then _G.CensuraG.WindowManager:RemoveWindow(self) end
    if self.Minimized and _G.CensuraG.Taskbar then _G.CensuraG.Taskbar:RemoveWindow(self) end
    if self.Shadow then self.Shadow:Destroy() end
    if self.Instance then self.Instance:Destroy() end
    logger:info("Window destroyed: %s", self.TitleText.Text or "Unknown")
    EventManager:FireEvent("WindowClosed", self)
end

return Window
