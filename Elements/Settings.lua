-- Elements/Settings.lua
-- Enhanced settings menu for CensuraG with seamless updates

local Settings = {}
local logger = _G.CensuraG.Logger
local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager

Settings.Window = nil
Settings.Elements = {} -- Store UI elements for dynamic updates

-- Refresh all UI elements instantly
local function RefreshUI()
    Styling:UpdateAllElements()
    if _G.CensuraG.Taskbar then
        _G.CensuraG.Taskbar:RefreshCluster()
        for _, window in ipairs(_G.CensuraG.Taskbar.Windows) do
            if window.TaskbarButton then
                Styling:Apply(window.TaskbarButton, "TextButton")
            end
        end
    end
    logger:debug("UI refreshed")
end

function Settings:Init()
    if self.Window then
        logger:warn("Settings menu already initialized")
        return self
    end
    logger:info("Initializing Settings menu")
    local screenSize = Utilities.getScreenSize()
    local windowWidth, windowHeight = 500, 450 -- Larger for better organization
    local x = (screenSize.X - windowWidth) / 2
    local y = (screenSize.Y - windowHeight) / 2
    local window = _G.CensuraG.Window.new("Settings", x, y, windowWidth, windowHeight, { CanClose = false })
    -- Override Destroy to minimize instead of close
    local origDestroy = window.Destroy
    window.Destroy = function(self)
        if not self.Minimized then self:Minimize() end
        logger:debug("Settings window minimized instead of destroyed")
        return false
    end
    if window.MaximizeButton then
        window.MaximizeButton:Destroy()
        window.MaximizeButton = nil
        window.MinimizeButton.Position = UDim2.new(1, -19, 0, 3)
    end
    self.Window = window
    self:CreateSettingsContent(window)
    logger:info("Settings menu initialized")
    return self
end

