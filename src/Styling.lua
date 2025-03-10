-- Styling.lua: Centralized styling for a miltech-inspired minimalist look
local Styling = {}

-- Miltech-inspired color palette
Styling.Colors = {
    Background = Color3.fromRGB(20, 25, 20),      -- Dark greenish-gray
    Accent = Color3.fromRGB(50, 60, 50),          -- Slightly lighter accent
    Highlight = Color3.fromRGB(100, 120, 100),    -- Subtle green for active states
    Text = Color3.fromRGB(200, 210, 200),         -- Off-white with a hint of green
    Warning = Color3.fromRGB(120, 40, 40),        -- Muted red for emphasis
    Border = Color3.fromRGB(40, 45, 40)           -- Subtle border color
}

-- Font settings
Styling.Font = Enum.Font.Code -- Monospace for that terminal feel
Styling.TextSize = 14

-- Default properties
Styling.Defaults = {
    BorderSizePixel = 1,
    BorderColor3 = Styling.Colors.Border,
    BackgroundTransparency = 0.1 -- Slight transparency for depth
}

-- Apply style to an instance
function Styling:Apply(instance, styleType)
    local styles = {
        Frame = {
            BackgroundColor3 = self.Colors.Background,
            BorderSizePixel = self.Defaults.BorderSizePixel,
            BorderColor3 = self.Defaults.BorderColor3,
            BackgroundTransparency = self.Defaults.BackgroundTransparency
        },
        TextLabel = {
            BackgroundColor3 = self.Colors.Background,
            TextColor3 = self.Colors.Text,
            Font = self.Font,
            TextSize = self.TextSize,
            BorderSizePixel = self.Defaults.BorderSizePixel,
            BorderColor3 = self.Defaults.BorderColor3,
            BackgroundTransparency = self.Defaults.BackgroundTransparency
        },
        TextButton = {
            BackgroundColor3 = self.Colors.Accent,
            TextColor3 = self.Colors.Text,
            Font = self.Font,
            TextSize = self.TextSize,
            BorderSizePixel = self.Defaults.BorderSizePixel,
            BorderColor3 = self.Defaults.BorderColor3,
            BackgroundTransparency = self.Defaults.BackgroundTransparency
        }
    }
    local style = styles[styleType] or {}
    for prop, value in pairs(style) do
        instance[prop] = value
    end
end

-- Customize styles dynamically
function Styling:Customize(key, value)
    if self.Colors[key] then
        self.Colors[key] = value
    elseif key == "Font" then
        self.Font = value
    elseif key == "TextSize" then
        self.TextSize = value
    end
end

return Styling
