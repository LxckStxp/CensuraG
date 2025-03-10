-- Elements/Cluster.lua: Enhanced taskbar cluster showing avatar, display name, and time
local Cluster = setmetatable({}, {__index = _G.CensuraG.UIElement})
Cluster.__index = Cluster

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local logger = _G.CensuraG.Logger
local Players = game:GetService("Players")

local function getAvatarThumbnail(userId)
    local success, content = pcall(function()
        return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size100x100)
    end)
    if success and content then
        logger:debug("Fetched avatar thumbnail for user %d: %s", userId, tostring(content))
        return content
    else
        logger:warn("Failed to fetch avatar thumbnail for user %d: %s", userId, tostring(content))
        return "rbxassetid://0" -- Fallback to a blank image
    end
end

function Cluster.new(parent)
    if not parent or not parent.Instance or not parent.Instance:IsA("GuiObject") then
        logger:error("Invalid parent for cluster: %s", tostring(parent))
        return nil
    end

    local localPlayer = Players.LocalPlayer
    if not localPlayer then
        logger:warn("No local player found for cluster")
        return nil
    end

    logger:info("Creating cluster with parent: %s", tostring(parent.Instance))

    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(1, -210, 0, 5), -- Adjusted to 210px from right for better spacing
        Size = UDim2.new(0, 200, 0, 30),
        BackgroundTransparency = 0.6, -- Slightly more transparent for a sleek look
        BackgroundColor3 = Styling.Colors.Highlight,
        Visible = true,
        ZIndex = 2
    })
    Styling:Apply(frame, "Frame")
    logger:debug("Cluster frame created: Position: %s, Size: %s, ZIndex: %d, Visible: %s", tostring(frame.Position), tostring(frame.Size), frame.ZIndex, tostring(frame.Visible))

    local frameStroke = Utilities.createInstance("UIStroke", {
        Parent = frame,
        Thickness = 1,
        Color = Color3.fromRGB(200, 200, 200),
        Transparency = 0.4 -- Slightly more visible border
    })

    -- Avatar image using ImageLabel
    local avatarImageUrl = getAvatarThumbnail(localPlayer.UserId)
    local avatarImage = _G.CensuraG.ImageLabel.new(frame, avatarImageUrl, 5, 2, 28, 28, {Shadow = true})
    if not avatarImage then
        logger:error("Failed to create avatar ImageLabel for cluster")
    else
        logger:debug("Cluster avatar image created with URL: %s", avatarImageUrl)
    end

    -- Display name
    local displayName = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 40, 0, 0),
        Size = UDim2.new(0, 110, 0, 30),
        BackgroundTransparency = 1,
        Text = localPlayer.DisplayName,
        TextColor3 = Styling.Colors.Text,
        Font = Enum.Font.Code,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = true,
        ZIndex = 3
    })
    Styling:Apply(displayName, "TextLabel")
    logger:debug("Cluster display name created: Position: %s, Size: %s, ZIndex: %d, Visible: %s, Text: %s", tostring(displayName.Position), tostring(displayName.Size), displayName.ZIndex, tostring(displayName.Visible), displayName.Text)

    -- Update display name if it changes
    localPlayer:GetPropertyChangedSignal("DisplayName"):Connect(function()
        displayName.Text = localPlayer.DisplayName
        logger:debug("Updated cluster display name to: %s", displayName.Text)
    end)

    -- Time
    local timeLabel = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 155, 0, 0),
        Size = UDim2.new(0, 40, 0, 30),
        BackgroundTransparency = 1,
        Text = os.date("%H:%M"),
        TextColor3 = Styling.Colors.Text,
        Font = Enum.Font.Code,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        Visible = true,
        ZIndex = 3
    })
    Styling:Apply(timeLabel, "TextLabel")
    logger:debug("Cluster time label created: Position: %s, Size: %s, ZIndex: %d, Visible: %s, Text: %s", tostring(timeLabel.Position), tostring(timeLabel.Size), timeLabel.ZIndex, tostring(timeLabel.Visible), timeLabel.Text)

    -- Update time every 10 seconds for smoother updates
    spawn(function()
        while wait(10) do
            timeLabel.Text = os.date("%H:%M")
            logger:debug("Updated cluster time to: %s", timeLabel.Text)
        end
    end)

    local self = setmetatable({
        Instance = frame,
        AvatarImage = avatarImage,
        DisplayName = displayName,
        TimeLabel = timeLabel
    }, Cluster)

    return self
end

function Cluster:Destroy()
    if self.AvatarImage and self.AvatarImage.Destroy then
        self.AvatarImage:Destroy()
    end
    self.Instance:Destroy()
    logger:info("Cluster destroyed")
end

return Cluster
