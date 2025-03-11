-- CensuraG/src/components/textbutton.lua
local Config = _G.CensuraG.Config

return function(parent, text, callback)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    
    local Button = Instance.new("TextButton", parent)
    Button.Size = UDim2.new(0, 100, 0, 30)
    Button.BackgroundColor3 = theme.SecondaryColor
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = theme.TextColor
    Button.Font = theme.Font
    Button.TextSize = theme.TextSize
    Button.BackgroundTransparency = 1 -- Start hidden
    
    -- Animation
    _G.CensuraG.AnimationManager:Tween(Button, {BackgroundTransparency = 0}, animConfig.FadeDuration)
    
    if callback then
        Button.MouseButton1Click:Connect(callback)
    end
    
    local TextButton = {
        Instance = Button,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("textbutton", self.Instance)
        end
    }
    
    _G.CensuraG.Logger:info("TextButton created with text: " .. text)
    return TextButton
end
