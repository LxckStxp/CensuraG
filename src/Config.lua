-- CensuraG/src/Config.lua (Modern Configuration System v2.0)
-- High-performance configuration with advanced theme management and optimization

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Config = {}

-- Performance optimization: Pre-calculate common values
local function calculateOptimalValues()
    local camera = game.Workspace.CurrentCamera
    local viewport = camera.ViewportSize
    local aspectRatio = viewport.X / viewport.Y
    
    return {
        ScreenWidth = viewport.X,
        ScreenHeight = viewport.Y,
        AspectRatio = aspectRatio,
        IsWidescreen = aspectRatio > 1.6,
        IsMobile = viewport.X < 800 or UserInputService.TouchEnabled,
        OptimalTaskbarHeight = math.clamp(viewport.Y * 0.04, 35, 50),
        OptimalWindowSize = Vector2.new(
            math.clamp(viewport.X * 0.3, 280, 500),
            math.clamp(viewport.Y * 0.4, 300, 600)
        )
    }
end

-- Dynamic configuration system
Config.System = calculateOptimalValues()

-- Modern UI Mathematics with responsive design
Config.Math = {
    -- Responsive window sizing
    DefaultWindowSize = Config.System.OptimalWindowSize,
    MinWindowSize = Vector2.new(240, 180),
    MaxWindowSize = Vector2.new(
        Config.System.ScreenWidth * 0.9, 
        Config.System.ScreenHeight * 0.9
    ),
    
    -- Responsive taskbar
    TaskbarHeight = Config.System.OptimalTaskbarHeight,
    
    -- Modern spacing system (8px grid)
    Padding = {
        XS = 4,   -- Extra small
        SM = 8,   -- Small  
        MD = 16,  -- Medium (default)
        LG = 24,  -- Large
        XL = 32   -- Extra large
    },
    
    -- Advanced border system
    BorderThickness = Config.System.IsMobile and 2 or 1,
    
    -- Glassmorphic corner radius
    CornerRadius = {
        SM = 8,   -- Small elements
        MD = 12,  -- Standard components
        LG = 20,  -- Large containers
        XL = 28   -- Major elements
    },
    
    -- Responsive measurements
    SnapDistance = Config.System.IsMobile and 25 : 15,
    TitleBarHeight = Config.System.IsMobile and 44 : 36,
    ButtonSize = Config.System.IsMobile and 32 : 28,
    
    -- Performance optimization
    MaxConcurrentAnimations = 12,
    AnimationFrameRate = 60
}

-- Advanced animation system with performance optimization
Config.Animations = {
    -- Micro-animations for subtle feedback
    Micro = {
        Duration = 0.08,
        Easing = Enum.EasingStyle.Quad,
        Direction = Enum.EasingDirection.Out
    },
    
    -- Standard animations
    Standard = {
        Duration = 0.15,
        Easing = Enum.EasingStyle.Quart,
        Direction = Enum.EasingDirection.Out
    },
    
    -- Entrance/exit animations
    Entrance = {
        Duration = 0.25,
        Easing = Enum.EasingStyle.Back,
        Direction = Enum.EasingDirection.Out
    },
    
    Exit = {
        Duration = 0.18,
        Easing = Enum.EasingStyle.Quad,
        Direction = Enum.EasingDirection.In
    },
    
    -- Complex state transitions
    StateChange = {
        Duration = 0.3,
        Easing = Enum.EasingStyle.Cubic,
        Direction = Enum.EasingDirection.InOut
    },
    
    -- Performance settings
    EnableMotionReduction = false,  -- Accessibility option
    MaxSimultaneousAnimations = 8,
    PreferPerformance = false       -- Reduce animation quality for performance
}

-- Modern desktop environment configuration
Config.Desktop = {
    -- Glassmorphic overlay settings
    TransparentDesktop = true,      -- Show game world through UI
    EnableBlurEffects = true,       -- Backdrop blur effects
    ShowDesktopIcons = false,       -- Use start menu instead
    
    -- Interaction settings  
    DoubleClickTime = 0.25,         -- Faster double-click
    EnableContextMenu = true,       
    EnableHotkeys = true,           -- Keyboard shortcuts
    
    -- Performance settings
    EnableVSync = true,             -- Smooth animations
    RenderMode = "Optimized",       -- "Quality" or "Optimized"
}

-- Advanced start menu system
Config.StartMenu = {
    Layout = {
        Width = 340,
        Height = 480,
        Padding = Config.Math.Padding.MD,
        ItemSpacing = Config.Math.Padding.SM
    },
    
    Features = {
        EnableSearch = true,
        EnableCategories = true,
        EnableRecentApps = true,
        EnableMostUsed = true,
        EnableAppSuggestions = false
    },
    
    Behavior = {
        AutoHide = true,
        CloseOnAppLaunch = true,
        MaxRecentApps = 8,
        SearchMinChars = 2
    },
    
    Animation = {
        OpenDuration = Config.Animations.Entrance.Duration,
        CloseDuration = Config.Animations.Exit.Duration,
        ItemStagger = 0.02  -- Staggered item animation
    }
}

