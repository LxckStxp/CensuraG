-- CensuraG/src/Utilities.lua
local Utilities = {}

function Utilities.LoadModule(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        _G.CensuraG.Logger:error("Failed to load module from " .. url .. ": " .. result)
    end
    return success and result or nil
end

return Utilities
