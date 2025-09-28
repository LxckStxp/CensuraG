-- CensuraG/src/components/dropdown.lua (fixed syntax error)
local Config = _G.CensuraG.Config

return function(parent, title, options, callback)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    
    -- Glassmorphic Container
    local DropdownFrame = Instance.new("Frame", parent)
    DropdownFrame.Size = UDim2.new(1, -12, 0, 36) -- Slightly taller for modern look
    DropdownFrame.BackgroundColor3 = theme.SecondaryColor
    DropdownFrame.BackgroundTransparency = theme.GlassTransparency or 0.8
    DropdownFrame.BorderSizePixel = 0
    
    -- Glassmorphic corner radius
    local Corner = Instance.new("UICorner", DropdownFrame)
    Corner.CornerRadius = UDim.new(0, 12) -- More rounded for modern look
    
    -- Glassmorphic stroke
    local Stroke = Instance.new("UIStroke", DropdownFrame)
    Stroke.Color = theme.BorderColor
    Stroke.Transparency = theme.BorderTransparency or 0.7
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
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
    
    -- Glassmorphic Selected value display
    local SelectedDisplay = Instance.new("Frame", DropdownFrame)
    SelectedDisplay.Size = UDim2.new(0, 110, 0, 28) -- Slightly larger
    SelectedDisplay.Position = UDim2.new(1, -118, 0.5, -14)
    SelectedDisplay.BackgroundColor3 = theme.PrimaryColor
    SelectedDisplay.BackgroundTransparency = (theme.GlassTransparency or 0.8) + 0.1
    
    local DisplayCorner = Instance.new("UICorner", SelectedDisplay)
    DisplayCorner.CornerRadius = UDim.new(0, 8) -- Smaller radius for contrast
    
    local DisplayStroke = Instance.new("UIStroke", SelectedDisplay)
    DisplayStroke.Color = theme.BorderColor
    DisplayStroke.Transparency = theme.BorderTransparency or 0.7
    DisplayStroke.Thickness = 1
    
    local SelectedText = Instance.new("TextLabel", SelectedDisplay)
    SelectedText.Size = UDim2.new(1, -24, 1, 0)
    SelectedText.BackgroundTransparency = 1
    SelectedText.Text = options[1] or "Select"
    SelectedText.TextColor3 = theme.TextColor
    SelectedText.Font = theme.Font
    SelectedText.TextSize = theme.TextSize
    
    -- Store the currently selected option
    local selectedOption = options[1] or "Select"
    
    -- Glassmorphic Arrow button
    local ArrowButton = Instance.new("TextButton", SelectedDisplay)
    ArrowButton.Size = UDim2.new(0, 28, 1, 0)
    ArrowButton.Position = UDim2.new(1, -28, 0, 0)
    ArrowButton.BackgroundColor3 = theme.AccentColor
    ArrowButton.BackgroundTransparency = 0.8
    ArrowButton.Text = "▼"
    ArrowButton.TextColor3 = theme.TextColor
    ArrowButton.Font = theme.Font
    ArrowButton.TextSize = 12
    ArrowButton.AutoButtonColor = false
    
    local ArrowCorner = Instance.new("UICorner", ArrowButton)
    ArrowCorner.CornerRadius = UDim.new(0, 6) -- Smaller radius
    
    local ArrowStroke = Instance.new("UIStroke", ArrowButton)
    ArrowStroke.Color = theme.BorderColor
    ArrowStroke.Transparency = theme.BorderTransparency or 0.7
    ArrowStroke.Thickness = 1
    
    -- Create a separate parent for the option list to ensure it's on top
    local OptionListContainer = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
    OptionListContainer.Name = "DropdownOptions_" .. game:GetService("HttpService"):GenerateGUID(false)
    OptionListContainer.ResetOnSpawn = false
    OptionListContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Glassmorphic Options list
    local OptionList = Instance.new("Frame", OptionListContainer)
    OptionList.Size = UDim2.new(0, 110, 0, #options * 28) -- Match display width and use taller rows
    OptionList.BackgroundColor3 = theme.PrimaryColor
    OptionList.BackgroundTransparency = theme.GlassTransparency or 0.2
    OptionList.BorderSizePixel = 0
    OptionList.Visible = false
    OptionList.ZIndex = 100
    
    local ListCorner = Instance.new("UICorner", OptionList)
    ListCorner.CornerRadius = UDim.new(0, 12) -- Match modern styling
    
    local ListStroke = Instance.new("UIStroke", OptionList)
    ListStroke.Color = theme.BorderColor
    ListStroke.Transparency = theme.BorderTransparency or 0.7
    ListStroke.Thickness = 1
    ListStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    -- Add shadow/blur effect to option list
    local ListShadow = Instance.new("Frame", OptionList)
    ListShadow.Size = UDim2.new(1, 6, 1, 6)
    ListShadow.Position = UDim2.new(0, -3, 0, -3)
    ListShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ListShadow.BackgroundTransparency = 0.8
    ListShadow.ZIndex = -1
    
    local ShadowCorner = Instance.new("UICorner", ListShadow)
    ShadowCorner.CornerRadius = UDim.new(0, 15)
    
    -- Function to update option list position
    local function updateOptionListPosition()
        local displayPos = SelectedDisplay.AbsolutePosition
        local displaySize = SelectedDisplay.AbsoluteSize
        
        OptionList.Position = UDim2.new(0, displayPos.X, 0, displayPos.Y + displaySize.Y + 2)
        OptionList.Size = UDim2.new(0, displaySize.X, 0, #options * 28) -- Use new taller rows
    end
    
    -- Storage for option buttons
    local optionButtons = {}
    
    -- Create option buttons
    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton", OptionList)
        OptionButton.Size = UDim2.new(1, -4, 0, 26) -- Slightly smaller with padding
        OptionButton.Position = UDim2.new(0, 2, 0, (i-1) * 28 + 1) -- Add margin
        
        -- Set background color based on selection state
        if option == selectedOption then
            OptionButton.BackgroundColor3 = theme.AccentColor
            OptionButton.BackgroundTransparency = 0.5
        else
            OptionButton.BackgroundColor3 = theme.SecondaryColor
            OptionButton.BackgroundTransparency = 0.8
        end
        
        OptionButton.Text = option
        OptionButton.TextColor3 = theme.TextColor
        OptionButton.Font = theme.Font
        OptionButton.TextSize = theme.TextSize
        OptionButton.ZIndex = 100
        OptionButton.Name = "Option_" .. option
        
        -- Add hover effect
        OptionButton.MouseEnter:Connect(function()
            if option ~= selectedOption then
                _G.CensuraG.AnimationManager:Tween(OptionButton, {BackgroundTransparency = 0.6}, 0.2)
            end
        end)
        
        OptionButton.MouseLeave:Connect(function()
            if option ~= selectedOption then
                _G.CensuraG.AnimationManager:Tween(OptionButton, {BackgroundTransparency = 0.8}, 0.2)
            end
        end)
        
        -- Selection logic
        OptionButton.MouseButton1Click:Connect(function()
            -- Update the selected option
            selectedOption = option
            SelectedText.Text = option
            
            -- Update option button appearances
            for j, btn in ipairs(optionButtons) do
                if btn.Text == option then
                    _G.CensuraG.AnimationManager:Tween(btn, {
                        BackgroundColor3 = theme.AccentColor,
                        BackgroundTransparency = 0.5
                    }, 0.2)
                else
                    _G.CensuraG.AnimationManager:Tween(btn, {
                        BackgroundColor3 = theme.SecondaryColor,
                        BackgroundTransparency = 0.8
                    }, 0.2)
                end
            end
            
            -- Hide dropdown
            OptionList.Visible = false
            ArrowButton.Text = "▼"
            
            -- Call callback
            if callback then 
                callback(option)
            end
        end)
        
        -- Store reference to the button
        optionButtons[i] = OptionButton
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
    
    -- Public API
    local Dropdown = {
        Instance = DropdownFrame,
        SelectedDisplay = SelectedDisplay,
        SelectedText = SelectedText,
        ArrowButton = ArrowButton,
        OptionList = OptionList,
        OptionListContainer = OptionListContainer,
        OptionButtons = optionButtons,
        SetSelected = function(self, option, skipCallback)
            if table.find(options, option) then
                -- Find the option in the options table
                for i, opt in ipairs(options) do
                    if opt == option then
                        -- Update selected state
                        selectedOption = option
                        SelectedText.Text = option
                        
                        -- Update button appearances
                        for j, btn in ipairs(optionButtons) do
                            if j == i then
                                _G.CensuraG.AnimationManager:Tween(btn, {
                                    BackgroundColor3 = theme.AccentColor,
                                    BackgroundTransparency = 0.5
                                }, 0.2)
                            else
                                _G.CensuraG.AnimationManager:Tween(btn, {
                                    BackgroundColor3 = theme.SecondaryColor,
                                    BackgroundTransparency = 0.8
                                }, 0.2)
                            end
                        end
                        
                        -- Call callback if needed
                        if not skipCallback and callback then
                            callback(option)
                        end
                        
                        break
                    end
                end
            end
        end,
        GetSelected = function(self)
            return selectedOption
        end,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("dropdown", self)
            updateOptionListPosition()
            
            -- Refresh appearance for all options
            local theme = Config:GetTheme()
            for i, btn in ipairs(optionButtons) do
                if btn.Text == selectedOption then
                    _G.CensuraG.AnimationManager:Tween(btn, {
                        BackgroundColor3 = theme.AccentColor,
                        BackgroundTransparency = 0.5,
                        TextColor3 = theme.TextColor
                    }, 0.2)
                else
                    _G.CensuraG.AnimationManager:Tween(btn, {
                        BackgroundColor3 = theme.SecondaryColor,
                        BackgroundTransparency = 0.8,
                        TextColor3 = theme.TextColor
                    }, 0.2)
                end
                btn.Font = theme.Font
            end
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