-- Intelligent window management
Config.Windows = {
    Behavior = {
        EnableSnapping = true,
        EnableSmartPositioning = true,  -- AI-like positioning
        EnableFocusManagement = true,
        EnableGestureControls = Config.System.IsMobile,
        MaxConcurrentWindows = Config.System.IsMobile and 5 or 12
    },
    
    Snapping = {
        Enabled = true,
        Zones = {"left", "right", "top", "bottom", "corners"},
        Sensitivity = Config.Math.SnapDistance,
        ShowPreview = true
    },
    
    Memory = {
        RememberPositions = true,
        RememberSizes = true,
        SessionPersistence = false  -- Across game sessions
    },
    
    Performance = {
        EnableShadows = not Config.System.IsMobile,
        EnableBlur = true,
        RenderOptimization = true,
        OffscreenCulling = true     -- Hide off-screen windows
    }
}

-- Modern taskbar configuration
Config.Taskbar = {
    Layout = {
        Height = Config.Math.TaskbarHeight,
        Position = "bottom",         -- "top", "bottom", "auto-hide"
        Spacing = Config.Math.Padding.SM
    },
    
    Features = {
        ShowStartButton = true,
        ShowClock = true,
        ShowNotifications = true,
        ShowSystemTray = true,
        EnableWindowPreviews = not Config.System.IsMobile
    },
    
    Behavior = {
        AutoHide = false,
        HideDelay = 3.0,            -- Auto-hide after 3 seconds
        ShowOnHover = true,
        GroupSimilarWindows = true
    },
    
    Appearance = {
        ButtonMaxWidth = 180,
        ShowLabels = true,
        ShowIcons = true,
        IconSize = Config.System.IsMobile and 24 or 20
    }
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
-- Advanced Glassmorphic Theme System (continuation from previous)
Config.Themes = Config.Themes or {}

-- Add modern theme definitions if they don't exist
if not Config.Themes.Glass then
    Config.Themes = {
        Glass = {
            PrimaryColor = Color3.fromRGB(255, 255, 255),
            SecondaryColor = Color3.fromRGB(250, 250, 250),
            AccentColor = Color3.fromRGB(0, 122, 255),
            BorderColor = Color3.fromRGB(255, 255, 255),
            TextColor = Color3.fromRGB(0, 0, 0),
            EnabledColor = Color3.fromRGB(52, 199, 89),
            DisabledColor = Color3.fromRGB(255, 59, 48),
            SecondaryTextColor = Color3.fromRGB(60, 60, 67),
            GlassTransparency = 0.12,
            BorderTransparency = 0.65,
            Font = Enum.Font.Gotham,
            BoldFont = Enum.Font.GothamBold,
            TextSize = 14
        },
        
        Dark = {
            PrimaryColor = Color3.fromRGB(22, 22, 24),
            SecondaryColor = Color3.fromRGB(32, 32, 36),
            AccentColor = Color3.fromRGB(10, 132, 255),
            BorderColor = Color3.fromRGB(255, 255, 255),
            TextColor = Color3.fromRGB(255, 255, 255),
            EnabledColor = Color3.fromRGB(48, 209, 88),
            DisabledColor = Color3.fromRGB(255, 69, 58),
            SecondaryTextColor = Color3.fromRGB(174, 174, 178),
            GlassTransparency = 0.18,
            BorderTransparency = 0.55,
            Font = Enum.Font.Gotham,
            BoldFont = Enum.Font.GothamBold,
            TextSize = 14
        },
        
        Minimal = {
            PrimaryColor = Color3.fromRGB(252, 252, 252),
            SecondaryColor = Color3.fromRGB(255, 255, 255),
            AccentColor = Color3.fromRGB(0, 0, 0),
            BorderColor = Color3.fromRGB(224, 224, 224),
            TextColor = Color3.fromRGB(0, 0, 0),
            EnabledColor = Color3.fromRGB(0, 0, 0),
            DisabledColor = Color3.fromRGB(192, 192, 192),
            SecondaryTextColor = Color3.fromRGB(64, 64, 64),
            GlassTransparency = 0.02,
            BorderTransparency = 0.85,
            Font = Enum.Font.Gotham,
            BoldFont = Enum.Font.GothamBold,
            TextSize = 13
        }
    }
end

Config.CurrentTheme = "Glass"

-- Advanced State Management
Config.WindowStates = {
    NORMAL = "normal",
    MINIMIZED = "minimized", 
    MAXIMIZED = "maximized",
    SNAPPED_LEFT = "snapped_left",
    SNAPPED_RIGHT = "snapped_right",
    SNAPPED_TOP = "snapped_top",
    SNAPPED_BOTTOM = "snapped_bottom",
    FULLSCREEN = "fullscreen",
    FLOATING = "floating"
}

Config.ComponentStates = {
    IDLE = "idle",
    HOVER = "hover", 
    ACTIVE = "active",
    DISABLED = "disabled",
    LOADING = "loading"
}

-- Performance monitoring
Config.Performance = {
    MaxFrameTime = 16.67, -- 60 FPS target
    EnableProfiling = false,
    OptimizationLevel = "balanced" -- "performance", "balanced", "quality"
}

-- Modern Configuration Methods
function Config:Initialize()
    -- Responsive recalculation on viewport changes
    local camera = game.Workspace.CurrentCamera
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        self.System = calculateOptimalValues()
        self:UpdateResponsiveValues()
    end)
    
    -- Initialize theme cache
    self.ThemeCache = {}
    self:CacheCurrentTheme()
