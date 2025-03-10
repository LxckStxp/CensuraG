-- WindowManager.lua: Manages windows with dynamic ZIndex and positioning
local WindowManager = {}

local logger = _G.CensuraG.Logger
WindowManager.Windows = {}
WindowManager.ZIndexCounter = 2
WindowManager.WindowCount = 0
WindowManager.MaxZIndex = 100 -- Cap for Z-index to prevent overflow

function WindowManager:Init()
    -- Reset state on initialization
    self.Windows = {}
    self.ZIndexCounter = 2
    self.WindowCount = 0
    logger:info("WindowManager initialized with WindowCount: %d, ZIndexCounter: %d", self.WindowCount, self.ZIndexCounter)
end

function WindowManager:AddWindow(window)
    if not window or not window.Instance then
        logger:warn("Invalid window instance in AddWindow")
        return
    end

    -- Check for duplicate windows
    if table.find(self.Windows, window) then
        logger:debug("Window already exists in WindowManager, updating state")
        return
    end

    table.insert(self.Windows, window)
    window.Instance.ZIndex = self.ZIndexCounter
    self.ZIndexCounter = self.ZIndexCounter + 1
    if self.ZIndexCounter > self.MaxZIndex then
        self.ZIndexCounter = 2
        self:ReassignZIndices()
    end
    self.WindowCount = self.WindowCount + 1
    logger:debug("Added window with ZIndex: %d, Total Windows: %d", window.Instance.ZIndex, self.WindowCount)

    -- Set initial position only if not already dragged
    if not window.CurrentPosition then
        local baseX, baseY = 50, 50
        local offsetX, offsetY = 20, 20
        window.Instance.Position = UDim2.new(0, baseX + ((self.WindowCount - 1) % 3) * (300 + offsetX), 0, baseY + math.floor((self.WindowCount - 1) / 3) * (200 + offsetY))
        window.OriginalPosition = window.Instance.Position
        logger:info("Window registered with WindowManager at initial Position: %s, ZIndex: %d", tostring(window.Instance.Position), window.Instance.ZIndex)
    else
        logger:info("Window registered with WindowManager at dragged Position: %s, ZIndex: %d", tostring(window.CurrentPosition), window.Instance.ZIndex)
    end
end

function WindowManager:ReassignZIndices()
    -- Reassign Z-indices starting from 2, incrementing for each window
    local zIndex = 2
    for _, w in ipairs(self.Windows) do
        if w.Instance then
            w.Instance.ZIndex = zIndex
            zIndex = zIndex + 1
        end
    end
    self.ZIndexCounter = zIndex
    logger:debug("Reassigned Z-indices, new ZIndexCounter: %d", self.ZIndexCounter)
end

function WindowManager:Destroy()
    for _, window in pairs(self.Windows) do
        if window.Destroy then
            window:Destroy()
        end
    end
    self.Windows = {}
    self.WindowCount = 0
    self.ZIndexCounter = 2
    logger:info("WindowManager destroyed")
end

return WindowManager
