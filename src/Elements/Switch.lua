-- Elements/Switch.lua: Styled toggle switch
local Switch = setmetatable({}, {__index = _G.CensuraG.UIElement})
Switch.__index = Switch

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
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
        ZIndex = parent.Instance.ZIndex + 1
    })

    local label = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 60, 0, 20),
        Text = options.LabelText or "Switch",
        ZIndex = frame.ZIndex + 1
    })
    Styling:Apply(label, "TextLabel")

    local track = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new(0, 65, 0, 5),
        Size = UDim2.new(0, width, 0, height),
        ZIndex = frame.ZIndex + 1
    })
    Styling:Apply(track, "Frame")

    local knob = Utilities.createInstance("Frame", {
        Parent = track,
        Size = UDim2.new(0, height, 0, height),
        Position = defaultState and UDim2.new(1, -height, 0, 0) or UDim2.new(0, 0, 0, 0),
        ZIndex = track.ZIndex + 1
    })
    Styling:Apply(knob, "Frame")

    local labelValue = options.ShowLabel and Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, width + 70, 0, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Text = defaultState and "On" or "Off",
        ZIndex = frame.ZIndex + 1
    }) or nil
    if labelValue then Styling:Apply(labelValue, "TextLabel") end

    local self = setmetatable({
        Instance = frame,
        Knob = knob,
        Label = label,
        LabelValue = labelValue,
        State = defaultState,
        Debounce = false
    }, Switch)

    local function toggleState()
        if self.Debounce then return end
        self.Debounce = true
        self.State = not self.State
        local newPos = self.State and UDim2.new(1, -height, 0, 0) or UDim2.new(0, 0, 0, 0)
        Animation:Tween(self.Knob, {Position = newPos}, 0.2, nil, nil, function()
            self.Debounce = false
        end)
        if self.LabelValue then self.LabelValue.Text = self.State and "On" or "Off" end
        if options.OnToggled then options.OnToggled(self.State) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggleState()
        end
    end)

    function self:Destroy()
        self.Instance:Destroy()
        logger:info("Switch destroyed")
    end

    return self
end

return Switch
