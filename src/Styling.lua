-- Styling.lua: Centralized styling for a modern miltech-inspired look
local Styling = {}

Styling.Colors = {
    Base = Color3.fromRGB(20, 20, 25),         -- Deep charcoal for backgrounds
    Accent = Color3.fromRGB(0, 200, 255),      -- Neon cyan for highlights
    Secondary = Color3.fromRGB(100, 100, 120), -- Metallic gray for secondary elements
    Text = Color3.fromRGB(220, 220, 240),      -- Light gray-blue for text
    Glow = Color3.fromRGB(0, 255, 255),        -- Cyan glow for effects
}

Styling.Transparency = {
    Background = 0.6, -- Frosted glass effect for frames
    Highlight = 0.3,  -- Brighter highlight for interactive elements
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
    stroke.Transparency = 0.8 -- Subtle glow
    stroke.Parent = element

    -- Add a frosted glass effect via gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(self.Colors.Base, self.Colors.Secondary)
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, self.Transparency.Background),
        NumberSequenceKeypoint.new(1, self.Transparency.Background + 0.1)
    })
    gradient.Rotation = 45
    gradient.Parent = element

    if elementType == "TextLabel" or elementType == "TextButton" then
        element.TextColor3 = self.Colors.Text
        element.Font = Enum.Font.SourceSansPro -- Modern font
        element.TextSize = 14
        element.BackgroundColor3 = self.Colors.Secondary
        element.BackgroundTransparency = self.Transparency.Highlight
        element.TextTransparency = self.Transparency.Text
    end
end

return Styling
