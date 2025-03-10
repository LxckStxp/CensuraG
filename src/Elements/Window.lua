-- Window.lua: Draggable window class
local Window = setmetatable({}, {__index = _G.CensuraG.UIElement})
Window.__index = Window

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Draggable = _G.CensuraG.Draggable

function Window.new(title, x, y, width, height)
    local frame = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width, 0, height)
    })
    Styling:Apply(frame, "Frame")

    local titleBar = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, 0, 0, 20),
        Text = title
    })
    Styling:Apply(titleBar, "TextLabel")

    local self = setmetatable({Instance = frame}, Window)
    self.DragHandler = Draggable.new(frame, titleBar)
    return self
end

return Window
