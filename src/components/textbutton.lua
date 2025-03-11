-- CensuraG/src/components/textbutton.lua
local Config = _G.CensuraG.Config

return function(parent, text, callback)
    local theme = Config:GetTheme()
    local Button = Instance.new("TextButton", parent)
    Button.Size = UDim2.new(0, 100, 0, 30)
    Button.BackgroundColor3 = theme.SecondaryColor
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = theme.TextColor
    Button.Font = theme.Font
    Button.TextSize = theme.TextSize
    
    -- Hover animation
    Button.MouseEnter:Connect(function()
        _G.CensuraG.AnimationManager:Tween(Button, {
            Size = UDim2.new(0, 105, 0, 32)
        }, Config.Animations.FadeDuration)
    end)
    Button.MouseLeave:Connect(function()
        _G.CensuraG.AnimationManager:Tween(Button, {
            Size = UDim2.new(0, 100, 0, 30)
        }, Config.Animations.FadeDuration)
    end)
    
    -- Click animation
    if callback then
        Button.MouseButton1Click:Connect(function()
            _G.CensuraG.AnimationManager:Tween(Button, {
                BackgroundColor3 = theme.AccentColor
            }, Config.Animations.FadeDuration / 2)
            wait(Config.Animations.FadeDuration / 2)
            _G.CensuraG.AnimationManager:Tween(Button, {
                BackgroundColor3 = theme.SecondaryColor
            }, Config.Animations.FadeDuration / 2)
            callback()
        end)
    end
    
    _G.CensuraG.Logger:info("TextButton created with text: " .. text)
    return Button
end
