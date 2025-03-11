-- CensuraG/src/Config.lua (updated for CensuraDev styling)
local Config = {
    -- UI Math Values
    Math = {
        DefaultWindowSize = Vector2.new(300, 400),
        TaskbarHeight = 40,
        Padding = 10,              -- Standard padding between elements
        BorderThickness = 1,       -- Thickness for borders
        ElementSpacing = 6,        -- Spacing between UI elements
        ScaleFactor = 1,           -- For potential DPI scaling
        CornerRadius = 2,          -- Rounded corners radius
    },

    -- Animation Values
    Animations = {
        FadeDuration = 0.2,        -- Duration for fade animations
        SlideDuration = 0.3,       -- Duration for slide animations
        DefaultEasingStyle = Enum.EasingStyle.Quad,
        DefaultEasingDirection = Enum.EasingDirection.Out,
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
        },
    },

    -- Current Theme (default to Military)
    CurrentTheme = "Military"
}

-- Convenience function to get the active theme
function Config:GetTheme()
    return self.Themes[self.CurrentTheme]
end

return Config
