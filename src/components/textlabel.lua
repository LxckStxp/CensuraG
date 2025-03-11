-- CensuraG/src/components/textlabel.lua (updated return)
local Config = _G.CensuraG.Config

return function(parent, text)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    
    local Label = Instance.new("TextLabel", parent)
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = theme.TextColor
    Label.Font = theme.Font
    Label.TextSize = theme.TextSize
    Label.TextTransparency = 1
    Label.TextWrapped = true -- Enable text wrapping
    
    _G.CensuraG.AnimationManager:Tween(Label, {TextTransparency = 0}, animConfig.FadeDuration)
    
    local TextLabel = {
        Instance = Label,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("textlabel", self.Instance)
        end
    }
    
    _G.CensuraG.Logger:info("TextLabel created with text: " .. text)
    return TextLabel -- Return the full table, not TextLabel.Instance
end
