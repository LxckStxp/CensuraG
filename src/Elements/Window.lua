-- Window.lua: Draggable window with modern styling
local Window = setmetatable({}, {__index = _G.CensuraG.UIElement})
Window.__index = Window

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local Draggable = _G.CensuraG.Draggable
local logger = _G.CensuraG.Logger

function Window.new(title, x, y, width, height)
    width = width or 300
    height = height or 200

    local frame = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Position = UDim2.new(0, x or 0, 0, y or 0),
        Size = UDim2.new(0, width, 0, height),
        ZIndex = 2
    })
    Styling:Apply(frame, "Window")

    local shadow = Utilities.createTaperedShadow(frame, 5, 5, 0.9)
    shadow.ZIndex = frame.ZIndex - 1

    local titleBarHeight = 20
    local titleBar = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -titleBarHeight - 5, 0, titleBarHeight),
        Text = title,
        ZIndex = frame.ZIndex + 2
    })
    Styling:Apply(titleBar, "TextLabel")

    local minimizeButton = Utilities.createInstance("TextButton", {
        Parent = frame,
        Position = UDim2.new(1, -titleBarHeight, 0, 0),
        Size = UDim2.new(0, titleBarHeight, 0, titleBarHeight),
        Text = "-",
        ZIndex = frame.ZIndex + 2
    })
    Styling:Apply(minimizeButton, "TextButton")
    Animation:HoverEffect(minimizeButton)

    local self = setmetatable({
        Instance = frame,
        Shadow = shadow,
        Minimized = false,
        CurrentPosition = frame.Position,
        OriginalPosition = frame.Position,
        DragHandler = Draggable.new(frame, titleBar)
    }, Window)

    _G.CensuraG.WindowManager:AddWindow(self)

    minimizeButton.MouseButton1Click:Connect(function()
        if self.Minimized then self:Maximize() else self:Minimize() end
    end)

    return self
end

function Window:Minimize()
    if self.Minimized or self.Debounce then return end
    self.Debounce = true
    self.Minimized = true
    self.CurrentPosition = self.Instance.Position
    local screenHeight = _G.CensuraG.ScreenGui.AbsoluteSize.Y
    Animation:SlideY(self.Instance, screenHeight + 50, 0.3, nil, nil, function()
        self.Instance.Visible = false
        self.Shadow.Visible = false
        self:UpdateChildrenVisibility(false)
        self.Debounce = false
    end)
    Animation:SlideY(self.Shadow, screenHeight + 45, 0.3)
    _G.CensuraG.Taskbar:AddWindow(self)
end

function Window:Maximize()
    if not self.Minimized or self.Debounce then return end
    self.Debounce = true
    self.Minimized = false
    self.Instance.Visible = true
    self.Shadow.Visible = true
    local targetY = self.CurrentPosition.Y.Offset
    Animation:SlideY(self.Instance, targetY, 0.3, nil, nil, function()
        self:UpdateChildrenVisibility(true)
        self.Debounce = false
    end)
    Animation:SlideY(self.Shadow, targetY - 5, 0.3)
    for i, win in ipairs(_G.CensuraG.Taskbar.Windows) do
        if win == self then
            local btn = _G.CensuraG.Taskbar.Instance:GetChildren()[i]
            if btn then btn:Destroy() end
            table.remove(_G.CensuraG.Taskbar.Windows, i)
            break
        end
    end
end

function Window:UpdateChildrenVisibility(visible)
    for _, child in pairs(self.Instance:GetChildren()) do
        if child:IsA("GuiObject") then
            child.Visible = visible
            if visible and (child:IsA("TextLabel") or child:IsA("TextButton")) then
                child.TextTransparency = 0
                child.ZIndex = self.Instance.ZIndex + 2
            end
        end
    end
end

function Window:Destroy()
    self.DragHandler:Destroy()
    self.Shadow:Destroy()
    self.Instance:Destroy()
    logger:info("Window destroyed")
end

return Window
