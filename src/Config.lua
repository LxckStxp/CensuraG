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

    -- Desktop Environment Settings (Glassmorphic Overlay)
    Desktop = {
        ShowBackground = false,     -- No background - show game world
        ShowDesktopIcons = false,   -- Use start menu instead
        DoubleClickTime = 0.3,      -- Double-click detection time
        EnableContextMenu = true,   -- Right-click desktop menu
        BlurBackground = true,      -- Blur effects behind UI
    },
    
    -- Start Menu Configuration
    StartMenu = {
        Size = UDim2.new(0, 320, 0, 400),          -- Menu size
        Position = UDim2.new(0, 10, 1, -450),      -- Position from taskbar
        ShowSearch = true,                           -- Search functionality
        ShowRecent = true,                          -- Recent apps section
        ShowCategories = true,                      -- App categories
        MaxRecentApps = 6,                         -- Max recent apps to show
        ItemHeight = 40,                           -- Menu item height
        CategoryHeight = 30,                       -- Category header height
        AnimationSpeed = 0.25,                     -- Open/close animation
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

    -- Glassmorphic Themes - Modern and Minimalistic
    Themes = {
        Glass = {
            -- Glassmorphic colors with transparency
            PrimaryColor = Color3.fromRGB(255, 255, 255),      -- Pure white base
            SecondaryColor = Color3.fromRGB(255, 255, 255),     -- White secondary
            AccentColor = Color3.fromRGB(0, 122, 255),          -- Modern blue accent
            BorderColor = Color3.fromRGB(255, 255, 255),        -- White border
            TextColor = Color3.fromRGB(0, 0, 0),                -- Black text
            EnabledColor = Color3.fromRGB(52, 199, 89),         -- iOS green
            DisabledColor = Color3.fromRGB(255, 59, 48),        -- iOS red
            SecondaryTextColor = Color3.fromRGB(60, 60, 67),    -- Secondary gray text
            
            -- Glassmorphic properties
            GlassTransparency = 0.15,                           -- Main glass transparency
            BlurIntensity = 20,                                 -- Blur effect intensity
            BorderTransparency = 0.7,                           -- Border transparency
            ShadowColor = Color3.fromRGB(0, 0, 0),              -- Shadow color
            ShadowTransparency = 0.8,                           -- Shadow transparency
            
            -- Typography
            Font = Enum.Font.Gotham,
            BoldFont = Enum.Font.GothamBold,
            LightFont = Enum.Font.GothamLight,
            TextSize = 14,
            
            -- Legacy aliases
            Background = Color3.fromRGB(255, 255, 255),
            Accent = Color3.fromRGB(0, 122, 255),
            Enabled = Color3.fromRGB(52, 199, 89),
            Disabled = Color3.fromRGB(255, 59, 48),
        },
        
        Dark = {
            -- Dark glassmorphic theme
            PrimaryColor = Color3.fromRGB(28, 28, 30),          -- Dark gray base
            SecondaryColor = Color3.fromRGB(44, 44, 46),        -- Lighter dark gray
            AccentColor = Color3.fromRGB(10, 132, 255),         -- Bright blue accent
            BorderColor = Color3.fromRGB(255, 255, 255),        -- White border
            TextColor = Color3.fromRGB(255, 255, 255),          -- White text
            EnabledColor = Color3.fromRGB(48, 209, 88),         -- Green
            DisabledColor = Color3.fromRGB(255, 69, 58),        -- Red
            SecondaryTextColor = Color3.fromRGB(174, 174, 178), -- Gray text
            
            -- Glassmorphic properties
            GlassTransparency = 0.2,
            BlurIntensity = 25,
            BorderTransparency = 0.6,
            ShadowColor = Color3.fromRGB(0, 0, 0),
            ShadowTransparency = 0.6,
            
            -- Typography
            Font = Enum.Font.Gotham,
            BoldFont = Enum.Font.GothamBold,
            LightFont = Enum.Font.GothamLight,
            TextSize = 14,
            
            -- Legacy aliases
            Background = Color3.fromRGB(28, 28, 30),
            Accent = Color3.fromRGB(10, 132, 255),
            Enabled = Color3.fromRGB(48, 209, 88),
            Disabled = Color3.fromRGB(255, 69, 58),
        },
        
        Minimal = {
            -- Ultra minimal theme
            PrimaryColor = Color3.fromRGB(248, 248, 248),       -- Off-white
            SecondaryColor = Color3.fromRGB(255, 255, 255),     -- Pure white
            AccentColor = Color3.fromRGB(0, 0, 0),              -- Pure black accent
            BorderColor = Color3.fromRGB(200, 200, 200),        -- Light gray border
            TextColor = Color3.fromRGB(0, 0, 0),                -- Black text
            EnabledColor = Color3.fromRGB(0, 0, 0),             -- Black for enabled
            DisabledColor = Color3.fromRGB(160, 160, 160),      -- Gray for disabled
            SecondaryTextColor = Color3.fromRGB(100, 100, 100), -- Dark gray text
            
            -- Glassmorphic properties
            GlassTransparency = 0.05,
            BlurIntensity = 10,
            BorderTransparency = 0.8,
            ShadowColor = Color3.fromRGB(0, 0, 0),
            ShadowTransparency = 0.9,
            
            -- Typography
            Font = Enum.Font.Gotham,
            BoldFont = Enum.Font.GothamBold,
            LightFont = Enum.Font.GothamLight,
            TextSize = 13,
            
            -- Legacy aliases
            Background = Color3.fromRGB(248, 248, 248),
            Accent = Color3.fromRGB(0, 0, 0),
            Enabled = Color3.fromRGB(0, 0, 0),
            Disabled = Color3.fromRGB(160, 160, 160),
        }
    },

    -- Current Theme (default to Glass)
    CurrentTheme = "Glass"
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
