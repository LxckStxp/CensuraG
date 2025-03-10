-- Elements/Slider.lua: Value slider component
local Slider = setmetatable({}, {__index = _G.CensuraG.UIElement})
Slider.__index = Slider

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager
local UserInputService = game:GetService("UserInputService")
local logger = _G.CensuraG.Logger

-- Create a new slider
function Slider.new(parent, x, y, width, min, max, default, options)
    if not parent or not parent.Instance then
        logger:error("Invalid parent for Slider")
        return nil
    end
    
    options = options or {}
    min = min or 0
    max = max or 100
    default = math.clamp(default or min, min, max)
    width = width or 200
    
    -- Create main frame
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width + 80, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = parent.Instance.ZIndex + 1,
        Name = "Slider_" .. (options.LabelText or "Slider")
    })
    
    -- Create label
    local label = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 60, 0, 20),
        Text = options.LabelText or "Slider",
        ZIndex = frame.ZIndex + 1,
        Name = "Label"
    })
    Styling:Apply(label, "TextLabel")
    
    -- Create track (background)
    local track = Utilities.createInstance("Frame", {
        Parent = frame,
        Position = UDim2.new(0, 65, 0, 5),
        Size = UDim2.new(0, width - 70, 0, 20),
        ZIndex = frame.ZIndex + 1,
        Name = "Track"
    })
    Styling:Apply(track, "Frame")
    
    -- Create fill (colored portion)
    local fill = Utilities.createInstance("Frame", {
        Parent = track,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Styling.Colors.Accent,
        ZIndex = track.ZIndex + 1,
        Name = "Fill"
    })
    Styling:Apply(fill, "Frame")
    
    -- Create knob (draggable handle)
    local knob = Utilities.createInstance("Frame", {
        Parent = track,
        Position = UDim2.new((default - min) / (max - min), -10, 0, 0),
        Size = UDim2.new(0, 20, 0, 20),
        ZIndex = track.ZIndex + 2,
        Name = "Knob"
    })
    Styling:Apply(knob, "Frame")
    
    -- Create value label if requested
    local labelValue = nil
    if options.ShowValue then
        labelValue = Utilities.createInstance("TextLabel", {
            Parent = frame,
            Position = UDim2.new(0, width + 5, 0, 0),
            Size = UDim2.new(0, 40, 0, 20),
            Text = tostring(default),
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
        Fill = fill,
        Knob = knob,
        LabelValue = labelValue,
        Value = default,
        Min = min,
        Max = max,
        Step = options.Step or 1,
        OnChanged = options.OnChanged,
        IsDragging = false,
        Connections = {}
    }, Slider)
    
    -- Update value function
    function self:UpdateValue(newValue, animate)
        -- Clamp and step the value
        newValue = math.clamp(math.floor((newValue / self.Step) + 0.5) * self.Step, self.Min, self.Max)
        
        if newValue == self.Value then return self end
        self.Value = newValue
        
        -- Calculate ratio for positioning
        local ratio = (newValue - self.Min) / (self.Max - self.Min)
        
        -- Update fill and knob positions
        local fillProps = {Size = UDim2.new(ratio, 0, 1, 0)}
        local knobPos = UDim2.new(ratio, -10, 0, 0)
        
        if animate then
            Animation:Tween(self.Fill, fillProps, 0.2)
            Animation:Tween(self.Knob, {Position = knobPos}, 0.2)
        else
            self.Fill.Size = fillProps.Size
            self.Knob.Position = knobPos
        end
        
        -- Update value label if present
        if self.LabelValue then
            self.LabelValue.Text = tostring(newValue)
        end
        
        -- Call callback if provided
        if self.OnChanged then
            local success, result = pcall(self.OnChanged, newValue)
            if not success then
                logger:warn("Slider callback error: %s", result)
            end
        end
        
        logger:debug("Slider value updated to %d: %s", newValue, self.Label.Text)
        EventManager:FireEvent("SliderChanged", self, newValue)
        
        return self
    end
    
    -- Handle knob dragging
    table.insert(self.Connections, EventManager:Connect(
        knob.InputBegan,
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.IsDragging = true
            end
        end
    ))
    
    -- Handle track clicking (jump to position)
    table.insert(self.Connections, EventManager:Connect(
        track.InputBegan,
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                -- Calculate ratio based on click position
                local ratio = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local newValue = self.Min + (self.Max - self.Min) * ratio
                
                -- Update with animation
                self:UpdateValue(newValue, true)
            end
        end
    ))
    
    -- Handle input ended (stop dragging)
    table.insert(self.Connections, EventManager:Connect(
        UserInputService.InputEnded,
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.IsDragging = false
            end
        end
    ))
    
    -- Handle mouse movement for dragging
    table.insert(self.Connections, EventManager:Connect(
        UserInputService.InputChanged,
        function(input)
            if self.IsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                -- Calculate ratio based on mouse position
                local ratio = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local newValue = self.Min + (self.Max - self.Min) * ratio
                
                -- Update without animation during drag
                self:UpdateValue(newValue, false)
            end
        end
    ))
    
    -- Get value method
    function self:GetValue()
        return self.Value
    end
    
    -- Set callback method
    function self:SetCallback(callback)
        self.OnChanged = callback
        logger:debug("Slider callback updated: %s", self.Label.Text)
        return self
    end
    
    -- Set range method
    function self:SetRange(newMin, newMax)
        if newMin >= newMax then
            logger:warn("Invalid range for slider: min must be less than max")
            return self
        end
        
        self.Min = newMin
        self.Max = newMax
        
        -- Clamp current value to new range
        local newValue = math.clamp(self.Value, newMin, newMax)
        self:UpdateValue(newValue, true)
        
        logger:debug("Slider range updated to %d-%d: %s", newMin, newMax, self.Label.Text)
        return self
    end
    
    -- Set step method
    function self:SetStep(newStep)
        if newStep <= 0 then
            logger:warn("Invalid step for slider: step must be positive")
            return self
        end
        
        self.Step = newStep
        
        -- Adjust current value to match step
        local newValue = math.floor((self.Value / newStep) + 0.5) * newStep
        self:UpdateValue(newValue, true)
        
        logger:debug("Slider step updated to %d: %s", newStep, self.Label.Text)
        return self
    end
    
    -- Set label text method
    function self:SetLabel(text)
        if not text then return self end
        
        self.Label.Text = text
        logger:debug("Slider label updated: %s", text)
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
        
        logger:info("Slider destroyed: %s", self.Label.Text)
    end
    
    -- Example of how to use the slider
    if options.ShowExample then
        logger:debug([[
Example usage:
local slider = CensuraG.Slider.new(window, 10, 50, 200, 0, 100, 50, {
    LabelText = "Volume",
    ShowValue = true,
    Step = 5,
    OnChanged = function(value)
        print("Slider value:", value)
    end
})
]])
    end
    
    return self
end

return Slider
