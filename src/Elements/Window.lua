-- Window.lua: Enhanced draggable window with slide-based minimize/maximize and shadows
local Window = setmetatable({}, {__index = _G.CensuraG.UIElement})
Window.__index = Window

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local Draggable = _G.CensuraG.Draggable

function Window.new(title, x, y, width, height)
    local frame = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Size = UDim2.new(0, width, 0, height),
        ZIndex = 2 -- Ensure windows are above the taskbar
    })
    Styling:Apply(frame, "Frame")

    -- Add shadow to the window
    local shadow = Utilities.createShadow(frame, 10, 10, Color3.fromRGB(0, 0, 0), 0.7)

    local titleBar = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 20),
        Text = title,
        ZIndex = 3
    })
    Styling:Apply(titleBar, "TextLabel")

    local minimizeButton = Utilities.createInstance("TextButton", {
        Parent = titleBar,
        Position = UDim2.new(1, -20, 0, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Text = "-",
        ZIndex = 3
    })
    Styling:Apply(minimizeButton, "TextButton")
    Animation:HoverEffect(minimizeButton)

    local self = setmetatable({
        Instance = frame,
        Shadow = shadow,
        Minimized = false,
        OriginalPosition = nil, -- Store position before minimizing
        OriginalZIndex = frame.ZIndex,
        Debounce = false -- Prevent animation overlap
    }, Window)

    -- Make the window draggable
    self.DragHandler = Draggable.new(frame, titleBar)

    -- Register with WindowManager
    _G.CensuraG.WindowManager:AddWindow(self)
    self.OriginalPosition = frame.Position -- Store initial position

    -- Update shadow position when window moves
    self.DragHandler.OnDrag = function()
        shadow.Position = UDim2.new(0, -10, 0, -10)
    end

    minimizeButton.MouseButton1Click:Connect(function()
        if self.Debounce then return end
        if self.Minimized then
            self:Maximize()
        else
            self:Minimize()
        end
    end)

    return self
end

function Window:Minimize()
    if self.Minimized or self.Debounce then return end
    self.Debounce = true
    self.Minimized = true
    -- Store the current position before minimizing
    self.OriginalPosition = self.Instance.Position
    -- Calculate offscreen position (below the screen)
    local screenHeight = _G.CensuraG.ScreenGui.AbsoluteSize.Y
    local offscreenY = screenHeight + self.Instance.Size.Y.Offset
    Animation:Tween(self.Instance, {Position = UDim2.new(0, self.OriginalPosition.X.Offset, 0, offscreenY)}, 0.3, function()
        self.Instance.Visible = false
        self.Shadow.Visible = false
        self.Debounce = false
    end)
    Animation:Tween(self.Shadow, {Position = UDim2.new(0, -10, 0, offscreenY - 10)}, 0.3)
    _G.CensuraG.Taskbar:AddWindow(self)
    _G.CensuraG.WindowManager:RemoveWindow(self)
end

function Window:Maximize()
    if not self.Minimized or self.Debounce then return end
    self.Debounce = true
    self.Minimized = false
    self.Instance.Visible = true
    self.Shadow.Visible = true
    -- Slide back to the original position
    Animation:Tween(self.Instance, {Position = self.OriginalPosition}, 0.3, function()
        self.Debounce = false
    end)
    Animation:Tween(self.Shadow, {Position = UDim2.new(0, -10, 0, -10)}, 0.3)
    _G.CensuraG.WindowManager:AddWindow(self)
end

function Window:Destroy()
    self.DragHandler:Destroy()
    self.Instance:Destroy()
end

return Window
