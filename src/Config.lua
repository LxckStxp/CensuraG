-- CensuraG/src/Config.lua (Enhanced for Desktop Environment)
local Config = {
    -- UI Math Values
    Math = {
        DefaultWindowSize = Vector2.new(300, 400),
        MinWindowSize = Vector2.new(200, 150),
        MaxWindowSize = Vector2.new(1200, 800),
        TaskbarHeight = 40,
        Padding = 10,              -- Standard padding between elements
        BorderThickness = 1,       -- Thickness for borders
        ElementSpacing = 6,        -- Spacing between UI elements
        ScaleFactor = 1,           -- For potential DPI scaling
        CornerRadius = 2,          -- Rounded corners radius
        SnapDistance = 15,         -- Pixels to snap to edges
        TitleBarHeight = 32,       -- Height of window title bars
        ButtonSize = 25,           -- Size of window control buttons
    },

    -- Animation Values
    Animations = {
        FadeDuration = 0.2,        -- Duration for fade animations
        SlideDuration = 0.3,       -- Duration for slide animations
        DefaultEasingStyle = Enum.EasingStyle.Quad,
        DefaultEasingDirection = Enum.EasingDirection.Out,
        WindowAnimationSpeed = 0.25, -- Window state change animations
        FocusAnimationSpeed = 0.15,  -- Window focus change animations
    },

    -- Desktop Environment Settings
    Desktop = {
        BackgroundColor = Color3.fromRGB(25, 30, 35),
        ShowDesktopIcons = true,
        IconSize = 64,
        IconSpacing = 20,
        DoubleClickTime = 0.3,     -- Double-click detection time
        EnableContextMenu = true,   -- Right-click desktop menu
    },

    -- Window Behavior Settings
    Windows = {
        EnableSnapping = true,      -- Snap windows to screen edges
        EnableFocusManagement = true, -- Click to bring to front
        EnableMaximize = true,      -- Allow window maximizing
        RememberPositions = false,  -- Remember window positions (future feature)
        MaxOpenWindows = 15,        -- Maximum concurrent windows
        DefaultPosition = "cascade", -- "center", "cascade", "random"
        EnableAnimations = true,    -- Window state change animations
        EnableShadows = false,      -- Window drop shadows (performance impact)
    },

    -- Taskbar Settings
    Taskbar = {
        AutoHide = true,           -- Auto-hide taskbar
        ShowClock = true,          -- Show system clock
        ShowStartButton = true,     -- Show start button
        ShowNotifications = true,   -- Show notification area
        ButtonMaxWidth = 150,      -- Maximum taskbar button width
        ShowWindowPreviews = false, -- Hover previews (future feature)
    },

    -- Themes based on CensuraDev
    Themes = {
        Military = {
            PrimaryColor = Color3.fromRGB(15, 17, 19),      -- Deep dark gray (background)
            SecondaryColor = Color3.fromRGB(25, 28, 32),    -- Slightly lighter gray
            AccentColor = Color3.fromRGB(200, 200, 200),    -- Almost white accent
            BorderColor = Color3.fromRGB(200, 200, 200),    -- Light border
            TextColor = Color3.fromRGB(225, 228, 230),      -- Soft white text
            EnabledColor = Color3.fromRGB(50, 200, 100),    -- Success green
            DisabledColor = Color3.fromRGB(180, 70, 70),    -- Muted red
            SecondaryTextColor = Color3.fromRGB(130, 135, 140), -- Muted text
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            
            -- For backwards compatibility
            Background = Color3.fromRGB(15, 17, 19), -- Alias for PrimaryColor
            Accent = Color3.fromRGB(200, 200, 200),  -- Alias for AccentColor
            Enabled = Color3.fromRGB(50, 200, 100),  -- Alias for EnabledColor
            Disabled = Color3.fromRGB(180, 70, 70),  -- Alias for DisabledColor
        },
        
        -- Add Cyberpunk theme
        Cyberpunk = {
            PrimaryColor = Color3.fromRGB(15, 15, 30),       -- Dark blue-purple
            SecondaryColor = Color3.fromRGB(30, 30, 45),     -- Lighter blue-purple
            AccentColor = Color3.fromRGB(255, 20, 147),      -- Neon pink
            BorderColor = Color3.fromRGB(255, 20, 147),      -- Neon pink
            TextColor = Color3.fromRGB(0, 255, 255),         -- Cyan
            EnabledColor = Color3.fromRGB(0, 255, 128),      -- Neon green
            DisabledColor = Color3.fromRGB(128, 0, 128),     -- Purple
            SecondaryTextColor = Color3.fromRGB(180, 180, 255), -- Muted cyan
            Font = Enum.Font.Arcade,
            TextSize = 14,
            
            -- For backwards compatibility
            Background = Color3.fromRGB(15, 15, 30),       -- Alias for PrimaryColor
            Accent = Color3.fromRGB(255, 20, 147),         -- Alias for AccentColor
            Enabled = Color3.fromRGB(0, 255, 128),         -- Alias for EnabledColor
            Disabled = Color3.fromRGB(128, 0, 128),        -- Alias for DisabledColor
        }
    },

    -- Current Theme (default to Military)
    CurrentTheme = "Military"
}

-- Window State Enumeration
Config.WindowStates = {
    NORMAL = "normal",
    MINIMIZED = "minimized", 
    MAXIMIZED = "maximized",
    SNAPPED_LEFT = "snapped_left",
    SNAPPED_RIGHT = "snapped_right",
    SNAPPED_TOP = "snapped_top",
    SNAPPED_BOTTOM = "snapped_bottom"
}

-- Convenience function to get the active theme
function Config:GetTheme()
    return self.Themes[self.CurrentTheme]
end

-- Get window snap zones based on screen size
function Config:GetSnapZones()
    local camera = game.Workspace.CurrentCamera
    local screenSize = camera.ViewportSize
    
    return {
        left = UDim2.new(0, 0, 0, 0),
        right = UDim2.new(0.5, 0, 0, 0),
        top = UDim2.new(0, 0, 0, 0),
        bottom = UDim2.new(0, 0, 0.5, 0),
        maximize = UDim2.new(0, 0, 0, 0)
    }
end

-- Calculate cascade position for new windows
function Config:GetCascadePosition(windowIndex)
    local offset = (windowIndex - 1) * 30
    return UDim2.new(0, 100 + offset, 0, 100 + offset)
end

return Config
