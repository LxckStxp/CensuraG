-- CensuraG/src/components/dropdown.lua
local Config = _G.CensuraG.Config

return function(parent, options, callback)
    local DropdownFrame = Instance.new("Frame", parent)
    DropdownFrame.Size = UDim2.new(0, 120, 0, 30)
    DropdownFrame.BackgroundColor3 = Config.Theme.SecondaryColor
    DropdownFrame.BorderSizePixel = 0
    
    local SelectedText = Instance.new("TextLabel", DropdownFrame)
    SelectedText.Size = UDim2.new(1, -30, 1, 0)
    SelectedText.BackgroundTransparency = 1
    SelectedText.Text = options[1] or "Select"
    SelectedText.TextColor3 = Config.Theme.TextColor
    SelectedText.Font = Config.Theme.Font
    SelectedText.TextSize = 14
    
    local Arrow = Instance.new("TextButton", DropdownFrame)
    Arrow.Size = UDim2.new(0, 30, 1, 0)
    Arrow.Position = UDim2.new(1, -30, 0, 0)
    Arrow.BackgroundColor3 = Config.Theme.AccentColor
    Arrow.Text = "▼"
    Arrow.TextColor3 = Config.Theme.TextColor
    Arrow.Font = Config.Theme.Font
    
    local OptionList = Instance.new("Frame", DropdownFrame)
    OptionList.Size = UDim2.new(1, 0, 0, #options * 25)
    OptionList.Position = UDim2.new(0, 0, 1, 0)
    OptionList.BackgroundColor3 = Config.Theme.PrimaryColor
    OptionList.Visible = false
    OptionList.BorderSizePixel = 0
    
    local function updateList()
        for i, option in ipairs(options) do
            local Button = Instance.new("TextButton", OptionList)
            Button.Size = UDim2.new(1, 0, 0, 25)
            Button.Position = UDim2.new(0, 0, 0, (i-1) * 25)
            Button.BackgroundColor3 = Config.Theme.PrimaryColor
            Button.Text = option
            Button.TextColor3 = Config.Theme.TextColor
            Button.Font = Config.Theme.Font
            Button.TextSize = 14
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
    end)
    
    updateList()
    _G.CensuraG.Logger:info("Dropdown created with " .. #options .. " options")
    return DropdownFrame
end
