-- CensuraG/src/components/textlabel.lua
local Config = _G.CensuraG.Config

return function(parent, text)
    local Label = Instance.new("TextLabel", parent)
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Config.Theme.TextColor
    Label.Font = Config.Theme.Font
    Label.TextSize = 14
    
    _G.CensuraG.Logger:info("TextLabel created with text: " .. text)
    return Label
end
