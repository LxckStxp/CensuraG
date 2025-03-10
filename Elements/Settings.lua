-- Elements/Settings.lua
-- Simplified settings menu with improved layout and element organization

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
    local windowWidth, windowHeight = 450, 350
    local x = (screenSize.X - windowWidth) / 2
    local y = (screenSize.Y - windowHeight) / 2
    local window = _G.CensuraG.Window.new("Settings", x, y, windowWidth, windowHeight, { CanClose = false })
    
    -- Override destroy to minimize instead
    local origDestroy = window.Destroy
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
    
    if self.UIElements["TransparencySlider"] then
        self.UIElements["TransparencySlider"]:UpdateValue(_G.CensuraG.Config.WindowTransparency, false)
    end
    
    if self.UIElements["AnimSpeedSlider"] then
        self.UIElements["AnimSpeedSlider"]:UpdateValue(_G.CensuraG.Config.AnimationSpeed, false)
    end
    
    logger:debug("Synced Settings UI with Config")
end

function Settings:CreateSettingsContent(window)
    -- Create tab structure
    local tabContainer = Utilities.createInstance("Frame", {
        Parent = window.ContentContainer,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 0.8,
        ZIndex = window.ContentContainer.ZIndex + 1,
        Name = "TabContainer"
    })
    Styling:Apply(tabContainer, "Frame")
    
    local contentContainer = Utilities.createInstance("Frame", {
        Parent = window.ContentContainer,
        Position = UDim2.new(0, 125, 0, 0),
        Size = UDim2.new(1, -130, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = window.ContentContainer.ZIndex + 1,
        Name = "ContentContainer"
    })
    
    -- Define tabs
    local tabs = {
        { Name = "General", Icon = "⚙️" },
        { Name = "Theme", Icon = "🎨" },
        { Name = "Performance", Icon = "⚡" },
        { Name = "About", Icon = "ℹ️" }
    }
    
    local contentFrames = {}
    local tabButtons = {}
    
    -- Create tab buttons and content frames
    for i, tab in ipairs(tabs) do
        local tabButton = Utilities.createInstance("TextButton", {
            Parent = tabContainer,
            Position = UDim2.new(0, 5, 0, (i-1)*40+5),
            Size = UDim2.new(1, -10, 0, 35),
            Text = tab.Icon.." "..tab.Name,
            TextSize = 14,
            ZIndex = tabContainer.ZIndex + 1,
            Name = "Tab_"..tab.Name
        })
        Styling:Apply(tabButton, "TextButton")
        Animation:HoverEffect(tabButton)
        tabButtons[tab.Name] = tabButton
        
        local contentFrame = Utilities.createInstance("ScrollingFrame", {
            Parent = contentContainer,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            CanvasSize = UDim2.new(1, -10, 2, 0), -- Allow scrolling
            Visible = i == 1,
            ZIndex = contentContainer.ZIndex + 1,
            Name = "Content_"..tab.Name
        })
        
        -- Add padding for content
        local padding = Utilities.createInstance("UIPadding", {
            Parent = contentFrame,
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        })
        
        contentFrames[tab.Name] = contentFrame
        
        -- Handle tab switching
        tabButton.MouseButton1Click:Connect(function()
            -- Update visual state of tabs
            for name, btn in pairs(tabButtons) do
                btn.BackgroundColor3 = name == tab.Name 
                    and Styling.Colors.Accent 
                    or Styling.Colors.Secondary
            end
            
            -- Show selected content
            for _, cf in pairs(contentFrames) do 
                cf.Visible = false 
            end
            contentFrame.Visible = true
            
            -- Animation effect
            Animation:Elastic(tabButton, { Size = UDim2.new(1, -10, 0, 35 * 1.05) }, 0.5, function()
                Animation:Tween(tabButton, { Size = UDim2.new(1, -10, 0, 35) }, 0.2)
            end)
            
            logger:debug("Switched to tab: %s", tab.Name)
        end)
        
        -- Make first tab appear selected
        if i == 1 then
            tabButton.BackgroundColor3 = Styling.Colors.Accent
        end
    end
    
    self.TabContainer = tabContainer
    self.ContentContainer = contentContainer
    self.ContentFrames = contentFrames
    
    -- Populate tab content
    for name, frame in pairs(contentFrames) do
        self:PopulateTabContent(name, frame)
    end
    
    logger:debug("Settings content created with %d tabs", #tabs)
end

function Settings:CreateSettingSection(parent, title, yPosition)
    -- Create a section with title
    local section = Utilities.createInstance("Frame", {
        Parent = parent,
        Position = UDim2.new(0, 0, 0, yPosition),
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = parent.ZIndex + 1,
        Name = "Section_" .. title
    })
    
    local titleLabel = Utilities.createInstance("TextLabel", {
        Parent = section,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 25),
        Text = title,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = section.ZIndex + 1,
        Name = "Title"
    })
    Styling:Apply(titleLabel, "TextLabel")
    
    -- Add a separator line
    local separator = Utilities.createInstance("Frame", {
        Parent = section,
        Position = UDim2.new(0, 0, 0, 25),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Styling.Colors.Accent,
        BackgroundTransparency = 0.7,
        ZIndex = section.ZIndex + 1,
        Name = "Separator"
    })
    
    return section
}

