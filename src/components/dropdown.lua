-- CensuraG/src/components/dropdown.lua
local Config = _G.CensuraG.Config

return function(parent, options, callback)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    
    local DropdownFrame = Instance.new("Frame", parent)
    DropdownFrame.Size = UDim2.new(0, 120, 0, 30)
    DropdownFrame.BackgroundColor3 = theme.SecondaryColor
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.BackgroundTransparency = 1 -- Start hidden
    
    local SelectedText = Instance.new("TextLabel", DropdownFrame)
    SelectedText.Size = UDim2.new(1, -30, 1, 0)
    SelectedText.BackgroundTransparency = 1
    SelectedText.Text = options[1] or "Select"
    SelectedText.TextColor3 = theme.TextColor
    SelectedText.Font = theme.Font
    SelectedText.TextSize = theme.TextSize
    
    local Arrow = Instance.new("TextButton", DropdownFrame)
    Arrow.Size = UDim2.new(0, 30, 1, 0)
    Arrow.Position = UDim2.new(1, -30, 0, 0)
    Arrow.BackgroundColor3 = theme.AccentColor
    Arrow.Text = "▼"
    Arrow.TextColor3 = theme.TextColor
    Arrow.Font = theme.Font
    
    local OptionList = Instance.new("Frame", DropdownFrame)
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
    
    local Dropdown = {
        Instance = DropdownFrame,
        SelectedText = SelectedText,
        Arrow = Arrow,
        OptionList = OptionList,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("dropdown", self)
        end
    }
    
    _G.CensuraG.Logger:info("Dropdown created with " .. #options .. " options")
    return Dropdown.Instance
end
