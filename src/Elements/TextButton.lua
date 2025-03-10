-- TextButton.lua: Styled and animated button
local TextButton = setmetatable({}, {__index = _G.CensuraG.UIElement})
TextButton.__index = TextButton

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation

function TextButton.new(parent, text, x, y, width, height, callback)
    local button = Utilities.createInstance("TextButton", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width, 0, height),
        Text = text
    })
    Styling:Apply(button, "TextButton")
    Animation:HoverEffect(button)
    
    local self = setmetatable({Instance = button}, TextButton)
    button.MouseButton1Click:Connect(callback or function() end)
    return self
end

return TextButton
