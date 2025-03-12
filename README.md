# CensuraG - Modern UI Library for Roblox

CensuraG is a sleek, modern UI library for Roblox that provides a complete solution for creating stylish interfaces with minimal effort. This lightweight yet powerful library includes animated windows, auto-hiding taskbar, and a variety of UI components.

## Features

- **Modern Aesthetic**: Clean, minimalist design with smooth animations
- **Theme Support**: Built-in themes with easy customization
- **Component System**: Rich set of UI components (buttons, sliders, dropdowns, etc.)
- **Auto-hiding Taskbar**: Taskbar that appears when needed and hides when not in use
- **Window Management**: Draggable windows with minimize/restore functionality

## Installation

Add CensuraG to your script with a simple loadstring:

```lua
local CensuraG = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/CensuraG/main/CensuraG.lua"))()
```

## Quick Start

Here's a simple example to get you started:

```lua
-- Load CensuraG
local CensuraG = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/CensuraG/main/CensuraG.lua"))()

-- Create a window
local window = CensuraG.CreateWindow("Control Panel")

-- Create a grid for organizing components
local grid = CensuraG.Methods:CreateGrid(window.ContentFrame)

-- Add components to the grid
local label = CensuraG.Methods:CreateLabel(grid.Instance, "Hello, CensuraG!")
grid:AddComponent(label)

local button = CensuraG.Methods:CreateButton(grid.Instance, "Click Me", function()
    print("Button clicked!")
end)
grid:AddComponent(button)

local slider = CensuraG.Methods:CreateSlider(grid.Instance, "Volume", 0, 100, 50, function(value)
    print("Slider value: " .. value)
end)
grid:AddComponent(slider)

local dropdown = CensuraG.Methods:CreateDropdown(grid.Instance, "Options", {"Option 1", "Option 2", "Option 3"}, function(selected)
    print("Selected: " .. selected)
end)
grid:AddComponent(dropdown)

local switch = CensuraG.Methods:CreateSwitch(grid.Instance, "Toggle Feature", false, function(enabled)
    print("Switch toggled: " .. tostring(enabled))
end)
grid:AddComponent(switch)

-- Change theme (available themes: "Military", "Cyberpunk")
CensuraG.SetTheme("Cyberpunk")
```

## Components

### Window

Creates a draggable window with a title bar and content area.

```lua
local window = CensuraG.CreateWindow("Window Title")
```

### Grid

Creates a grid layout for organizing components.

```lua
local grid = CensuraG.Methods:CreateGrid(window.ContentFrame)
```

### TextLabel

Creates a text label for displaying information.

```lua
local label = CensuraG.Methods:CreateLabel(grid.Instance, "Text content")
grid:AddComponent(label)
```

### TextButton

Creates a button with hover and click effects.

```lua
local button = CensuraG.Methods:CreateButton(grid.Instance, "Button Text", function()
    -- Callback when clicked
    print("Button clicked!")
end)
grid:AddComponent(button)
```

### Slider

Creates a slider for selecting numeric values.

```lua
local slider = CensuraG.Methods:CreateSlider(grid.Instance, "Slider Name", 0, 100, 50, function(value)
    -- Callback when value changes
    print("Value: " .. value)
end)
grid:AddComponent(slider)
```

### Dropdown

Creates a dropdown menu for selecting from options.

```lua
local dropdown = CensuraG.Methods:CreateDropdown(grid.Instance, "Dropdown", {"Option 1", "Option 2", "Option 3"}, function(selected)
    -- Callback when selection changes
    print("Selected: " .. selected)
end)
grid:AddComponent(dropdown)
```

### Switch

Creates a toggle switch for boolean values.

```lua
local switch = CensuraG.Methods:CreateSwitch(grid.Instance, "Feature", false, function(enabled)
    -- Callback when toggled
    print("Enabled: " .. tostring(enabled))
end)
grid:AddComponent(switch)
```

