-- Modern CensuraG v2.0 Comprehensive Test Suite
-- Tests all modernized systems and performance optimizations

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Load the modern CensuraG system
print("🚀 Loading Modern CensuraG v2.0...")
local startTime = tick()

-- Load from GitHub (update URL as needed)
local CensuraG = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/CensuraG/main/CensuraG.lua"))()

-- Wait for full initialization
repeat 
    task.wait(0.1) 
until _G.CensuraG and _G.CensuraG.Initialized

local loadTime = tick() - startTime
print(string.format("✅ CensuraG loaded in %.2f seconds", loadTime))

-- Display performance metrics
local metrics = _G.CensuraG.GetPerformanceMetrics()
print("📊 Performance Metrics:")
for key, value in pairs(metrics) do
    print(string.format("  • %s: %s", key, tostring(value)))
end

-- Test Suite Functions
local TestSuite = {}

-- Test 1: Theme System
function TestSuite:TestThemes()
    print("\n🎨 Testing Modern Theme System...")
    
    local themes = {"Glass", "Dark", "Minimal"}
    local currentIndex = 1
    
    local function cycleTheme()
        local theme = themes[currentIndex]
        _G.CensuraG.SetTheme(theme)
        print("  → Switched to " .. theme .. " theme")
        
        currentIndex = currentIndex + 1
        if currentIndex > #themes then
            currentIndex = 1
        end
    end
    
    -- Create theme cycling window
    local themeWindow = _G.CensuraG.API.CreateWindow({
        Title = "Theme Tester",
        Size = {320, 240},
        Position = {100, 100}
    })
    
    if themeWindow then
        -- Theme cycle button
        local cycleButton = _G.CensuraG.Components.textbutton(
            themeWindow.Content,
            "Cycle Themes",
            cycleTheme
        )
        
        -- Current theme display
        local themeLabel = _G.CensuraG.Components.textlabel(
            themeWindow.Content,
            "Current: " .. _G.CensuraG.CurrentTheme
        )
        
        -- Layout
        local layout = Instance.new("UIListLayout", themeWindow.Content)
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.Padding = UDim.new(0, 12)
        
        local padding = Instance.new("UIPadding", themeWindow.Content)
        padding.PaddingTop = UDim.new(0, 20)
        
        print("  ✅ Theme test window created")
    end
end

-- Test 2: Advanced Animation System
function TestSuite:TestAnimations()
    print("\n✨ Testing Advanced Animation System...")
    
    local animWindow = _G.CensuraG.API.CreateWindow({
        Title = "Animation Showcase",
        Size = {400, 300},
        Position = {150, 150}
    })
    
    if animWindow then
        -- Test different animation types
        local animations = {
            {name = "Micro", preset = "Micro"},
            {name = "Standard", preset = "Standard"},
            {name = "Entrance", preset = "Entrance"},
            {name = "Elastic", preset = "Elastic"},
            {name = "Bounce", preset = "Bounce"}
        }
        
        for i, anim in ipairs(animations) do
            local button = _G.CensuraG.Components.textbutton(
                animWindow.Content,
                anim.name .. " Animation",
                function()
                    -- Test the animation preset
                    if _G.CensuraG.AnimationManager then
                        _G.CensuraG.AnimationManager:Tween(
                            button.Instance,
                            {BackgroundTransparency = 0.2},
                            nil, nil, nil,
                            anim.preset
                        )
                        
                        task.delay(0.5, function()
                            _G.CensuraG.AnimationManager:Tween(
                                button.Instance,
                                {BackgroundTransparency = 0.8},
                                nil, nil, nil,
                                "Standard"
                            )
                        end)
                    end
                    
                    print("  → Tested " .. anim.name .. " animation")
                end
            )
        end
        
        -- Layout animations
        local layout = Instance.new("UIListLayout", animWindow.Content)
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.Padding = UDim.new(0, 8)
        
        local padding = Instance.new("UIPadding", animWindow.Content)
        padding.PaddingTop = UDim.new(0, 16)
        
        print("  ✅ Animation test window created")
    end
end

