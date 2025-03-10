-- Core/Styling.lua
-- Simplified theming system

local Styling = {}
local logger = _G.CensuraG.Logger

Styling.Themes = {
	Dark = {
		Base = Color3.fromRGB(30, 30, 35),
		Accent = Color3.fromRGB(200, 200, 210),
		Secondary = Color3.fromRGB(50, 50, 55),
		Text = Color3.fromRGB(220, 220, 230),
		Highlight = Color3.fromRGB(90, 90, 100)
	},
	Light = {
		Base = Color3.fromRGB(240, 240, 245),
		Accent = Color3.fromRGB(70, 70, 80),
		Secondary = Color3.fromRGB(220, 220, 225),
		Text = Color3.fromRGB(50, 50, 60),
		Highlight = Color3.fromRGB(180, 180, 190)
	},
	Military = {
		Base = Color3.fromRGB(40, 45, 40),
		Accent = Color3.fromRGB(180, 200, 170),
		Secondary = Color3.fromRGB(60, 70, 60),
		Text = Color3.fromRGB(210, 230, 200),
		Highlight = Color3.fromRGB(100, 120, 100)
	}
}

Styling.CurrentTheme = "Dark"
Styling.Colors = Styling.Themes.Dark
Styling.Transparency = { WindowBackground = 0.2, ElementBackground = 0.25 }
Styling.TextSizes = { Title = 18, Label = 16, Button = 16 }
Styling.Fonts = { Primary = Enum.Font.Gotham }
Styling.CornerRadius = UDim.new(0, 4)
Styling.StrokeThickness = 1

function Styling:SetTheme(themeName)
	if not self.Themes[themeName] then
		logger:error("Theme not found: %s", themeName)
		return false
	end
	self.CurrentTheme = themeName
	self.Colors = self.Themes[themeName]
	logger:info("Theme changed to: %s", themeName)
	-- Fire a theme changed event if needed
	if _G.CensuraG and _G.CensuraG.EventManager then
		_G.CensuraG.EventManager:FireEvent("ThemeChanged", themeName)
	end
	return true
end

function Styling:RegisterCustomTheme(themeName, themeColors)
	if type(themeName) ~= "string" or type(themeColors) ~= "table" then
		logger:error("Invalid custom theme parameters")
		return false
	end
	local required = {"Base", "Accent", "Secondary", "Text", "Highlight"}
	for _, key in ipairs(required) do
		if not themeColors[key] then
			logger:error("Custom theme missing key: %s", key)
			return false
		end
	end
	self.Themes[themeName] = themeColors
	logger:info("Registered custom theme: %s", themeName)
	return true
end

function Styling:Apply(element, typeName)
	if not element then return end
	if typeName == "Window" then
		element.BackgroundColor3 = self.Colors.Base
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
	elseif typeName == "TextLabel" then
		element.TextColor3 = self.Colors.Text
		element.Font = self.Fonts.Primary
		element.TextSize = self.TextSizes.Label
		element.BackgroundTransparency = 1
	elseif typeName == "ImageLabel" then
		element.BackgroundColor3 = self.Colors.Secondary
		element.BackgroundTransparency = self.Transparency.ElementBackground
	end
	-- Optionally add UICorner and UIStroke if not already present.
	local corner = element:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", element)
	corner.CornerRadius = self.CornerRadius
	local stroke = element:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", element)
	stroke.Thickness = self.StrokeThickness
	stroke.Color = self.Colors.Highlight
	stroke.Transparency = 0.8
	logger:debug("Applied %s styling to %s", typeName, element:GetFullName())
end

function Styling:UpdateAllElements()
	-- Recursively update all children in ScreenGui
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
