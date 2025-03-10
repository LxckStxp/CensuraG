-- build.lua: Combines all source files into a single CensuraG.lua
local outputFile = "CensuraG.lua"
local files = {
    "src/Utilities.lua",
    "src/UIElement.lua",
    "src/Elements/Window.lua",
    "src/Elements/TextButton.lua",
    "src/Elements/Slider.lua",
    "src/Taskbar.lua",
    "src/Core.lua"
}

local combined = "-- CensuraG UI API\n-- Generated on " .. os.date("%Y-%m-%d") .. "\n\n"

for _, file in ipairs(files) do
    local content = loadfile(file) and io.open(file, "r"):read("*a") or ""
    combined = combined .. "-- " .. file .. "\n" .. content .. "\n\n"
end

local file = io.open(outputFile, "w")
file:write(combined)
file:close()

print("Build complete: " .. outputFile)
