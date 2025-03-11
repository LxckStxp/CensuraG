-- CensuraG/src/components/textlabel.lua
local Config = _G.CensuraG.Config

return function(parent, text)
    local theme = Config:GetTheme()
    local Label = Instance.new("TextLabel", parent)
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = theme.TextColor
    Label.Font = theme.Font
    Label.TextSize = theme.TextSize
    
    _G.CensuraG.Logger:info("TextLabel created with text: " .. text)
    return Label
end
