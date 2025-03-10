-- Styling.lua: Centralized styling for a monochrome miltech-inspired look with subtle accents
local Styling = {}

-- Define a monochrome color palette with subtle accents
Styling.Colors = {
    Base = Color3.fromRGB(30, 30, 35), -- Dark gray for main backgrounds
    Accent = Color3.fromRGB(255, 255, 255), -- White for primary accents
    Secondary = Color3.fromRGB(50, 50, 55), -- Slightly lighter gray for secondary elements
    Text = Color3.fromRGB(255, 255, 255), -- White text for contrast on dark backgrounds
    Glow = Color3.fromRGB(100, 100, 255), -- Subtle blue glow for effects
    Highlight = Color3.fromRGB(70, 70, 75), -- Highlight color for interactive elements
}

Styling.Transparency = {
    WindowBackground = 0.3, -- Window background at 30% transparency
    ElementBackground = 0.3, -- Elements (sliders, switches, buttons) at 30% transparency
    Highlight = 0.2, -- Slightly less transparent for highlights
    Text = 0, -- Fully opaque text
}

Styling.TextSizes = {
    Title = 16,
    Label = 14,
    Button = 14
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
        -- Add text stroke for better visibility
        element.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        element.TextStrokeTransparency = 0.5
    end
end

return Styling
