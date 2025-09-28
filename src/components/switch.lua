-- CensuraG/src/components/switch.lua (fixed version)
local Config = _G.CensuraG.Config

return function(parent, title, default, callback)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    
    -- Constants from CensuraDev
    local TRACK_SIZE = UDim2.new(0, 24, 0, 16)
    local KNOB_SIZE = UDim2.new(0, 12, 0, 12)
    local KNOB_POSITIONS = {
        OFF = UDim2.new(0, 2, 0.5, -6),
        ON = UDim2.new(1, -14, 0.5, -6)
    }
    
    -- Container
    local SwitchFrame = Instance.new("Frame", parent)
    SwitchFrame.Name = "SwitchContainer"
    SwitchFrame.Size = UDim2.new(1, -12, 0, 32)
    SwitchFrame.BackgroundColor3 = theme.SecondaryColor
    SwitchFrame.BackgroundTransparency = 0.8
    SwitchFrame.BorderSizePixel = 0
    
    -- Add corner radius
    local Corner = Instance.new("UICorner", SwitchFrame)
    Corner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)
    
    -- Add stroke
    local Stroke = Instance.new("UIStroke", SwitchFrame)
    Stroke.Color = theme.AccentColor
    Stroke.Transparency = 0.6
    Stroke.Thickness = Config.Math.BorderThickness
    
    -- Title
    local TitleLabel = Instance.new("TextLabel", SwitchFrame)
    TitleLabel.Size = UDim2.new(1, -44, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "Toggle"
    TitleLabel.TextColor3 = theme.TextColor
    TitleLabel.Font = theme.Font
    TitleLabel.TextSize = theme.TextSize
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Track
    local Track = Instance.new("Frame", SwitchFrame)
    Track.Size = TRACK_SIZE
    Track.Position = UDim2.new(1, -34, 0.5, -8)
    Track.BackgroundColor3 = default and theme.EnabledColor or theme.PrimaryColor
    Track.BackgroundTransparency = 0.5
    
    local TrackCorner = Instance.new("UICorner", Track)
    TrackCorner.CornerRadius = UDim.new(1, 0)
    
    -- Knob
    local Knob = Instance.new("Frame", Track)
    Knob.Size = KNOB_SIZE
    Knob.Position = default and KNOB_POSITIONS.ON or KNOB_POSITIONS.OFF
    Knob.BackgroundColor3 = theme.TextColor
    
    local KnobCorner = Instance.new("UICorner", Knob)
    KnobCorner.CornerRadius = UDim.new(1, 0)
    
    local KnobStroke = Instance.new("UIStroke", Knob)
    KnobStroke.Color = theme.AccentColor
    KnobStroke.Transparency = 0.8
    KnobStroke.Thickness = 0.5
    
    -- State management
    local state = {
        enabled = default or false,
        hovering = false
    }
    
    -- Input handling
    local function handleClick()
        -- Click feedback - create a new UDim2 for the smaller size instead of multiplying
        _G.CensuraG.AnimationManager:Tween(Knob, {Size = UDim2.new(0, 10, 0, 10)}, 0.1)
        
        task.delay(0.1, function()
            state.enabled = not state.enabled
            
            -- Animate knob position
            _G.CensuraG.AnimationManager:Tween(Knob, {
                Position = state.enabled and KNOB_POSITIONS.ON or KNOB_POSITIONS.OFF,
                Size = KNOB_SIZE
            }, 0.2)
            
            -- Animate track color
            _G.CensuraG.AnimationManager:Tween(Track, {
                BackgroundColor3 = state.enabled and theme.EnabledColor or theme.PrimaryColor
            }, 0.2)
            
            if callback then callback(state.enabled) end
        end)
    end
    
    -- Connect events
    SwitchFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            handleClick()
        end
    end)
    
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            handleClick()
        end
    end)
    
    -- Hover effects
    SwitchFrame.MouseEnter:Connect(function()
        state.hovering = true
        _G.CensuraG.AnimationManager:Tween(Stroke, {Transparency = 0.2}, 0.2)
        _G.CensuraG.AnimationManager:Tween(Track, {BackgroundTransparency = 0.3}, 0.2)
    end)
    
    SwitchFrame.MouseLeave:Connect(function()
        state.hovering = false
        _G.CensuraG.AnimationManager:Tween(Stroke, {Transparency = 0.6}, 0.2)
        _G.CensuraG.AnimationManager:Tween(Track, {BackgroundTransparency = 0.5}, 0.2)
    end)
    
    local Switch = {
        Instance = SwitchFrame,
        Track = Track,
        Knob = Knob,
        TitleLabel = TitleLabel,
        State = state.enabled,
        Stroke = Stroke,
        SetState = function(self, newState, skipCallback)
            state.enabled = newState
            
            -- Update visuals
            _G.CensuraG.AnimationManager:Tween(self.Knob, {
                Position = state.enabled and KNOB_POSITIONS.ON or KNOB_POSITIONS.OFF
            }, 0.2)
            
            _G.CensuraG.AnimationManager:Tween(self.Track, {
                BackgroundColor3 = state.enabled and theme.EnabledColor or theme.PrimaryColor
            }, 0.2)
            
            self.State = state.enabled
            
            if not skipCallback and callback then
                callback(state.enabled)
            end
        end,
        GetState = function(self)
            return self.State
        end,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("switch", self)
        end
    }
    
    _G.CensuraG.Logger:info("Switch created with default state: " .. tostring(default))
    return Switch, state.enabled
end
