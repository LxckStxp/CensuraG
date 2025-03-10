-- Elements/Switch.lua
local Switch = setmetatable({}, { __index = _G.CensuraG.UIElement })
Switch.__index = Switch

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager
local logger = _G.CensuraG.Logger

function Switch.new(parent, x, y, options)
    if not parent or not parent.Instance then return nil end
    options = options or {}
    local width = options.Width or Styling.ElementWidth
    local height = options.Height or 20
    local defaultState = options.defaultState or false
    local labelText = options.LabelText or "Switch"

    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, Styling.LabelWidth + width, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = parent.Instance.ZIndex + 1,
        Name = "Switch_" .. labelText
    })

    local label = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, Styling.LabelWidth, 0, 30),
        Text = labelText,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = frame.ZIndex + 1,
        Name = "Label"
    })
    Styling:Apply(label, "TextLabel")

    local track = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new(0, Styling.LabelWidth, 0, 5),
        Size = UDim2.new(0, 40, 0, height),
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
    Animation:HoverEffect(knob, { Size = UDim2.new(0, height + 4, 0, height + 4) })

    local labelValue = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, Styling.LabelWidth + 50, 0, 0),
        Size = UDim2.new(0, 40, 0, 30),
        Text = defaultState and "On" or "Off",
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = frame.ZIndex + 1,
        Name = "ValueLabel"
    })
    Styling:Apply(labelValue, "TextLabel")

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
        self.LabelValue.Text = self.State and "On" or "Off"
        if self.OnToggled then self.OnToggled(self.State) end
        EventManager:FireEvent("SwitchToggled", self, self.State)
        return self
    end

    track.MouseButton1Click:Connect(function() self:Toggle() end)
    knob.MouseButton1Click:Connect(function() self:Toggle() end)

    function self:Destroy()
        for _, conn in ipairs(self.Connections) do conn:Disconnect() end
        self.Connections = {}
        if self.Instance then self.Instance:Destroy() end
        logger:info("Switch destroyed: %s", self.Label.Text)
    end

    return self
end

return Switch
