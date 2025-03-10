-- CensuraG.lua: Main entry point for the UI API
local CensuraG = {}

-- Load services and modules
CensuraG.ScreenGui = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"))
CensuraG.Utilities = require(script.Utilities) -- Assumed module
CensuraG.Styling = require(script.Styling)    -- Assumed module
CensuraG.Animation = require(script.Animation) -- Assumed module
CensuraG.Draggable = require(script.Draggable)
CensuraG.Window = require(script.Elements.Window)
CensuraG.Slider = require(script.Elements.Slider)
CensuraG.TextButton = require(script.Elements.TextButton)
CensuraG.WindowManager = require(script.WindowManager) -- Assumed module
CensuraG.Taskbar = require(script.Taskbar) -- Assumed module

-- Base UIElement class
CensuraG.UIElement = { Instance = nil }
CensuraG.UIElement.__index = CensuraG.UIElement

_G.CensuraG = CensuraG
return CensuraG
