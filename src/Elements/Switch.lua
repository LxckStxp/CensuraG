-- Elements/Switch.lua: Toggle switch with modern miltech styling, proper knob height, and label
local Switch = setmetatable({}, {__index = _G.CensuraG.UIElement})
Switch.__index = Switch

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local logger = _G.CensuraG.Logger

function Switch.new(parent, x, y, width, height, defaultState, options)
    if not parent or not parent.Instance or not parent.Instance:IsA("GuiObject") then
        logger:error("Invalid parent for switch: %s", tostring(parent))
        return nil
    end

    defaultState = defaultState or false
    options = options or {}
    width = width or 40
    height = height or 20
    local labelText = options.LabelText or "Switch"

    logger:debug("Creating switch with parent: %s, Position: (%d, %d), Label: %s", tostring(parent.Instance), x, y, labelText)

    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width + 40, 0, 40),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = parent.Instance.ZIndex + 1
    })
    logger:debug("Switch frame created: Position: %s, Size: %s, ZIndex: %d", tostring(frame.Position), tostring(frame.Size), frame.ZIndex)

    local label = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, width, 0, 20),
        Text = labelText,
        BackgroundTransparency = 1,
        ZIndex = frame.ZIndex + 1
    })
    Styling:Apply(label, "TextLabel")
    logger:debug("Switch label created: Position: %s, Size: %s, Text: %s", tostring(label.Position), tostring(label.Size), label.Text)

    local track = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(0, width, 0, height),
        BackgroundTransparency = Styling.Transparency.ElementBackground,
        ClipsDescendants = true,
        ZIndex = frame.ZIndex + 1
    })
    Styling:Apply(track, "Frame")
    logger:debug("Switch track created: Position: %s, Size: %s, ZIndex: %d", tostring(track.Position), tostring(track.Size), track.ZIndex)

    local knobSize = height
    local knob = Utilities.createInstance("Frame", {
        Parent = track,
        Size = UDim2.new(0, knobSize, 0, height),
        Position = defaultState and UDim2.new(1, -knobSize, 0, 0) or UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = Styling.Transparency.ElementBackground,
        ZIndex = track.ZIndex + 1
    })
    Styling:Apply(knob, "Frame")
    logger:debug("Switch knob created: Position: %s, Size: %s, ZIndex: %d", tostring(knob.Position), tostring(knob.Size), knob.ZIndex)

    local labelValue = options.ShowLabel and Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, width + 5, 0, 20),
        Size = UDim2.new(0, 40, 0, height),
        Text = defaultState and "On" or "Off",
        BackgroundTransparency = 1,
        ZIndex = frame.ZIndex + 1
    }) or nil
    if labelValue then
        Styling:Apply(labelValue, "TextLabel")
        logger:debug("Switch value label created: Position: %s, Size: %s, Text: %s", tostring(labelValue.Position), tostring(labelValue.Size), labelValue.Text)
    end

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
        local newPos = self.State and UDim2.new(1, -knobSize, 0, 0) or UDim2.new(0, 0, 0, 0)
        local newTransparency = self.State and Styling.Transparency.ElementBackground - 0.1 or Styling.Transparency.ElementBackground
        Animation:Tween(self.Knob, {Position = newPos}, 0.2, function()
            self.Debounce = false
        end)
        Animation:Tween(track, {BackgroundTransparency = newTransparency})
        if self.LabelValue then
            self.LabelValue.Text = self.State and "On" or "Off"
        end
        if options.OnToggled then
            options.OnToggled(self.State)
        end
        logger:debug("Switch toggled: State: %s, Knob Position: %s", tostring(self.State), tostring(self.Knob.Position))
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not self.Debounce then
            toggleState()
        end
    end)

    track.BackgroundTransparency = self.State and Styling.Transparency.ElementBackground - 0.1 or Styling.Transparency.ElementBackground

    function self:Destroy()
        if self.Instance then self.Instance:Destroy() end
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
