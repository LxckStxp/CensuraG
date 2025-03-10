-- Elements/Cluster.lua: Enhanced taskbar info cluster
local Cluster = setmetatable({}, {__index = _G.CensuraG.UIElement})
Cluster.__index = Cluster

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager
local logger = _G.CensuraG.Logger
local Players = game:GetService("Players")

-- Get player avatar thumbnail
local function getAvatarThumbnail(userId)
    return Utilities.getPlayerAvatar(userId, Enum.ThumbnailSize.Size100x100)
end

-- Create a new cluster
function Cluster.new(parent, options)
    if not parent or not parent.Instance then
        logger:error("Invalid parent for Cluster")
        return nil
    end
    
    options = options or {}
    
    -- Get local player
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then
        LocalPlayer = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    end
    
    -- Create main frame
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = options.Position or UDim2.new(1, -210, 0, 5),
        Size = UDim2.new(0, 200, 0, 30),
        BackgroundTransparency = Styling.Transparency.ElementBackground,
        ZIndex = parent.Instance.ZIndex + 1,
        Name = "Cluster"
    })
    Styling:Apply(frame, "Frame")
    
    -- Create avatar image
    local avatarImage = _G.CensuraG.ImageLabel.new(
        {Instance = frame}, 
        getAvatarThumbnail(LocalPlayer.UserId), 
        5, 1, 28, 28, 
        {
            ZIndex = frame.ZIndex + 1,
            ScaleType = Enum.ScaleType.Crop,
            CornerRadius = 14, -- Make it circular
            ImageTransparency = 0
        }
    )
    
    -- Create display name
    local displayName = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 40, 0, 0),
        Size = UDim2.new(0, 110, 0, 30),
        BackgroundTransparency = 1,
        Text = LocalPlayer.DisplayName,
        ZIndex = frame.ZIndex + 2,
        Name = "DisplayName"
    })
    Styling:Apply(displayName, "TextLabel")
    
    -- Create time label
    local timeLabel = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 155, 0, 0),
        Size = UDim2.new(0, 40, 0, 30),
        BackgroundTransparency = 1,
        Text = os.date("%H:%M"),
        ZIndex = frame.ZIndex + 2,
        Name = "TimeLabel"
    })
    Styling:Apply(timeLabel, "TextLabel")
    
    -- Create self object
    local self = setmetatable({
        Instance = frame,
        AvatarImage = avatarImage,
        DisplayName = displayName,
        TimeLabel = timeLabel,
        Connections = {}
    }, Cluster)
    
    -- Update display name when it changes
    table.insert(self.Connections, EventManager:Connect(
        LocalPlayer:GetPropertyChangedSignal("DisplayName"),
        function()
            displayName.Text = LocalPlayer.DisplayName
            logger:debug("Updated display name: %s", LocalPlayer.DisplayName)
        end
    ))
    
    -- Update time periodically
    task.spawn(function()
        while task.wait(10) do
            if self.TimeLabel and self.TimeLabel.Parent then
                self.TimeLabel.Text = os.date("%H:%M")
            else
                break
            end
        end
    end)
    
    -- Add click handler for avatar
    avatarImage:OnClick(function()
        -- Show player info or menu
        logger:debug("Avatar clicked")
        EventManager:FireEvent("AvatarClicked", LocalPlayer)
    end)
    
    -- Add hover effect for the entire cluster
    Animation:HoverEffect(frame)
    
    -- Example of how to use the cluster
    if options.ShowExample then
        logger:debug([[
Example usage:
local cluster = CensuraG.Cluster.new({Instance = taskbar}, {
    Position = UDim2.new(1, -210, 0, 5)
})
]])
    end
    
    return self
end

-- Clean up resources
function Cluster:Destroy()
    for _, conn in ipairs(self.Connections) do
        conn:Disconnect()
    end
    self.Connections = {}
    
    if self.AvatarImage then
        self.AvatarImage:Destroy()
    end
    
    if self.Instance then
        self.Instance:Destroy()
    end
    
    logger:info("Cluster destroyed")
end

return Cluster
