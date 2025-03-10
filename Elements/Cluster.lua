-- Elements/Cluster.lua
-- Simplified taskbar info cluster using enhanced UIElement base

local Cluster = {}
Cluster.__index = Cluster
setmetatable(Cluster, { __index = _G.CensuraG.UIElement })

function Cluster.new(options)
    options = options or {}
    
    -- Set default properties for Cluster
    options.position = options.position or UDim2.new(1, -210, 0, 5)
    options.width = options.width or 200
    options.height = options.height or 30
    options.styleType = "Frame"
    
    -- Create the base element
    local self = _G.CensuraG.UIElement.new(options.parent, options)
    
    -- Get player info
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    
    -- Create avatar image
    local avatar = _G.CensuraG.ImageLabel.new({
        parent = self,
        x = 5,
        y = 1,
        width = 28,
        height = 28,
        imageUrl = _G.CensuraG.Utilities.getPlayerAvatar(LocalPlayer.UserId),
        zIndex = self.Instance.ZIndex + 1,
        scaleType = Enum.ScaleType.Crop,
        cornerRadius = 14
    })
    
    -- Create name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "DisplayName"
    nameLabel.Size = UDim2.new(0, 110, 0, 30)
    nameLabel.Position = UDim2.new(0, 40, 0, 0)
    nameLabel.Text = LocalPlayer.DisplayName
    nameLabel.ZIndex = self.Instance.ZIndex + 2
    nameLabel.BackgroundTransparency = 1
    nameLabel.Parent = self.Instance
    _G.CensuraG.Styling:Apply(nameLabel, "TextLabel")
    
    -- Create time label
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "TimeLabel"
    timeLabel.Size = UDim2.new(0, 40, 0, 30)
    timeLabel.Position = UDim2.new(0, 155, 0, 0)
    timeLabel.Text = os.date("%H:%M")
    timeLabel.ZIndex = self.Instance.ZIndex + 2
    timeLabel.BackgroundTransparency = 1
    timeLabel.Parent = self.Instance
    _G.CensuraG.Styling:Apply(timeLabel, "TextLabel")
    
    -- Set up properties
    self.AvatarImage = avatar
    self.DisplayName = nameLabel
    self.TimeLabel = timeLabel
    
    -- Listen for display name changes
    self:AddConnection(_G.CensuraG.EventManager:Connect(
        LocalPlayer:GetPropertyChangedSignal("DisplayName"), 
        function()
            nameLabel.Text = LocalPlayer.DisplayName
        end
    ))
    
    -- Update time periodically
    task.spawn(function()
        while wait(10) do
            if self.TimeLabel and self.TimeLabel.Parent then
                self.TimeLabel.Text = os.date("%H:%M")
            else
                break
            end
        end
    end)
    
    -- Set up avatar click handler
    avatar:OnClick(function()
        _G.CensuraG.EventManager:FireEvent("AvatarClicked", LocalPlayer)
    end)
    
    -- Add hover effect
    _G.CensuraG.Animation:HoverEffect(
        self.Instance, 
        { BackgroundTransparency = _G.CensuraG.Styling.Transparency.ElementBackground - 0.1 }, 
        { BackgroundTransparency = _G.CensuraG.Styling.Transparency.ElementBackground }
    )
    
    -- Set metatable for this instance
    return setmetatable(self, Cluster)
end

return Cluster
