-- Taskbar.lua: Enhanced taskbar with transparent frame, polished animations, and cluster
local Taskbar = {}
Taskbar.Windows = {}

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local UserInputService = game:GetService("UserInputService")
local logger = _G.CensuraG.Logger

function Taskbar:Init()
    if not self.Instance then
        -- Create the taskbar frame
        local taskbar = Utilities.createInstance("Frame", {
            Parent = _G.CensuraG.ScreenGui,
            Position = UDim2.new(0, 10, 1, 40), -- Start off-screen below the bottom
            Size = UDim2.new(1, -210, 0, 40),   -- Width spans screen minus padding, height 40
            BackgroundTransparency = 0.7,       -- Subtle visibility
            Visible = false,                    -- Hidden initially
            ZIndex = 2                          -- Ensure it’s above most UI elements
        })
        self.Instance = taskbar
        logger:debug("Taskbar created: Position: %s, Size: %s", tostring(taskbar.Position), tostring(taskbar.Size))

        -- Button container with gradient
        local buttonContainer = Utilities.createInstance("Frame", {
            Parent = taskbar,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 0.7,
            BackgroundColor3 = Styling.Colors.Highlight,
            ZIndex = 3
        })
        Utilities.createInstance("UIGradient", {
            Parent = buttonContainer,
            Color = ColorSequence.new(Color3.fromRGB(40, 40, 40), Color3.fromRGB(60, 60, 60)),
            Transparency = NumberSequence.new(0.3),
            Rotation = 90
        })
        Utilities.createInstance("UIStroke", {
            Parent = buttonContainer,
            Thickness = 1,
            Color = Color3.fromRGB(200, 200, 200),
            Transparency = 0.4
        })

        -- Add a shadow for depth
        local shadow = Utilities.createTaperedShadow(taskbar, 5, 5, 0.9)
        shadow.ZIndex = 1

        -- Initialize the cluster
        task.wait(0.1) -- Ensure container is ready
        self.Cluster = _G.CensuraG.Cluster.new({Instance = buttonContainer})
        if not self.Cluster or not self.Cluster.Instance then
            logger:error("Cluster failed to initialize")
            return
        end
        self.Cluster.Instance.Visible = false -- Sync with taskbar initially
        logger:info("Cluster initialized successfully")

        -- Animation and input handling
        local isAnimating = false
        local hoverDebounce = false
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseMovement or isAnimating then
                return
            end

            local screenHeight = _G.CensuraG.ScreenGui.AbsoluteSize.Y
            local mouseY = input.Position.Y
            local threshold = screenHeight * 0.2 -- Bottom 20%

            if mouseY >= screenHeight - threshold and not taskbar.Visible then
                if hoverDebounce then return end
                hoverDebounce = true
                taskbar.Visible = true
                self.Cluster.Instance.Visible = true
                taskbar.BackgroundTransparency = 0.7 -- Ensure visibility
                isAnimating = true
                Animation:SlideY(taskbar, -80, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
                    isAnimating = false
                    logger:debug("Taskbar shown at: %s", tostring(taskbar.Position))
                    hoverDebounce = false
                end)
            elseif mouseY < screenHeight - threshold and taskbar.Visible then
                if hoverDebounce then return end
                hoverDebounce = true
                isAnimating = true
                Animation:SlideY(taskbar, 40, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
                    taskbar.Visible = false
                    self.Cluster.Instance.Visible = false
                    isAnimating = false
                    logger:debug("Taskbar hidden at: %s", tostring(taskbar.Position))
                    hoverDebounce = false
                end)
            end
        end)
    end
end

function Taskbar:AddWindow(window)
    if not window or not window.Instance or not self.Instance then
        logger:warn("Invalid window or taskbar instance in AddWindow")
        return
    end

    local titleLabel = window.Instance:FindFirstChildWhichIsA("TextLabel")
    if not titleLabel then
        logger:warn("No TextLabel found in window instance")
        return
    end

    local title = titleLabel.Text
    local buttonWidth = 150
    local spacing = 15
    local totalWidth = 0

    for _, btn in ipairs(self.Instance:GetChildren()) do
        if btn:IsA("TextButton") then
            totalWidth = totalWidth + btn.Size.X.Offset + spacing
        end
    end

    local button = Utilities.createInstance("TextButton", {
        Parent = self.Instance,
        Position = UDim2.new(0, totalWidth, 0, 5),
        Size = UDim2.new(0, buttonWidth, 0, 30),
        Text = title,
        TextTruncate = Enum.TextTruncate.AtEnd,
        BackgroundTransparency = 0.4,
        BackgroundColor3 = Styling.Colors.Highlight,
        Visible = true,
        ZIndex = 3
    })
    Styling:Apply(button, "TextButton")
    logger:debug("Taskbar button created: Text: %s, Position: %s, Size: %s, ZIndex: %d, Visible: %s", title, tostring(button.Position), tostring(button.Size), button.ZIndex, tostring(button.Visible))

    local buttonStroke = Utilities.createInstance("UIStroke", {
        Parent = button,
        Thickness = 1,
        Color = Color3.fromRGB(200, 200, 200),
        Transparency = 0.3
    })

    local buttonShadow = Utilities.createTaperedShadow(button, 3, 3, 0.95)
    buttonShadow.ZIndex = 2

    button.MouseEnter:Connect(function()
        button.BackgroundTransparency = 0.2
        button.BorderSizePixel = 1
        button.BorderColor3 = Styling.Colors.Accent
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundTransparency = 0.4
        button.BorderSizePixel = 0
    end)

    button.MouseButton1Click:Connect(function()
        if window and window.Maximize then
            window:Maximize()
        end
        button:Destroy()
        buttonShadow:Destroy()
        local index = table.find(self.Windows, window)
        if index then
            table.remove(self.Windows, index)
        end
    end)

    table.insert(self.Windows, window)
end

function Taskbar:Destroy()
    if self.Instance then
        if self.Cluster and self.Cluster.Destroy then
            self.Cluster:Destroy()
        end
        self.Instance:Destroy()
        logger:info("Taskbar destroyed")
    end
end

return Taskbar
