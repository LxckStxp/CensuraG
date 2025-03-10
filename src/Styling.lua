-- Styling.lua: Centralized styling for a dark mode miltech-inspired look with white accent
local Styling = {}

Styling.Colors = {
    Base = Color3.fromRGB(15, 15, 20),
    Accent = Color3.fromRGB(255, 255, 255),
    Secondary = Color3.fromRGB(50, 50, 60),
    Text = Color3.fromRGB(200, 200, 210),
    Glow = Color3.fromRGB(200, 200, 255),
}

Styling.Transparency = {
    Background = 0.5, -- Reduced for better readability
    Highlight = 0.3,
    Text = 0,
}

Styling.TextSizes = {
    Title = 16,
    Label = 14,
    Button = 14
}

function Styling:Apply(element, elementType)
    element.BackgroundColor3 = self.Colors.Base
    element.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = element

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = self.Colors.Glow
    stroke.Transparency = 0.85
    stroke.Parent = element

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(self.Colors.Base, self.Colors.Secondary)
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, self.Transparency.Background - 0.1),
        NumberSequenceKeypoint.new(1, self.Transparency.Background)
    })
    gradient.Rotation = 90
    gradient.Parent = element

    if elementType == "TextLabel" or elementType == "TextButton" then
        element.TextColor3 = self.Colors.Text
        element.Font = Enum.Font.Gotham
        element.TextSize = elementType == "TextButton" and self.TextSizes.Button or self.TextSizes.Label
        element.BackgroundColor3 = self.Colors.Secondary
        element.BackgroundTransparency = self.Transparency.Highlight
        element.TextTransparency = self.Transparency.Text
        -- Add text stroke for better visibility
        element.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        element.TextStrokeTransparency = 0.5
    end
end

return Styling
