-- Elements/Settings.lua
local Settings = {}
local Window = _G.CensuraG.Window
local Dropdown = _G.CensuraG.Dropdown
local Switch = _G.CensuraG.Switch
local Slider = _G.CensuraG.Slider
local Styling = _G.CensuraG.Styling
local EventManager = _G.CensuraG.EventManager
local logger = _G.CensuraG.Logger

function Settings:Init()
    if self.Instance then return self end
    self.Instance = Window.new("Settings", 100, 100, 400, 400, { Name = "SettingsWindow" })
    logger:debug("Settings window created: %s", self.Instance.TitleText.Text or "Unknown")

    if not self.Instance or not self.Instance.ContentContainer or not self.Instance.ContentContainer:IsA("Frame") then
        logger:error("Failed to initialize Settings: Invalid window or ContentContainer")
        return nil
    end
    
    -- Tabs
    local tabs = {"General", "Appearance", "Performance", "About"}
    self.currentTab = "Appearance"
    local tabButtons = {}
    local contentY = 80
    local spacing = Styling.Padding

    -- Tab buttons
    for i, tab in ipairs(tabs) do
        tabButtons[tab] = _G.CensuraG.TextButton.new(self.Instance, tab, 10 + (i-1) * 90, 40, 80, 30, function()
            self.currentTab = tab
            self:RefreshUI()
        end)
        logger:debug("Added tab button: %s", tab)
    end

    -- Content area
    local contentContainer = self.Instance.ContentContainer
    logger:debug("Using ContentContainer: %s", contentContainer and contentContainer.Name or "nil")

    -- Appearance Tab Content
    self.appearanceElements = {}
    contentY = 80

    self.appearanceElements.Theme = Dropdown.new(contentContainer, 10, contentY, {
        LabelText = "Theme",
        Width = Styling.ElementWidth,
        Items = {"Dark", "Light", "Military"},
        defaultSelection = Styling.CurrentTheme,
        Callback = function(theme)
            Styling:SetTheme(theme)
        end
    })
    if not self.appearanceElements.Theme then logger:warn("Failed to create Theme Dropdown") end
    contentY = contentY + 30 + spacing

    self.appearanceElements.Shadows = Switch.new(contentContainer, 10, contentY, {
        LabelText = "Enable Shadows",
        Width = Styling.ElementWidth,
        Height = 20,
        defaultState = _G.CensuraG.Config.EnableShadows,
        OnToggled = function(state)
            _G.CensuraG.Config.EnableShadows = state
            Styling:UpdateAllElements()
        end
    })
    if not self.appearanceElements.Shadows then logger:warn("Failed to create Shadows Switch") end
    contentY = contentY + 30 + spacing

    self.appearanceElements.WindowTransparency = Slider.new(contentContainer, 10, contentY, {
        LabelText = "Window Transparency",
        Width = Styling.ElementWidth,
        Min = 0,
        Max = 1,
        Default = Styling.Transparency.WindowBackground,
        Step = 0.05,
        OnChanged = function(value)
            Styling.Transparency.WindowBackground = value
            Styling:UpdateAllElements()
        end
    })
    if not self.appearanceElements.WindowTransparency then logger:warn("Failed to create Window Transparency Slider") end
    contentY = contentY + 30 + spacing

    self.appearanceElements.ElementTransparency = Slider.new(contentContainer, 10, contentY, {
        LabelText = "Element Transparency",
        Width = Styling.ElementWidth,
        Min = 0,
        Max = 1,
        Default = Styling.Transparency.ElementBackground,
        Step = 0.05,
        OnChanged = function(value)
            Styling.Transparency.ElementBackground = value
            Styling:UpdateAllElements()
        end
    })
    if not self.appearanceElements.ElementTransparency then logger:warn("Failed to create Element Transparency Slider") end
    contentY = contentY + 30 + spacing

    self.appearanceElements.TextSize = Slider.new(contentContainer, 10, contentY, {
        LabelText = "Text Size",
        Width = Styling.ElementWidth,
        Min = 10,
        Max = 24,
        Default = Styling.TextSizes.Label,
        Step = 1,
        OnChanged = function(value)
            Styling.TextSizes.Title = value + 2
            Styling.TextSizes.Label = value
            Styling.TextSizes.Button = value
            Styling:UpdateAllElements()
        end
    })
    if not self.appearanceElements.TextSize then logger:warn("Failed to create Text Size Slider") end

    self:RefreshUI()
    logger:info("Settings initialized")
    return self
end

function Settings:RefreshUI()
    if not self.Instance or not self.Instance.ContentContainer then
        logger:warn("Cannot refresh UI: Invalid window or ContentContainer")
        return
    end
    local contentContainer = self.Instance.ContentContainer
    -- Hide all elements and show only the current tab's elements
    for tab, elements in pairs({Appearance = self.appearanceElements}) do
        for _, element in pairs(elements) do
            if element and element.Instance then
                element.Instance.Visible = (tab == self.currentTab)
            end
        end
    end
    logger:debug("Refreshed UI for tab: %s", self.currentTab)
end

function Settings:Toggle()
    if self.Instance then
        if self.Instance.Minimized then
            self.Instance:Restore()
        else
            self.Instance:Minimize()
        end
    end
end

function Settings:Show()
    if self.Instance and self.Instance.Minimized then
        self.Instance:Restore()
    end
end

function Settings:Destroy()
    if self.Instance then
        self.Instance:Destroy()
        self.Instance = nil
        self.appearanceElements = nil
    end
    logger:info("Settings destroyed")
end

return Settings
