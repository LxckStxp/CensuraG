-- Settings.lua: Persistent settings menu for CensuraG
local Settings = {}
local logger = _G.CensuraG.Logger
local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager

-- Store reference to the settings window
Settings.Window = nil

-- Initialize settings menu
function Settings:Init()
    if self.Window then
        logger:warn("Settings menu already initialized")
        return self
    end
    
    logger:info("Initializing CensuraG Settings menu")
    
    -- Calculate initial position (centered)
    local screenSize = Utilities.getScreenSize()
    local windowWidth = 400
    local windowHeight = 350
    local x = (screenSize.X - windowWidth) / 2
    local y = (screenSize.Y - windowHeight) / 2
    
    -- Create the settings window with special options
    local window = _G.CensuraG.Window.new("CensuraG Settings", x, y, windowWidth, windowHeight, {
        CanClose = false -- Custom property to prevent closing
    })
    
    -- Override the window's destroy function to prevent closing
    local originalDestroy = window.Destroy
    window.Destroy = function(self)
        -- Instead of destroying, just minimize
        if not self.Minimized then
            self:Minimize()
        end
        
        logger:debug("Attempted to close settings window - minimized instead")
        return false
    end
    
    -- Customize the close button to minimize instead
    if window.MaximizeButton then
        -- Remove the maximize button
        window.MaximizeButton:Destroy()
        window.MaximizeButton = nil
        
        -- Reposition minimize button
        window.MinimizeButton.Position = UDim2.new(1, -19, 0, 3)
    end
    
    -- Store reference to the window
    self.Window = window
    
    -- Add settings content
    self:CreateSettingsContent(window)
    
    logger:info("Settings menu initialized")
    return self
end

