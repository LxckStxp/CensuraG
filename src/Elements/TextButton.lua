-- TextButton.lua: Styled clickable button
local TextButton = setmetatable({}, {__index = _G.CensuraG.UIElement})
TextButton.__index = TextButton

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local logger = _G.CensuraG.Logger

function TextButton.new(parent, text, x, y, width, height, callback)
    if not parent or not parent.Instance then return nil end
    width = width or 120
    height = height or 30

    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width + 80, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = parent.Instance.ZIndex + 1
    })

    local label = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 60, 0, 20),
        Text = text,
        ZIndex = frame.ZIndex + 1
    })
    Styling:Apply(label, "TextLabel")

    local button = Utilities.createInstance("TextButton", {
        Parent = frame,
        Position = UDim2.new(0, 65, 0, 0),
        Size = UDim2.new(0, width, 0, height),
        Text = "",
        ZIndex = frame.ZIndex + 1
    })
    Styling:Apply(button, "TextButton")
    Animation:HoverEffect(button)

    local self = setmetatable({
        Instance = frame,
        Button = button,
        Label = label
    }, TextButton)

    button.MouseButton1Click:Connect(function()
        if callback then callback() end
        logger:debug("Button %s clicked", text)
    end)

    function self:Destroy()
        self.Instance:Destroy()
        logger:info("TextButton destroyed")
    end

    return self
end

return TextButton
