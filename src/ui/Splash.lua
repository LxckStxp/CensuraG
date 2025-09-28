-- CensuraG/src/ui/Splash.lua (fixed progress bar)
local Splash = {}

-- This module needs to work without any dependencies
local function createScreenGui()
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local existingGui = playerGui:FindFirstChild("CensuraGSplashScreenGui")
    if existingGui then return existingGui end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CensuraGSplashScreenGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999 -- Make sure it's on top
    screenGui.Parent = playerGui
    return screenGui
end

-- Show a splash screen during initialization
function Splash:Show()
    local screenGui = createScreenGui()
    
    -- Create the main container with military theme defaults
    local container = Instance.new("Frame")
    container.Name = "SplashContainer"
    container.Size = UDim2.new(0, 300, 0, 150)
    container.Position = UDim2.new(0.5, -150, 0.5, -75)
    container.BackgroundColor3 = Color3.fromRGB(15, 17, 19) -- Default military theme
    container.BackgroundTransparency = 0.1
    container.BorderSizePixel = 0
    container.Parent = screenGui
    
    -- Corner radius
    local corner = Instance.new("UICorner", container)
    corner.CornerRadius = UDim.new(0, 4)
    
    -- Border glow
    local stroke = Instance.new("UIStroke", container)
    stroke.Color = Color3.fromRGB(200, 200, 200) -- Accent color
    stroke.Thickness = 1.5
    stroke.Transparency = 0.2
    
    -- Add shadow
    local shadow = Instance.new("ImageLabel", container)
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://7912134082" -- Shadow image
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    shadow.ZIndex = 0 -- Behind container
    
    -- Logo text
    local logoText = Instance.new("TextLabel", container)
    logoText.Name = "LogoText"
    logoText.Size = UDim2.new(1, 0, 0, 40)
    logoText.Position = UDim2.new(0, 0, 0, 20)
    logoText.BackgroundTransparency = 1
    logoText.Text = "CensuraG"
    logoText.TextColor3 = Color3.fromRGB(225, 228, 230) -- Text color
    logoText.Font = Enum.Font.GothamBold
    logoText.TextSize = 28
    
    -- Status text
    local statusText = Instance.new("TextLabel", container)
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, -40, 0, 20)
    statusText.Position = UDim2.new(0, 20, 0, 70)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Initializing..."
    statusText.TextColor3 = Color3.fromRGB(200, 200, 200) -- Accent color
    statusText.Font = Enum.Font.Gotham
    statusText.TextSize = 14
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Progress bar background
    local progressBg = Instance.new("Frame", container)
    progressBg.Name = "ProgressBackground"
    progressBg.Size = UDim2.new(1, -40, 0, 6)
    progressBg.Position = UDim2.new(0, 20, 0, 100)
    progressBg.BackgroundColor3 = Color3.fromRGB(25, 28, 32) -- Secondary color
    progressBg.BackgroundTransparency = 0.5
    progressBg.BorderSizePixel = 0
    
    local progressBgCorner = Instance.new("UICorner", progressBg)
    progressBgCorner.CornerRadius = UDim.new(0, 3)
    
    -- Progress bar fill
    local progressFill = Instance.new("Frame", progressBg)
    progressFill.Name = "ProgressFill"
    progressFill.Size = UDim2.new(0, 0, 1, 0) -- Start at 0 width
    progressFill.BackgroundColor3 = Color3.fromRGB(50, 200, 100) -- Enabled color
    progressFill.BorderSizePixel = 0
    
    local progressFillCorner = Instance.new("UICorner", progressFill)
    progressFillCorner.CornerRadius = UDim.new(0, 3)
    
    -- Version text
    local versionText = Instance.new("TextLabel", container)
    versionText.Name = "VersionText"
    versionText.Size = UDim2.new(1, -40, 0, 20)
    versionText.Position = UDim2.new(0, 20, 1, -30)
    versionText.BackgroundTransparency = 1
    versionText.Text = "v1.0.0"
    versionText.TextColor3 = Color3.fromRGB(130, 135, 140) -- Secondary text color
    versionText.Font = Enum.Font.Gotham
    versionText.TextSize = 12
    versionText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Animate in
    container.BackgroundTransparency = 1
    logoText.TextTransparency = 1
    statusText.TextTransparency = 1
    progressBg.BackgroundTransparency = 1
    progressFill.BackgroundTransparency = 1
    versionText.TextTransparency = 1
    stroke.Transparency = 1
    shadow.ImageTransparency = 1
    
    -- Start animation
    self.Container = container
    self.StatusText = statusText
    self.ProgressFill = progressFill
    self.ProgressBg = progressBg
    self.ScreenGui = screenGui
    self.CurrentProgress = 0
    
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    tweenService:Create(container, tweenInfo, {BackgroundTransparency = 0.1}):Play()
    tweenService:Create(logoText, tweenInfo, {TextTransparency = 0}):Play()
    tweenService:Create(statusText, tweenInfo, {TextTransparency = 0}):Play()
    tweenService:Create(progressBg, tweenInfo, {BackgroundTransparency = 0.5}):Play()
    tweenService:Create(progressFill, tweenInfo, {BackgroundTransparency = 0}):Play()
    tweenService:Create(versionText, tweenInfo, {TextTransparency = 0.3}):Play()
    tweenService:Create(stroke, tweenInfo, {Transparency = 0.2}):Play()
    tweenService:Create(shadow, tweenInfo, {ImageTransparency = 0.6}):Play()
    
    return self
end

-- Update status text and progress
function Splash:UpdateStatus(text, progress)
    if not self.StatusText or not self.ProgressFill or not self.ProgressBg then return end
    
    if text then
        self.StatusText.Text = text
    end
    
    if progress then
        -- Store current progress
        self.CurrentProgress = progress
        
        -- Calculate absolute width based on progress percentage
        local bgWidth = self.ProgressBg.AbsoluteSize.X
        local targetWidth = bgWidth * progress
        
        -- Directly set size without tweening first (more reliable)
        self.ProgressFill.Size = UDim2.new(progress, 0, 1, 0)
        
        -- Then apply tween for smooth animation
        local tweenService = game:GetService("TweenService")
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        -- Create and play the tween
        local tween = tweenService:Create(self.ProgressFill, tweenInfo, {
            Size = UDim2.new(progress, 0, 1, 0)
        })
        tween:Play()
        
        -- Debug output
        print("Updating progress bar to: " .. progress .. " (width: " .. targetWidth .. "px)")
    end
end

-- Hide the splash screen with animation
function Splash:Hide()
    if not self.Container then return end
    
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    
    local elements = self.Container:GetDescendants()
    table.insert(elements, self.Container)
    
    for _, element in ipairs(elements) do
        if element:IsA("Frame") or element:IsA("TextLabel") then
            tweenService:Create(element, tweenInfo, {BackgroundTransparency = 1}):Play()
        end
        
        if element:IsA("TextLabel") then
            tweenService:Create(element, tweenInfo, {TextTransparency = 1}):Play()
        end
        
        if element:IsA("UIStroke") then
            tweenService:Create(element, tweenInfo, {Transparency = 1}):Play()
        end
        
        if element:IsA("ImageLabel") then
            tweenService:Create(element, tweenInfo, {ImageTransparency = 1}):Play()
        end
    end
    
    -- Remove after animation completes
    task.delay(0.6, function()
        if self.ScreenGui then
            self.ScreenGui:Destroy()
            self.ScreenGui = nil
            self.Container = nil
            self.StatusText = nil
            self.ProgressFill = nil
            self.ProgressBg = nil
        end
    end)
end

return Splash
