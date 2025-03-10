-- init.lua
-- Main entry point for CensuraG UI framework

local CensuraG = {
	_VERSION = "1.0.0",
	_DESCRIPTION = "Modern UI framework for Roblox exploits",
	_LICENSE = "MIT"
}

_G.CensuraG = CensuraG

-- Central module loader using loadstring and caching
local ModuleCache = {}
local function loadModule(url, moduleName)
	if ModuleCache[moduleName] then return ModuleCache[moduleName] end
	local response = game:HttpGet(url, true)
	local moduleFunc, err = loadstring(response)
	if not moduleFunc then error("Failed to compile ["..moduleName.."]: "..err) end
	local success, moduleResult = pcall(moduleFunc)
	if not success then error("Failed to execute module ["..moduleName.."]: "..moduleResult) end
	ModuleCache[moduleName] = moduleResult
	return moduleResult
end

local baseUrl = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/"
local oratioUrl = "https://raw.githubusercontent.com/LxckStxp/Oratio/main/init.lua"
local OratioFunc = loadModule(oratioUrl, "Oratio")
if OratioFunc then
	local Oratio = OratioFunc()
	CensuraG.Logger = Oratio.new({
		moduleName = "CensuraG",
		minLevel = "DEBUG",
		storeHistory = true,
		outputEnabled = true
	})
else
	CensuraG.Logger = {
		debug = print, info = print, warn = warn, error = warn, critical = warn
	}
end

CensuraG.Logger:info("Initializing CensuraG v%s", CensuraG._VERSION)

local modules = {
	{ name = "Utilities", path = "Core/Utilities.lua" },
	{ name = "ErrorHandler", path = "Core/ErrorHandler.lua" },
	{ name = "EventManager", path = "Core/EventManager.lua" },
	{ name = "DependencyManager", path = "Core/DependencyManager.lua" },
	{ name = "Styling", path = "Core/Styling.lua" },
	{ name = "Animation", path = "Core/Animation.lua" },
	{ name = "UIElement", path = "UI/UIElement.lua" },
	{ name = "Draggable", path = "UI/Draggable.lua" },
	{ name = "WindowManager", path = "UI/WindowManager.lua" },
	{ name = "Taskbar", path = "UI/Taskbar.lua" },
	{ name = "Window", path = "Elements/Window.lua" },
	{ name = "TextButton", path = "Elements/TextButton.lua" },
	{ name = "ImageLabel", path = "Elements/ImageLabel.lua" },
	{ name = "Slider", path = "Elements/Slider.lua" },
	{ name = "Switch", path = "Elements/Switch.lua" },
	{ name = "Dropdown", path = "Elements/Dropdown.lua" },
	{ name = "Cluster", path = "Elements/Cluster.lua" },
	{ name = "Settings", path = "Elements/Settings.lua" }
}

for _, mod in ipairs(modules) do
	CensuraG[mod.name] = loadModule(baseUrl..mod.path, mod.name)
	CensuraG.Logger:debug("Loaded %s", mod.name)
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local playerGui = LocalPlayer:WaitForChild("PlayerGui",5)
if not playerGui then
	CensuraG.Logger:error("Failed to access PlayerGui")
	return CensuraG
end
CensuraG.ScreenGui = playerGui:FindFirstChild("CensuraGGui")
if not CensuraG.ScreenGui then
	CensuraG.ScreenGui = Utilities.createInstance("ScreenGui", {
		Parent = playerGui,
		Name = "CensuraGGui",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true
	})
end
CensuraG.Logger:info("ScreenGui initialized: %s", CensuraG.ScreenGui.Name)

if CensuraG.WindowManager then CensuraG.WindowManager:Init() end
if CensuraG.Taskbar then CensuraG.Taskbar:Init() end
if CensuraG.Settings then
	task.spawn(function()
		wait(0.5)
		CensuraG.Settings:Init()
		CensuraG.Logger:info("Settings menu auto-initialized")
	end)
end

CensuraG.Logger:info("CensuraG initialization completed successfully")

-- API for custom elements
function CensuraG.AddCustomElement(name, class)
	if not name or not class then
		CensuraG.Logger:warn("Invalid parameters for AddCustomElement")
		return
	end
	CensuraG[name] = class
	CensuraG.Logger:debug("Added custom element: %s", name)
end

function CensuraG.ToggleSettings()
	if CensuraG.Settings then
		CensuraG.Settings:Toggle()
	else
		CensuraG.Logger:warn("Settings module not loaded")
	end
end

function CensuraG.OpenSettings()
	if CensuraG.Settings then
		CensuraG.Settings:Show()
	else
		CensuraG.Logger:warn("Settings module not loaded")
	end
end

CensuraG.Config = {
	EnableShadows = true,
	AnimationQuality = 1.0,
	AnimationSpeed = 1.0,
	WindowSnapEnabled = true,
	DebugMode = false
}

function CensuraG.Destroy()
	CensuraG.Logger:info("Destroying CensuraG framework...")
	if CensuraG.EventManager then CensuraG.EventManager:DisconnectAll() end
	if CensuraG.WindowManager then CensuraG.WindowManager:Destroy() end
	if CensuraG.Taskbar then CensuraG.Taskbar:Destroy() end
	if CensuraG.ScreenGui then CensuraG.ScreenGui:Destroy() end
	CensuraG.Logger:info("CensuraG framework destroyed")
	_G.CensuraG = nil
end

CensuraG.Logger:info("CensuraG initialized")
return CensuraG
