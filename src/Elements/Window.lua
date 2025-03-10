-- Window.lua: Draggable window with minimize/maximize functionality
local Window = setmetatable({}, {__index = _G.CensuraG.UIElement})
Window.__index = Window

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local Draggable = _G.CensuraG.Draggable

function Window.new(title, x, y, width, height)
    local frame = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Size = UDim2.new(0, width, 0, height)
    })
    Styling:Apply(frame, "Frame")

    local titleBar = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 20),
        Text = title
    })
    Styling:Apply(titleBar, "TextLabel")

    local minimizeButton = Utilities.createInstance("TextButton", {
        Parent = titleBar,
        Position = UDim2.new(1, -20, 0, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Text = "-"
    })
    Styling:Apply(minimizeButton, "TextButton")
    Animation:HoverEffect(minimizeButton)

    local self = setmetatable({
        Instance = frame,
        Minimized = false,
        OriginalPosition = nil -- Store position before minimizing
    }, Window)

    self.DragHandler = Draggable.new(frame, titleBar)

    -- Register with WindowManager
    _G.CensuraG.WindowManager:AddWindow(self)
    self.OriginalPosition = frame.Position -- Store initial position

    minimizeButton.MouseButton1Click:Connect(function()
        if self.Minimized then
            self:Maximize()
        else
            self:Minimize()
        end
    end)

    return self
end

function Window:Minimize()
    if self.Minimized then return end
    self.Minimized = true
    _G.CensuraG.Animation:Tween(self.Instance, {Transparency = 1}, 0.2, function()
        self.Instance.Visible = false
    end)
    _G.CensuraG.Taskbar:AddWindow(self)
    _G.CensuraG.WindowManager:RemoveWindow(self)
end

function Window:Maximize()
    if not self.Minimized then return end
    self.Minimized = false
    self.Instance.Visible = true
    self.Instance.Position = self.OriginalPosition
    _G.CensuraG.Animation:Tween(self.Instance, {Transparency = 0})
    _G.CensuraG.WindowManager:AddWindow(self)
end

function Window:Destroy()
    self.DragHandler:Destroy()
    self.Instance:Destroy()
end

return Window
