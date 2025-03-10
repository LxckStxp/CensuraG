-- Switch.lua: Toggle switch with animated state changes
local Switch = setmetatable({}, {__index = _G.CensuraG.UIElement})
Switch.__index = Switch

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation

function Switch.new(parent, x, y, width, height, defaultState, options)
    defaultState = defaultState or false
    options = options or {}
    width = width or 40
    height = height or 20

    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width, 0, height),
        ClipsDescendants = true
    })
    Styling:Apply(frame, "Frame")

    local knob = Utilities.createInstance("Frame", {
        Parent = frame,
        Size = UDim2.new(0, height - 4, 0, height - 4),
        Position = defaultState and UDim2.new(1, -(height - 2), 0, 2) or UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = Color3.fromRGB(150, 150, 150),
        BorderSizePixel = 0
    })

    local label = options.ShowLabel and Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, -25),
        Size = UDim2.new(1, 0, 0, 20),
        Text = defaultState and "On" or "Off",
        BackgroundTransparency = 1,
        TextColor3 = Styling.Colors.Text,
        Font = Enum.Font.Code,
        TextSize = 12
    }) or nil

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
        local newColor = self.State and Styling.Colors.Highlight or Styling.Colors.Base
        Animation:Tween(self.Knob, {Position = newPos}, 0.2, function()
            self.Debounce = false
        end)
        Animation:Tween(self.Instance, {BackgroundColor3 = newColor})
        if self.Label then
            self.Label.Text = self.State and "On" or "Off"
        end
        if options.OnToggled then
            options.OnToggled(self.State)
        end
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not self.Debounce then
            toggleState()
        end
    end)

    frame.BackgroundColor3 = self.State and Styling.Colors.Highlight or Styling.Colors.Base

    function self:Destroy()
        self.Instance:Destroy()
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
