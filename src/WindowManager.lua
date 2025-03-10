-- WindowManager.lua: Manages windows with dynamic ZIndex and positioning
local WindowManager = {}

local logger = _G.CensuraG.Logger
WindowManager.Windows = {}
WindowManager.ZIndexCounter = 2 -- Start with the base ZIndex
WindowManager.WindowCount = 0

function WindowManager:Init()
    logger:info("WindowManager initialized.")
end

function WindowManager:AddWindow(window)
    if not window or not window.Instance then
        logger:warn("Invalid window instance in AddWindow")
        return
    end
    table.insert(self.Windows, window)
    window.Instance.ZIndex = self.ZIndexCounter
    self.ZIndexCounter = self.ZIndexCounter + 1
    logger:debug("Added window with ZIndex: %d", window.Instance.ZIndex)

    -- Update window position based on count
    local baseX, baseY = 50, 50
    local offsetX, offsetY = 20, 20
    self.WindowCount = self.WindowCount + 1
    window.Instance.Position = UDim2.new(0, baseX + ((self.WindowCount - 1) % 3) * (300 + offsetX), 0, baseY + math.floor((self.WindowCount - 1) / 3) * (200 + offsetY))
    logger:info("Window registered with WindowManager at Position: %s, ZIndex: %d", tostring(window.Instance.Position), window.Instance.ZIndex)
end

function WindowManager:RemoveWindow(window)
    local index = table.find(self.Windows, window)
    if index then
        table.remove(self.Windows, index)
        self.WindowCount = self.WindowCount - 1
        logger:debug("Removed window, remaining count: %d", self.WindowCount)
    end
end

function WindowManager:Destroy()
    for _, window in pairs(self.Windows) do
        if window.Destroy then
            window:Destroy()
        end
    end
    self.Windows = {}
    logger:info("WindowManager destroyed")
end

return WindowManager
