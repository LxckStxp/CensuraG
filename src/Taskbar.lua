-- Taskbar.lua: Enhanced taskbar with reactive behavior, better spacing, and modern styling
local Taskbar = {}
Taskbar.Windows = {}

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local UserInputService = game:GetService("UserInputService")

function Taskbar:Init()
    if not self.Instance then -- Ensure initialization only happens once
        local taskbar = Utilities.createInstance("Frame", {
            Parent = _G.CensuraG.ScreenGui,
            Position = UDim2.new(0, 0, 1, 0), -- Start offscreen
            Size = UDim2.new(1, 0, 0, 60), -- Increased height for better visuals
            BackgroundTransparency = 0.8, -- More subtle transparency
            Visible = false,
            ZIndex = 1 -- Below windows but above base UI
        })
        self.Instance = taskbar

        -- Add a subtle background glow
        local stroke = Utilities.createInstance("UIStroke", {
            Parent = taskbar,
            Thickness = 1,
            Color = Styling.Colors.Border,
            Transparency = 0.7
        })

        -- Reactive show/hide with hover intent
        local hoverDebounce = false
        local lastInputTime = 0
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local screenHeight = _G.CensuraG.ScreenGui.AbsoluteSize.Y
                local mouseY = input.Position.Y
                local threshold = screenHeight - 20 -- Trigger when within 20px of bottom

                if mouseY >= threshold and not taskbar.Visible and not hoverDebounce then
                    hoverDebounce = true
                    lastInputTime = tick()
                    task.wait(0.1) -- Hover intent delay
                    if tick() - lastInputTime >= 0.1 then
                        taskbar.Visible = true
                        Animation:Tween(taskbar, {Position = UDim2.new(0, 0, 1, -60), BackgroundTransparency = 0.5}, 0.25)
                    end
                    hoverDebounce = false
                elseif mouseY < threshold and taskbar.Visible and not hoverDebounce then
                    hoverDebounce = true
                    lastInputTime = tick()
                    task.wait(0.2) -- Slightly longer hide delay
                    if tick() - lastInputTime >= 0.2 then
                        Animation:Tween(taskbar, {Position = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 0.8}, 0.25, function()
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
    local buttonWidth = math.clamp(#title * 8, 100, 200) -- Dynamic width based on title length
    local spacing = 20 -- Increased spacing
    local totalWidth = 0
    for _, w in ipairs(self.Windows) do
        local btn = self.Instance:GetChildren()[table.find(self.Windows, w)]
        if btn then
            totalWidth = totalWidth + btn.Size.X.Offset + spacing
        end
    end

    local button = Utilities.createInstance("TextButton", {
        Parent = self.Instance,
        Position = UDim2.new(0, totalWidth, 0, 10), -- Centered vertically with padding
        Size = UDim2.new(0, buttonWidth, 0, 40), -- Taller buttons
        Text = title,
        BackgroundTransparency = 0.5, -- Idle transparency
        ZIndex = 2
    })
    Styling:Apply(button, "TextButton")

    -- Add glow effect
    local stroke = Utilities.createInstance("UIStroke", {
        Parent = button,
        Thickness = 1,
        Color = Styling.Colors.Accent,
        Transparency = 0.8
    })

    -- Enhanced shadow
    local shadow = Utilities.createTaperedShadow(button, 5, 5, 1.2, 0.6)

    -- Advanced hover and click animations
    local originalSize = button.Size
    button.MouseEnter:Connect(function()
        Animation:Tween(button, {
            BackgroundTransparency = 0.2,
            Size = originalSize + UDim2.new(0, 10, 0, 5),
            BackgroundColor3 = Styling.Colors.Accent
        }, 0.15)
        Animation:Tween(stroke, {Transparency = 0.5}, 0.15)
    end)
    button.MouseLeave:Connect(function()
        Animation:Tween(button, {
            BackgroundTransparency = 0.5,
            Size = originalSize,
            BackgroundColor3 = Styling.Colors.Base
        }, 0.15)
        Animation:Tween(stroke, {Transparency = 0.8}, 0.15)
    end)

    button.MouseButton1Click:Connect(function()
        Animation:Tween(button, {Size = originalSize - UDim2.new(0, 5, 0, 5)}, 0.1, function()
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
    end)

    table.insert(self.Windows, window)
end

function Taskbar:Destroy()
    if self.Instance then
        self.Instance:Destroy()
    end
end

return Taskbar