function Settings:CreateSettingsContent(window)
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
        Size = UDim2.new(1, -130, 1, -10),
        BackgroundTransparency = 1,
        ZIndex = window.ContentContainer.ZIndex + 1,
        Name = "ContentContainer"
    })
    
    local tabs = {
        { Name = "General", Icon = "⚙️" },
        { Name = "Appearance", Icon = "🎨" },
        { Name = "Performance", Icon = "⚡" },
        { Name = "About", Icon = "ℹ️" }
    }
    local contentFrames = {}
    
    for i, tab in ipairs(tabs) do
        local tabButton = Utilities.createInstance("TextButton", {
            Parent = tabContainer,
            Position = UDim2.new(0, 5, 0, (i-1)*45+5),
            Size = UDim2.new(1, -10, 0, 40),
            Text = tab.Icon.." "..tab.Name,
            TextSize = 16,
            ZIndex = tabContainer.ZIndex + 1,
            Name = "Tab_"..tab.Name
        })
        Styling:Apply(tabButton, "TextButton")
        Animation:HoverEffect(tabButton)
        
        local contentFrame = Utilities.createInstance("Frame", {
            Parent = contentContainer,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = i == 1,
            ZIndex = contentContainer.ZIndex + 1,
            Name = "Content_"..tab.Name
        })
        contentFrames[tab.Name] = contentFrame
        
        tabButton.MouseButton1Click:Connect(function()
            for _, cf in pairs(contentFrames) do cf.Visible = false end
            contentFrame.Visible = true
            Animation:Elastic(tabButton, { Size = UDim2.new(1, -10, 0, 40 * 1.05) }, 0.5, function()
                Animation:Tween(tabButton, { Size = UDim2.new(1, -10, 0, 40) }, 0.2)
            end)
            logger:debug("Switched to tab: %s", tab.Name)
        end)
        self:PopulateTabContent(tab.Name, contentFrame)
    end
    
    self.TabContainer = tabContainer
    self.ContentContainer = contentContainer
    self.ContentFrames = contentFrames
    logger:debug("Settings content created with %d tabs", #tabs)
end

function Settings:PopulateTabContent(tabName, contentFrame)
    if tabName == "General" then
        local title = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -20, 0, 25),
            Text = "General Settings",
            TextSize = 20,
            Font = Enum.Font.GothamBold,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "Title"
        })
        Styling:Apply(title, "TextLabel")
        
        -- Window Management Section
        local windowHeader = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 40),
            Size = UDim2.new(1, -20, 0, 20),
            Text = "Window Management",
            TextSize = 16,
            Font = Enum.Font.GothamSemibold,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "WindowHeader"
        })
        Styling:Apply(windowHeader, "TextLabel")
        
        self.Elements.WindowSnapSwitch = _G.CensuraG.Switch.new({ Instance = contentFrame }, 10, 70, 40, 20, _G.CensuraG.Config.WindowSnapEnabled, {
            LabelText = "Window Snap",
            ShowLabel = true,
            OnToggled = function(state)
                _G.CensuraG.Config.WindowSnapEnabled = state
                logger:info("Window Snap %s", state and "enabled" or "disabled")
                RefreshUI()
            end
        })
        
        self.Elements.AutoHideSwitch = _G.CensuraG.Switch.new({ Instance = contentFrame }, 10, 110, 40, 20, _G.CensuraG.Taskbar.AutoHideEnabled, {
            LabelText = "Taskbar Auto-Hide",
            ShowLabel = true,
            OnToggled = function(state)
                _G.CensuraG.Taskbar:SetAutoHide(state)
                _G.CensuraG.Taskbar.AutoHideEnabled = state
                logger:info("Taskbar Auto-Hide %s", state and "enabled" or "disabled")
                RefreshUI()
            end
        })
        
        -- Debugging Section
        local debugHeader = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 150),
            Size = UDim2.new(1, -20, 0, 20),
            Text = "Debugging",
            TextSize = 16,
            Font = Enum.Font.GothamSemibold,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "DebugHeader"
        })
        Styling:Apply(debugHeader, "TextLabel")
        
        self.Elements.DebugSwitch = _G.CensuraG.Switch.new({ Instance = contentFrame }, 10, 180, 40, 20, _G.CensuraG.Config.DebugMode, {
            LabelText = "Debug Mode",
            ShowLabel = true,
            OnToggled = function(state)
                _G.CensuraG.Config.DebugMode = state
                _G.CensuraG.Logger.minLevel = state and 1 or 2 -- DEBUG or INFO
                logger:info("Debug Mode %s", state and "enabled" or "disabled")
                RefreshUI()
            end
        })
        
    elseif tabName == "Appearance" then
        local title = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -20, 0, 25),
            Text = "Appearance Settings",
            TextSize = 20,
            Font = Enum.Font.GothamBold,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "Title"
        })
        Styling:Apply(title, "TextLabel")
        
        -- Theme Section
        local themeHeader = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 40),
            Size = UDim2.new(1, -20, 0, 20),
            Text = "Theme",
            TextSize = 16,
            Font = Enum.Font.GothamSemibold,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "ThemeHeader"
        })
        Styling:Apply(themeHeader, "TextLabel")
        
        local themeOptions = {}
        for themeName in pairs(Styling.Themes) do
            table.insert(themeOptions, themeName)
        end
        self.Elements.ThemeDropdown = _G.CensuraG.Dropdown.new({ Instance = contentFrame }, 10, 70, 250, {
            LabelText = "Theme",
            Items = themeOptions,
            defaultSelection = Styling.CurrentTheme,
            Callback = function(selected)
                Styling:SetTheme(selected)
                _G.CensuraG.Styling.CurrentTheme = selected -- Update global table
                RefreshUI()
                logger:info("Theme set to %s", selected)
            end
        })
        
        self.Elements.ShadowSwitch = _G.CensuraG.Switch.new({ Instance = contentFrame }, 10, 110, 40, 20, _G.CensuraG.Config.EnableShadows, {
            LabelText = "Enable Shadows",
            ShowLabel = true,
            OnToggled = function(state)
                _G.CensuraG.Config.EnableShadows = state
                -- Toggle shadow visibility (requires implementation in Window.lua)
                for _, window in ipairs(_G.CensuraG.WindowManager.Windows) do
                    if window.Shadow then
                        window.Shadow.Visible = state
                    end
                end
                logger:info("Shadows %s", state and "enabled" or "disabled")
                RefreshUI()
            end
        })
        
        -- Transparency Section
        local transHeader = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 150),
            Size = UDim2.new(1, -20, 0, 20),
            Text = "Transparency",
            TextSize = 16,
            Font = Enum.Font.GothamSemibold,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "TransHeader"
        })
        Styling:Apply(transHeader, "TextLabel")
        
        self.Elements.WindowTransSlider = _G.CensuraG.Slider.new({ Instance = contentFrame }, 10, 180, 250, 0, 1, Styling.Transparency.WindowBackground, {
            LabelText = "Window",
            ShowValue = true,
            Step = 0.05,
            OnChanged = function(value)
                _G.CensuraG.Styling.Transparency.WindowBackground = value
                RefreshUI()
                logger:info("Window transparency set to %.2f", value)
            end
        })
        
        self.Elements.ElementTransSlider = _G.CensuraG.Slider.new({ Instance = contentFrame }, 10, 220, 250, 0, 1, Styling.Transparency.ElementBackground, {
            LabelText = "Elements",
            ShowValue = true,
            Step = 0.05,
            OnChanged = function(value)
                _G.CensuraG.Styling.Transparency.ElementBackground = value
                RefreshUI()
                logger:info("Element transparency set to %.2f", value)
            end
        })
        
        -- Text Section
        local textHeader = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 260),
            Size = UDim2.new(1, -20, 0, 20),
            Text = "Text",
            TextSize = 16,
            Font = Enum.Font.GothamSemibold,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "TextHeader"
        })
        Styling:Apply(textHeader, "TextLabel")
        
        self.Elements.TextSizeSlider = _G.CensuraG.Slider.new({ Instance = contentFrame }, 10, 290, 250, 12, 24, Styling.TextSizes.Button, {
            LabelText = "Size",
            ShowValue = true,
            Step = 1,
            OnChanged = function(value)
                _G.CensuraG.Styling.TextSizes.Title = value + 2
                _G.CensuraG.Styling.TextSizes.Label = value
                _G.CensuraG.Styling.TextSizes.Button = value
                RefreshUI()
                logger:info("Text size set to %d", value)
            end
        })
        
    elseif tabName == "Performance" then
        local title = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -20, 0, 25),
            Text = "Performance Settings",
            TextSize = 20,
            Font = Enum.Font.GothamBold,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "Title"
        })
        Styling:Apply(title, "TextLabel")
        
        -- Animation Section
        local animHeader = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 40),
            Size = UDim2.new(1, -20, 0, 20),
            Text = "Animations",
            TextSize = 16,
            Font = Enum.Font.GothamSemibold,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "AnimHeader"
        })
        Styling:Apply(animHeader, "TextLabel")
        
        self.Elements.AnimQualitySlider = _G.CensuraG.Slider.new({ Instance = contentFrame }, 10, 70, 250, 0.1, 1, _G.CensuraG.Config.AnimationQuality, {
            LabelText = "Quality",
            ShowValue = true,
            Step = 0.1,
            OnChanged = function(value)
                _G.CensuraG.Config.AnimationQuality = value
                logger:info("Animation quality set to %.1f", value)
                RefreshUI()
            end
        })
        
        self.Elements.AnimSpeedSlider = _G.CensuraG.Slider.new({ Instance = contentFrame }, 10, 110, 250, 0.5, 2, _G.CensuraG.Config.AnimationSpeed, {
            LabelText = "Speed",
            ShowValue = true,
            Step = 0.1,
            OnChanged = function(value)
                _G.CensuraG.Config.AnimationSpeed = value
                logger:info("Animation speed set to %.1f", value)
                RefreshUI()
            end
        })
        
        -- Window Management Section
        local windowHeader = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 150),
            Size = UDim2.new(1, -20, 0, 20),
            Text = "Window Management",
            TextSize = 16,
            Font = Enum.Font.GothamSemibold,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "WindowHeader"
        })
        Styling:Apply(windowHeader, "TextLabel")
        
        self.Elements.ClearButton = _G.CensuraG.TextButton.new({ Instance = contentFrame }, "Clear All Windows", 10, 180, 150, 30, function()
            _G.CensuraG.WindowManager:CloseAllWindows()
            logger:info("All windows cleared")
            RefreshUI()
        end)
        
    elseif tabName == "About" then
        local title = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -20, 0, 25),
            Text = "About CensuraG",
            TextSize = 20,
            Font = Enum.Font.GothamBold,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "Title"
        })
        Styling:Apply(title, "TextLabel")
        
        self.Elements.VersionLabel = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 50),
            Size = UDim2.new(1, -20, 0, 20),
            Text = "Version: " .. _G.CensuraG._VERSION,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "Version"
        })
        Styling:Apply(self.Elements.VersionLabel, "TextLabel")
        
        self.Elements.DescLabel = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 80),
            Size = UDim2.new(1, -20, 0, 40),
            Text = _G.CensuraG._DESCRIPTION,
            TextWrapped = true,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "Description"
        })
        Styling:Apply(self.Elements.DescLabel, "TextLabel")
        
        self.Elements.LicenseLabel = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 130),
            Size = UDim2.new(1, -20, 0, 20),
            Text = "License: " .. _G.CensuraG._LICENSE,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "License"
        })
        Styling:Apply(self.Elements.LicenseLabel, "TextLabel")
    end
    logger:debug("Populated tab content for: %s", tabName)