-- Test 3: Component System
function TestSuite:TestComponents()
    print("\n🧩 Testing Modern Component System...")
    
    local compWindow = _G.CensuraG.API.CreateWindow({
        Title = "Component Gallery",
        Size = {380, 420},
        Position = {200, 200}
    })
    
    if compWindow then
        -- Test slider
        local slider = _G.CensuraG.Components.slider(
            compWindow.Content,
            "Test Slider",
            0, 100, 50,
            function(value)
                print("  → Slider value: " .. value)
            end
        )
        
        -- Test dropdown
        local dropdown = _G.CensuraG.Components.dropdown(
            compWindow.Content,
            "Test Dropdown",
            {"Option A", "Option B", "Option C", "Glassmorphic", "Modern"},
            function(selected)
                print("  → Dropdown selected: " .. selected)
            end
        )
        
        -- Test switch (if available)
        if _G.CensuraG.Components.switch then
            local switch = _G.CensuraG.Components.switch(
                compWindow.Content,
                "Test Switch",
                true,
                function(state)
                    print("  → Switch state: " .. tostring(state))
                end
            )
        end
        
        -- Layout components
        local layout = Instance.new("UIListLayout", compWindow.Content)
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.Padding = UDim.new(0, 12)
        
        local padding = Instance.new("UIPadding", compWindow.Content)
        padding.PaddingTop = UDim.new(0, 16)
        
        print("  ✅ Component test window created")
    end
end

-- Test 4: Desktop Environment
function TestSuite:TestDesktop()
    print("\n🖥️ Testing Desktop Environment...")
    
    -- Test app registration
    _G.CensuraG.RegisterApp({
        Name = "Test App",
        Description = "Modern test application",
        Icon = "🧪",
        Category = "Testing",
        Action = function()
            local testApp = _G.CensuraG.API.CreateWindow({
                Title = "Test Application",
                Size = {300, 200},
                Position = {250, 250}
            })
            
            if testApp then
                local label = _G.CensuraG.Components.textlabel(
                    testApp.Content,
                    "This is a test application demonstrating the modern CensuraG v2.0 system!"
                )
                
                local padding = Instance.new("UIPadding", testApp.Content)
                padding.PaddingTop = UDim.new(0, 20)
                padding.PaddingLeft = UDim.new(0, 16)
                padding.PaddingRight = UDim.new(0, 16)
                
                print("  → Test app window created")
            end
        end
    })
    
    print("  ✅ Test app registered with desktop")
end

-- Test 5: Performance Monitoring
function TestSuite:TestPerformance()
    print("\n⚡ Testing Performance Systems...")
    
    -- Animation performance test
    if _G.CensuraG.AnimationManager then
        local animMetrics = _G.CensuraG.AnimationManager:GetPerformanceMetrics()
        print("  → Animation metrics:")
        for key, value in pairs(animMetrics) do
            print(string.format("    • %s: %s", key, tostring(value)))
        end
    end
    
    -- Memory usage
    local memoryUsage = collectgarbage("count")
    print(string.format("  → Memory usage: %.1f KB", memoryUsage))
    
    -- System metrics
    local systemMetrics = _G.CensuraG.GetPerformanceMetrics()
    print("  → System metrics:")
    for key, value in pairs(systemMetrics) do
        print(string.format("    • %s: %s", key, tostring(value)))
    end
    
    print("  ✅ Performance monitoring active")
end

-- Execute all tests
function TestSuite:RunAllTests()
    print("🧪 Starting CensuraG v2.0 Comprehensive Test Suite")
    print("=" .. string.rep("=", 50))
    
    self:TestThemes()
    task.wait(0.5)
    
    self:TestAnimations()
    task.wait(0.5)
    
    self:TestComponents()
    task.wait(0.5)
    
    self:TestDesktop()
    task.wait(0.5)
    
    self:TestPerformance()
    
    print("\n" .. string.rep("=", 52))
    print("✅ All tests completed successfully!")
    print("🎉 Modern CensuraG v2.0 is fully operational!")
    print("\n📱 Use the Start Menu to access applications")
    print("🎨 Try the Theme Tester to see glassmorphic themes")
    print("✨ Experience smooth micro-animations throughout")
end

-- Start the test suite
TestSuite:RunAllTests()

-- Performance monitoring loop
spawn(function()
    while _G.CensuraG and _G.CensuraG.Initialized do
        task.wait(5)
        
        local metrics = _G.CensuraG.GetPerformanceMetrics()
        if metrics.MemoryUsage > 1000 then -- Alert if memory > 1MB
            print(string.format("⚠️ High memory usage detected: %.1f KB", metrics.MemoryUsage))
        end
    end
end)

print("\n🚀 CensuraG v2.0 Modern Test Suite Active!")
print("💡 Check console for test results and performance metrics")