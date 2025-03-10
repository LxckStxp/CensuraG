-- WindowManager.lua: Manages windows with dynamic ZIndex and positioning
local WindowManager = {}

local logger = _G.CensuraG.Logger
WindowManager.Windows = {}
WindowManager.ZIndexCounter = 2
WindowManager.WindowCount = 0

-- Use a global table to persist state across script runs
_G.CensuraGGlobal = _G.CensuraGGlobal or {}
_G.CensuraGGlobal.WindowManagerState = _G.CensuraGGlobal.WindowManagerState or {
    ZIndexCounter = 2,
    WindowCount = 0,
    Windows = {}
}

-- Load global state
WindowManager.ZIndexCounter = _G.CensuraGGlobal.WindowManagerState.ZIndexCounter
WindowManager.WindowCount = _G.CensuraGGlobal.WindowManagerState.WindowCount
WindowManager.Windows = _G.CensuraGGlobal.WindowManagerState.Windows

function WindowManager:Init()
    logger:info("WindowManager initialized with WindowCount: %d, ZIndexCounter: %d", self.WindowCount, self.ZIndexCounter)
end

function WindowManager:AddWindow(window)
    if not window or not window.Instance then
        logger:warn("Invalid window instance in AddWindow")
        return
    end
    table.insert(self.Windows, window)
    window.Instance.ZIndex = self.ZIndexCounter
    self.ZIndexCounter = self.ZIndexCounter + 1
    self.WindowCount = self.WindowCount + 1
    logger:debug("Added window with ZIndex: %d, Total Windows: %d", window.Instance.ZIndex, self.WindowCount)

    -- Update global state
    _G.CensuraGGlobal.WindowManagerState.ZIndexCounter = self.ZIndexCounter
    _G.CensuraGGlobal.WindowManagerState.WindowCount = self.WindowCount
    _G.CensuraGGlobal.WindowManagerState.Windows = self.Windows

    -- Update window position based on global count
    local baseX, baseY = 50, 50
    local offsetX, offsetY = 20, 20
    window.Instance.Position = UDim2.new(0, baseX + ((self.WindowCount - 1) % 3) * (300 + offsetX), 0, baseY + math.floor((self.WindowCount - 1) / 3) * (200 + offsetY))
    logger:info("Window registered with WindowManager at Position: %s, ZIndex: %d", tostring(window.Instance.Position), window.Instance.ZIndex)
end

function WindowManager:RemoveWindow(window)
    local index = table.find(self.Windows, window)
    if index then
        table.remove(self.Windows, index)
        self.WindowCount = self.WindowCount - 1
        _G.CensuraGGlobal.WindowManagerState.WindowCount = self.WindowCount
        _G.CensuraGGlobal.WindowManagerState.Windows = self.Windows
        logger:debug("Removed window, remaining count: %d", self.WindowCount)

        -- Recalculate positions for remaining windows
        for i, w in ipairs(self.Windows) do
            local baseX, baseY = 50, 50
            local offsetX, offsetY = 20, 20
            w.Instance.Position = UDim2.new(0, baseX + ((i - 1) % 3) * (300 + offsetX), 0, baseY + math.floor((i - 1) / 3) * (200 + offsetY))
            logger:debug("Repositioned window %d to Position: %s", i, tostring(w.Instance.Position))
        end
    end
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
    _G.CensuraGGlobal.WindowManagerState = {
        ZIndexCounter = 2,
        WindowCount = 0,
        Windows = {}
    }
    logger:info("WindowManager destroyed")
end

return WindowManager
