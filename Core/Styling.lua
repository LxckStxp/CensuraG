-- Core/Styling.lua
-- Enhanced theming system with base styles and better organization

local Styling = {}
local logger = _G.CensuraG.Logger

-- =============================================
-- Theme Definitions
-- =============================================
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

-- Current theme state
Styling.CurrentTheme = "Dark"
Styling.Colors = Styling.Themes.Dark

-- Default styling properties
Styling.Transparency = { 
    WindowBackground = 0.2, 
    ElementBackground = 0.25 
}

Styling.TextSizes = { 
    Title = 18, 
    Label = 16, 
    Button = 16 
}

Styling.Fonts = { 
    Primary = Enum.Font.Gotham 
}

Styling.CornerRadius = UDim.new(0, 4)
Styling.StrokeThickness = 1

-- =============================================
-- Base Style Definitions
-- =============================================
-- Base style that all elements inherit from
Styling.BaseStyle = {
    Properties = {
        BorderSizePixel = 0
    },
    Apply = function(element, style)
        -- Apply base properties
        for prop, value in pairs(style.Properties) do
            pcall(function() element[prop] = value end)
        end
        
        -- Apply corner radius if not already present
        local corner = element:FindFirstChildOfClass("UICorner")
        if not corner then
            corner = Instance.new("UICorner", element)
        end
        corner.CornerRadius = style.CornerRadius or Styling.CornerRadius
        
        -- Apply stroke if not already present
        local stroke = element:FindFirstChildOfClass("UIStroke")
        if not stroke then
            stroke = Instance.new("UIStroke", element)
        end
        stroke.Thickness = style.StrokeThickness or Styling.StrokeThickness
        stroke.Color = style.StrokeColor or Styling.Colors.Highlight
        stroke.Transparency = style.StrokeTransparency or 0.8
    end
}

-- =============================================
-- Element Style Definitions
-- =============================================
Styling.ElementStyles = {
    Window = {
        Properties = {
            BackgroundColor3 = function() return Styling.Colors.Base end,
            BackgroundTransparency = function() return Styling.Transparency.WindowBackground end
        },
        CornerRadius = UDim.new(0, 4),
        StrokeThickness = 1,
        StrokeColor = function() return Styling.Colors.Highlight end,
        StrokeTransparency = 0.8
    },
    
    Frame = {
        Properties = {
            BackgroundColor3 = function() return Styling.Colors.Secondary end,
            BackgroundTransparency = function() return Styling.Transparency.ElementBackground end
        },
        CornerRadius = UDim.new(0, 4),
        StrokeThickness = 1,
        StrokeColor = function() return Styling.Colors.Highlight end,
        StrokeTransparency = 0.8
    },
    
    TextButton = {
        Properties = {
            BackgroundColor3 = function() return Styling.Colors.Secondary end,
            BackgroundTransparency = function() return Styling.Transparency.ElementBackground end,
            TextColor3 = function() return Styling.Colors.Text end,
            Font = function() return Styling.Fonts.Primary end,
            TextSize = function() return Styling.TextSizes.Button end
        },
        CornerRadius = UDim.new(0, 4),
        StrokeThickness = 1,
        StrokeColor = function() return Styling.Colors.Highlight end,
        StrokeTransparency = 0.8
    },
    
    TextLabel = {
        Properties = {
            TextColor3 = function() return Styling.Colors.Text end,
            Font = function() return Styling.Fonts.Primary end,
            TextSize = function() return Styling.TextSizes.Label end,
            BackgroundTransparency = 1
        },
        CornerRadius = UDim.new(0, 0),
        StrokeThickness = 0,
        StrokeTransparency = 1
    },
    
    ImageLabel = {
        Properties = {
            BackgroundColor3 = function() return Styling.Colors.Secondary end,
            BackgroundTransparency = function() return Styling.Transparency.ElementBackground end
        },
        CornerRadius = UDim.new(0, 4),
        StrokeThickness = 1,
        StrokeColor = function() return Styling.Colors.Highlight end,
        StrokeTransparency = 0.8
    }
}

