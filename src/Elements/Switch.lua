-- Switch.lua: Toggle switch with modern miltech styling, proper knob height, and label
local Switch = setmetatable({}, {__index = _G.CensuraG.UIElement})
Switch.__index = Switch

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local logger = _G.CensuraG.Logger

function Switch.new(parent, x, y, width, height, defaultState, options)
    defaultState = defaultState or false
    options = options or {}
    width = width or 40
    height = height or 20
    local labelText = options.LabelText or "Switch" -- Default label text

    if not parent or not parent.Instance then
        logger:error("Invalid parent for switch: %s", tostring(parent))
        return nil
    end

    logger:debug("Creating switch with parent: %s, Position: (%d, %d), Label: %s", tostring(parent.Instance), x, y, labelText)

    -- Create the label
    local label = Utilities.createInstance("TextLabel", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x - 60, 0, y), -- 60 pixels to the left of the switch
        Size = UDim2.new(0, 50, 0, height),   -- Width of 50 pixels, same height as switch
        Text = labelText,
        BackgroundTransparency = 1,
        ZIndex = 3
    })
    Styling:Apply(label, "TextLabel")
    logger:debug("Switch label created: Position: %s, Size: %s, Text: %s", tostring(label.Position), tostring(label.Size), label.Text)

    -- Create the switch frame (track)
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width, 0, height),
        BackgroundTransparency = Styling.Transparency.Background,
        ClipsDescendants = true,
        Visible = true,
        ZIndex = 3
    })
    Styling:Apply(frame, "Frame")
    logger:debug("Switch frame created: Position: %s, Size: %s, ZIndex: %d", tostring(frame.Position), tostring(frame.Size), frame.ZIndex)

    -- Create the knob with full track height
    local knobSize = height -- Match the track height
    local knob = Utilities.createInstance("Frame", {
        Parent = frame,
        Size = UDim2.new(0, knobSize, 0, height), -- Full height of the track
        Position = defaultState and UDim2.new(1, -knobSize, 0, 0) or UDim2.new(0, 0, 0, 0), -- Align with track top
        BackgroundTransparency = Styling.Transparency.Highlight,
        ZIndex = 4
    })
    Styling:Apply(knob, "Frame")
    logger:debug("Switch knob created: Position: %s, Size: %s, ZIndex: %d", tostring(knob.Position), tostring(knob.Size), knob.ZIndex)

    -- Add a value label if enabled
    local labelValue = options.ShowLabel and Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(1, 5, 0, 0), -- To the right of the switch
        Size = UDim2.new(0, 40, 0, height),
        Text = defaultState and "On" or "Off",
        BackgroundTransparency = 1,
        ZIndex = 4
    }) or nil
    if labelValue then
        Styling:Apply(labelValue, "TextLabel")
        logger:debug("Switch value label created: Position: %s, Size: %s, Text: %s", tostring(labelValue.Position), tostring(labelValue.Size), labelValue.Text)
    end

    local self = setmetatable({
        Instance = frame,
        Knob = knob,
        Label = label,           -- Reference to the context label
        LabelValue = labelValue, -- Reference to the value label
        State = defaultState,
        Debounce = false
    }, Switch)

    local function toggleState()
        if self.Debounce then return end
        self.Debounce = true
        self.State = not self.State
        local newPos = self.State and UDim2.new(1, -knobSize, 0, 0) or UDim2.new(0, 0, 0, 0)
        local newTransparency = self.State and Styling.Transparency.Background - 0.1 or Styling.Transparency.Background
        Animation:Tween(self.Knob, {Position = newPos}, 0.2, function()
            self.Debounce = false
        end)
        Animation:Tween(self.Instance, {BackgroundTransparency = newTransparency})
        if self.LabelValue then
            self.LabelValue.Text = self.State and "On" or "Off"
        end
        if options.OnToggled then
            options.OnToggled(self.State)
        end
        logger:debug("Switch toggled: State: %s, Knob Position: %s", tostring(self.State), tostring(self.Knob.Position))
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not self.Debounce then
            toggleState()
        end
    end)

    frame.BackgroundTransparency = self.State and Styling.Transparency.Background - 0.1 or Styling.Transparency.Background

    function self:Destroy()
        self.Instance:Destroy()
        if self.Label then self.Label:Destroy() end
        if self.LabelValue then self.LabelValue:Destroy() end
        logger:info("Switch destroyed")
    end

    function self:SetState(state)
        if self.State ~= state and not self.Debounce then
            self.State = state
            toggleState()
        end
    end

    return self
end

return Switch
