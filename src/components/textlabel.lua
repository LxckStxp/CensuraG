-- CensuraG/src/components/textlabel.lua (revised)
local Config = _G.CensuraG.Config

return function(parent, text)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    
    local LabelFrame = Instance.new("Frame", parent)
    LabelFrame.Size = UDim2.new(1, -12, 0, 32)
    LabelFrame.BackgroundColor3 = theme.SecondaryColor
    LabelFrame.BackgroundTransparency = 0.9 -- More transparent for labels
    LabelFrame.BorderSizePixel = 0
    
    -- Add corner radius
    local Corner = Instance.new("UICorner", LabelFrame)
    Corner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)
    
    local Label = Instance.new("TextLabel", LabelFrame)
    Label.Size = UDim2.new(1, -10, 1, 0)
    Label.Position = UDim2.new(0, 5, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = theme.TextColor
    Label.Font = theme.Font
    Label.TextSize = theme.TextSize
    Label.TextWrapped = true
    Label.TextXAlignment = Enum.TextXAlignment.Center
    
    -- Add text shadow for depth
    local TextShadow = Instance.new("TextLabel", Label)
    TextShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    TextShadow.Position = UDim2.new(0.5, 1, 0.5, 1)
    TextShadow.Size = UDim2.new(1, 0, 1, 0)
    TextShadow.BackgroundTransparency = 1
    TextShadow.Text = text
    TextShadow.TextColor3 = theme.PrimaryColor
    TextShadow.TextTransparency = 0.8
    TextShadow.Font = theme.Font
    TextShadow.TextSize = theme.TextSize
    TextShadow.TextWrapped = true
    TextShadow.TextXAlignment = Enum.TextXAlignment.Center
    
    -- Animation
    LabelFrame.BackgroundTransparency = 1
    Label.TextTransparency = 1
    TextShadow.TextTransparency = 1
    
    _G.CensuraG.AnimationManager:Tween(LabelFrame, {BackgroundTransparency = 0.9}, animConfig.FadeDuration)
    _G.CensuraG.AnimationManager:Tween(Label, {TextTransparency = 0}, animConfig.FadeDuration)
    _G.CensuraG.AnimationManager:Tween(TextShadow, {TextTransparency = 0.8}, animConfig.FadeDuration)
    
    local TextLabel = {
        Instance = LabelFrame,
        Label = Label,
        TextShadow = TextShadow,
        SetText = function(self, newText)
            self.Label.Text = newText
            self.TextShadow.Text = newText
        end,
        Refresh = function(self)
            local theme = Config:GetTheme()
            
            -- Frame
            _G.CensuraG.AnimationManager:Tween(self.Instance, {
                BackgroundColor3 = theme.SecondaryColor,
                BackgroundTransparency = 0.9
            }, animConfig.FadeDuration)
            
            -- Label
            _G.CensuraG.AnimationManager:Tween(self.Label, {
                TextColor3 = theme.TextColor,
                TextSize = theme.TextSize
            }, animConfig.FadeDuration)
            
            -- Set Font directly
            self.Label.Font = theme.Font
            
            -- Shadow
            _G.CensuraG.AnimationManager:Tween(self.TextShadow, {
                TextColor3 = theme.PrimaryColor,
                TextSize = theme.TextSize
            }, animConfig.FadeDuration)
            
            -- Set Font directly
            self.TextShadow.Font = theme.Font
        end
    }
    
    -- Add component type attribute for the RefreshAll system
    LabelFrame:SetAttribute("ComponentType", "textlabel")
    
    _G.CensuraG.Logger:info("TextLabel created with text: " .. text)
    return TextLabel
end