function Settings:PopulateTabContent(tabName, contentFrame)
    if tabName == "General" then
        -- General settings
        local generalSection = self:CreateSettingSection(contentFrame, "General Settings", 10)
        
        -- Description text
        local description = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 0, 0, 50),
            Size = UDim2.new(1, 0, 0, 40),
            Text = "Configure general behavior of the interface.",
            TextWrapped = true,
            TextSize = 14,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "Description"
        })
        Styling:Apply(description, "TextLabel")
        
        -- Taskbar Auto-Hide switch with better layout
        local autoHideSwitch = _G.CensuraG.Switch.new(
            { Instance = contentFrame }, 10, 100, 40, 20, _G.CensuraG.Config.AutoHide,
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
        
        -- Add description for auto-hide
        local autoHideDesc = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 130),
            Size = UDim2.new(1, -20, 0, 40),
            Text = "When enabled, the taskbar will hide automatically and appear when you move your mouse to the bottom of the screen.",
            TextWrapped = true,
            TextSize = 12,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Styling.Colors.Text,
            TextTransparency = 0.3,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "AutoHideDescription"
        })
        
    elseif tabName == "Theme" then
        -- Theme settings
        local themeSection = self:CreateSettingSection(contentFrame, "Theme Settings", 10)
        
        -- Description
        local description = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 0, 0, 50),
            Size = UDim2.new(1, 0, 0, 40),
            Text = "Customize the appearance of the interface.",
            TextWrapped = true,
            TextSize = 14,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "Description"
        })
        Styling:Apply(description, "TextLabel")
        
        -- Theme dropdown with better layout
        local themeDropdown = _G.CensuraG.Dropdown.new(
            { Instance = contentFrame }, 10, 100, 250,
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
        
        -- Window transparency slider
        local transparencySlider = _G.CensuraG.Slider.new(
            { Instance = contentFrame }, 10, 160, 250, 0, 1, _G.CensuraG.Config.WindowTransparency,
            { 
                LabelText = "Window Transparency", 
                ShowValue = true,
                Step = 0.05,
                OnChanged = function(value)
                    _G.CensuraG.Config.WindowTransparency = value
                    Styling.Transparency.WindowBackground = value
                    Styling:UpdateAllElements()
                end 
            }
        )
        self.UIElements["TransparencySlider"] = transparencySlider
        
        -- Theme preview (optional)
        local previewLabel = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 0, 0, 210),
            Size = UDim2.new(1, 0, 0, 20),
            Text = "Preview:",
            TextSize = 14,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "PreviewLabel"
        })
        Styling:Apply(previewLabel, "TextLabel")
        
        local previewFrame = Utilities.createInstance("Frame", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 235),
            Size = UDim2.new(0, 250, 0, 80),
            BackgroundColor3 = Styling.Colors.Base,
            BackgroundTransparency = Styling.Transparency.WindowBackground,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "ThemePreview"
        })
        Styling:Apply(previewFrame, "Frame")
        
    elseif tabName == "Performance" then
        -- Performance settings
        local perfSection = self:CreateSettingSection(contentFrame, "Performance Settings", 10)
        
        -- Description
        local description = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 0, 0, 50),
            Size = UDim2.new(1, 0, 0, 40),
            Text = "Adjust performance-related settings.",
            TextWrapped = true,
            TextSize = 14,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "Description"
        })
        Styling:Apply(description, "TextLabel")
        
        -- Animation speed slider with better layout
        local animSpeedSlider = _G.CensuraG.Slider.new(
            { Instance = contentFrame }, 10, 100, 250, 0.5, 2, _G.CensuraG.Config.AnimationSpeed,
            { 
                LabelText = "Animation Speed", 
                Step = 0.1, 
                ShowValue = true,
                OnChanged = function(value)
                    _G.CensuraG.Config.AnimationSpeed = value
                end 
            }
        )
        self.UIElements["AnimSpeedSlider"] = animSpeedSlider
        
        -- Add description for animation speed
        local animSpeedDesc = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 130),
            Size = UDim2.new(1, -20, 0, 40),
            Text = "Higher values make animations faster. Lower values make animations slower but smoother.",
            TextWrapped = true,
            TextSize = 12,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Styling.Colors.Text,
            TextTransparency = 0.3,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "AnimSpeedDescription"
        })
        
    elseif tabName == "About" then
        -- About section
        local aboutSection = self:CreateSettingSection(contentFrame, "About CensuraG", 10)
        
        -- Version info
        local version = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 0, 0, 50),
            Size = UDim2.new(1, 0, 0, 20),
            Text = "Version: " .. _G.CensuraG._VERSION,
            TextSize = 14,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "Version"
        })
        Styling:Apply(version, "TextLabel")
        
        -- Description
        local description = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 0, 0, 80),
            Size = UDim2.new(1, 0, 0, 60),
            Text = _G.CensuraG._DESCRIPTION or "Modern UI framework for Roblox",
            TextWrapped = true,
            TextSize = 14,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "Description"
        })
        Styling:Apply(description, "TextLabel")
        
        -- Credits
        local credits = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 0, 0, 150),
            Size = UDim2.new(1, 0, 0, 20),
            Text = "Created by LxckStxp",
            TextSize = 14,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "Credits"
        })
        Styling:Apply(credits, "TextLabel")
        
        -- License
        if _G.CensuraG._LICENSE then
            local license = Utilities.createInstance("TextLabel", {
                Parent = contentFrame,
                Position = UDim2.new(0, 0, 0, 180),
                Size = UDim2.new(1, 0, 0, 20),
                Text = "License: " .. _G.CensuraG._LICENSE,
                TextSize = 14,
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = contentFrame.ZIndex + 1,
                Name = "License"
            })
            Styling:Apply(license, "TextLabel")
        end
    end
    
    logger:debug("Populated tab content for: %s", tabName)
}

function Settings:Show()
    if not self.Window then self:Init() end
    if self.Window.Minimized then self.Window:Restore() end
    self:SyncUIWithConfig()
    logger:info("Settings shown")
}

function Settings:Toggle()
    if not self.Window then self:Init(); return end
    if self.Window.Minimized then 
        self.Window:Restore() 
        self:SyncUIWithConfig()
    else 
        self.Window:Minimize() 
    end
    logger:info("Settings toggled")
}

return Settings
