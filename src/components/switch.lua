-- CensuraG/src/components/switch.lua (updated return and add title)
local Config = _G.CensuraG.Config

return function(parent, title, default, callback)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    
    local SwitchFrame = Instance.new("Frame", parent)
    SwitchFrame.Size = UDim2.new(0, 150, 0, 40) -- Increased height for title
    SwitchFrame.BackgroundColor3 = theme.PrimaryColor
    SwitchFrame.BorderSizePixel = 0
    SwitchFrame.BackgroundTransparency = 1
    
    -- Title
    local TitleLabel = Instance.new("TextLabel", SwitchFrame)
    TitleLabel.Size = UDim2.new(1, -2 * Config.Math.Padding, 0, 15)
    TitleLabel.Position = UDim2.new(0, Config.Math.Padding, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "Switch"
    TitleLabel.TextColor3 = theme.TextColor
    TitleLabel.Font = theme.Font
    TitleLabel.TextSize = theme.TextSize
    TitleLabel.TextWrapped = true
    TitleLabel.TextTransparency = 1
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Switch
    local SwitchInner = Instance.new("Frame", SwitchFrame)
    SwitchInner.Size = UDim2.new(0, 50, 0, 20)
    SwitchInner.Position = UDim2.new(1, -50 - Config.Math.Padding, 0, 20 + Config.Math.ElementSpacing)
    SwitchInner.BackgroundColor3 = theme.PrimaryColor
    SwitchInner.BackgroundTransparency = 1
    
    local Knob = Instance.new("Frame", SwitchInner)
    Knob.Size = UDim2.new(0, 20, 0, 20)
    Knob.BackgroundColor3 = default and theme.AccentColor or theme.SecondaryColor
    Knob.BorderSizePixel = 0
    
    local state = default or false
    Knob.Position = state and UDim2.new(1, -20, 0, 0) or UDim2.new(0, 0, 0, 0)
    
    local Button = Instance.new("TextButton", SwitchInner)
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    
    Button.MouseButton1Click:Connect(function()
        state = not state
        Knob.BackgroundColor3 = state and theme.AccentColor or theme.SecondaryColor
        _G.CensuraG.AnimationManager:Tween(Knob, {Position = state and UDim2.new(1, -20, 0, 0) or UDim2.new(0, 0, 0, 0)}, animConfig.SlideDuration)
        if callback then callback(state) end
    end)
    
    _G.CensuraG.AnimationManager:Tween(SwitchFrame, {BackgroundTransparency = 0}, animConfig.FadeDuration)
    _G.CensuraG.AnimationManager:Tween(SwitchInner, {BackgroundTransparency = 0}, animConfig.FadeDuration)
    _G.CensuraG.AnimationManager:Tween(TitleLabel, {TextTransparency = 0}, animConfig.FadeDuration)
    
    local Switch = {
        Instance = SwitchFrame,
        InnerFrame = SwitchInner,
        Knob = Knob,
        TitleLabel = TitleLabel,
        State = state,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("switch", self)
        end
    }
    
    _G.CensuraG.Logger:info("Switch created with default state: " .. tostring(default))
    return Switch, state
end
