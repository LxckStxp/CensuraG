-- Elements/Dropdown.lua
-- Simplified dropdown using enhanced UIElement base

local Dropdown = {}
Dropdown.__index = Dropdown
setmetatable(Dropdown, { __index = _G.CensuraG.UIElement })

function Dropdown.new(options)
    options = options or {}
    
    -- Set default properties for Dropdown
    options.width = options.width or 200
    options.height = options.height or 30
    options.items = options.items or {}
    options.labelText = options.labelText or "Dropdown"
    options.selectedItem = options.selectedItem or (options.items[1] or "Select...")
    
    -- Create the base element
    local self = _G.CensuraG.UIElement.new(options.parent, options)
    
    -- Create label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0, 60, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = options.labelText
    label.BackgroundTransparency = 1
    label.ZIndex = self.Instance.ZIndex + 1
    label.Parent = self.Instance
    _G.CensuraG.Styling:Apply(label, "TextLabel")
    
    -- Create dropdown button
    local dropButton = Instance.new("TextButton")
    dropButton.Name = "DropButton"
    dropButton.Size = UDim2.new(0, options.width - 70, 0, options.height)
    dropButton.Position = UDim2.new(0, 65, 0, 0)
    dropButton.Text = options.selectedItem
    dropButton.ZIndex = self.Instance.ZIndex + 1
    dropButton.Parent = self.Instance
    _G.CensuraG.Styling:Apply(dropButton, "TextButton")
    
    -- Create dropdown icon
    local dropIcon = Instance.new("TextLabel")
    dropIcon.Name = "DropIcon"
    dropIcon.Size = UDim2.new(0, 20, 1, 0)
    dropIcon.Position = UDim2.new(1, -25, 0, 0)
    dropIcon.Text = "▼"
    dropIcon.BackgroundTransparency = 1
    dropIcon.ZIndex = dropButton.ZIndex + 1
    dropIcon.Parent = dropButton
    _G.CensuraG.Styling:Apply(dropIcon, "TextLabel")
    
    -- Create dropdown list
    local dropList = Instance.new("Frame")
    dropList.Name = "DropList"
    dropList.Size = UDim2.new(0, options.width - 70, 0, 0)
    dropList.Position = UDim2.new(0, 65, 0, options.height + 5)
    dropList.BackgroundTransparency = _G.CensuraG.Styling.Transparency.ElementBackground
    dropList.Visible = false
    dropList.ZIndex = self.Instance.ZIndex + 2
    dropList.Parent = self.Instance
    _G.CensuraG.Styling:Apply(dropList, "Frame")
    
    -- Set up properties
    self.Label = label
    self.Button = dropButton
    self.Icon = dropIcon
    self.List = dropList
    self.Items = options.items
    self.SelectedItem = options.selectedItem
    self.IsOpen = false
    self.Callback = options.onChange
    self.Width = options.width
    
    -- Add hover effect to button
    dropButton.MouseEnter:Connect(function()
        _G.CensuraG.Animation:Tween(dropButton, { 
            BackgroundTransparency = _G.CensuraG.Styling.Transparency.ElementBackground - 0.1 
        }, 0.1)
    end)
    
    dropButton.MouseLeave:Connect(function()
        _G.CensuraG.Animation:Tween(dropButton, { 
            BackgroundTransparency = _G.CensuraG.Styling.Transparency.ElementBackground 
        }, 0.1)
    end)
    
    -- Set up click handler
    dropButton.MouseButton1Click:Connect(function() 
        self:ToggleList() 
    end)
    
    -- Close list when clicking outside
    self:AddConnection(_G.CensuraG.EventManager:Connect(
        game:GetService("UserInputService").InputBegan, 
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and self.IsOpen then
                local pos = input.Position
                if not _G.CensuraG.Utilities.isPointInElement(self.Button, pos) and
                   not _G.CensuraG.Utilities.isPointInElement(self.List, pos) then
                    self:ToggleList(false)
                end
            end
        end
    ))
    
    -- Set metatable for this instance
    return setmetatable(self, Dropdown)
end

-- Populate the dropdown list
function Dropdown:PopulateList()
    -- Clear existing items
    for _, child in ipairs(self.List:GetChildren()) do
        if child:IsA("TextButton") then 
            child:Destroy() 
        end
    end
    
    -- Create new items
    for i, item in ipairs(self.Items) do
        local itemButton = Instance.new("TextButton")
        itemButton.Name = "Item_" .. i
        itemButton.Size = UDim2.new(1, 0, 0, 30)
        itemButton.Position = UDim2.new(0, 0, 0, (i-1) * 30)
        itemButton.Text = tostring(item)
        itemButton.ZIndex = self.List.ZIndex + 1
        itemButton.Parent = self.List
        _G.CensuraG.Styling:Apply(itemButton, "TextButton")
        
        -- Add hover effect
        itemButton.MouseEnter:Connect(function()
            _G.CensuraG.Animation:Tween(itemButton, { 
                BackgroundTransparency = _G.CensuraG.Styling.Transparency.ElementBackground - 0.1 
            }, 0.1)
        end)
        
        itemButton.MouseLeave:Connect(function()
            _G.CensuraG.Animation:Tween(itemButton, { 
                BackgroundTransparency = _G.CensuraG.Styling.Transparency.ElementBackground 
            }, 0.1)
        end)
        
        -- Add click handler
        itemButton.MouseButton1Click:Connect(function()
            self:SelectItem(item)
            self:ToggleList(false)
        end)
    end
end

-- Select an item
function Dropdown:SelectItem(item)
    self.SelectedItem = item
    self.Button.Text = tostring(item)
    
    if self.Callback then 
        _G.CensuraG.ErrorHandler:TryCatch(self.Callback, "Dropdown callback error", item)
    end
    
    _G.CensuraG.EventManager:FireEvent("DropdownSelected", self, item)
    return self
end

-- Toggle the dropdown list
function Dropdown:ToggleList(forceState)
    local newState = forceState ~= nil and forceState or not self.IsOpen
    self.IsOpen = newState
    
    if newState then
        self:PopulateList()
        self.List.Visible = true
        self.Icon.Text = "▲"
        _G.CensuraG.Animation:Tween(self.List, { 
            Size = UDim2.new(0, self.Width - 70, 0, #self.Items * 30) 
        }, 0.2)
        _G.CensuraG.EventManager:FireEvent("DropdownOpened", self)
    else
        self.Icon.Text = "▼"
        _G.CensuraG.Animation:Tween(self.List, { 
            Size = UDim2.new(0, self.Width - 70, 0, 0) 
        }, 0.2, nil, nil, function()
            self.List.Visible = false
        end)
        _G.CensuraG.EventManager:FireEvent("DropdownClosed", self)
    end
    
    return self
end

-- Set the items list
function Dropdown:SetItems(newItems)
    self.Items = newItems or {}
    
    if self.IsOpen then
        self:PopulateList()
        self.List.Size = UDim2.new(0, self.Width - 70, 0, #self.Items * 30)
    end
    
    return self
end

return Dropdown
