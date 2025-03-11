-- CensuraG/src/components/textbutton.lua
local Config = _G.CensuraG.Config

return function(parent, text, callback)
    local Button = Instance.new("TextButton", parent)
    Button.Size = UDim2.new(0, 100, 0, 30)
    Button.BackgroundColor3 = Config.Theme.SecondaryColor
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = Config.Theme.TextColor
    Button.Font = Config.Theme.Font
    Button.TextSize = 14
    
    if callback then
        Button.MouseButton1Click:Connect(callback)
    end
    
    _G.CensuraG.Logger:info("TextButton created with text: " .. text)
    return Button
end
