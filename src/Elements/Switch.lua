-- Switch.lua: Toggle switch with animated state changes
local Switch = setmetatable({}, {__index = _G.CensuraG.UIElement})
Switch.__index = Switch

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation

function Switch.new(parent, x, y, width, height, defaultState, options)
    -- Validate inputs
    defaultState = defaultState or false
    options = options or {}
    width = width or 40
    height = height or 20

    -- Create switch frame
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width, 0, height),
        ClipsDescendants = true
    })
    Styling:Apply(frame, "Frame")

    -- Knob (the moving part of the switch)
    local knob = Utilities.createInstance("Frame", {
        Parent = frame,
        Size = UDim2.new(0, height - 4, 0, height - 4),
        Position = defaultState and UDim2.new(1, -(height - 2), 0, 2) or UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = Color3.fromRGB(200, 200, 200), -- Light gray for visibility
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(80, 80, 80)
    })

    -- Optional label
    local label = options.ShowLabel and Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, -25),
        Size = UDim2.new(1, 0, 0, 20),
        Text = defaultState and "On" or "Off",
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.Code,
        TextSize = 12
    }) or nil

    local self = setmetatable({
        Instance = frame,
        Knob = knob,
        Label = label,
        State = defaultState
    }, Switch)

    -- Toggle state
    local function toggleState()
        self.State = not self.State
        local newPos = self.State and UDim2.new(1, -(height - 2), 0, 2) or UDim2.new(0, 2, 0, 2)
        local newColor = self.State and Color3.fromRGB(0, 120, 215) or Styling.Colors.Base
        Animation:Tween(self.Knob, {Position = newPos})
        Animation:Tween(self.Instance, {BackgroundColor3 = newColor})
        if self.Label then
            self.Label.Text = self.State and "On" or "Off"
        end
        if options.OnToggled then
            options.OnToggled(self.State)
        end
    end

    -- Click to toggle
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggleState()
        end
    end)

    -- Initial styling
    frame.BackgroundColor3 = self.State and Color3.fromRGB(0, 120, 215) or Styling.Colors.Base

    -- Cleanup method
    function self:Destroy()
        self.Instance:Destroy()
    end

    return self
end

-- Public method to set state programmatically
function Switch:SetState(state)
    if self.State ~= state then
        self.State = state
        toggleState()
    end
end

return Switch
