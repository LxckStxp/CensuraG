-- Elements/Switch.lua: Toggle switch component
local Switch = setmetatable({}, {__index = _G.CensuraG.UIElement})
Switch.__index = Switch

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager
local logger = _G.CensuraG.Logger

-- Create a new switch
function Switch.new(parent, x, y, width, height, defaultState, options)
    if not parent or not parent.Instance then
        logger:error("Invalid parent for Switch")
        return nil
    end
    
    options = options or {}
    width = width or 40
    height = height or 20
    defaultState = defaultState or false
    
    -- Create main frame
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width + 80, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = parent.Instance.ZIndex + 1,
        Name = "Switch_" .. (options.LabelText or "Switch")
    })
    
    -- Create label
    local label = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 60, 0, 20),
        Text = options.LabelText or "Switch",
        ZIndex = frame.ZIndex + 1,
        Name = "Label"
    })
    Styling:Apply(label, "TextLabel")
    
    -- Create track (background)
    local track = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new(0, 65, 0, 5),
        Size = UDim2.new(0, width, 0, height),
        ZIndex = frame.ZIndex + 1,
        Name = "Track"
    })
    Styling:Apply(track, "Frame")
    
    -- Create knob (the moving part)
    local knob = Utilities.createInstance("Frame", {
        Parent = track,
        Size = UDim2.new(0, height, 0, height),
        Position = defaultState and UDim2.new(1, -height, 0, 0) or UDim2.new(0, 0, 0, 0),
        ZIndex = track.ZIndex + 1,
        Name = "Knob"
    })
    Styling:Apply(knob, "Frame")
    
    -- Create value label if requested
    local labelValue = nil
    if options.ShowLabel then
        labelValue = Utilities.createInstance("TextLabel", {
            Parent = frame,
            Position = UDim2.new(0, width + 70, 0, 0),
            Size = UDim2.new(0, 20, 0, 20),
            Text = defaultState and "On" or "Off",
            ZIndex = frame.ZIndex + 1,
            Name = "ValueLabel"
        })
        Styling:Apply(labelValue, "TextLabel")
    end
    
    -- Create self object
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
    
    -- Toggle state function
    function self:Toggle(newState)
        if self.Debounce then return self end
        self.Debounce = true
        
        -- If newState is provided, use it; otherwise toggle current state
        if newState ~= nil then
            self.State = newState
        else
            self.State = not self.State
        end
        
        -- Calculate new position
        local newPos = self.State and UDim2.new(1, -height, 0, 0) or UDim2.new(0, 0, 0, 0)
        
        -- Animate knob movement
        Animation:Tween(self.Knob, {Position = newPos}, 0.2, nil, nil, function()
            self.Debounce = false
        end)
        
        -- Update color based on state
        if self.State then
            Animation:Tween(self.Track, {BackgroundColor3 = Styling.Colors.Accent}, 0.2)
        else
            Animation:Tween(self.Track, {BackgroundColor3 = Styling.Colors.Secondary}, 0.2)
        end
        
        -- Update label value if present
        if self.LabelValue then
            self.LabelValue.Text = self.State and "On" or "Off"
        end
        
        -- Call callback if provided
        if self.OnToggled then
            local success, result = pcall(self.OnToggled, self.State)
            if not success then
                logger:warn("Switch callback error: %s", result)
            end
        end
        
        logger:debug("Switch toggled to %s: %s", tostring(self.State), self.Label.Text)
        EventManager:FireEvent("SwitchToggled", self, self.State)
        
        return self
    end
    
    -- Handle track click
    table.insert(self.Connections, EventManager:Connect(
        track.InputBegan,
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self:Toggle()
            end
        end
    ))
    
    -- Handle knob click
    table.insert(self.Connections, EventManager:Connect(
        knob.InputBegan,
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self:Toggle()
            end
        end
    ))
    
    -- Set initial track color based on state
    if self.State then
        self.Track.BackgroundColor3 = Styling.Colors.Accent
    end
    
    -- Get state method
    function self:GetState()
        return self.State
    end
    
    -- Set callback method
    function self:SetCallback(callback)
        self.OnToggled = callback
        logger:debug("Switch callback updated: %s", self.Label.Text)
        return self
    end
    
    -- Set label text method
    function self:SetLabel(text)
        if not text then return self end
        
        self.Label.Text = text
        logger:debug("Switch label updated: %s", text)
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
        
        logger:info("Switch destroyed: %s", self.Label.Text)
    end
    
    -- Example of how to use the switch
    if options.ShowExample then
        logger:debug([[
Example usage:
local switch = CensuraG.Switch.new(window, 10, 50, 40, 20, false, {
    LabelText = "Enable",
    ShowLabel = true,
    OnToggled = function(state)
        print("Switch state:", state)
    end
})
]])
    end
    
    return self
end

return Switch
