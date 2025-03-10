-- TextButton.lua: Styled clickable button with modern miltech styling
local TextButton = setmetatable({}, {__index = _G.CensuraG.UIElement})
TextButton.__index = TextButton

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local logger = _G.CensuraG.Logger

function TextButton.new(parent, text, x, y, width, height, callback)
    if not parent or not parent.Instance then
        logger:error("Invalid parent for text button: %s", tostring(parent))
        return nil
    end

    height = height or 30
    width = width or 120

    logger:debug("Creating text button with parent: %s, Text: %s, Position: (%d, %d)", tostring(parent.Instance), text, x, y)

    -- Create the main frame
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width, 0, height + 20), -- Include label height
        BackgroundTransparency = 1,
        ZIndex = parent.Instance.ZIndex + 1
    })

    -- Create the label (above the button)
    local label = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, width, 0, 20),
        Text = text,
        BackgroundTransparency = 1,
        ZIndex = frame.ZIndex + 1
    })
    Styling:Apply(label, "TextLabel")

    -- Create the button
    local button = Utilities.createInstance("TextButton", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 20), -- Below the label
        Size = UDim2.new(0, width, 0, height),
        Text = "",
        BackgroundTransparency = Styling.Transparency.Highlight,
        ZIndex = frame.ZIndex + 1
    })
    Styling:Apply(button, "TextButton")
    logger:debug("TextButton created: Position: %s, Size: %s, ZIndex: %d", tostring(button.Position), tostring(button.Size), button.ZIndex)

    local self = setmetatable({Instance = frame, Button = button, Label = label}, TextButton)
    button.MouseButton1Click:Connect(function()
        logger:debug("TextButton clicked: Text: %s", text)
        if callback then callback() end
    end)

    function self:Destroy()
        self.Instance:Destroy()
        logger:info("TextButton destroyed")
    end

    return self
end

return TextButton
