-- Core/Styling.lua: Enhanced theming system
local Styling = {}
local logger = _G.CensuraG.Logger

-- Theme definitions
Styling.Themes = {
    Dark = {
        Base = Color3.fromRGB(30, 30, 35),
        Accent = Color3.fromRGB(200, 200, 210),
        Secondary = Color3.fromRGB(50, 50, 55),
        Text = Color3.fromRGB(220, 220, 230),
        Highlight = Color3.fromRGB(90, 90, 100),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 152, 0),
        Error = Color3.fromRGB(244, 67, 54)
    },
    Light = {
        Base = Color3.fromRGB(240, 240, 245),
        Accent = Color3.fromRGB(70, 70, 80),
        Secondary = Color3.fromRGB(220, 220, 225),
        Text = Color3.fromRGB(50, 50, 60),
        Highlight = Color3.fromRGB(180, 180, 190),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 152, 0),
        Error = Color3.fromRGB(244, 67, 54)
    },
    Military = {
        Base = Color3.fromRGB(40, 45, 40),
        Accent = Color3.fromRGB(180, 200, 170),
        Secondary = Color3.fromRGB(60, 70, 60),
        Text = Color3.fromRGB(210, 230, 200),
        Highlight = Color3.fromRGB(100, 120, 100),
        Success = Color3.fromRGB(76, 175, 80),
        Warning = Color3.fromRGB(255, 152, 0),
        Error = Color3.fromRGB(244, 67, 54)
    }
}

-- Current theme and settings
Styling.CurrentTheme = "Dark"
Styling.Colors = Styling.Themes.Dark

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

Styling.Fonts = {
    Primary = Enum.Font.Gotham,
    Secondary = Enum.Font.GothamSemibold,
    Monospace = Enum.Font.Code
}

Styling.CornerRadius = UDim.new(0, 4)
Styling.StrokeThickness = 1

-- Theme management functions
function Styling:SetTheme(themeName)
    if not self.Themes[themeName] then
        logger:error("Theme not found: %s", themeName)
        return false
    end
    
    self.CurrentTheme = themeName
    self.Colors = self.Themes[themeName]
    logger:info("Theme changed to: %s", themeName)
    
    -- Notify all registered UI elements about theme change
    if _G.CensuraG and _G.CensuraG.EventManager then
        _G.CensuraG.EventManager:FireEvent("ThemeChanged", themeName)
    end
    
    return true
end

function Styling:RegisterCustomTheme(themeName, themeColors)
    if not themeName or type(themeName) ~= "string" then
        logger:error("Invalid theme name")
        return false
    end
    
    if not themeColors or type(themeColors) ~= "table" then
        logger:error("Invalid theme colors")
        return false
    end
    
    -- Validate required color keys
    local requiredKeys = {"Base", "Accent", "Secondary", "Text", "Highlight"}
    for _, key in ipairs(requiredKeys) do
        if not themeColors[key] then
            logger:error("Theme is missing required color: %s", key)
            return false
        end
    end
    
    self.Themes[themeName] = themeColors
    logger:info("Registered custom theme: %s", themeName)
    return true
end

-- Apply styling to UI elements
function Styling:Apply(element, elementType)
    if not element then return end
    
    -- Base styling for all elements
    element.BorderSizePixel = 0
    
    -- Type-specific styling
    if elementType == "Window" then
        element.BackgroundColor3 = self.Colors.Base
        element.BackgroundTransparency = self.Transparency.WindowBackground
    elseif elementType == "Frame" then
        element.BackgroundColor3 = self.Colors.Secondary
        element.BackgroundTransparency = self.Transparency.ElementBackground
    elseif elementType == "TextButton" then
        element.BackgroundColor3 = self.Colors.Secondary
        element.BackgroundTransparency = self.Transparency.ElementBackground
        element.TextColor3 = self.Colors.Text
        element.Font = self.Fonts.Primary
        element.TextSize = self.TextSizes.Button
        element.TextTransparency = self.Transparency.Text
        element.AutoButtonColor = false -- We'll handle hover effects manually
    elseif elementType == "TextLabel" then
        element.BackgroundTransparency = 1 -- Usually transparent
        element.TextColor3 = self.Colors.Text
        element.Font = self.Fonts.Primary
        element.TextSize = self.TextSizes.Label
        element.TextTransparency = self.Transparency.Text
    elseif elementType == "ImageLabel" then
        element.BackgroundColor3 = self.Colors.Secondary
        element.BackgroundTransparency = self.Transparency.ElementBackground
    end
    
    -- Apply corner rounding
    local corner = element:FindFirstChildOfClass("UICorner")
    if not corner then
        corner = Instance.new("UICorner")
        corner.Parent = element
    end
    corner.CornerRadius = self.CornerRadius
    
    -- Apply stroke
    local stroke = element:FindFirstChildOfClass("UIStroke")
    if not stroke then
        stroke = Instance.new("UIStroke")
        stroke.Parent = element
    end
    stroke.Thickness = self.StrokeThickness
    stroke.Color = self.Colors.Highlight
    stroke.Transparency = 0.8
    
    logger:debug("Applied %s styling to %s", elementType, element:GetFullName())
end

-- Update all UI elements when theme changes
function Styling:UpdateAllElements()
    if not _G.CensuraG or not _G.CensuraG.ScreenGui then return end
    
    local function updateElement(element)
        -- Determine element type
        local elementType = nil
        if element:IsA("Frame") then
            elementType = "Frame"
        elseif element:IsA("TextButton") then
            elementType = "TextButton"
        elseif element:IsA("TextLabel") then
            elementType = "TextLabel"
        elseif element:IsA("ImageLabel") then
            elementType = "ImageLabel"
        end
        
        if elementType then
            self:Apply(element, elementType)
        end
        
        -- Recursively update children
        for _, child in ipairs(element:GetChildren()) do
            if child:IsA("GuiObject") then
                updateElement(child)
            end
        end
    end
    
    updateElement(_G.CensuraG.ScreenGui)
    logger:info("Updated all UI elements to match current theme")
end

return Styling
