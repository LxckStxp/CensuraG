-- CensuraG/src/Config.lua
local Config = {
    -- UI Math Values
    Math = {
        DefaultWindowSize = Vector2.new(300, 200),
        TaskbarHeight = 40,
        Padding = 10,              -- Standard padding between elements
        BorderThickness = 2,       -- Thickness for borders (if used)
        ElementSpacing = 5,        -- Spacing between UI elements
        ScaleFactor = 1,           -- For potential DPI scaling
    },

    -- Animation Values
    Animations = {
        FadeDuration = 0.2,        -- Duration for fade animations
        SlideDuration = 0.3,       -- Duration for slide animations
        DefaultEasingStyle = Enum.EasingStyle.Quad,
        DefaultEasingDirection = Enum.EasingDirection.Out,
    },

    -- Themes
    Themes = {
        Miltech = {
            PrimaryColor = Color3.fromRGB(30, 30, 30),    -- Dark gray
            SecondaryColor = Color3.fromRGB(50, 50, 50),  -- Lighter gray
            AccentColor = Color3.fromRGB(0, 105, 92),     -- Muted teal
            BorderColor = Color3.fromRGB(20, 20, 20),     -- Near-black
            TextColor = Color3.fromRGB(200, 200, 200),    -- Light gray
            Font = Enum.Font.Code,
            TextSize = 14,
        },
        Stealth = {
            PrimaryColor = Color3.fromRGB(10, 10, 10),    -- Near-black
            SecondaryColor = Color3.fromRGB(25, 25, 25),  -- Dark gray
            AccentColor = Color3.fromRGB(50, 75, 50),     -- Subtle green
            BorderColor = Color3.fromRGB(5, 5, 5),        -- Pure black
            TextColor = Color3.fromRGB(150, 150, 150),    -- Medium gray
            Font = Enum.Font.SourceSans,
            TextSize = 14,
        },
        Cyberpunk = {
            PrimaryColor = Color3.fromRGB(15, 15, 30),    -- Dark blue-purple
            SecondaryColor = Color3.fromRGB(40, 40, 60),  -- Lighter blue-purple
            AccentColor = Color3.fromRGB(255, 20, 147),   -- Neon pink
            BorderColor = Color3.fromRGB(0, 0, 20),       -- Deep blue
            TextColor = Color3.fromRGB(0, 255, 255),      -- Cyan
            Font = Enum.Font.Arcade,
            TextSize = 14,
        },
    },

    -- Current Theme (default to Miltech)
    CurrentTheme = "Miltech"
}

-- Convenience function to get the active theme
function Config:GetTheme()
    return self.Themes[self.CurrentTheme]
end

return Config
