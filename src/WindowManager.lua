-- WindowManager.lua: Manages windows with modern miltech styling and grid layout
local WindowManager = {}

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local logger = _G.CensuraG.Logger

WindowManager.Windows = {}
WindowManager.ZIndexCounter = 2 -- Start with a base ZIndex
WindowManager.WindowCount = 0
WindowManager.Grid = {columns = 2, spacing = 20} -- Default 2-column grid with 20px spacing

function WindowManager:Init()
    logger:info("Initializing WindowManager with WindowCount: %d, ZIndexCounter: %d", self.WindowCount, self.ZIndexCounter)
    self.Background = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 0.7,
        ZIndex = 1
    })
    Styling:Apply(self.Background, "Frame")
    if self.Background then
        self.Background.Visible = true
        logger:debug("Background frame created: Size: %s, ZIndex: %d", tostring(self.Background.Size), self.Background.ZIndex)
    else
        logger:warn("Background frame creation failed")
    end
end

function WindowManager:AddWindow(window)
    if not window or not window.Instance then
        logger:warn("Invalid window instance in AddWindow")
        return
    end

    self.WindowCount = self.WindowCount + 1
    window.Instance.ZIndex = self.ZIndexCounter
    self.ZIndexCounter = self.ZIndexCounter + 1
    table.insert(self.Windows, window)
    logger:info("Added window: %s, WindowCount: %d, ZIndex: %d", window.Instance.Name, self.WindowCount, window.Instance.ZIndex)

    -- Automatic grid positioning
    local screenWidth = _G.CensuraG.ScreenGui.AbsoluteSize.X or 800
    local screenHeight = _G.CensuraG.ScreenGui.AbsoluteSize.Y or 600
    local windowWidth = window.Instance.Size.X.Offset
    local windowHeight = window.Instance.Size.Y.Offset
    local cols = self.Grid.columns
    local rows = math.ceil(self.WindowCount / cols)
    local x = 50 + ((self.WindowCount - 1) % cols) * (windowWidth + self.Grid.spacing)
    local y = 50 + math.floor((self.WindowCount - 1) / cols) * (windowHeight + self.Grid.spacing)

    if x + windowWidth > screenWidth then x = 50 end -- Wrap to next row if out of bounds
    if y + windowHeight > screenHeight then y = 50 end -- Reset if off-screen

    window.Instance.Position = UDim2.new(0, x, 0, y)
    logger:debug("Positioned window: %s at (%d, %d), Size: %s", window.Instance.Name, x, y, tostring(window.Instance.Size))
end

function WindowManager:BringToFront(window)
    if not window or not window.Instance then return end
    local currentIndex = table.find(self.Windows, window)
    if currentIndex then
        table.remove(self.Windows, currentIndex)
        table.insert(self.Windows, window)
        window.Instance.ZIndex = self.ZIndexCounter
        self.ZIndexCounter = self.ZIndexCounter + 1
        logger:info("Brought window to front: %s, New ZIndex: %d", window.Instance.Name, window.Instance.ZIndex)
    end
end

function WindowManager:Destroy()
    for _, window in ipairs(self.Windows) do
        if window and window.Destroy then
            window:Destroy()
        end
    end
    if self.Background then
        self.Background:Destroy()
    end
    self.Windows = {}
    self.WindowCount = 0
    self.ZIndexCounter = 2
    logger:info("WindowManager destroyed")
end

return WindowManager
