-- WindowManager.lua: Manages window spawning to prevent overlap
local WindowManager = {}
WindowManager.Windows = {}

function WindowManager:Init()
    self.Offset = 20 -- Pixels to offset each new window
    self.MaxPerRow = 5 -- Max windows before wrapping to next row
end

function WindowManager:AddWindow(window)
    local count = #self.Windows
    local row = math.floor(count / self.MaxPerRow)
    local col = count % self.MaxPerRow
    
    local x = col * (window.Instance.Size.X.Offset + self.Offset) + self.Offset
    local y = row * (window.Instance.Size.Y.Offset + self.Offset) + self.Offset
    
    window:SetPosition(x, y)
    table.insert(self.Windows, window)
end

function WindowManager:RemoveWindow(window)
    local index = table.find(self.Windows, window)
    if index then
        table.remove(self.Windows, index)
    end
end

return WindowManager
