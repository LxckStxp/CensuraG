-- Core/Styling.lua: Simplified theming system
local Styling = {}
Styling.Themes = {
    Dark = {
        Base = Color3.fromRGB(30, 30, 35),
        Accent = Color3.fromRGB(200, 200, 210),
        Secondary = Color3.fromRGB(50, 50, 55),
        Text = Color3.fromRGB(220, 220, 230)
    }
}

Styling.CurrentTheme = "Dark"
Styling.Colors = Styling.Themes.Dark

-- Apply styling to an element
function Styling:Apply(element, elementType)
    if elementType == "Window" then
        element.BackgroundColor3 = self.Colors.Base
    elseif elementType == "TextButton" then
        element.BackgroundColor3 = self.Colors.Secondary
        element.TextColor3 = self.Colors.Text
    end
end

return Styling