-- =============================================
-- Public Methods
-- =============================================
-- Set the current theme
function Styling:SetTheme(themeName)
    if not self.Themes[themeName] then
        logger:error("Theme not found: %s", themeName)
        return false
    end
    
    self.CurrentTheme = themeName
    self.Colors = self.Themes[themeName]
    
    logger:info("Theme changed to: %s", themeName)
    
    -- Fire theme changed event
    if _G.CensuraG and _G.CensuraG.EventManager then
        _G.CensuraG.EventManager:FireEvent("ThemeChanged", themeName)
    end
    
    return true
end

-- Register a custom theme
function Styling:RegisterCustomTheme(themeName, themeColors)
    if type(themeName) ~= "string" or type(themeColors) ~= "table" then
        logger:error("Invalid custom theme parameters")
        return false
    end
    
    -- Validate required color keys
    local required = {"Base", "Accent", "Secondary", "Text", "Highlight"}
    for _, key in ipairs(required) do
        if not themeColors[key] then
            logger:error("Custom theme missing key: %s", key)
            return false
        end
    end
    
    -- Register the theme
    self.Themes[themeName] = themeColors
    logger:info("Registered custom theme: %s", themeName)
    
    return true
end

-- Get a resolved style for an element type
function Styling:GetStyle(typeName)
    local style = self.ElementStyles[typeName]
    if not style then
        logger:warn("No style defined for type: %s, using Frame style", typeName)
        style = self.ElementStyles.Frame
    end
    
    -- Create a new style object with resolved values
    local resolvedStyle = {
        Properties = {}
    }
    
    -- Resolve dynamic properties
    for prop, valueFunc in pairs(style.Properties) do
        if type(valueFunc) == "function" then
            resolvedStyle.Properties[prop] = valueFunc()
        else
            resolvedStyle.Properties[prop] = valueFunc
        end
    end
    
    -- Resolve style attributes
    resolvedStyle.CornerRadius = style.CornerRadius
    
    if type(style.StrokeColor) == "function" then
        resolvedStyle.StrokeColor = style.StrokeColor()
    else
        resolvedStyle.StrokeColor = style.StrokeColor or self.Colors.Highlight
    end
    
    resolvedStyle.StrokeThickness = style.StrokeThickness or self.StrokeThickness
    resolvedStyle.StrokeTransparency = style.StrokeTransparency or 0.8
    
    return resolvedStyle
end

-- Apply styling to an element
function Styling:Apply(element, typeName)
    if not element then return end
    
    -- Get the appropriate style for this element type
    local style = self:GetStyle(typeName)
    
    -- Apply the base style first
    self.BaseStyle.Apply(element, style)
    
    -- Log the styling application
    logger:debug("Applied %s styling to %s", typeName, element:GetFullName())
    
    return element
end

-- Update all UI elements to the current theme
function Styling:UpdateAllElements()
    -- Recursively update all children in ScreenGui
    if _G.CensuraG and _G.CensuraG.ScreenGui then
        local function update(obj)
            if obj:IsA("GuiObject") then
                -- Apply appropriate styling based on object type
                if obj:IsA("TextButton") then
                    self:Apply(obj, "TextButton")
                elseif obj:IsA("TextLabel") then
                    self:Apply(obj, "TextLabel")
                elseif obj:IsA("ImageLabel") then
                    self:Apply(obj, "ImageLabel")
                elseif obj:IsA("Frame") then
                    -- Check if this is a window or regular frame
                    if obj.Name:find("Window_") then
                        self:Apply(obj, "Window")
                    else
                        self:Apply(obj, "Frame")
                    end
                end
            end
            
            -- Process children
            for _, child in ipairs(obj:GetChildren()) do
                update(child)
            end
        end
        
        update(_G.CensuraG.ScreenGui)
        logger:info("Updated all UI elements to %s theme", self.CurrentTheme)
    end
end

return Styling
