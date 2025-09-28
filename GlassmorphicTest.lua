-- Test the complete glassmorphic CensuraG system
-- This script loads CensuraG and creates a comprehensive test application

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Load CensuraG
local CensuraG = loadstring(game:HttpGet("https://raw.githubusercontent.com/path/to/your/CensuraG.lua"))()

-- Wait for CensuraG to initialize
repeat wait() until _G.CensuraG and _G.CensuraG.Initialized

-- Create a comprehensive test application
local function createTestApp()
    local testWindow = _G.CensuraG.WindowManager:Create({
        Title = "Glassmorphic Test Suite",
        Size = {400, 350},
        Position = {200, 150}
    })
    
    if testWindow then
        -- Test text button
        local testButton = _G.CensuraG.Components.textbutton(
            testWindow.Content,
            "Test Button",
            function()
                _G.CensuraG.Logger:info("Glassmorphic button clicked!")
            end
        )
        
        -- Add some spacing
        local spacer1 = Instance.new("Frame", testWindow.Content)
        spacer1.Size = UDim2.new(1, 0, 0, 10)
        spacer1.BackgroundTransparency = 1
        
        -- Test slider
        local testSlider = _G.CensuraG.Components.slider(
            testWindow.Content,
            "Test Slider",
            0, 100, 50,
            function(value)
                _G.CensuraG.Logger:info("Slider value: " .. tostring(value))
            end
        )
        
        -- Add spacing
        local spacer2 = Instance.new("Frame", testWindow.Content)
        spacer2.Size = UDim2.new(1, 0, 0, 10)
        spacer2.BackgroundTransparency = 1
        
        -- Test dropdown
        local testDropdown = _G.CensuraG.Components.dropdown(
            testWindow.Content,
            "Test Dropdown",
            {"Option 1", "Option 2", "Option 3", "Glassmorphic", "Modern UI"},
            function(selected)
                _G.CensuraG.Logger:info("Selected: " .. tostring(selected))
            end
        )
        
        -- Add layout to organize components
        local layout = Instance.new("UIListLayout", testWindow.Content)
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        
        -- Set layout orders
        testButton.Instance.LayoutOrder = 1
        spacer1.LayoutOrder = 2
        testSlider.Instance.LayoutOrder = 3
        spacer2.LayoutOrder = 4
        testDropdown.Instance.LayoutOrder = 5
        
        -- Add padding to content
        local padding = Instance.new("UIPadding", testWindow.Content)
        padding.PaddingTop = UDim.new(0, 12)
        padding.PaddingLeft = UDim.new(0, 12)
        padding.PaddingRight = UDim.new(0, 12)
        padding.PaddingBottom = UDim.new(0, 12)
        
        _G.CensuraG.Logger:success("Glassmorphic test suite created successfully!")
        return testWindow
    else
        _G.CensuraG.Logger:error("Failed to create test window")
        return nil
    end
end

-- Register the test app with the desktop
_G.CensuraG.Desktop:RegisterApp({
    Name = "Test Suite",
    Description = "Glassmorphic Component Test",
    Icon = "🧪",
    Category = "Development",
    Action = createTestApp
})

-- Create theme switcher app
local function createThemeSwitcher()
    local themeWindow = _G.CensuraG.WindowManager:Create({
        Title = "Theme Switcher",
        Size = {300, 200},
        Position = {250, 200}
    })
    
    if themeWindow then
        -- Theme selection dropdown
        local themeDropdown = _G.CensuraG.Components.dropdown(
            themeWindow.Content,
            "Select Theme",
            {"Glass", "Dark", "Minimal"},
            function(selected)
                _G.CensuraG.Config:SetTheme(selected)
                _G.CensuraG.RefreshManager:RefreshAll()
                _G.CensuraG.Logger:success("Theme changed to: " .. selected)
            end
        )
        
        -- Add layout
        local layout = Instance.new("UIListLayout", themeWindow.Content)
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.Padding = UDim.new(0, 12)
        
        -- Add padding
        local padding = Instance.new("UIPadding", themeWindow.Content)
        padding.PaddingTop = UDim.new(0, 20)
        padding.PaddingLeft = UDim.new(0, 12)
        padding.PaddingRight = UDim.new(0, 12)
        
        _G.CensuraG.Logger:success("Theme switcher created!")
        return themeWindow
    end
end

-- Register theme switcher
_G.CensuraG.Desktop:RegisterApp({
    Name = "Theme Switcher",
    Description = "Change UI Theme",
    Icon = "🎨",
    Category = "Settings",
    Action = createThemeSwitcher
})

_G.CensuraG.Logger:success("Glassmorphic CensuraG system test loaded!")
print("✨ Glassmorphic CensuraG Test Suite Loaded!")
print("📱 Click the Start button to access apps")
print("🎨 Try the Theme Switcher to test glassmorphic themes")