-- CensuraG/src/components/dropdown.lua (with improved z-index)
local Config = _G.CensuraG.Config

return function(parent, title, options, callback)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    
    local DropdownFrame = Instance.new("Frame", parent)
    DropdownFrame.Size = UDim2.new(0, 120, 0, 50) -- Increased height for title
    DropdownFrame.BackgroundColor3 = theme.SecondaryColor
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.ZIndex = 1 -- Base z-index
    
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
    TitleLabel.ZIndex = 1
    
    -- Dropdown
    local DropdownInner = Instance.new("Frame", DropdownFrame)
    DropdownInner.Size = UDim2.new(1, 0, 0, 30)
    DropdownInner.Position = UDim2.new(0, 0, 0, 20 + Config.Math.ElementSpacing)
    DropdownInner.BackgroundColor3 = theme.SecondaryColor
    DropdownInner.BackgroundTransparency = 1
    DropdownInner.ZIndex = 1
    
    local SelectedText = Instance.new("TextLabel", DropdownInner)
    SelectedText.Size = UDim2.new(1, -30, 1, 0)
    SelectedText.BackgroundTransparency = 1
    SelectedText.Text = options[1] or "Select"
    SelectedText.TextColor3 = theme.TextColor
    SelectedText.Font = theme.Font
    SelectedText.TextSize = theme.TextSize
    SelectedText.ZIndex = 1
    
    local Arrow = Instance.new("TextButton", DropdownInner)
    Arrow.Size = UDim2.new(0, 30, 1, 0)
    Arrow.Position = UDim2.new(1, -30, 0, 0)
    Arrow.BackgroundColor3 = theme.AccentColor
    Arrow.Text = "▼"
    Arrow.TextColor3 = theme.TextColor
    Arrow.Font = theme.Font
    Arrow.ZIndex = 1
    
    -- Create a separate parent for the option list to ensure it's on top
    local OptionListContainer = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
    OptionListContainer.Name = "DropdownOptions_" .. game:GetService("HttpService"):GenerateGUID(false)
    OptionListContainer.ResetOnSpawn = false
    OptionListContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local OptionList = Instance.new("Frame", OptionListContainer)
    OptionList.Size = UDim2.new(0, DropdownInner.AbsoluteSize.X, 0, #options * 25)
    OptionList.BackgroundColor3 = theme.PrimaryColor
    OptionList.BorderSizePixel = 0
    OptionList.Visible = false
    OptionList.ZIndex = 100 -- Very high z-index to be above everything
    
    -- Function to update option list position to match dropdown
    local function updateOptionListPosition()
        local dropdownPos = DropdownInner.AbsolutePosition
        local dropdownSize = DropdownInner.AbsoluteSize
        
        OptionList.Position = UDim2.new(0, dropdownPos.X, 0, dropdownPos.Y + dropdownSize.Y)
        OptionList.Size = UDim2.new(0, dropdownSize.X, 0, #options * 25)
    end
    
    local function updateList()
        -- Clear existing options
        for _, child in pairs(OptionList:GetChildren()) do
            child:Destroy()
        end
        
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
            Button.ZIndex = 100 -- Match parent z-index
            
            Button.MouseButton1Click:Connect(function()
                SelectedText.Text = option
                OptionList.Visible = false
                if callback then callback(option) end
            end)
        end
    end
    
    Arrow.MouseButton1Click:Connect(function()
        updateOptionListPosition() -- Update position before showing
        OptionList.Visible = not OptionList.Visible
    end)
    
    -- Close dropdown when clicking elsewhere
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
            local listPos = OptionList.AbsolutePosition
            local listSize = OptionList.AbsoluteSize
            
            -- Check if click is outside the dropdown options
            if OptionList.Visible and (
                mousePos.X < listPos.X or 
                mousePos.Y < listPos.Y or 
                mousePos.X > listPos.X + listSize.X or 
                mousePos.Y > listPos.Y + listSize.Y
            ) and not (
                mousePos.X >= Arrow.AbsolutePosition.X and
                mousePos.Y >= Arrow.AbsolutePosition.Y and
                mousePos.X <= Arrow.AbsolutePosition.X + Arrow.AbsoluteSize.X and
                mousePos.Y <= Arrow.AbsolutePosition.Y + Arrow.AbsoluteSize.Y
            ) then
                OptionList.Visible = false
            end
        end
    end)
    
    -- Update position when parent changes
    parent:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateOptionListPosition)
    parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateOptionListPosition)
    
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
        OptionListContainer = OptionListContainer,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("dropdown", self)
            updateOptionListPosition() -- Refresh position
        end,
        Cleanup = function(self)
            -- Remove the option list container when no longer needed
            if self.OptionListContainer then
                self.OptionListContainer:Destroy()
            end
        end
    }
    
    _G.CensuraG.Logger:info("Dropdown created with " .. #options .. " options")
    return Dropdown
end
