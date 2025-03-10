-- Core/Styling.lua
-- Centralized styling system for CensuraG

local Styling = {}
local logger = _G.CensuraG.Logger

Styling.Themes = {
    Dark = {
        Base = Color3.fromRGB(30, 30, 35),
        Accent = Color3.fromRGB(100, 180, 255), -- Brighter accent for contrast
        Secondary = Color3.fromRGB(40, 40, 45),
        Text = Color3.fromRGB(220, 220, 230), -- Adjusted for readability
        Highlight = Color3.fromRGB(70, 90, 120),
        Gradient = {Color3.fromRGB(35, 35, 40), Color3.fromRGB(25, 25, 30)}
    },
    Light = {
        Base = Color3.fromRGB(240, 240, 245),
        Accent = Color3.fromRGB(70, 70, 80),
        Secondary = Color3.fromRGB(220, 220, 225),
        Text = Color3.fromRGB(50, 50, 60),
        Highlight = Color3.fromRGB(180, 180, 190),
        Gradient = {Color3.fromRGB(250, 250, 255), Color3.fromRGB(230, 230, 235)}
    },
    Military = {
        Base = Color3.fromRGB(40, 45, 40),
        Accent = Color3.fromRGB(180, 200, 170),
        Secondary = Color3.fromRGB(60, 70, 60),
        Text = Color3.fromRGB(210, 230, 200),
        Highlight = Color3.fromRGB(100, 120, 100),
        Gradient = {Color3.fromRGB(50, 55, 50), Color3.fromRGB(35, 40, 35)}
    }
}

Styling.CurrentTheme = "Dark"
Styling.Colors = Styling.Themes.Dark
Styling.Transparency = { WindowBackground = 0.2, ElementBackground = 0.25 }
Styling.TextSizes = { Title = 18, Label = 16, Button = 16 }
Styling.Fonts = { Primary = Enum.Font.Gotham }
Styling.CornerRadius = UDim.new(0, 6)
Styling.StrokeThickness = 1
Styling.Padding = 10 -- Increased for better spacing
Styling.ElementWidth = 200 -- Standard interactive width
Styling.LabelWidth = 80 -- Standard label width

function Styling:SetTheme(themeName)
    if not self.Themes[themeName] then
        logger:warn("Theme not found: %s", themeName)
        return false
    end
    self.CurrentTheme = themeName
    self.Colors = self.Themes[themeName]
    logger:info("Theme changed to: %s", themeName)
    _G.CensuraG.EventManager:FireEvent("ThemeChanged", themeName)
    self:UpdateAllElements()
    return true
end

function Styling:Apply(element, typeName)
    if not element then return end
    local gradient = element:FindFirstChild("UIGradient") or Instance.new("UIGradient", element)
    gradient.Color = ColorSequence.new(self.Colors.Gradient[1], self.Colors.Gradient[2])
    gradient.Rotation = 45

    if typeName == "Window" then
        element.BackgroundTransparency = self.Transparency.WindowBackground
    elseif typeName == "Frame" then
        element.BackgroundColor3 = self.Colors.Secondary
        element.BackgroundTransparency = self.Transparency.ElementBackground
    elseif typeName == "TextButton" then
        element.BackgroundColor3 = self.Colors.Secondary
        element.BackgroundTransparency = self.Transparency.ElementBackground
        element.TextColor3 = self.Colors.Text
        element.Font = self.Fonts.Primary
        element.TextSize = self.TextSizes.Button
        element.TextWrapped = true
    elseif typeName == "TextLabel" then
        element.TextColor3 = self.Colors.Text
        element.Font = self.Fonts.Primary
        element.TextSize = self.TextSizes.Label
        element.BackgroundTransparency = 1
        element.TextWrapped = true
    elseif typeName == "ImageLabel" then
        element.BackgroundColor3 = self.Colors.Secondary
        element.BackgroundTransparency = self.Transparency.ElementBackground
    end

    local corner = element:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", element)
    corner.CornerRadius = self.CornerRadius
    local stroke = element:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", element)
    stroke.Thickness = self.StrokeThickness
    stroke.Color = self.Colors.Highlight
    stroke.Transparency = 0.8
    logger:debug("Applied %s styling to %s", typeName, element:GetFullName())
end

function Styling:UpdateAllElements()
    if _G.CensuraG and _G.CensuraG.ScreenGui then
        local function update(obj)
            if obj:IsA("GuiObject") then
                self:Apply(obj, obj.ClassName)
            end
            for _, child in ipairs(obj:GetChildren()) do
                update(child)
            end
        end
        update(_G.CensuraG.ScreenGui)
        logger:info("Updated all UI elements to new theme")
    end
end

return Styling
