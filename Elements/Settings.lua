-- Elements/Settings.lua
-- Simple settings menu with only essential options

local Settings = {}
local logger = _G.CensuraG.Logger
local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager

Settings.Window = nil
Settings.UIElements = {} -- Store references to UI elements

function Settings:Init()
    if self.Window then
        logger:warn("Settings menu already initialized")
        return self
    end
    
    logger:info("Initializing Settings menu")
    local screenSize = Utilities.getScreenSize()
    local windowWidth, windowHeight = 350, 250
    local x = (screenSize.X - windowWidth) / 2
    local y = (screenSize.Y - windowHeight) / 2
    
    local window = _G.CensuraG.Window.new("Settings", x, y, windowWidth, windowHeight, { CanClose = false })
    
    -- Override destroy to minimize instead
    window.Destroy = function(self)
        if not self.Minimized then self:Minimize() end
        logger:debug("Settings window minimized instead of destroyed")
        return false
    end
    
    -- Remove maximize button
    if window.MaximizeButton then
        window.MaximizeButton:Destroy()
        window.MaximizeButton = nil
        window.MinimizeButton.Position = UDim2.new(1, -19, 0, 3)
    end
    
    self.Window = window
    self:CreateSettingsContent(window)
    self:SyncUIWithConfig()
    logger:info("Settings menu initialized")
    return self
end

function Settings:SyncUIWithConfig()
    -- Use stored references for UI elements
    if self.UIElements["AutoHideSwitch"] then
        self.UIElements["AutoHideSwitch"]:Toggle(_G.CensuraG.Config.AutoHide)
    end
    
    if self.UIElements["ThemeDropdown"] then
        self.UIElements["ThemeDropdown"]:SelectItem(_G.CensuraG.Config.Theme)
    end
    
    logger:debug("Synced Settings UI with Config")
end

function Settings:CreateSettingsContent(window)
    -- Create content container
    local contentFrame = Utilities.createInstance("Frame", {
        Parent = window.ContentContainer,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = window.ContentContainer.ZIndex + 1,
        Name = "ContentFrame"
    })
    
    -- Add padding
    local padding = Utilities.createInstance("UIPadding", {
        Parent = contentFrame,
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        PaddingTop = UDim.new(0, 15),
        PaddingBottom = UDim.new(0, 15)
    })
    
    -- Title
    local title = Utilities.createInstance("TextLabel", {
        Parent = contentFrame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 30),
        Text = "Settings",
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = contentFrame.ZIndex + 1,
        Name = "Title"
    })
    Styling:Apply(title, "TextLabel")
    
    -- Separator
    local separator = Utilities.createInstance("Frame", {
        Parent = contentFrame,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Styling.Colors.Accent,
        BackgroundTransparency = 0.7,
        ZIndex = contentFrame.ZIndex + 1,
        Name = "Separator"
    })
    
    -- 1. Taskbar Auto-Hide switch
    local autoHideSwitch = _G.CensuraG.Switch.new(
        { Instance = contentFrame }, 10, 50, 40, 20, _G.CensuraG.Config.AutoHide,
        { 
            LabelText = "Taskbar Auto-Hide", 
            ShowLabel = true,
            OnToggled = function(state)
                _G.CensuraG.Config.AutoHide = state
                if _G.CensuraG.Taskbar then
                    _G.CensuraG.Taskbar:SetAutoHide(state)
                end
            end 
        }
    )
    self.UIElements["AutoHideSwitch"] = autoHideSwitch
    
    -- 2. Theme dropdown
    local themeDropdown = _G.CensuraG.Dropdown.new(
        { Instance = contentFrame }, 10, 100, 200,
        { 
            Items = {"Dark", "Light", "Military"}, 
            LabelText = "Theme" 
        },
        _G.CensuraG.Config.Theme, 
        function(theme)
            _G.CensuraG.Config.Theme = theme
            Styling:SetTheme(theme)
            Styling:UpdateAllElements()
        end
    )
    self.UIElements["ThemeDropdown"] = themeDropdown
    
    -- Version info at bottom
    local version = Utilities.createInstance("TextLabel", {
        Parent = contentFrame,
        Position = UDim2.new(0, 0, 1, -25),
        Size = UDim2.new(1, 0, 0, 20),
        Text = "CensuraG v" .. _G.CensuraG._VERSION,
        TextSize = 12,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextColor3 = Styling.Colors.Text,
        TextTransparency = 0.3,
        ZIndex = contentFrame.ZIndex + 1,
        Name = "Version"
    })
    
    logger:debug("Settings content created with essential options")
    return contentFrame
end

function Settings:Show()
    if not self.Window then self:Init() end
    if self.Window.Minimized then self.Window:Restore() end
    self:SyncUIWithConfig()
    logger:info("Settings shown")
end

function Settings:Toggle()
    if not self.Window then self:Init(); return end
    if self.Window.Minimized then 
        self.Window:Restore() 
        self:SyncUIWithConfig()
    else 
        self.Window:Minimize() 
    end
    logger:info("Settings toggled")
end

return Settings
