-- Elements/Dropdown.lua: Dropdown selection component
local Dropdown = setmetatable({}, {__index = _G.CensuraG.UIElement})
Dropdown.__index = Dropdown

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager
local UserInputService = game:GetService("UserInputService")
local logger = _G.CensuraG.Logger

-- Create a new dropdown
function Dropdown.new(parent, x, y, width, options, defaultSelection, callback)
    if not parent or not parent.Instance then
        logger:error("Invalid parent for Dropdown")
        return nil
    end
    
    options = options or {}
    width = width or 200
    
    local items = options.Items or {}
    local labelText = options.LabelText or "Dropdown"
    
    -- Create main frame
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width + 80, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = parent.Instance.ZIndex + 1,
        Name = "Dropdown_" .. labelText
    })
    
    -- Create label
    local label = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 60, 0, 20),
        Text = labelText,
        ZIndex = frame.ZIndex + 1,
        Name = "Label"
    })
    Styling:Apply(label, "TextLabel")
    
    -- Selected text (initial value)
    local selectedText = defaultSelection or (items[1] or "Select...")
    
    -- Create dropdown button
    local dropButton = Utilities.createInstance("TextButton", {
        Parent = frame,
        Position = UDim2.new(0, 65, 0, 0),
        Size = UDim2.new(0, width - 70, 0, 30),
        Text = selectedText,
        ZIndex = frame.ZIndex + 1,
        Name = "DropButton"
    })
    Styling:Apply(dropButton, "TextButton")
    Animation:HoverEffect(dropButton)
    
    -- Create dropdown icon
    local dropIcon = Utilities.createInstance("TextLabel", {
        Parent = dropButton,
        Position = UDim2.new(1, -25, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),
        Text = "▼",
        BackgroundTransparency = 1,
        ZIndex = dropButton.ZIndex + 1,
        Name = "DropIcon"
    })
    Styling:Apply(dropIcon, "TextLabel")
    
    -- Create dropdown list container (initially hidden)
    local dropList = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new(0, 65, 0, 35),
        Size = UDim2.new(0, width - 70, 0, 0), -- Start collapsed
        BackgroundTransparency = Styling.Transparency.ElementBackground,
        Visible = false,
        ZIndex = frame.ZIndex + 2,
        Name = "DropList"
    })
    Styling:Apply(dropList, "Frame")
    
    -- Create self object
    local self = setmetatable({
        Instance = frame,
        Label = label,
        Button = dropButton,
        Icon = dropIcon,
        List = dropList,
        Items = items,
        SelectedItem = selectedText,
        IsOpen = false,
        Callback = callback,
        Connections = {}
    }, Dropdown)
    
    -- Populate the dropdown list
    function self:PopulateList()
        -- Clear existing items
        for _, child in pairs(self.List:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        -- Add new items
        for i, item in ipairs(self.Items) do
            local itemButton = Utilities.createInstance("TextButton", {
                Parent = self.List,
                Position = UDim2.new(0, 0, 0, (i-1) * 30),
                Size = UDim2.new(1, 0, 0, 30),
                Text = tostring(item),
                ZIndex = self.List.ZIndex + 1,
                Name = "Item_" .. i
            })
            Styling:Apply(itemButton, "TextButton")
            Animation:HoverEffect(itemButton)
            
            -- Handle item selection
            itemButton.MouseButton1Click:Connect(function()
                self:SelectItem(item)
                self:ToggleList(false)
            end)
        end
    end
    
    -- Select an item
    function self:SelectItem(item)
        self.SelectedItem = item
        self.Button.Text = tostring(item)
        
        if self.Callback then
            self.Callback(item)
        end
        
        logger:debug("Dropdown selected: %s", tostring(item))
        EventManager:FireEvent("DropdownSelected", self, item)
    end
    
    -- Toggle the dropdown list
    function self:ToggleList(forceState)
        local newState = forceState ~= nil and forceState or not self.IsOpen
        self.IsOpen = newState
        
        if newState then
            -- Open the list
            self:PopulateList()
            self.List.Visible = true
            self.Icon.Text = "▲"
            
            -- Animate opening
            Animation:Tween(self.List, {
                Size = UDim2.new(0, width - 70, 0, #self.Items * 30)
            }, 0.2)
            
            -- Bring to front
            self.List.ZIndex = 100
            
            logger:debug("Dropdown opened: %s", self.Label.Text)
            EventManager:FireEvent("DropdownOpened", self)
        else
            -- Close the list
            self.Icon.Text = "▼"
            
            -- Animate closing
            Animation:Tween(self.List, {
                Size = UDim2.new(0, width - 70, 0, 0)
            }, 0.2, nil, nil, function()
                self.List.Visible = false
            end)
            
            logger:debug("Dropdown closed: %s", self.Label.Text)
            EventManager:FireEvent("DropdownClosed", self)
        end
    end
    
    -- Handle dropdown button click
    dropButton.MouseButton1Click:Connect(function()
        self:ToggleList()
    end)
    
    -- Close dropdown when clicking elsewhere
    table.insert(self.Connections, EventManager:Connect(
        UserInputService.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and self.IsOpen then
                local position = input.Position
                
                -- Check if click is outside dropdown
                if not Utilities.isPointInElement(self.Button, position) and 
                   not Utilities.isPointInElement(self.List, position) then
                    self:ToggleList(false)
                end
            end
        end
    ))
    
    -- Set items method
    function self:SetItems(newItems)
        self.Items = newItems or {}
        
        -- If dropdown is open, refresh the list
        if self.IsOpen then
            self:PopulateList()
            
            -- Update size
            self.List.Size = UDim2.new(0, width - 70, 0, #self.Items * 30)
        end
        
        logger:debug("Dropdown items updated: %s", self.Label.Text)
        return self
    end
    
    -- Clean up resources
    function self:Destroy()
        for _, conn in ipairs(self.Connections) do
            conn:Disconnect()
        end
        self.Connections = {}
        
        if self.Instance then
            self.Instance:Destroy()
        end
        
        logger:info("Dropdown destroyed: %s", self.Label.Text)
    end
    
    -- Example of how to use the dropdown
    if #items == 0 then
        logger:debug([[
Example usage:
local dropdown = CensuraG.Dropdown.new(window, 10, 50, 200, {
    LabelText = "Select",
    Items = {"Option 1", "Option 2", "Option 3"}
}, "Option 1", function(selected)
    print("Selected:", selected)
end)
]])
    end
    
    return self
end

return Dropdown
