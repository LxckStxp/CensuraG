-- TextButton.lua: Styled clickable button
local TextButton = setmetatable({}, {__index = _G.CensuraG.UIElement})
TextButton.__index = TextButton

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local logger = _G.CensuraG.Logger

function TextButton.new(parent, text, x, y, width, height, callback)
    logger:debug("Creating text button with parent: %s, Text: %s, Position: (%d, %d)", tostring(parent.Instance), text, x, y)

    local button = Utilities.createInstance("TextButton", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width, 0, height or 30),
        Text = text,
        BackgroundTransparency = 0
    })
    Styling:Apply(button, "TextButton")
    logger:debug("TextButton created: Position: %s, Size: %s, ZIndex: %d, Visible: %s, Parent: %s", tostring(button.Position), tostring(button.Size), button.ZIndex, tostring(button.Visible), tostring(button.Parent))

    Animation:HoverEffect(button)

    local self = setmetatable({Instance = button}, TextButton)
    button.MouseButton1Click:Connect(function()
        logger:debug("TextButton clicked: Text: %s", text)
        if callback then callback() end
    end)
    return self
end

return TextButton
