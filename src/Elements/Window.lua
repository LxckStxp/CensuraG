-- Window.lua: Draggable and managed window
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
    
    local self = setmetatable({Instance = frame, Minimized = false}, Window)
    
    -- Make draggable from title bar only
    Draggable:MakeDraggable(frame, titleBar)
    
    -- Register with WindowManager (overrides x, y)
    _G.CensuraG.WindowManager:AddWindow(self)
    
    -- Minimize Logic with Animation
    minimizeButton.MouseButton1Click:Connect(function()
        self:Minimize()
    end)
    
    return self
end

function Window:Minimize()
    if self.Minimized then
        Animation:FadeIn(self.Instance)
    else
        Animation:FadeOut(self.Instance)
        _G.CensuraG.Taskbar:AddWindow(self)
    end
    self.Minimized = not self.Minimized
end

return Window
