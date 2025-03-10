-- Styling.lua: Centralized styling for a monochrome miltech-inspired look with subtle accents
local Styling = {}

-- Define a monochrome color palette with subtle accents
Styling.Colors = {
    Base = Color3.fromRGB(40, 40, 45), -- Slightly lighter dark gray for better text contrast
    Accent = Color3.fromRGB(255, 255, 255), -- White for primary accents
    Secondary = Color3.fromRGB(60, 60, 65), -- Slightly lighter gray for secondary elements
    Text = Color3.fromRGB(255, 255, 255), -- White text for contrast on dark backgrounds
    Glow = Color3.fromRGB(100, 100, 255), -- Subtle blue glow for effects
    Highlight = Color3.fromRGB(80, 80, 85), -- Highlight color for interactive elements
}

Styling.Transparency = {
    WindowBackground = 0.3, -- Window background at 30% transparency
    ElementBackground = 0.3, -- Elements (sliders, switches, buttons) at 30% transparency
    Highlight = 0.2, -- Slightly less transparent for highlights
    Text = 0, -- Fully opaque text
}

Styling.TextSizes = {
    Title = 18, -- Increased for better readability
    Label = 16, -- Increased for better readability
    Button = 16 -- Increased for better readability
}

function Styling:Apply(element, elementType)
    -- Set background properties based on element type
    if elementType == "Window" then
        element.BackgroundColor3 = self.Colors.Base
        element.BackgroundTransparency = self.Transparency.WindowBackground
    elseif elementType == "Frame" or elementType == "TextButton" or elementType == "ImageLabel" then
        element.BackgroundColor3 = self.Colors.Secondary
        element.BackgroundTransparency = self.Transparency.ElementBackground
    end

    element.BorderSizePixel = 0

    -- Apply a subtle corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = element

    -- Apply a glow stroke
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = self.Colors.Glow
    stroke.Transparency = 0.85
    stroke.Parent = element

    -- Apply a subtle gradient for depth
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(self.Colors.Base, self.Colors.Secondary)
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, element.BackgroundTransparency),
        NumberSequenceKeypoint.new(1, element.BackgroundTransparency + 0.1)
    })
    gradient.Rotation = 90
    gradient.Parent = element

    -- Style text elements
    if elementType == "TextLabel" or elementType == "TextButton" then
        element.TextColor3 = self.Colors.Text -- White text for contrast
        element.Font = Enum.Font.Gotham
        element.TextSize = elementType == "TextButton" and self.TextSizes.Button or self.TextSizes.Label
        element.BackgroundColor3 = self.Colors.Secondary
        element.BackgroundTransparency = self.Transparency.ElementBackground
        element.TextTransparency = self.Transparency.Text
        -- Remove text stroke to prevent blending issues
        element.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        element.TextStrokeTransparency = 1 -- Disable stroke
        -- Force text visibility
        element.Visible = true
        element.TextTransparency = 0
    end
end

return Styling