### ImageLabel

Creates an image display.

```lua
local image = CensuraG.Methods:CreateImage(grid.Instance, "rbxassetid://123456789")
grid:AddComponent(image)
```

## Themes

CensuraG comes with built-in themes:

```lua
-- Set theme to Military (default)
CensuraG.SetTheme("Military")

-- Set theme to Cyberpunk
CensuraG.SetTheme("Cyberpunk")
```

## API Reference

### CensuraG

The main library object.

- `CensuraG.CreateWindow(title)` - Creates a new window
- `CensuraG.SetTheme(themeName)` - Changes the active theme
- `CensuraG.RefreshAll()` - Refreshes all UI elements with current theme

### Methods

Component creation and utility methods.

- `Methods:CreateLabel(parent, text)`
- `Methods:CreateButton(parent, text, callback)`
- `Methods:CreateSlider(parent, name, min, max, default, callback)`
- `Methods:CreateSwitch(parent, title, default, callback)`
- `Methods:CreateDropdown(parent, title, options, callback)`
- `Methods:CreateGrid(parent)`
- `Methods:CreateImage(parent, imageId)`
- `Methods:RefreshComponent(component, instance)`
- `Methods:RefreshAll()`
- `Methods:GetConfigValue(keyPath)`
- `Methods:SetConfigValue(keyPath, value)`
- `Methods:DestroyAll()`

### Component Objects

All components return objects with these common methods:

- `component:Refresh()` - Refreshes the component with current theme
- `component.Instance` - Access to the Roblox Instance

Additional component-specific methods:

- **TextLabel**: `label:SetText(newText)`
- **TextButton**: `button:SetText(newText)`, `button:SetEnabled(enabled)`
- **Slider**: `slider:SetValue(newValue)`, `slider:GetValue()`
- **Switch**: `switch:SetState(newState)`, `switch:GetState()`
- **Dropdown**: `dropdown:SetSelected(option)`, `dropdown:GetSelected()`

## Advanced Usage

### Configuration Access

Get or set configuration values:

```lua
-- Get a theme color
local primaryColor = CensuraG.Methods:GetConfigValue("Themes.Military.PrimaryColor")

-- Change a theme property
CensuraG.Methods:SetConfigValue("Themes.Cyberpunk.AccentColor", Color3.fromRGB(0, 255, 0))
```

### Custom Themes

Create your own theme by setting configuration values:

```lua
-- Add a new theme
CensuraG.Methods:SetConfigValue("Themes.MyTheme", {
    PrimaryColor = Color3.fromRGB(30, 30, 30),
    SecondaryColor = Color3.fromRGB(45, 45, 45),
    AccentColor = Color3.fromRGB(0, 120, 215),
    BorderColor = Color3.fromRGB(0, 120, 215),
    TextColor = Color3.fromRGB(255, 255, 255),
    EnabledColor = Color3.fromRGB(0, 180, 80),
    DisabledColor = Color3.fromRGB(180, 70, 70),
    SecondaryTextColor = Color3.fromRGB(180, 180, 180),
    Font = Enum.Font.SourceSansBold,
    TextSize = 14
})

-- Use your custom theme
CensuraG.SetTheme("MyTheme")
```

### Taskbar Management

Control the auto-hiding taskbar:

```lua
-- Manually show the taskbar
CensuraG.TaskbarManager:ShowTaskbar()

-- Manually hide the taskbar
CensuraG.TaskbarManager:HideTaskbar()

-- Enable/disable auto-hide
CensuraG.TaskbarManager:SetAutoHide(true)
```

### Cleanup

When you're done with the UI, clean up resources:

```lua
CensuraG.Methods:DestroyAll()
```

## Notes

- The taskbar auto-hides by default, appearing when your mouse enters the bottom 20% of the screen
- Windows can be dragged by their title bar and minimized using the "-" button
- All components automatically adapt to theme changes