end

function Config:GetTheme(themeName)
    local targetTheme = themeName or self.CurrentTheme
    
    -- Use cached theme if available
    if self.ThemeCache[targetTheme] then
        return self.ThemeCache[targetTheme]
    end
    
    local theme = self.Themes[targetTheme]
    if not theme then
        warn("Theme not found: " .. targetTheme .. ", falling back to Glass")
        theme = self.Themes.Glass
    end
    
    -- Cache the theme
    self.ThemeCache[targetTheme] = theme
    return theme
end

function Config:SetTheme(themeName, animated)
    if not self.Themes[themeName] then
        warn("Unknown theme: " .. themeName)
        return false
    end
    
    local oldTheme = self.CurrentTheme
    self.CurrentTheme = themeName
    
    -- Clear cache to force refresh
    self.ThemeCache = {}
    self:CacheCurrentTheme()
    
    if animated and _G.CensuraG and _G.CensuraG.RefreshManager then
        _G.CensuraG.RefreshManager:RefreshAll()
    end
    
    return true
end

function Config:CacheCurrentTheme()
    local theme = self.Themes[self.CurrentTheme]
    if theme then
        self.ThemeCache[self.CurrentTheme] = theme
    end
end

function Config:UpdateResponsiveValues()
    -- Recalculate responsive values
    self.Math.DefaultWindowSize = self.System.OptimalWindowSize
    self.Math.TaskbarHeight = self.System.OptimalTaskbarHeight
    self.Math.BorderThickness = self.System.IsMobile and 2 or 1
    self.Math.SnapDistance = self.System.IsMobile and 25 or 15
end

-- Advanced window positioning
function Config:GetSnapZones()
    local viewport = self.System
    
    return {
        left = {
            position = UDim2.new(0, 0, 0, 0),
            size = UDim2.new(0.5, 0, 1, -self.Math.TaskbarHeight)
        },
        right = {
            position = UDim2.new(0.5, 0, 0, 0),
            size = UDim2.new(0.5, 0, 1, -self.Math.TaskbarHeight)
        },
        top = {
            position = UDim2.new(0, 0, 0, 0),
            size = UDim2.new(1, 0, 0.5, 0)
        },
        bottom = {
            position = UDim2.new(0, 0, 0.5, 0),
            size = UDim2.new(1, 0, 0.5, -self.Math.TaskbarHeight)
        },
        maximize = {
            position = UDim2.new(0, 0, 0, 0),
            size = UDim2.new(1, 0, 1, -self.Math.TaskbarHeight)
        }
    }
end

function Config:GetSmartPosition(windowIndex, existingWindows)
    local viewport = self.System
    local offset = math.min((windowIndex - 1) * 35, 200)
    
    -- Smart positioning to avoid overlap
    local baseX = math.clamp(120 + offset, 50, viewport.ScreenWidth - 350)
    local baseY = math.clamp(80 + offset, 50, viewport.ScreenHeight - 300)
    
    return UDim2.new(0, baseX, 0, baseY)
end

-- Performance utilities
function Config:GetOptimalAnimationDuration(complexity)
    local base = self.Animations.Standard.Duration
    
    if self.Performance.OptimizationLevel == "performance" then
        return base * 0.5
    elseif self.Performance.OptimizationLevel == "quality" then
        return base * 1.2
    end
    
    return base
end

function Config:ShouldEnableEffect(effectName)
    if self.Performance.OptimizationLevel == "performance" then
        return effectName ~= "shadows" and effectName ~= "blur"
    end
    
    return true
end

-- Export configuration
return Config
