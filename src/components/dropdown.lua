-- CensuraG/src/components/dropdown.lua (updated return and add title)
local Config = _G.CensuraG.Config

return function(parent, title, options, callback)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    
    local DropdownFrame = Instance.new("Frame", parent)
    DropdownFrame.Size = UDim2.new(0, 120, 0, 50) -- Increased height for title
    DropdownFrame.BackgroundColor3 = theme.SecondaryColor
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.BackgroundTransparency = 1
    
    -- Title
    local TitleLabel = Instance.new("TextLabel", DropdownFrame)
    TitleLabel.Size = UDim2.new(1, -2 * Config.Math.Padding, 0, 15)
    TitleLabel.Position = UDim2.new(0, Config.Math.Padding, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "Dropdown"
    TitleLabel.TextColor3 = theme.TextColor
    TitleLabel.Font = theme.Font
    TitleLabel.TextSize = theme.TextSize
    TitleLabel.TextWrapped = true
    TitleLabel.TextTransparency = 1
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Dropdown
    local DropdownInner = Instance.new("Frame", DropdownFrame)
    DropdownInner.Size = UDim2.new(1, 0, 0, 30)
    DropdownInner.Position = UDim2.new(0, 0, 0, 20 + Config.Math.ElementSpacing)
    DropdownInner.BackgroundColor3 = theme.SecondaryColor
    DropdownInner.BackgroundTransparency = 1
    
    local SelectedText = Instance.new("TextLabel", DropdownInner)
    SelectedText.Size = UDim2.new(1, -30, 1, 0)
    SelectedText.BackgroundTransparency = 1
    SelectedText.Text = options[1] or "Select"
    SelectedText.TextColor3 = theme.TextColor
    SelectedText.Font = theme.Font
    SelectedText.TextSize = theme.TextSize
    
    local Arrow = Instance.new("TextButton", DropdownInner)
    Arrow.Size = UDim2.new(0, 30, 1, 0)
    Arrow.Position = UDim2.new(1, -30, 0, 0)
    Arrow.BackgroundColor3 = theme.AccentColor
    Arrow.Text = "▼"
    Arrow.TextColor3 = theme.TextColor
    Arrow.Font = theme.Font
    
    local OptionList = Instance.new("Frame", DropdownInner)
    OptionList.Size = UDim2.new(1, 0, 0, #options * 25)
    OptionList.Position = UDim2.new(0, 0, 1, 0)
    OptionList.BackgroundColor3 = theme.PrimaryColor
    OptionList.Visible = false
    OptionList.BorderSizePixel = 0
    
    local function updateList()
        for i, option in ipairs(options) do
            local Button = Instance.new("TextButton", OptionList)
            Button.Size = UDim2.new(1, 0, 0, 25)
            Button.Position = UDim2.new(0, 0, 0, (i-1) * 25)
            Button.BackgroundColor3 = theme.PrimaryColor
            Button.Text = option
            Button.TextColor3 = theme.TextColor
            Button.Font = theme.Font
            Button.TextSize = theme.TextSize
            Button.BorderSizePixel = 0
            
            Button.MouseButton1Click:Connect(function()
                SelectedText.Text = option
                OptionList.Visible = false
                if callback then callback(option) end
            end)
        end
    end
    
    Arrow.MouseButton1Click:Connect(function()
        OptionList.Visible = not OptionList.Visible
        local targetPos = OptionList.Visible and UDim2.new(0, 0, 1, 0) or UDim2.new(0, 0, 1, -#options * 25)
        _G.CensuraG.AnimationManager:Tween(OptionList, {Position = targetPos}, animConfig.SlideDuration)
    end)
    
    updateList()
    _G.CensuraG.AnimationManager:Tween(DropdownFrame, {BackgroundTransparency = 0}, animConfig.FadeDuration)
    _G.CensuraG.AnimationManager:Tween(DropdownInner, {BackgroundTransparency = 0}, animConfig.FadeDuration)
    _G.CensuraG.AnimationManager:Tween(TitleLabel, {TextTransparency = 0}, animConfig.FadeDuration)
    
    local Dropdown = {
        Instance = DropdownFrame,
        InnerFrame = DropdownInner,
        TitleLabel = TitleLabel,
        SelectedText = SelectedText,
        Arrow = Arrow,
        OptionList = OptionList,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("dropdown", self)
        end
    }
    
    _G.CensuraG.Logger:info("Dropdown created with " .. #options .. " options")
    return Dropdown
end
