-- Styling.lua: Centralized styling for a miltech-inspired look
local Styling = {}

Styling.Colors = {
    Base = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(0, 120, 215),
    Highlight = Color3.fromRGB(50, 50, 50),
    Text = Color3.fromRGB(200, 200, 200),
    Border = Color3.fromRGB(80, 80, 80)
}

function Styling:Apply(element, elementType)
    element.BackgroundColor3 = self.Colors.Base
    element.BorderColor3 = self.Colors.Border
    element.BorderSizePixel = 1
    if elementType == "TextLabel" or elementType == "TextButton" then
        element.TextColor3 = self.Colors.Text
        element.Font = Enum.Font.Code
        element.TextSize = 14
        element.BackgroundColor3 = self.Colors.Highlight
    end
end

return Styling
