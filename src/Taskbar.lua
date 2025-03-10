-- Taskbar.lua: Enhanced taskbar with modern miltech styling and cluster stability
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
            Position = UDim2.new(0, 10, 1, 40),
            Size = UDim2.new(1, -210, 0, 40),
            BackgroundTransparency = Styling.Transparency.ElementBackground,
            ClipsDescendants = false,
            Visible = false,
            ZIndex = 2
        })
        self.Instance = taskbar
        Styling:Apply(taskbar, "Frame")
        logger:debug("Taskbar created: Position: %s, Size: %s, ZIndex: %d", tostring(taskbar.Position), tostring(taskbar.Size), taskbar.ZIndex)

        local buttonContainer = Utilities.createInstance("Frame", {
            Parent = taskbar,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = Styling.Transparency.ElementBackground,
            ClipsDescendants = false,
            ZIndex = taskbar.ZIndex + 1
        })
        Styling:Apply(buttonContainer, "Frame")
        logger:debug("Button container created: Parent: %s, Size: %s, ZIndex: %d", tostring(buttonContainer.Parent), tostring(buttonContainer.Size), buttonContainer.ZIndex)

        local shadow = Utilities.createTaperedShadow(taskbar, 5, 5, 0.9)
        shadow.ZIndex = taskbar.ZIndex - 1
        logger:debug("Taskbar shadow created: ZIndex: %d", shadow.ZIndex)

        task.wait(0.1)

        self.Cluster = _G.CensuraG.Cluster.new({Instance = buttonContainer})
        if not self.Cluster or not self.Cluster.Instance then
            logger:error("Failed to initialize cluster on taskbar, parent: %s", tostring(buttonContainer))
            return
        end
        self.Cluster.Instance.Visible = false
        self.Cluster.Instance.BackgroundTransparency = Styling.Transparency.ElementBackground
        self.Cluster.Instance.ZIndex = buttonContainer.ZIndex + 1
        logger:info("Cluster initialized on taskbar, parent: %s, Position: %s, Visible: %s, ZIndex: %d", 
            tostring(buttonContainer), tostring(self.Cluster.Instance.Position), tostring(self.Cluster.Instance.Visible), self.Cluster.Instance.ZIndex)

        local isAnimating = false
        local hoverDebounce = false
        local lastInputTime = 0
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseMovement or isAnimating then
                return
            end

            local screenHeight = _G.CensuraG.ScreenGui and _G.CensuraG.ScreenGui.AbsoluteSize and _G.CensuraG.ScreenGui.AbsoluteSize.Y or 600
            local mouseY = input.Position.Y
            local threshold = screenHeight * 0.2
            local padding = 5
            local taskbarHeight = 40

            if mouseY >= screenHeight - threshold and not taskbar.Visible and not hoverDebounce then
                hoverDebounce = true
                lastInputTime = tick()
                task.wait(0.1)
                if tick() - lastInputTime < 0.1 then return end
                isAnimating = true
                taskbar.Visible = true
                taskbar.BackgroundTransparency = Styling.Transparency.ElementBackground
                if self.Cluster and self.Cluster.Instance then
                    self.Cluster.Instance.Visible = true
                    self.Cluster.Instance.BackgroundTransparency = Styling.Transparency.ElementBackground
                    if self.Cluster.AvatarImage and self.Cluster.AvatarImage.Image then
                        self.Cluster.AvatarImage.Image.Visible = true
                        if self.Cluster.AvatarImage.Image.ImageTransparency then
                            self.Cluster.AvatarImage.Image.ImageTransparency = 0
                        end
                    end
                    if self.Cluster.DisplayName then
                        self.Cluster.DisplayName.Visible = true
                        self.Cluster.DisplayName.TextTransparency = 0
                    end
                    if self.Cluster.TimeLabel then
                        self.Cluster.TimeLabel.Visible = true
                        self.Cluster.TimeLabel.TextTransparency = 0
                    end
                    logger:debug("Cluster set to visible: %s, Position: %s, ZIndex: %d", tostring(self.Cluster.Instance.Visible), tostring(self.Cluster.Instance.Position), self.Cluster.Instance.ZIndex)
                end
                Animation:SlideY(taskbar, -taskbarHeight - padding, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
                    isAnimating = false
                    hoverDebounce = false
                    logger:debug("Taskbar shown at position: %s, ZIndex: %d", tostring(taskbar.Position), taskbar.ZIndex)
                end)
            elseif mouseY < screenHeight - threshold and taskbar.Visible and not hoverDebounce then
                hoverDebounce = true
                lastInputTime = tick()
                task.wait(0.2)
                if tick() - lastInputTime < 0.2 then return end
                isAnimating = true
                Animation:SlideY(taskbar, taskbarHeight, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
                    taskbar.Visible = false
                    taskbar.BackgroundTransparency = Styling.Transparency.ElementBackground
                    if self.Cluster and self.Cluster.Instance then
                        self.Cluster.Instance.Visible = false
                        logger:debug("Cluster set to hidden: %s, ZIndex: %d", tostring(self.Cluster.Instance.Visible), self.Cluster.Instance.ZIndex)
                    end
                    isAnimating = false
                    hoverDebounce = false
                    logger:debug("Taskbar hidden at position: %s, ZIndex: %d", tostring(taskbar.Position), taskbar.ZIndex)
                end)
            end
        end)

        function self:RefreshCluster()
            if self.Cluster and self.Cluster.Instance and taskbar.Visible then
                self.Cluster.Instance.Visible = true
                self.Cluster.Instance.BackgroundTransparency = Styling.Transparency.ElementBackground
                if self.Cluster.AvatarImage and self.Cluster.AvatarImage.Image then
                    self.Cluster.AvatarImage.Image.Visible = true
                    if self.Cluster.AvatarImage.Image.ImageTransparency then
                        self.Cluster.AvatarImage.Image.ImageTransparency = 0
                    end
                end
                if self.Cluster.DisplayName then
                    self.Cluster.DisplayName.Visible = true
                    self.Cluster.DisplayName.TextTransparency = 0
                end
                if self.Cluster.TimeLabel then
                    self.Cluster.TimeLabel.Visible = true
                    self.Cluster.TimeLabel.TextTransparency = 0
                end
                logger:debug("Cluster refreshed: Visible: %s, Position: %s, ZIndex: %d", tostring(self.Cluster.Instance.Visible), tostring(self.Cluster.Instance.Position), self.Cluster.Instance.ZIndex)
            end
        end
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
        BackgroundTransparency = Styling.Transparency.ElementBackground,
        ZIndex = self.Instance.ZIndex + 2
    })
    Styling:Apply(button, "TextButton")
    -- Force text visibility
    button.TextTransparency = 0
    button.Visible = true
    logger:debug("Taskbar button created: Text: %s, Position: %s, Size: %s, ZIndex: %d", title, tostring(button.Position), tostring(button.Size), button.ZIndex)

    local buttonShadow = Utilities.createTaperedShadow(button, 3, 3, 0.95)
    buttonShadow.ZIndex = button.ZIndex - 1

    button.MouseEnter:Connect(function()
        button.BackgroundTransparency = Styling.Transparency.ElementBackground - 0.1
        local stroke = button:FindFirstChild("UIStroke")
        if stroke then
            stroke.Transparency = 0.5
        end
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundTransparency = Styling.Transparency.ElementBackground
        local stroke = button:FindFirstChild("UIStroke")
        if stroke then
            stroke.Transparency = 0.85
        end
    end)

    button.MouseButton1Click:Connect(function()
        if window and window.Maximize then
            window:Maximize()
            self:RefreshCluster()
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