-- Create settings content
function Settings:CreateSettingsContent(window)
    -- Create tabs container
    local tabContainer = Utilities.createInstance("Frame", {
        Parent = window.ContentContainer,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundTransparency = 0.8,
        ZIndex = window.ContentContainer.ZIndex + 1,
        Name = "TabContainer"
    })
    Styling:Apply(tabContainer, "Frame")
    
    -- Create content container
    local contentContainer = Utilities.createInstance("Frame", {
        Parent = window.ContentContainer,
        Position = UDim2.new(0, 105, 0, 0),
        Size = UDim2.new(1, -110, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = window.ContentContainer.ZIndex + 1,
        Name = "ContentContainer"
    })
    
    -- Tab data
    local tabs = {
        {Name = "General", Icon = "⚙️"},
        {Name = "Theme", Icon = "🎨"},
        {Name = "Performance", Icon = "⚡"},
        {Name = "About", Icon = "ℹ️"}
    }
    
    -- Store tab content frames
    local contentFrames = {}
    
    -- Create tabs and their content
    for i, tabInfo in ipairs(tabs) do
        -- Create tab button
        local tabButton = Utilities.createInstance("TextButton", {
            Parent = tabContainer,
            Position = UDim2.new(0, 5, 0, (i-1) * 40 + 5),
            Size = UDim2.new(1, -10, 0, 35),
            Text = tabInfo.Icon .. " " .. tabInfo.Name,
            TextSize = 14,
            ZIndex = tabContainer.ZIndex + 1,
            Name = "Tab_" .. tabInfo.Name
        })
        Styling:Apply(tabButton, "TextButton")
        Animation:HoverEffect(tabButton)
        
        -- Create content frame for this tab (initially hidden)
        local contentFrame = Utilities.createInstance("Frame", {
            Parent = contentContainer,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = i == 1, -- First tab visible by default
            ZIndex = contentContainer.ZIndex + 1,
            Name = "Content_" .. tabInfo.Name
        })
        
        -- Store content frame reference
        contentFrames[tabInfo.Name] = contentFrame
        
        -- Handle tab switching
        tabButton.MouseButton1Click:Connect(function()
            -- Hide all content frames
            for _, frame in pairs(contentFrames) do
                frame.Visible = false
            end
            
            -- Show this tab's content
            contentFrame.Visible = true
            
            -- Visual feedback
            Animation:Bounce(tabButton, 1.05, 0.2)
            
            logger:debug("Switched to settings tab: %s", tabInfo.Name)
        end)
        
        -- Populate tab content
        self:PopulateTabContent(tabInfo.Name, contentFrame)
    end
    
    -- Store references
    self.TabContainer = tabContainer
    self.ContentContainer = contentContainer
    self.ContentFrames = contentFrames
    
    logger:debug("Created settings menu content with %d tabs", #tabs)
end

-- Populate content for each tab
function Settings:PopulateTabContent(tabName, contentFrame)
    if tabName == "General" then
        -- General settings
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
        
        -- Auto-hide taskbar setting
        local autoHideSwitch = _G.CensuraG.Switch.new(
            {Instance = contentFrame}, 10, 50, 40, 20, 
            _G.CensuraG.Taskbar.AutoHideEnabled, 
            {
                LabelText = "Auto-hide Taskbar",
                ShowLabel = true,
                OnToggled = function(state)
                    if _G.CensuraG.Taskbar then
                        _G.CensuraG.Taskbar:SetAutoHide(state)
                        logger:info("Changed taskbar auto-hide to: %s", tostring(state))
                    end
                end
            }
        )
        
        -- Debug mode switch
        local debugModeSwitch = _G.CensuraG.Switch.new(
            {Instance = contentFrame}, 10, 90, 40, 20, 
            false, 
            {
                LabelText = "Debug Mode",
                ShowLabel = true,
                OnToggled = function(state)
                    _G.CensuraG.DebugMode = state
                    
                    -- Show/hide debug elements
                    if _G.CensuraG.Taskbar and _G.CensuraG.Taskbar.DebugLabel then
                        _G.CensuraG.Taskbar.DebugLabel.Visible = state
                    end
                    
                    logger:info("Changed debug mode to: %s", tostring(state))
                    
                    -- If enabled, show more debug info
                    if state then
                        logger:debug("Debug information: Screen size: %s", tostring(Utilities.getScreenSize()))
                        logger:debug("Windows open: %d", #_G.CensuraG.WindowManager.Windows)
                    end
                end
            }
        )
        
        -- Window snap setting
        local windowSnapSwitch = _G.CensuraG.Switch.new(
            {Instance = contentFrame}, 10, 130, 40, 20, 
            true, 
            {
                LabelText = "Window Snap",
                ShowLabel = true,
                OnToggled = function(state)
                    _G.CensuraG.WindowSnapEnabled = state
                    logger:info("Changed window snap to: %s", tostring(state))
                end
            }
        )
        
        -- Reset windows button
        local resetButton = _G.CensuraG.TextButton.new(
            {Instance = contentFrame}, "Reset All Windows", 10, 180, 150, 30,
            function()
                if _G.CensuraG.WindowManager then
                    _G.CensuraG.WindowManager:ArrangeWindows()
                    logger:info("Reset all window positions")
                end
            end,
            {NoLabel = true}
        )
        
    elseif tabName == "Theme" then
        -- Theme settings
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
        
        -- Theme selector
        local themeLabel = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 50),
            Size = UDim2.new(0, 60, 0, 20),
            Text = "Theme",
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "ThemeLabel"
        })
        Styling:Apply(themeLabel, "TextLabel")
        
        -- Get available themes
        local themeNames = {}
        for name, _ in pairs(Styling.Themes) do
            table.insert(themeNames, name)
        end
        
        -- Create dropdown for theme selection
        local themeDropdown = _G.CensuraG.Dropdown.new(
            {Instance = contentFrame}, 75, 50, 180,
            {
                Items = themeNames,
                LabelText = ""
            },
            Styling.CurrentTheme,
            function(selected)
                Styling:SetTheme(selected)
                logger:info("Changed theme to: %s", selected)
            end
        )
        
        -- Transparency slider
        local transparencySlider = _G.CensuraG.Slider.new(
            {Instance = contentFrame}, 10, 100, 200, 0, 100, 
            Styling.Transparency.ElementBackground * 100,
            {
                LabelText = "Transparency",
                ShowValue = true,
                Step = 5,
                OnChanged = function(value)
                    -- Update transparency settings
                    local newTransparency = value / 100
                    Styling.Transparency.ElementBackground = newTransparency
                    Styling.Transparency.WindowBackground = math.max(0, newTransparency - 0.05)
                    
                    -- Update all UI elements
                    Styling:UpdateAllElements()
                    
                    logger:info("Changed UI transparency to: %d%%", value)
                end
            }
        )
        
        -- Text size slider
        local textSizeSlider = _G.CensuraG.Slider.new(
            {Instance = contentFrame}, 10, 150, 200, 10, 24, 
            Styling.TextSizes.Label,
            {
                LabelText = "Text Size",
                ShowValue = true,
                Step = 1,
                OnChanged = function(value)
                    -- Update text size settings
                    Styling.TextSizes.Label = value
                    Styling.TextSizes.Button = value
                    Styling.TextSizes.Title = value + 2
                    
                    -- Update all UI elements
                    Styling:UpdateAllElements()
                    
                    logger:info("Changed UI text size to: %d", value)
                end
            }
        )
        
        -- Custom theme creator button
        local customThemeButton = _G.CensuraG.TextButton.new(
            {Instance = contentFrame}, "Create Custom Theme", 10, 200, 150, 30,
            function()
                -- This would open a color picker window
                logger:info("Custom theme creator not implemented yet")
                
                -- Example implementation would create a new window with color pickers
                local colorWindow = _G.CensuraG.Window.new("Custom Theme Creator", 100, 100, 300, 400)
                
                -- Add implementation for custom theme creation here
            end,
            {NoLabel = true}
        )
        
    elseif tabName == "Performance" then
        -- Performance settings
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
        
        -- Animation quality setting
        local animationQualitySlider = _G.CensuraG.Slider.new(
            {Instance = contentFrame}, 10, 50, 200, 0, 100, 
            100,
            {
                LabelText = "Animation Quality",
                ShowValue = true,
                Step = 10,
                OnChanged = function(value)
                    _G.CensuraG.AnimationQuality = value / 100
                    logger:info("Changed animation quality to: %d%%", value)
                end
            }
        )
        
        -- Animation speed setting
        local animationSpeedSlider = _G.CensuraG.Slider.new(
            {Instance = contentFrame}, 10, 100, 200, 50, 200, 
            100,
            {
                LabelText = "Animation Speed",
                ShowValue = true,
                Step = 10,
                OnChanged = function(value)
                    _G.CensuraG.AnimationSpeed = value / 100
                    logger:info("Changed animation speed to: %d%%", value)
                end
            }
        )
        
        -- Shadow quality switch
        local shadowQualitySwitch = _G.CensuraG.Switch.new(
            {Instance = contentFrame}, 10, 150, 40, 20, 
            true, 
            {
                LabelText = "Window Shadows",
                ShowLabel = true,
                OnToggled = function(state)
                    _G.CensuraG.EnableShadows = state
                    
                    -- Update all windows
                    if _G.CensuraG.WindowManager then
                        for _, window in ipairs(_G.CensuraG.WindowManager.Windows) do
                            if window.Shadow then
                                window.Shadow.Visible = state
                            end
                        end
                    end
                    
                    logger:info("Changed window shadows to: %s", tostring(state))
                end
            }
        )
        
        -- Memory usage indicator
        local memoryLabel = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 200),
            Size = UDim2.new(1, -20, 0, 20),
            Text = "Memory Usage: Calculating...",
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "MemoryLabel"
        })
        Styling:Apply(memoryLabel, "TextLabel")
        
        -- Update memory usage periodically
        task.spawn(function()
            while task.wait(2) do
                if memoryLabel and memoryLabel.Parent then
                    local memory = math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb())
                    memoryLabel.Text = "Memory Usage: " .. memory .. " MB"
                else
                    break
                end
            end
        end)
        
    elseif tabName == "About" then
        -- About information
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
        
        -- Version info
        local versionLabel = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 50),
            Size = UDim2.new(1, -20, 0, 20),
            Text = "Version: " .. _G.CensuraG._VERSION,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "VersionLabel"
        })
        Styling:Apply(versionLabel, "TextLabel")
        
        -- Description
        local descriptionLabel = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 80),
            Size = UDim2.new(1, -20, 0, 60),
            Text = _G.CensuraG._DESCRIPTION,
            TextWrapped = true,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "DescriptionLabel"
        })
        Styling:Apply(descriptionLabel, "TextLabel")
        
        -- Credits
        local creditsLabel = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 150),
            Size = UDim2.new(1, -20, 0, 20),
            Text = "Created by LxckStxp",
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "CreditsLabel"
        })
        Styling:Apply(creditsLabel, "TextLabel")
        
        -- License
        local licenseLabel = Utilities.createInstance("TextLabel", {
            Parent = contentFrame,
            Position = UDim2.new(0, 10, 0, 180),
            Size = UDim2.new(1, -20, 0, 20),
            Text = "License: " .. _G.CensuraG._LICENSE,
            BackgroundTransparency = 1,
            ZIndex = contentFrame.ZIndex + 1,
            Name = "LicenseLabel"
        })
        Styling:Apply(licenseLabel, "TextLabel")
        
        -- GitHub link button
        local githubButton = _G.CensuraG.TextButton.new(
            {Instance = contentFrame}, "Visit GitHub Repository", 10, 220, 200, 30,
            function()
                -- Copy link to clipboard
                setclipboard("https://github.com/LxckStxp/CensuraG")
                logger:info("GitHub repository link copied to clipboard")
                
                -- Visual feedback
                local notification = _G.CensuraG.Window.new("Notification", 100, 100, 300, 100)
                local notifLabel = Utilities.createInstance("TextLabel", {
                    Parent = notification.ContentContainer,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -20, 1, -20),
                    Text = "GitHub link copied to clipboard!",
                    TextWrapped = true,
                    BackgroundTransparency = 1,
                    ZIndex = notification.ContentContainer.ZIndex + 1,
                    Name = "NotificationLabel"
                })
                Styling:Apply(notifLabel, "TextLabel")
                
                -- Auto-close notification after 3 seconds
                task.delay(3, function()
                    notification:Destroy()
                end)
            },
            {NoLabel = true}
        )
    end
    
    logger:debug("Populated content for tab: %s", tabName)
end

-- Show the settings menu
function Settings:Show()
    if not self.Window then
        self:Init()
    end
    
    if self.Window.Minimized then
        self.Window:Restore()
    end
    
    logger:info("Settings menu shown")
end

-- Toggle the settings menu
function Settings:Toggle()
    if not self.Window then
        self:Init()
        return
    end
    
    if self.Window.Minimized then
        self.Window:Restore()
    else
        self.Window:Minimize()
    end
    
    logger:info("Settings menu toggled")
end

return Settings
