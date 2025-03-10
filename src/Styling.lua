-- Styling.lua: Centralized styling for a dark mode miltech-inspired look with white accent
local Styling = {}

Styling.Colors = {
    Base = Color3.fromRGB(15, 15, 20),         -- Deeper charcoal for dark mode
    Accent = Color3.fromRGB(255, 255, 255),    -- White accent for high contrast
    Secondary = Color3.fromRGB(50, 50, 60),    -- Dark metallic gray for secondary elements
    Text = Color3.fromRGB(200, 200, 210),      -- Light gray for text with good contrast on dark base
    Glow = Color3.fromRGB(200, 200, 255),      -- Soft white-blue glow for subtle effects
}

Styling.Transparency = {
    Background = 0.7, -- Slightly more opaque frosted glass effect for better contrast
    Highlight = 0.4,  -- Brighter highlight for interactive elements to stand out
    Text = 0,         -- Fully opaque text for readability
}

function Styling:Apply(element, elementType)
    -- Common properties
    element.BackgroundColor3 = self.Colors.Base
    element.BorderSizePixel = 0

    -- Add a subtle rounded corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4) -- 4-pixel radius for slight rounding
    corner.Parent = element

    -- Add a glow effect via UIStroke
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = self.Colors.Glow
    stroke.Transparency = 0.85 -- Very subtle glow
    stroke.Parent = element

    -- Add a frosted glass effect via gradient with better contrast
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(self.Colors.Base, self.Colors.Secondary)
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, self.Transparency.Background - 0.1), -- Slightly less transparent at start
        NumberSequenceKeypoint.new(1, self.Transparency.Background)
    })
    gradient.Rotation = 45
    gradient.Parent = element

    if elementType == "TextLabel" or elementType == "TextButton" then
        element.TextColor3 = self.Colors.Text
        element.Font = Enum.Font.Gotham -- Modern, clean font
        element.TextSize = 14
        element.BackgroundColor3 = self.Colors.Secondary
        element.BackgroundTransparency = self.Transparency.Highlight
        element.TextTransparency = self.Transparency.Text
    end
end

return Styling
