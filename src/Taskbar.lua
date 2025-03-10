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
        local taskbar = Utilities.createInstance("Frame", {
            Parent = _G.CensuraG.ScreenGui,
            Position = UDim2.new(0, 10, 1, 40), -- Start off-screen below the bottom edge
            Size = UDim2.new(1, -210, 0, 40), -- Space for cluster (200px + 10px padding)
            BackgroundTransparency = 1, -- Fully transparent frame
            Visible = false,
            ZIndex = 1
        })
        self.Instance = taskbar
        logger:debug("Taskbar created: Position: %s, Size: %s, ZIndex: %d", tostring(taskbar.Position), tostring(taskbar.Size), taskbar.ZIndex)

        -- Subtle gradient for buttons and cluster
        local buttonContainer = Utilities.createInstance("Frame", {
            Parent = taskbar,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 0.7,
            BackgroundColor3 = Styling.Colors.Highlight,
            ZIndex = 2
        })
        local gradient = Utilities.createInstance("UIGradient", {
            Parent = buttonContainer,
            Color = ColorSequence.new(Color3.fromRGB(40, 40, 40), Color3.fromRGB(60, 60, 60)),
            Transparency = NumberSequence.new(0.3),
            Rotation = 90
        })
        local containerStroke = Utilities.createInstance("UIStroke", {
            Parent = buttonContainer,
            Thickness = 1,
            Color = Color3.fromRGB(200, 200, 200),
            Transparency = 0.4
        })

        -- Subtle shadow for depth
        local shadow = Utilities.createTaperedShadow(taskbar, 5, 5, 0.9)
        shadow.ZIndex = 1

        -- Ensure buttonContainer is fully instantiated before creating cluster
        task.wait() -- Small delay to ensure instantiation
        logger:debug("Button container created: Parent: %s, Size: %s, ZIndex: %d", tostring(buttonContainer.Parent), tostring(buttonContainer.Size), buttonContainer.ZIndex)

        -- Initialize cluster on the right side, parented to buttonContainer
        self.Cluster = _G.CensuraG.Cluster.new({Instance = buttonContainer})
        if self.Cluster and self.Cluster.Instance then
            logger:info("Cluster initialized on taskbar, parent: %s", tostring(buttonContainer))
        else
            logger:error("Failed to initialize cluster on taskbar, parent: %s", tostring(buttonContainer))
        end

        local hoverDebounce = false
        local lastInputTime = 0
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local screenHeight = _G.CensuraG.ScreenGui.AbsoluteSize.Y
                local mouseY = input.Position.Y
                local threshold = screenHeight * 0.2 -- Bottom 20% of the screen
                local padding = 5 -- Small padding from the bottom edge
                local taskbarHeight = 40 -- Taskbar height

                if mouseY >= screenHeight - threshold and not taskbar.Visible and not hoverDebounce then
                    hoverDebounce = true
                    lastInputTime = tick()
                    task.wait(0.1)
                    if tick() - lastInputTime >= 0.1 then
                        taskbar.Visible = true
                        -- Slide up to reveal the taskbar (top edge at padding)
                        Animation:SlideY(taskbar, padding, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                        if self.Cluster and self.Cluster.Instance then
                            self.Cluster.Instance.Visible = true
                        end
                        logger:debug("Taskbar shown at position: %s", tostring(taskbar.Position))
                    end
                    hoverDebounce = false
                elseif mouseY < screenHeight - threshold and taskbar.Visible and not hoverDebounce then
                    hoverDebounce = true
                    lastInputTime = tick()
                    task.wait(0.2)
                    if tick() - lastInputTime >= 0.2 then
                        -- Slide down to hide the taskbar (bottom edge off-screen)
                        Animation:SlideY(taskbar, taskbarHeight, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
                            taskbar.Visible = false
                            if self.Cluster and self.Cluster.Instance then
                                self.Cluster.Instance.Visible = false
                            end
                            logger:debug("Taskbar hidden at position: %s", tostring(taskbar.Position))
                        end)
                    end
                    hoverDebounce = false
                end
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
