-- Elements/Settings.lua
-- Persistent settings menu

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
    local windowWidth, windowHeight = 400, 350
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
        -- Additional general settings (switches, buttons, etc.) can be added here.
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
        -- Create theme picker/dropdown and transparency/text size sliders.
    elseif tabName == "Performance" then
        -- Populate performance settings.
    elseif tabName == "About" then
        -- Populate about information.
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
