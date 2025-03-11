-- CensuraG/src/Methods.lua
local Methods = {}

function Methods:CreateWindow(title)
    if not _G.CensuraG.WindowManager then
        _G.CensuraG.Logger:error("WindowManager not loaded")
        return nil
    end
    local window = _G.CensuraG.WindowManager.new(title)
    table.insert(_G.CensuraG.Windows, window)
    _G.CensuraG.TaskbarManager:UpdateTaskbar()
    return window
end

return Methods