end

function Settings:Show()
    if not self.Window then self:Init() end
    if self.Window.Minimized then self.Window:Restore() end
    -- Update all elements to reflect current settings
    self:RefreshSettings()
    logger:info("Settings shown")
end

function Settings:Toggle()
    if not self.Window then self:Init(); return end
    if self.Window.Minimized then 
        self.Window:Restore()
        self:RefreshSettings()
    else 
        self.Window:Minimize() 
    end
    logger:info("Settings toggled")
end

function Settings:RefreshSettings()
    if not self.Elements then return end
    -- General Tab
    if self.Elements.WindowSnapSwitch then
        self.Elements.WindowSnapSwitch:Toggle(_G.CensuraG.Config.WindowSnapEnabled)
    end
    if self.Elements.AutoHideSwitch then
        self.Elements.AutoHideSwitch:Toggle(_G.CensuraG.Taskbar.AutoHideEnabled)
    end
    if self.Elements.DebugSwitch then
        self.Elements.DebugSwitch:Toggle(_G.CensuraG.Config.DebugMode)
    end
    -- Appearance Tab
    if self.Elements.ThemeDropdown then
        self.Elements.ThemeDropdown:SelectItem(_G.CensuraG.Styling.CurrentTheme)
    end
    if self.Elements.ShadowSwitch then
        self.Elements.ShadowSwitch:Toggle(_G.CensuraG.Config.EnableShadows)
    end
    if self.Elements.WindowTransSlider then
        self.Elements.WindowTransSlider:UpdateValue(_G.CensuraG.Styling.Transparency.WindowBackground, false)
    end
    if self.Elements.ElementTransSlider then
        self.Elements.ElementTransSlider:UpdateValue(_G.CensuraG.Styling.Transparency.ElementBackground, false)
    end
    if self.Elements.TextSizeSlider then
        self.Elements.TextSizeSlider:UpdateValue(_G.CensuraG.Styling.TextSizes.Button, false)
    end
    -- Performance Tab
    if self.Elements.AnimQualitySlider then
        self.Elements.AnimQualitySlider:UpdateValue(_G.CensuraG.Config.AnimationQuality, false)
    end
    if self.Elements.AnimSpeedSlider then
        self.Elements.AnimSpeedSlider:UpdateValue(_G.CensuraG.Config.AnimationSpeed, false)
    end
    -- About Tab (static, no refresh needed)
    logger:debug("Settings refreshed to reflect current state")
end

return Settings
