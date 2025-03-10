-- Elements/Settings.lua
-- Persistent settings menu with comprehensive CensuraG settings

local Settings = {}
local logger = _G.CensuraG.Logger
local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager

Settings.Window = nil

function Settings:Init()
    if self.Window then
        logger:warn("Settings menu already initialized")
        return self
    end
    logger:info("Initializing Settings menu")
    local screenSize = Utilities.getScreenSize()
    local windowWidth, windowHeight = 450, 400 -- Adjusted for more content
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
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundTransparency = 0.8,
        ZIndex = window.ContentContainer.ZIndex + 1,
        Name = "TabContainer"
    })
    Styling:Apply(tabContainer, "Frame")
    
    local contentContainer = Utilities.createInstance("Frame", {
        Parent = window.ContentContainer,
        Position = UDim2.new(0, 105, 0, 0),
        Size = UDim2.new(1, -110, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = window.ContentContainer.ZIndex + 1,
        Name = "ContentContainer"
    })
    
    local tabs = {
        { Name = "General", Icon = "⚙️" },
        { Name = "Theme", Icon = "🎨" },
        { Name = "Performance", Icon = "⚡" },
        { Name = "About", Icon = "ℹ️" }
    }
    local contentFrames = {}
    
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
            Animation:Elastic(tabButton, { Size = UDim2.new(1, -10, 0, 35 * 1.05) }, 0.5, function()
                Animation:Tween(tabButton, { Size = UDim2.new(1, -10, 0, 35) }, 0.2)
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
            Size = UDim2.new(1, -20, 0, 30),
            Text = "General Settings",
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "Title"
        })
        Styling:Apply(title, "TextLabel")
        
        -- Enable Shadows Switch
        local shadowSwitch = _G.CensuraG.Switch.new({ Instance = contentFrame }, 10, 50, 40, 20, _G.CensuraG.Config.EnableShadows, {
            LabelText = "Enable Shadows",
            ShowLabel = true,
            OnToggled = function(state)
                _G.CensuraG.Config.EnableShadows = state
                logger:info("Shadows %s", state and "enabled" or "disabled")
            end
        })
        
        -- Window Snap Switch
        local snapSwitch = _G.CensuraG.Switch.new({ Instance = contentFrame }, 10, 90, 40, 20, _G.CensuraG.Config.WindowSnapEnabled, {
            LabelText = "Window Snap",
            ShowLabel = true,
            OnToggled = function(state)
                _G.CensuraG.Config.WindowSnapEnabled = state
                logger:info("Window Snap %s", state and "enabled" or "disabled")
            end
        })
        
        -- Debug Mode Switch
        local debugSwitch = _G.CensuraG.Switch.new({ Instance = contentFrame }, 10, 130, 40, 20, _G.CensuraG.Config.DebugMode, {
            LabelText = "Debug Mode",
            ShowLabel = true,
            OnToggled = function(state)
                _G.CensuraG.Config.DebugMode = state
                _G.CensuraG.Logger.minLevel = state and 1 or 2 -- DEBUG or INFO
                logger:info("Debug Mode %s", state and "enabled" or "disabled")
            end
        })
        
        -- Taskbar Auto-Hide Switch
        local autoHideSwitch = _G.CensuraG.Switch.new({ Instance = contentFrame }, 10, 170, 40, 20, _G.CensuraG.Taskbar.AutoHideEnabled, {
            LabelText = "Taskbar Auto-Hide",
            ShowLabel = true,
            OnToggled = function(state)
                _G.CensuraG.Taskbar:SetAutoHide(state)
            end
        })
        
    elseif tabName == "Theme" then
        local title = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -20, 0, 30),
            Text = "Theme Settings",
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "Title"
        })
        Styling:Apply(title, "TextLabel")
        
        -- Theme Dropdown
        local themeOptions = {}
        for themeName in pairs(Styling.Themes) do
            table.insert(themeOptions, themeName)
        end
        local themeDropdown = _G.CensuraG.Dropdown.new({ Instance = contentFrame }, 10, 50, 200, {
            LabelText = "Theme",
            Items = themeOptions,
            defaultSelection = Styling.CurrentTheme,
            Callback = function(selected)
                Styling:SetTheme(selected)
                Styling:UpdateAllElements()
                logger:info("Theme set to %s", selected)
            end
        })
        
        -- Window Transparency Slider
        local windowTransSlider = _G.CensuraG.Slider.new({ Instance = contentFrame }, 10, 90, 200, 0, 1, Styling.Transparency.WindowBackground, {
            LabelText = "Window Trans",
            ShowValue = true,
            Step = 0.05,
            OnChanged = function(value)
                Styling.Transparency.WindowBackground = value
                Styling:UpdateAllElements()
                logger:info("Window transparency set to %.2f", value)
            end
        })
        
        -- Element Transparency Slider
        local elementTransSlider = _G.CensuraG.Slider.new({ Instance = contentFrame }, 10, 130, 200, 0, 1, Styling.Transparency.ElementBackground, {
            LabelText = "Element Trans",
            ShowValue = true,
            Step = 0.05,
            OnChanged = function(value)
                Styling.Transparency.ElementBackground = value
                Styling:UpdateAllElements()
                logger:info("Element transparency set to %.2f", value)
            end
        })
        
        -- Text Size Slider
        local textSizeSlider = _G.CensuraG.Slider.new({ Instance = contentFrame }, 10, 170, 200, 12, 24, Styling.TextSizes.Button, {
            LabelText = "Text Size",
            ShowValue = true,
            Step = 1,
            OnChanged = function(value)
                Styling.TextSizes.Title = value + 2
                Styling.TextSizes.Label = value
                Styling.TextSizes.Button = value
                Styling:UpdateAllElements()
                logger:info("Text size set to %d", value)
            end
        })
        
    elseif tabName == "Performance" then
        local title = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -20, 0, 30),
            Text = "Performance Settings",
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "Title"
        })
        Styling:Apply(title, "TextLabel")
        
        -- Animation Quality Slider
        local animQualitySlider = _G.CensuraG.Slider.new({ Instance = contentFrame }, 10, 50, 200, 0.1, 1, _G.CensuraG.Config.AnimationQuality, {
            LabelText = "Anim Quality",
            ShowValue = true,
            Step = 0.1,
            OnChanged = function(value)
                _G.CensuraG.Config.AnimationQuality = value
                logger:info("Animation quality set to %.1f", value)
            end
        })
        
        -- Animation Speed Slider
        local animSpeedSlider = _G.CensuraG.Slider.new({ Instance = contentFrame }, 10, 90, 200, 0.5, 2, _G.CensuraG.Config.AnimationSpeed, {
            LabelText = "Anim Speed",
            ShowValue = true,
            Step = 0.1,
            OnChanged = function(value)
                _G.CensuraG.Config.AnimationSpeed = value
                logger:info("Animation speed set to %.1f", value)
            end
        })
        
        -- Clear All Windows Button
        local clearButton = _G.CensuraG.TextButton.new({ Instance = contentFrame }, "Clear All Windows", 10, 130, 150, 30, function()
            _G.CensuraG.WindowManager:CloseAllWindows()
            logger:info("All windows cleared")
        end)
        
    elseif tabName == "About" then
        local title = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 10),
            Size = UDim2.new(1, -20, 0, 30),
            Text = "About CensuraG",
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "Title"
        })
        Styling:Apply(title, "TextLabel")
        
        local versionLabel = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 50),
            Size = UDim2.new(1, -20, 0, 20),
            Text = "Version: " .. _G.CensuraG._VERSION,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "Version"
        })
        Styling:Apply(versionLabel, "TextLabel")
        
        local descLabel = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 80),
            Size = UDim2.new(1, -20, 0, 40),
            Text = _G.CensuraG._DESCRIPTION,
            TextWrapped = true,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "Description"
        })
        Styling:Apply(descLabel, "TextLabel")
        
        local licenseLabel = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 130),
            Size = UDim2.new(1, -20, 0, 20),
            Text = "License: " .. _G.CensuraG._LICENSE,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "License"
        })
        Styling:Apply(licenseLabel, "TextLabel")
    end
    logger:debug("Populated tab content for: %s", tabName)
end

function Settings:Show()
    if not self.Window then self:Init() end
    if self.Window.Minimized then self.Window:Restore() end
    logger:info("Settings shown")
end

function Settings:Toggle()
    if not self.Window then self:Init(); return end
    if self.Window.Minimized then self.Window:Restore() else self.Window:Minimize() end
    logger:info("Settings toggled")
end

return Settings
