-- Window.lua: Enhanced draggable window with synchronized shadow animations
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
    local shadow = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Size = UDim2.new(0, width + 20, 0, height + 20), -- Slightly larger for shadow offset
        Position = UDim2.new(0, x - 10, 0, y - 10),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.7,
        ZIndex = 1 -- Below the window but above the taskbar
    })

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
        OriginalPosition = nil,
        OriginalZIndex = frame.ZIndex,
        Debounce = false
    }, Window)

    -- Make the window draggable
    self.DragHandler = Draggable.new(frame, titleBar)

    -- Update shadow position when window moves
    self.DragHandler.OnDrag = function()
        self.Shadow.Position = UDim2.new(0, self.Instance.Position.X.Offset - 10, 0, self.Instance.Position.Y.Offset - 10)
    end

    -- Register with WindowManager
    _G.CensuraG.WindowManager:AddWindow(self)
    self.OriginalPosition = frame.Position

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
    self.OriginalPosition = self.Instance.Position
    local screenHeight = _G.CensuraG.ScreenGui.AbsoluteSize.Y
    local offscreenY = screenHeight + self.Instance.Size.Y.Offset

    -- Animate window and shadow together
    Animation:Tween(self.Instance, {Position = UDim2.new(0, self.OriginalPosition.X.Offset, 0, offscreenY)}, 0.3, function()
        self.Instance.Visible = false
        self.Shadow.Visible = false
        self.Debounce = false
        -- Ensure child elements are hidden
        for _, child in pairs(self.Instance:GetChildren()) do
            child.Visible = false
        end
    end)
    Animation:Tween(self.Shadow, {Position = UDim2.new(0, self.OriginalPosition.X.Offset - 10, 0, offscreenY - 10)}, 0.3)

    _G.CensuraG.Taskbar:AddWindow(self)
    _G.CensuraG.WindowManager:RemoveWindow(self)
end

function Window:Maximize()
    if not self.Minimized or self.Debounce then return end
    self.Debounce = true
    self.Minimized = false
    self.Instance.Visible = true
    self.Shadow.Visible = true

    -- Restore visibility of child elements
    for _, child in pairs(self.Instance:GetChildren()) do
        child.Visible = true
    end

    -- Animate window and shadow together
    Animation:Tween(self.Instance, {Position = self.OriginalPosition}, 0.3, function()
        self.Debounce = false
    end)
    Animation:Tween(self.Shadow, {Position = UDim2.new(0, self.OriginalPosition.X.Offset - 10, 0, self.OriginalPosition.Y.Offset - 10)}, 0.3)

    -- Remove the window from the taskbar
    for i, taskbarWindow in ipairs(_G.CensuraG.Taskbar.Windows) do
        if taskbarWindow == self then
            local button = _G.CensuraG.Taskbar.Instance:GetChildren()[i]
            if button then
                button:Destroy()
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
end

return Window
