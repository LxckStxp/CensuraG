-- Elements/Switch.lua
-- Modern toggle switch

local Switch = setmetatable({}, { __index = _G.CensuraG.UIElement })
Switch.__index = Switch

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager
local logger = _G.CensuraG.Logger

function Switch.new(parent, x, y, width, height, defaultState, options)
    if not parent or not parent.Instance then return nil end
    options = options or {}
    width = width or 40
    height = height or 20
    defaultState = defaultState or false
    
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width + 80, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = parent.Instance.ZIndex + 1,
        Name = "Switch_" .. (options.LabelText or "Switch")
    })
    
    local label = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 60, 0, 30),
        Text = options.LabelText or "Switch",
        ZIndex = frame.ZIndex + 1,
        Name = "Label"
    })
    Styling:Apply(label, "TextLabel")
    
    local track = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new(0, 65, 0, 5),
        Size = UDim2.new(0, width, 0, height),
        BackgroundColor3 = defaultState and Styling.Colors.Accent or Styling.Colors.Secondary,
        ZIndex = frame.ZIndex + 1,
        Name = "Track"
    })
    Styling:Apply(track, "Frame")
    
    local knob = Utilities.createInstance("Frame", {
        Parent = track,
        Size = UDim2.new(0, height, 0, height),
        Position = defaultState and UDim2.new(1, -height, 0, 0) or UDim2.new(0, 0, 0, 0),
        ZIndex = track.ZIndex + 1,
        Name = "Knob"
    })
    Styling:Apply(knob, "Frame")
    Animation:HoverEffect(knob, { Size = UDim2.new(0, height + 4, 0, height + 4) }, { Size = UDim2.new(0, height, 0, height) })
    
    local labelValue = options.ShowLabel and Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, width + 70, 0, 0),
        Size = UDim2.new(0, 20, 0, 30),
        Text = defaultState and "On" or "Off",
        ZIndex = frame.ZIndex + 1,
        Name = "ValueLabel"
    })
    if labelValue then Styling:Apply(labelValue, "TextLabel") end
    
    local self = setmetatable({
        Instance = frame,
        Label = label,
        Track = track,
        Knob = knob,
        LabelValue = labelValue,
        State = defaultState,
        Debounce = false,
        OnToggled = options.OnToggled,
        Connections = {}
    }, Switch)
    
    function self:Toggle(newState)
        if self.Debounce then return self end
        self.Debounce = true
        self.State = newState ~= nil and newState or not self.State
        local newPos = self.State and UDim2.new(1, -height, 0, 0) or UDim2.new(0, 0, 0, 0)
        Animation:Tween(self.Knob, { Position = newPos }, 0.2 / _G.CensuraG.Config.AnimationSpeed, nil, nil, function() self.Debounce = false end)
        Animation:Tween(self.Track, { BackgroundColor3 = self.State and Styling.Colors.Accent or Styling.Colors.Secondary }, 0.2 / _G.CensuraG.Config.AnimationSpeed)
        if self.LabelValue then self.LabelValue.Text = self.State and "On" or "Off" end
        if self.OnToggled then self.OnToggled(self.State) end
        EventManager:FireEvent("SwitchToggled", self, self.State)
        return self
    end
    
    table.insert(self.Connections, EventManager:Connect(track.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then self:Toggle() end
    end))
    table.insert(self.Connections, EventManager:Connect(knob.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then self:Toggle() end
    end))
    
    function self:Destroy()
        for _, conn in ipairs(self.Connections) do conn:Disconnect() end
        self.Connections = {}
        if self.Instance then self.Instance:Destroy() end
        logger:info("Switch destroyed: %s", self.Label.Text)
    end
    
    return self
end

return Switch
