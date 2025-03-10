-- Taskbar.lua: Minimal taskbar for minimized windows
local Taskbar = {}
Taskbar.Windows = {}

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local UserInputService = game:GetService("UserInputService")

function Taskbar:Init()
    if not self.Instance then
        local taskbar = Utilities.createInstance("Frame", {
            Parent = _G.CensuraG.ScreenGui,
            Position = UDim2.new(0, 10, 1, 0), -- 10px padding
            Size = UDim2.new(1, -20, 0, 40),   -- Reduced height
            BackgroundTransparency = 0.2,      -- Solid with slight transparency
            Visible = false,
            ZIndex = 1
        })
        self.Instance = taskbar

        local hoverDebounce = false
        local lastInputTime = 0
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local screenHeight = _G.CensuraG.ScreenGui.AbsoluteSize.Y
                local mouseY = input.Position.Y
                local threshold = screenHeight - 20

                if mouseY >= threshold and not taskbar.Visible and not hoverDebounce then
                    hoverDebounce = true
                    lastInputTime = tick()
                    task.wait(0.1)
                    if tick() - lastInputTime >= 0.1 then
                        taskbar.Visible = true
                        Animation:Tween(taskbar, {Position = UDim2.new(0, 10, 1, -40)}, 0.25)
                    end
                    hoverDebounce = false
                elseif mouseY < threshold and taskbar.Visible and not hoverDebounce then
                    hoverDebounce = true
                    lastInputTime = tick()
                    task.wait(0.2)
                    if tick() - lastInputTime >= 0.2 then
                        Animation:Tween(taskbar, {Position = UDim2.new(0, 10, 1, 0)}, 0.25, function()
                            taskbar.Visible = false
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
        warn("Invalid window or taskbar instance in AddWindow")
        return
    end

    local titleLabel = window.Instance:FindFirstChildWhichIsA("TextLabel")
    if not titleLabel then
        warn("No TextLabel found in window instance")
        return
    end

    local title = titleLabel.Text
    local buttonWidth = 150 -- Fixed width for consistency
    local spacing = 10
    local totalWidth = 0
    for _, w in ipairs(self.Windows) do
        local btn = self.Instance:GetChildren()[table.find(self.Windows, w)]
        if btn then
            totalWidth = totalWidth + btn.Size.X.Offset + spacing
        end
    end

    local button = Utilities.createInstance("TextButton", {
        Parent = self.Instance,
        Position = UDim2.new(0, totalWidth, 0, 5),
        Size = UDim2.new(0, buttonWidth, 0, 30),
        Text = title,
        TextTruncate = Enum.TextTruncate.AtEnd,
        BackgroundTransparency = 0,
        ZIndex = 2
    })
    Styling:Apply(button, "TextButton")

    local shadow = Utilities.createTaperedShadow(button, 3, 3, 0.9) -- Smaller offset

    button.MouseEnter:Connect(function()
        button.BorderSizePixel = 1
        button.BorderColor3 = Styling.Colors.Accent
    end)
    button.MouseLeave:Connect(function()
        button.BorderSizePixel = 0
    end)

    button.MouseButton1Click:Connect(function()
        if window and window.Maximize then
            window:Maximize()
        end
        button:Destroy()
        shadow:Destroy()
        local index = table.find(self.Windows, window)
        if index then
            table.remove(self.Windows, index)
        end
    end)

    table.insert(self.Windows, window)
end

function Taskbar:Destroy()
    if self.Instance then
        self.Instance:Destroy()
    end
end

return Taskbar
