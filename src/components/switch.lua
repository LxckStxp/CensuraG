-- CensuraG/src/components/switch.lua
local Config = _G.CensuraG.Config

return function(parent, default, callback)
    local theme = Config:GetTheme()
    local SwitchFrame = Instance.new("Frame", parent)
    SwitchFrame.Size = UDim2.new(0, 50, 0, 20)
    SwitchFrame.BackgroundColor3 = theme.PrimaryColor
    SwitchFrame.BorderSizePixel = 0
    
    local Knob = Instance.new("Frame", SwitchFrame)
    Knob.Size = UDim2.new(0, 20, 0, 20)
    Knob.BackgroundColor3 = default and theme.AccentColor or theme.SecondaryColor
    Knob.BorderSizePixel = 0
    
    local state = default or false
    Knob.Position = state and UDim2.new(1, -20, 0, 0) or UDim2.new(0, 0, 0, 0)
    
    local Button = Instance.new("TextButton", SwitchFrame)
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    
    Button.MouseButton1Click:Connect(function()
        state = not state
        _G.CensuraG.AnimationManager:Tween(Knob, {
            Position = state and UDim2.new(1, -20, 0, 0) or UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = state and theme.AccentColor or theme.SecondaryColor
        }, Config.Animations.SlideDuration)
        if callback then callback(state) end
    end)
    
    _G.CensuraG.Logger:info("Switch created with default state: " .. tostring(default))
    return SwitchFrame, state
end
