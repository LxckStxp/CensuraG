-- CensuraG/src/ui/Splash.lua (Modern Glassmorphic Design)
local Splash = {}

-- Services for advanced animations
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Modern glassmorphic theme constants (hardcoded since this loads first)
local GLASS_THEME = {
    -- Glassmorphic colors
    PrimaryColor = Color3.fromRGB(22, 28, 35),
    SecondaryColor = Color3.fromRGB(32, 40, 50),
    AccentColor = Color3.fromRGB(120, 180, 255),
    TextColor = Color3.fromRGB(255, 255, 255),
    SecondaryTextColor = Color3.fromRGB(180, 185, 190),
    
    -- Glassmorphic transparency
    GlassTransparency = 0.15,
    BorderTransparency = 0.6,
    
    -- Modern fonts
    Font = Enum.Font.GothamMedium,
    BoldFont = Enum.Font.GothamBold,
    TextSize = 14
}

-- Utility for smooth easing
local function createEasingTween(object, properties, duration, easing, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.5,
        easing or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )
    return TweenService:Create(object, tweenInfo, properties)
end

-- Create glassmorphic blur effect
local function createBlurEffect(parent)
    local blurFrame = Instance.new("Frame")
    blurFrame.Name = "GlassBlur"
    blurFrame.Size = UDim2.new(1, 0, 1, 0)
    blurFrame.BackgroundColor3 = GLASS_THEME.PrimaryColor
    blurFrame.BackgroundTransparency = GLASS_THEME.GlassTransparency
    blurFrame.BorderSizePixel = 0
    blurFrame.Parent = parent
    
    -- Multiple layers for depth effect
    for i = 1, 3 do
        local layer = Instance.new("Frame", blurFrame)
        layer.Size = UDim2.new(1, 0, 1, 0)
        layer.BackgroundColor3 = GLASS_THEME.SecondaryColor
        layer.BackgroundTransparency = 0.8 + (i * 0.05)
        layer.BorderSizePixel = 0
        layer.ZIndex = -i
    end
    
    return blurFrame
end

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

