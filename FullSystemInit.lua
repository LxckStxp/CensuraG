-- Run this to load censura with core applications

-- Load CensuraG from GitHub
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/CensuraG/main/CensuraG.lua"))()
end)

if not success then
    warn("Failed to load CensuraG: " .. tostring(result))
    return
end

wait(2)

loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura-Applications/main/System/CensuraConsole.lua"))()

wait(2)

loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura-Applications/main/Services/PlayerService.lua"))()

wait(2)

loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura-Applications/main/Services/ChatBox.lua"))()

wait(2)

loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura-Applications/main/LocalPlayer/LocoManager.lua"))()

