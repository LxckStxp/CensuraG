-- Styling.lua: Centralized styling for a miltech-inspired look
local Styling = {}

Styling.Colors = {
    Base = Color3.fromRGB(30, 30, 30),        -- Dark grey base
    Accent = Color3.fromRGB(0, 80, 120),      -- Subtle desaturated blue for highlights
    Highlight = Color3.fromRGB(50, 50, 50),   -- Slightly lighter grey
    Text = Color3.fromRGB(200, 200, 200),     -- Light grey for readability
    Border = Color3.fromRGB(80, 80, 80)       -- Medium grey for borders
}

function Styling:Apply(element, elementType)
    element.BackgroundColor3 = self.Colors.Base
    element.BorderColor3 = self.Colors.Border
    element.BorderSizePixel = 0 -- Default to no border unless specified
    if elementType == "TextLabel" or elementType == "TextButton" then
        element.TextColor3 = self.Colors.Text
        element.Font = Enum.Font.Code
        element.TextSize = 14
        element.BackgroundColor3 = self.Colors.Highlight
    end
end

return Styling
