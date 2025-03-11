-- CensuraG/src/components/dropdown.lua (updated for CensuraDev styling)
local Config = _G.CensuraG.Config

return function(parent, title, options, callback)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    
    -- Container
    local DropdownFrame = Instance.new("Frame", parent)
    DropdownFrame.Size = UDim2.new(1, -12, 0, 32)
    DropdownFrame.BackgroundColor3 = theme.SecondaryColor
    DropdownFrame.BackgroundTransparency = 0.8
    DropdownFrame.BorderSizePixel = 0
    
    -- Add corner radius
    local Corner = Instance.new("UICorner", DropdownFrame)
    Corner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)
    
    -- Add stroke
    local Stroke = Instance.new("UIStroke", DropdownFrame)
    Stroke.Color = theme.AccentColor
    Stroke.Transparency = 0.6
    Stroke.Thickness = Config.Math.BorderThickness
    
    -- Title
    local TitleLabel = Instance.new("TextLabel", DropdownFrame)
    TitleLabel.Size = UDim2.new(1, -44, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "Select"
    TitleLabel.TextColor3 = theme.TextColor
    TitleLabel.Font = theme.Font
    TitleLabel.TextSize = theme.TextSize
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Selected value display
    local SelectedDisplay = Instance.new("Frame", DropdownFrame)
    SelectedDisplay.Size = UDim2.new(0, 100, 0, 24)
    SelectedDisplay.Position = UDim2.new(1, -110, 0.5, -12)
    SelectedDisplay.BackgroundColor3 = theme.PrimaryColor
    SelectedDisplay.BackgroundTransparency = 0.5
    
    local DisplayCorner = Instance.new("UICorner", SelectedDisplay)
    DisplayCorner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)
    
    local SelectedText = Instance.new("TextLabel", SelectedDisplay)
    SelectedText.Size = UDim2.new(1, -24, 1, 0)
    SelectedText.BackgroundTransparency = 1
    SelectedText.Text = options[1] or "Select"
    SelectedText.TextColor3 = theme.TextColor
    SelectedText.Font = theme.Font
    SelectedText.TextSize = theme.TextSize
    
    -- Arrow button
    local ArrowButton = Instance.new("TextButton", SelectedDisplay)
    ArrowButton.Size = UDim2.new(0, 24, 1, 0)
    ArrowButton.Position = UDim2.new(1, -24, 0, 0)
    ArrowButton.BackgroundColor3 = theme.AccentColor
    ArrowButton.BackgroundTransparency = 0.7
    ArrowButton.Text = "▼"
    ArrowButton.TextColor3 = theme.TextColor
    ArrowButton.Font = theme.Font
    ArrowButton.TextSize = 12
    
    local ArrowCorner = Instance.new("UICorner", ArrowButton)
    ArrowCorner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)
    
    -- Create a separate parent for the option list to ensure it's on top
    local OptionListContainer = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
    OptionListContainer.Name = "DropdownOptions_" .. game:GetService("HttpService"):GenerateGUID(false)
    OptionListContainer.ResetOnSpawn = false
    OptionListContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Options list
    local OptionList = Instance.new("Frame", OptionListContainer)
    OptionList.Size = UDim2.new(0, 100, 0, #options * 24)
    OptionList.BackgroundColor3 = theme.PrimaryColor
    OptionList.BackgroundTransparency = 0.2
    OptionList.BorderSizePixel = 0
    OptionList.Visible = false
    OptionList.ZIndex = 100
    
    local ListCorner = Instance.new("UICorner", OptionList)
    ListCorner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)
    
    local ListStroke = Instance.new("UIStroke", OptionList)
    ListStroke.Color = theme.AccentColor
    ListStroke.Transparency = 0.6
    ListStroke.Thickness = Config.Math.BorderThickness
    
    -- Function to update option list position
    local function updateOptionListPosition()
        local displayPos = SelectedDisplay.AbsolutePosition
        local displaySize = SelectedDisplay.AbsoluteSize
        
        OptionList.Position = UDim2.new(0, displayPos.X, 0, displayPos.Y + displaySize.Y + 2)
        OptionList.Size = UDim2.new(0, displaySize.X, 0, #options * 24)
    end
    
    -- Create option buttons
    local function createOptions()
        for i, option in ipairs(options) do
            local OptionButton = Instance.new("TextButton", OptionList)
            OptionButton.Size = UDim2.new(1, 0, 0, 24)
            OptionButton.Position = UDim2.new(0, 0, 0, (i-1) * 24)
            OptionButton.BackgroundColor3 = theme.SecondaryColor
            OptionButton.BackgroundTransparency = 0.8
            OptionButton.Text = option
            OptionButton.TextColor3 = theme.TextColor
            OptionButton.Font = theme.Font
            OptionButton.TextSize = theme.TextSize
            OptionButton.ZIndex = 100
            
            -- Add hover effect
            OptionButton.MouseEnter:Connect(function()
                _G.CensuraG.AnimationManager:Tween(OptionButton, {BackgroundTransparency = 0.6}, 0.2)
            end)
            
            OptionButton.MouseLeave:Connect(function()
                _G.CensuraG.AnimationManager:Tween(OptionButton, {BackgroundTransparency = 0.8}, 0.2)
            end)
            
            -- Selection logic
            OptionButton.MouseButton1Click:Connect(function()
                SelectedText.Text = option
                OptionList.Visible = false
                if callback then callback(option) end
            end)
        end
    end
    
    -- Toggle dropdown
    ArrowButton.MouseButton1Click:Connect(function()
        updateOptionListPosition()
        OptionList.Visible = not OptionList.Visible
        
        -- Animate arrow
        local rotation = OptionList.Visible and "▲" or "▼"
        ArrowButton.Text = rotation
    end)
    
    -- Close dropdown when clicking elsewhere
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and OptionList.Visible then
            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
            local listPos = OptionList.AbsolutePosition
            local listSize = OptionList.AbsoluteSize
            
            -- Check if click is outside the dropdown options and arrow button
            if not (
                mousePos.X >= listPos.X and
                mousePos.Y >= listPos.Y and
                mousePos.X <= listPos.X + listSize.X and
                mousePos.Y <= listPos.Y + listSize.Y
            ) and not (
                mousePos.X >= ArrowButton.AbsolutePosition.X and
                mousePos.Y >= ArrowButton.AbsolutePosition.Y and
                mousePos.X <= ArrowButton.AbsolutePosition.X + ArrowButton.AbsoluteSize.X and
                mousePos.Y <= ArrowButton.AbsolutePosition.Y + ArrowButton.AbsoluteSize.Y
            ) then
                OptionList.Visible = false
                ArrowButton.Text = "▼"
            end
        end
    end)
    
    -- Update position when parent changes
    parent:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateOptionListPosition)
    parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateOptionListPosition)
    
    -- Hover effects
    DropdownFrame.MouseEnter:Connect(function()
        _G.CensuraG.AnimationManager:Tween(Stroke, {Transparency = 0.2}, 0.2)
        _G.CensuraG.AnimationManager:Tween(SelectedDisplay, {BackgroundTransparency = 0.3}, 0.2)
    end)
    
    DropdownFrame.MouseLeave:Connect(function()
        _G.CensuraG.AnimationManager:Tween(Stroke, {Transparency = 0.6}, 0.2)
        _G.CensuraG.AnimationManager:Tween(SelectedDisplay, {BackgroundTransparency = 0.5}, 0.2)
    end)
    
    ArrowButton.MouseEnter:Connect(function()
        _G.CensuraG.AnimationManager:Tween(ArrowButton, {BackgroundTransparency = 0.5}, 0.2)
    end)
    
    ArrowButton.MouseLeave:Connect(function()
        _G.CensuraG.AnimationManager:Tween(ArrowButton, {BackgroundTransparency = 0.7}, 0.2)
    end)
    
    -- Initialize
    createOptions()
    
    local Dropdown = {
        Instance = DropdownFrame,
        SelectedDisplay = SelectedDisplay,
        SelectedText = SelectedText,
        ArrowButton = ArrowButton,
        OptionList = OptionList,
        OptionListContainer = OptionListContainer,
        SetSelected = function(self, option, skipCallback)
            if table.find(options, option) then
                self.SelectedText.Text = option
                if not skipCallback and callback then
                    callback(option)
                end
            end
        end,
        GetSelected = function(self)
            return self.SelectedText.Text
        end,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("dropdown", self)
            updateOptionListPosition()
        end,
        Cleanup = function(self)
            if self.OptionListContainer then
                self.OptionListContainer:Destroy()
            end
        end
    }
    
    _G.CensuraG.Logger:info("Dropdown created with " .. #options .. " options")
    return Dropdown
end
