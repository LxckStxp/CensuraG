-- Styling.lua: Centralized miltech-inspired styling
local Styling = {}

Styling.Colors = {
    Base = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(200, 200, 210),
    Secondary = Color3.fromRGB(50, 50, 55),
    Text = Color3.fromRGB(220, 220, 230),
    Highlight = Color3.fromRGB(90, 90, 100)
}

Styling.Transparency = {
    WindowBackground = 0.2,
    ElementBackground = 0.25,
    Highlight = 0.15,
    Text = 0
}

Styling.TextSizes = {
    Title = 18,
    Label = 16,
    Button = 16,
    Value = 14
}

function Styling:Apply(element, elementType)
    if elementType == "Window" then
        element.BackgroundColor3 = self.Colors.Base
        element.BackgroundTransparency = self.Transparency.WindowBackground
    elseif elementType == "Frame" or elementType == "TextButton" or elementType == "ImageLabel" then
        element.BackgroundColor3 = self.Colors.Secondary
        element.BackgroundTransparency = self.Transparency.ElementBackground
    end

    element.BorderSizePixel = 0
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = element

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = self.Colors.Highlight
    stroke.Transparency = 0.8
    stroke.Parent = element

    if elementType == "TextLabel" or elementType == "TextButton" then
        element.TextColor3 = self.Colors.Text
        element.Font = Enum.Font.Gotham
        element.TextSize = elementType == "TextButton" and self.TextSizes.Button or self.TextSizes.Label
        element.TextTransparency = 0
        element.BackgroundTransparency = self.Transparency.ElementBackground
    end
end

return Styling
