-- Elements/Dropdown.lua
-- Modern dropdown component

local Dropdown = setmetatable({}, { __index = _G.CensuraG.UIElement })
Dropdown.__index = Dropdown

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager
local UserInputService = game:GetService("UserInputService")
local logger = _G.CensuraG.Logger

function Dropdown.new(parent, x, y, width, options)
    if not parent or not parent.Instance then return nil end
    options = options or {}
    width = width or 200
    local items = options.Items or {}
    local labelText = options.LabelText or "Dropdown"
    
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width + 80, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = parent.Instance.ZIndex + 1,
        Name = "Dropdown_"..labelText
    })
    
    local label = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 60, 0, 30),
        Text = labelText,
        ZIndex = frame.ZIndex + 1,
        Name = "Label"
    })
    Styling:Apply(label, "TextLabel")
    
    local selectedText = options.defaultSelection or (items[1] or "Select...")
    local dropButton = Utilities.createInstance("TextButton", {
        Parent = frame,
        Position = UDim2.new(0, 65, 0, 0),
        Size = UDim2.new(0, width - 65, 0, 30),
        Text = selectedText,
        ZIndex = frame.ZIndex + 1,
        Name = "DropButton"
    })
    Styling:Apply(dropButton, "TextButton")
    Animation:HoverEffect(dropButton, { BackgroundTransparency = Styling.Transparency.ElementBackground - 0.2 })
    
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
    
    local dropList = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new(0, 65, 0, 35),
        Size = UDim2.new(0, width - 65, 0, 0),
        BackgroundTransparency = Styling.Transparency.ElementBackground,
        Visible = false,
        ZIndex = frame.ZIndex + 2,
        Name = "DropList"
    })
    Styling:Apply(dropList, "Frame")
    
    local self = setmetatable({
        Instance = frame,
        Label = label,
        Button = dropButton,
        Icon = dropIcon,
        List = dropList,
        Items = items,
        SelectedItem = selectedText,
        IsOpen = false,
        Callback = options.Callback,
        Connections = {}
    }, Dropdown)
    
    function self:PopulateList()
        for _, child in ipairs(self.List:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for i, item in ipairs(self.Items) do
            local itemButton = Utilities.createInstance("TextButton", {
                Parent = self.List,
                Position = UDim2.new(0, 0, 0, (i-1) * 30),
                Size = UDim2.new(1, 0, 0, 30),
                Text = tostring(item),
                ZIndex = self.List.ZIndex + 1,
                Name = "Item_"..i
            })
            Styling:Apply(itemButton, "TextButton")
            Animation:HoverEffect(itemButton, { BackgroundTransparency = Styling.Transparency.ElementBackground - 0.2 })
            itemButton.MouseButton1Click:Connect(function()
                self:SelectItem(item)
                self:ToggleList(false)
            end)
        end
    end
    
    function self:SelectItem(item)
        self.SelectedItem = item
        self.Button.Text = tostring(item)
        if self.Callback then self.Callback(item) end
        EventManager:FireEvent("DropdownSelected", self, item)
    end
    
    function self:ToggleList(forceState)
        local newState = forceState ~= nil and forceState or not self.IsOpen
        self.IsOpen = newState
        if newState then
            self:PopulateList()
            self.List.Visible = true
            self.Icon.Text = "▲"
            Animation:Tween(self.List, { Size = UDim2.new(0, width - 65, 0, #self.Items * 30) }, 0.2 / _G.CensuraG.Config.AnimationSpeed)
        else
            self.Icon.Text = "▼"
            Animation:Tween(self.List, { Size = UDim2.new(0, width - 65, 0, 0) }, 0.2 / _G.CensuraG.Config.AnimationSpeed, nil, nil, function()
                self.List.Visible = false
            end)
        end
    end
    
    dropButton.MouseButton1Click:Connect(function() self:ToggleList() end)
    table.insert(self.Connections, EventManager:Connect(UserInputService.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and self.IsOpen then
            local pos = input.Position
            if not Utilities.isPointInElement(self.Button, pos) and not Utilities.isPointInElement(self.List, pos) then
                self:ToggleList(false)
            end
        end
    end))
    
    function self:Destroy()
        for _, conn in ipairs(self.Connections) do conn:Disconnect() end
        self.Connections = {}
        if self.Instance then self.Instance:Destroy() end
        logger:info("Dropdown destroyed: %s", self.Label.Text)
    end
    
    return self
end

return Dropdown
