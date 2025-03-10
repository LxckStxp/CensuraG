-- TextButton.lua: TextButton class
local TextButton = setmetatable({}, {__index = _G.CensuraG.UIElement})
TextButton.__index = TextButton

local Utilities = _G.CensuraG.Utilities

function TextButton.new(parent, text, x, y, width, height, callback)
    local button = Utilities.createInstance("TextButton", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width, 0, height),
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundColor3 = Color3.fromRGB(70, 70, 70),
        BorderSizePixel = 0
    })
    
    local self = setmetatable({Instance = button}, TextButton)
    button.MouseButton1Click:Connect(callback or function() end)
    return self
end

return TextButton