-- Show a modern glassmorphic splash screen
function Splash:Show()
    local screenGui = createScreenGui()
    
    -- Create animated background overlay
    local overlay = Instance.new("Frame")
    overlay.Name = "BackgroundOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.3
    overlay.BorderSizePixel = 0
    overlay.Parent = screenGui
    
    -- Main glassmorphic container
    local container = Instance.new("Frame")
    container.Name = "SplashContainer"
    container.Size = UDim2.new(0, 380, 0, 200) -- Larger, more modern size
    container.Position = UDim2.new(0.5, -190, 0.5, -100)
    container.BackgroundColor3 = GLASS_THEME.PrimaryColor
    container.BackgroundTransparency = GLASS_THEME.GlassTransparency
    container.BorderSizePixel = 0
    container.Parent = screenGui
    
    -- Modern glassmorphic corner radius
    local corner = Instance.new("UICorner", container)
    corner.CornerRadius = UDim.new(0, 20) -- More rounded for modern look
    
    -- Glassmorphic border with gradient effect
    local stroke = Instance.new("UIStroke", container)
    stroke.Color = GLASS_THEME.AccentColor
    stroke.Thickness = 1
    stroke.Transparency = GLASS_THEME.BorderTransparency
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    -- Advanced drop shadow system
    local shadowContainer = Instance.new("Frame", screenGui)
    shadowContainer.Size = container.Size + UDim2.new(0, 40, 0, 40)
    shadowContainer.Position = container.Position - UDim2.new(0, 20, 0, 20)
    shadowContainer.BackgroundTransparency = 1
    shadowContainer.ZIndex = container.ZIndex - 1
    
    -- Multiple shadow layers for depth
    for i = 1, 4 do
        local shadow = Instance.new("Frame", shadowContainer)
        shadow.Size = UDim2.new(1, 0, 1, 0)
        shadow.Position = UDim2.new(0, i * 2, 0, i * 2)
        shadow.BackgroundColor3 = Color3.new(0, 0, 0)
        shadow.BackgroundTransparency = 0.6 + (i * 0.1)
        shadow.BorderSizePixel = 0
        shadow.ZIndex = -i
        
        local shadowCorner = Instance.new("UICorner", shadow)
        shadowCorner.CornerRadius = UDim.new(0, 20)
    end
    
    -- Modern logo section
    local logoContainer = Instance.new("Frame", container)
    logoContainer.Size = UDim2.new(1, -40, 0, 60)
    logoContainer.Position = UDim2.new(0, 20, 0, 25)
    logoContainer.BackgroundTransparency = 1
    
    -- Animated logo icon
    local logoIcon = Instance.new("TextLabel", logoContainer)
    logoIcon.Name = "LogoIcon"
    logoIcon.Size = UDim2.new(0, 40, 0, 40)
    logoIcon.Position = UDim2.new(0, 0, 0, 10)
    logoIcon.BackgroundColor3 = GLASS_THEME.AccentColor
    logoIcon.BackgroundTransparency = 0.1
    logoIcon.BorderSizePixel = 0
    logoIcon.Text = "◈"
    logoIcon.TextColor3 = GLASS_THEME.TextColor
    logoIcon.Font = GLASS_THEME.BoldFont
    logoIcon.TextSize = 24
    
    local logoIconCorner = Instance.new("UICorner", logoIcon)
    logoIconCorner.CornerRadius = UDim.new(0, 12)
    
    local logoIconStroke = Instance.new("UIStroke", logoIcon)
    logoIconStroke.Color = GLASS_THEME.AccentColor
    logoIconStroke.Thickness = 1
    logoIconStroke.Transparency = 0.4
    
    -- Main logo text with gradient effect
    local logoText = Instance.new("TextLabel", logoContainer)
    logoText.Name = "LogoText"
    logoText.Size = UDim2.new(1, -50, 0, 32)
    logoText.Position = UDim2.new(0, 55, 0, 4)
    logoText.BackgroundTransparency = 1
    logoText.Text = "CensuraG"
    logoText.TextColor3 = GLASS_THEME.TextColor
    logoText.Font = GLASS_THEME.BoldFont
    logoText.TextSize = 28
    logoText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel", logoContainer)
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, -50, 0, 16)
    subtitle.Position = UDim2.new(0, 55, 0, 36)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Glassmorphic Desktop Environment"
    subtitle.TextColor3 = GLASS_THEME.SecondaryTextColor
    subtitle.Font = GLASS_THEME.Font
    subtitle.TextSize = 12
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Modern status section
    local statusContainer = Instance.new("Frame", container)
    statusContainer.Size = UDim2.new(1, -40, 0, 40)
    statusContainer.Position = UDim2.new(0, 20, 0, 100)
    statusContainer.BackgroundTransparency = 1
    
    -- Status text with modern styling
    local statusText = Instance.new("TextLabel", statusContainer)
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, 0, 0, 20)
    statusText.Position = UDim2.new(0, 0, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Initializing system..."
    statusText.TextColor3 = GLASS_THEME.AccentColor
    statusText.Font = GLASS_THEME.Font
    statusText.TextSize = 14
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    -- Modern glassmorphic progress bar
    local progressContainer = Instance.new("Frame", statusContainer)
    progressContainer.Size = UDim2.new(1, 0, 0, 8)
    progressContainer.Position = UDim2.new(0, 0, 0, 25)
    progressContainer.BackgroundColor3 = GLASS_THEME.SecondaryColor
    progressContainer.BackgroundTransparency = 0.4
    progressContainer.BorderSizePixel = 0
    
    local progressBgCorner = Instance.new("UICorner", progressContainer)
    progressBgCorner.CornerRadius = UDim.new(0, 4)
    
    local progressStroke = Instance.new("UIStroke", progressContainer)
    progressStroke.Color = GLASS_THEME.AccentColor
    progressStroke.Thickness = 1
    progressStroke.Transparency = 0.7
    
    -- Animated progress fill with gradient effect
    local progressFill = Instance.new("Frame", progressContainer)
    progressFill.Name = "ProgressFill"
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = GLASS_THEME.AccentColor
    progressFill.BackgroundTransparency = 0.2
    progressFill.BorderSizePixel = 0
    progressFill.ClipsDescendants = true
    
    local progressFillCorner = Instance.new("UICorner", progressFill)
    progressFillCorner.CornerRadius = UDim.new(0, 4)
    
    -- Animated shimmer effect inside progress bar
    local shimmer = Instance.new("Frame", progressFill)
    shimmer.Size = UDim2.new(0.3, 0, 1, 0)
    shimmer.Position = UDim2.new(-0.3, 0, 0, 0)
    shimmer.BackgroundColor3 = GLASS_THEME.TextColor
    shimmer.BackgroundTransparency = 0.6
    shimmer.BorderSizePixel = 0
    
    local shimmerCorner = Instance.new("UICorner", shimmer)
    shimmerCorner.CornerRadius = UDim.new(0, 4)
    
    -- Version and build info
    local infoContainer = Instance.new("Frame", container)
    infoContainer.Size = UDim2.new(1, -40, 0, 25)
    infoContainer.Position = UDim2.new(0, 20, 1, -35)
    infoContainer.BackgroundTransparency = 1
    
    local versionText = Instance.new("TextLabel", infoContainer)
    versionText.Name = "VersionText"
    versionText.Size = UDim2.new(0.5, 0, 1, 0)
    versionText.Position = UDim2.new(0, 0, 0, 0)
    versionText.BackgroundTransparency = 1
    versionText.Text = "v2.0.0"
    versionText.TextColor3 = GLASS_THEME.SecondaryTextColor
    versionText.Font = GLASS_THEME.Font
    versionText.TextSize = 11
    versionText.TextXAlignment = Enum.TextXAlignment.Left
    
    local buildText = Instance.new("TextLabel", infoContainer)
    buildText.Name = "BuildText"
    buildText.Size = UDim2.new(0.5, 0, 1, 0)
    buildText.Position = UDim2.new(0.5, 0, 0, 0)
    buildText.BackgroundTransparency = 1
    buildText.Text = "Build " .. math.floor(tick())
    buildText.TextColor3 = GLASS_THEME.SecondaryTextColor
    buildText.Font = GLASS_THEME.Font
    buildText.TextSize = 11
    buildText.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Store references for animations
    self.ScreenGui = screenGui
    self.Overlay = overlay
    self.Container = container
    self.ShadowContainer = shadowContainer
    self.LogoIcon = logoIcon
    self.LogoText = logoText
    self.Subtitle = subtitle
    self.StatusText = statusText
    self.ProgressContainer = progressContainer
    self.ProgressFill = progressFill
    self.Shimmer = shimmer
    self.VersionText = versionText
    self.BuildText = buildText
    self.Stroke = stroke
    self.CurrentProgress = 0
    
    -- Set initial states for sophisticated entrance animation
    overlay.BackgroundTransparency = 1
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(0, 320, 0, 160) -- Smaller initial size
    stroke.Transparency = 1
    
    -- Hide all elements initially
    for _, element in pairs({logoIcon, logoText, subtitle, statusText, versionText, buildText}) do
        element.TextTransparency = 1
    end
    
    logoIcon.BackgroundTransparency = 1
    logoIconStroke.Transparency = 1
    progressContainer.BackgroundTransparency = 1
    progressStroke.Transparency = 1
    progressFill.BackgroundTransparency = 1
    
    for _, shadow in pairs(shadowContainer:GetChildren()) do
        shadow.BackgroundTransparency = 1
    end
    
    -- Sophisticated entrance animation sequence
    local animationSequence = {
        -- Stage 1: Overlay fade in
        {0.0, function()
            createEasingTween(overlay, {BackgroundTransparency = 0.3}, 0.6, Enum.EasingStyle.Sine):Play()
        end},
        
        -- Stage 2: Container scale in with shadows
        {0.2, function()
            createEasingTween(container, {
                BackgroundTransparency = GLASS_THEME.GlassTransparency,
                Size = UDim2.new(0, 380, 0, 200)
            }, 0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
            
            createEasingTween(stroke, {Transparency = GLASS_THEME.BorderTransparency}, 0.8):Play()
            
            -- Animate shadows in sequence
            for i, shadow in pairs(shadowContainer:GetChildren()) do
                task.delay(i * 0.05, function()
                    createEasingTween(shadow, {BackgroundTransparency = shadow.BackgroundTransparency}, 0.4):Play()
                end)
            end
        end},
        
        -- Stage 3: Logo animation
        {0.6, function()
            -- Logo icon with bounce
            createEasingTween(logoIcon, {
                BackgroundTransparency = 0.1,
                TextTransparency = 0
            }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
            
            createEasingTween(logoIconStroke, {Transparency = 0.4}, 0.5):Play()
            
            -- Start logo icon rotation animation
            local rotateConnection
            rotateConnection = RunService.Heartbeat:Connect(function()
                logoIcon.Rotation = logoIcon.Rotation + 1
                if logoIcon.Rotation >= 360 then
                    logoIcon.Rotation = 0
                end
            end)
            
            -- Main text with typewriter effect
            task.delay(0.2, function()
                createEasingTween(logoText, {TextTransparency = 0}, 0.6, Enum.EasingStyle.Quad):Play()
                
                -- Typewriter animation
                local fullText = logoText.Text
                logoText.Text = ""
                for i = 1, #fullText do
                    task.delay(i * 0.05, function()
                        logoText.Text = string.sub(fullText, 1, i)
                    end)
                end
            end)
            
            -- Subtitle fade in
            task.delay(0.8, function()
                createEasingTween(subtitle, {TextTransparency = 0}, 0.4):Play()
            end)
        end},
        
        -- Stage 4: Progress system
        {1.2, function()
            createEasingTween(progressContainer, {BackgroundTransparency = 0.4}, 0.4):Play()
            createEasingTween(progressStroke, {Transparency = 0.7}, 0.4):Play()
            createEasingTween(progressFill, {BackgroundTransparency = 0.2}, 0.4):Play()
            
            -- Start shimmer animation
            local shimmerTween = createEasingTween(shimmer, {Position = UDim2.new(1, 0, 0, 0)}, 2, Enum.EasingStyle.Linear)
            shimmerTween:Play()
            
            shimmerTween.Completed:Connect(function()
                shimmer.Position = UDim2.new(-0.3, 0, 0, 0)
                createEasingTween(shimmer, {Position = UDim2.new(1, 0, 0, 0)}, 2, Enum.EasingStyle.Linear):Play()
            end)
        end},
        
        -- Stage 5: Status and info
        {1.6, function()
            createEasingTween(statusText, {TextTransparency = 0}, 0.4):Play()
            createEasingTween(versionText, {TextTransparency = 0}, 0.4):Play()
            createEasingTween(buildText, {TextTransparency = 0}, 0.4):Play()
        end}
    }
    
    -- Execute animation sequence
    for _, stage in pairs(animationSequence) do
        local delay, animation = stage[1], stage[2]
        task.delay(delay, animation)
    end
    
    return self
end

-- Update status text and progress with smooth animations
function Splash:UpdateStatus(text, progress)
    if not self.StatusText or not self.ProgressFill then return end
    
    if text then
        -- Smooth text transition with fade effect
        local oldTransparency = self.StatusText.TextTransparency
        createEasingTween(self.StatusText, {TextTransparency = 0.8}, 0.15):Play()
        
        task.delay(0.15, function()
            self.StatusText.Text = text
            createEasingTween(self.StatusText, {TextTransparency = oldTransparency}, 0.15):Play()
        end)
    end
    
    if progress then
        self.CurrentProgress = progress
        
        -- Smooth progress animation with easing
        createEasingTween(self.ProgressFill, {
            Size = UDim2.new(progress, 0, 1, 0)
        }, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out):Play()
        
        -- Add pulse effect on significant progress milestones
        if progress >= 0.25 and progress < 0.3 then
            self:AddProgressPulse(GLASS_THEME.AccentColor)
        elseif progress >= 0.75 and progress < 0.8 then
            self:AddProgressPulse(Color3.fromRGB(100, 255, 150))
        end
    end
end

-- Add visual feedback pulse effect
function Splash:AddProgressPulse(color)
    if not self.ProgressContainer then return end
    
    local pulse = Instance.new("Frame", self.ProgressContainer)
    pulse.Size = UDim2.new(1, 4, 1, 4)
    pulse.Position = UDim2.new(0, -2, 0, -2)
    pulse.BackgroundColor3 = color
    pulse.BackgroundTransparency = 0.6
    pulse.BorderSizePixel = 0
    pulse.ZIndex = -1
    
    local pulseCorner = Instance.new("UICorner", pulse)
    pulseCorner.CornerRadius = UDim.new(0, 6)
    
    -- Animate pulse
    createEasingTween(pulse, {
        Size = UDim2.new(1, 12, 1, 12),
        Position = UDim2.new(0, -6, 0, -6),
        BackgroundTransparency = 1
    }, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
    
    task.delay(0.6, function()
        pulse:Destroy()
    end)
end

-- Hide the splash screen with sophisticated exit animation
function Splash:Hide()
    if not self.Container then return end
    
    -- Sophisticated exit sequence
    local exitSequence = {
        -- Stage 1: Progress completion effect
        {0.0, function()
            if self.ProgressFill then
                createEasingTween(self.ProgressFill, {
                    BackgroundColor3 = Color3.fromRGB(100, 255, 150),
                    Size = UDim2.new(1, 0, 1, 0)
                }, 0.3, Enum.EasingStyle.Quad):Play()
                
                -- Final pulse effect
                self:AddProgressPulse(Color3.fromRGB(100, 255, 150))
            end
        end},
        
        -- Stage 2: Status completion
        {0.3, function()
            if self.StatusText then
                createEasingTween(self.StatusText, {TextTransparency = 0.8}, 0.2):Play()
                task.delay(0.1, function()
                    self.StatusText.Text = "Ready!"
                    createEasingTween(self.StatusText, {
                        TextTransparency = 0,
                        TextColor3 = Color3.fromRGB(100, 255, 150)
                    }, 0.2):Play()
                end)
            end
        end},
        
        -- Stage 3: Scale out animation
        {0.8, function()
            -- Container scale out with rotation
            createEasingTween(self.Container, {
                Size = UDim2.new(0, 320, 0, 160),
                BackgroundTransparency = 1,
                Rotation = 5
            }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In):Play()
            
            -- Fade out stroke
            if self.Stroke then
                createEasingTween(self.Stroke, {Transparency = 1}, 0.5):Play()
            end
            
            -- Fade out shadows
            if self.ShadowContainer then
                for _, shadow in pairs(self.ShadowContainer:GetChildren()) do
                    createEasingTween(shadow, {BackgroundTransparency = 1}, 0.4):Play()
                end
            end
            
            -- Fade out all text elements
            for _, element in pairs({
                self.LogoIcon, self.LogoText, self.Subtitle, 
                self.StatusText, self.VersionText, self.BuildText
            }) do
                if element then
                    createEasingTween(element, {TextTransparency = 1}, 0.4):Play()
                    if element.BackgroundTransparency then
                        createEasingTween(element, {BackgroundTransparency = 1}, 0.4):Play()
                    end
                end
            end
            
            -- Fade out progress system
            if self.ProgressContainer then
                createEasingTween(self.ProgressContainer, {BackgroundTransparency = 1}, 0.4):Play()
                if self.ProgressFill then
                    createEasingTween(self.ProgressFill, {BackgroundTransparency = 1}, 0.4):Play()
                end
            end
        end},
        
        -- Stage 4: Final overlay fade
        {1.1, function()
            if self.Overlay then
                createEasingTween(self.Overlay, {BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Sine):Play()
            end
        end}
    }
    
    -- Execute exit sequence
    for _, stage in pairs(exitSequence) do
        local delay, animation = stage[1], stage[2]
        task.delay(delay, animation)
    end
    
    -- Clean up after all animations complete
    task.delay(1.8, function()
        if self.ScreenGui then
            self.ScreenGui:Destroy()
            
            -- Clear all references
            self.ScreenGui = nil
            self.Overlay = nil
            self.Container = nil
            self.ShadowContainer = nil
            self.StatusText = nil
            self.ProgressFill = nil
            self.ProgressContainer = nil
            self.LogoIcon = nil
            self.LogoText = nil
            self.Subtitle = nil
            self.VersionText = nil
            self.BuildText = nil
            self.Stroke = nil
        end
    end)
end

return Splash
