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
    self.Instance = Window.new("Settings", 100, 100, 400, 400)
    
    -- Tabs
    local tabs = {"General", "Appearance", "Performance", "About"}
    local currentTab = "Appearance"
    local tabButtons = {}
    local contentY = 80
    local spacing = Styling.Padding

    -- Tab buttons
    for i, tab in ipairs(tabs) do
        tabButtons[tab] = _G.CensuraG.TextButton.new(self.Instance, tab, 10 + (i-1) * 90, 40, 80, 30, function()
            currentTab = tab
            self:RefreshUI()
        end)
    end

    -- Content area
    local contentContainer = self.Instance.ContentContainer

    -- Appearance Tab Content
    local appearanceElements = {}
    contentY = 80

    appearanceElements.Theme = Dropdown.new(contentContainer, 10, contentY, {
        LabelText = "Theme",
        Width = Styling.ElementWidth,
        Items = {"Dark", "Light", "Military"},
        defaultSelection = Styling.CurrentTheme,
        Callback = function(theme)
            Styling:SetTheme(theme)
        end
    })
    contentY = contentY + 30 + spacing

    appearanceElements.Shadows = Switch.new(contentContainer, 10, contentY, {
        LabelText = "Enable Shadows",
        Width = Styling.ElementWidth,
        Height = 20,
        defaultState = _G.CensuraG.Config.EnableShadows,
        OnToggled = function(state)
            _G.CensuraG.Config.EnableShadows = state
            Styling:UpdateAllElements()
        end
    })
    contentY = contentY + 30 + spacing

    appearanceElements.WindowTransparency = Slider.new(contentContainer, 10, contentY, {
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
    contentY = contentY + 30 + spacing

    appearanceElements.ElementTransparency = Slider.new(contentContainer, 10, contentY, {
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
    contentY = contentY + 30 + spacing

    appearanceElements.TextSize = Slider.new(contentContainer, 10, contentY, {
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

    function self:RefreshUI()
        -- Hide all tab content and show only the current tab
        for tab, elements in pairs({Appearance = appearanceElements}) do
            for _, element in pairs(elements) do
                if element and element.Instance then
                    element.Instance.Visible = (tab == currentTab)
                end
            end
        end
    end

    self:RefreshUI()
    logger:info("Settings initialized")
    return self
end

function Settings:Toggle()
    if self.Instance.Minimized then
        self.Instance:Restore()
    else
        self.Instance:Minimize()
    end
end

function Settings:Show()
    if self.Instance.Minimized then
        self.Instance:Restore()
    end
end

function Settings:Destroy()
    if self.Instance then
        self.Instance:Destroy()
        self.Instance = nil
    end
    logger:info("Settings destroyed")
end

return Settings
