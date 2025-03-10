-- Switch.lua: Toggle switch with miltech styling
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

    if not parent or not parent.Instance then
        logger:error("Invalid parent for switch: %s", tostring(parent))
        return nil
    end

    logger:debug("Creating switch with parent: %s, Position: (%d, %d)", tostring(parent.Instance), x, y)

    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width, 0, height),
        BackgroundTransparency = 0.5,
        ClipsDescendants = true,
        Visible = true,
        ZIndex = 3
    })
    Styling:Apply(frame, "Frame")
    logger:debug("Switch frame created: Position: %s, Size: %s, ZIndex: %d, Visible: %s, Parent: %s", tostring(frame.Position), tostring(frame.Size), frame.ZIndex, tostring(frame.Visible), tostring(frame.Parent))

    -- Add a thin white border
    local frameStroke = Utilities.createInstance("UIStroke", {
        Parent = frame,
        Thickness = 1,
        Color = Color3.fromRGB(200, 200, 200),
        Transparency = 0.5
    })

    local knob = Utilities.createInstance("Frame", {
        Parent = frame,
        Size = UDim2.new(0, height - 4, 0, height - 4),
        Position = defaultState and UDim2.new(1, -(height - 2), 0, 2) or UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = Color3.fromRGB(150, 150, 150),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Visible = true,
        ZIndex = 4
    })
    logger:debug("Switch knob created: Position: %s, Size: %s, ZIndex: %d, Visible: %s", tostring(knob.Position), tostring(knob.Size), knob.ZIndex, tostring(knob.Visible))

    local label = options.ShowLabel and Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, -25),
        Size = UDim2.new(1, 0, 0, 20),
        Text = defaultState and "On" or "Off",
        BackgroundTransparency = 1,
        TextColor3 = Styling.Colors.Text,
        Font = Enum.Font.Code,
        TextSize = 12,
        Visible = true,
        ZIndex = 4
    }) or nil
    if label then
        logger:debug("Switch label created: Position: %s, Size: %s, ZIndex: %d, Visible: %s, Text: %s", tostring(label.Position), tostring(label.Size), label.ZIndex, tostring(label.Visible), label.Text)
    end

    local self = setmetatable({
        Instance = frame,
        Knob = knob,
        Label = label,
        State = defaultState,
        Debounce = false
    }, Switch)

    local function toggleState()
        if self.Debounce then return end
        self.Debounce = true
        self.State = not self.State
        local newPos = self.State and UDim2.new(1, -(height - 2), 0, 2) or UDim2.new(0, 2, 0, 2)
        local newTransparency = self.State and 0.3 or 0.5
        Animation:Tween(self.Knob, {Position = newPos}, 0.2, function()
            self.Debounce = false
        end)
        Animation:Tween(self.Instance, {BackgroundTransparency = newTransparency})
        if self.Label then
            self.Label.Text = self.State and "On" or "Off"
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

    frame.BackgroundTransparency = self.State and 0.3 or 0.5

    function self:Destroy()
        self.Instance:Destroy()
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
