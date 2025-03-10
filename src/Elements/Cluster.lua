-- Elements/Cluster.lua: Enhanced taskbar cluster with modern miltech styling
local Cluster = setmetatable({}, {__index = _G.CensuraG.UIElement})
Cluster.__index = Cluster

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local logger = _G.CensuraG.Logger
local Players = game:GetService("Players")

local function getAvatarThumbnail(userId)
    local attempts = 3
    local content = nil
    for i = 1, attempts do
        local success, result = pcall(function()
            return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size100x100)
        end)
        if success and result then
            content = result
            break
        else
            logger:warn("Attempt %d failed to fetch avatar thumbnail for user %d: %s", i, userId, tostring(result))
            task.wait(0.5)
        end
    end
    if content then
        logger:debug("Fetched avatar thumbnail for user %d: %s", userId, tostring(content))
        return content
    else
        logger:warn("All attempts failed to fetch avatar thumbnail for user %d, using fallback", userId)
        return "rbxassetid://0"
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
        Position = UDim2.new(1, -210, 0, 5),
        Size = UDim2.new(0, 200, 0, 30),
        BackgroundTransparency = Styling.Transparency.Background,
        ZIndex = 4
    })
    Styling:Apply(frame, "Frame")
    logger:debug("Cluster frame created: Position: %s, Size: %s, ZIndex: %d", tostring(frame.Position), tostring(frame.Size), frame.ZIndex)

    local avatarImageUrl = getAvatarThumbnail(localPlayer.UserId)
    local avatarImage = _G.CensuraG.ImageLabel.new({Instance = frame}, avatarImageUrl, 5, 1, 28, 28, {ZIndex = 5})
    if not avatarImage then
        logger:error("Failed to create avatar ImageLabel for cluster")
    else
        logger:debug("Cluster avatar image created with URL: %s, Position: %s, ZIndex: %d", avatarImageUrl, tostring(avatarImage.Instance.Position), avatarImage.Instance.ZIndex)
        avatarImage.Instance.Visible = true
        task.wait(0.1)
        if avatarImage.Instance.ImageTransparency > 0 then
            avatarImage.Instance.ImageTransparency = 0
            logger:debug("Forced avatar image visibility")
        end
    end

    local displayName = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 40, 0, 0),
        Size = UDim2.new(0, 110, 0, 30),
        BackgroundTransparency = 1,
        Text = localPlayer.DisplayName,
        ZIndex = 5
    })
    Styling:Apply(displayName, "TextLabel")
    logger:debug("Cluster display name created: Position: %s, Size: %s, ZIndex: %d, Text: %s", tostring(displayName.Position), tostring(displayName.Size), displayName.ZIndex, displayName.Text)

    localPlayer:GetPropertyChangedSignal("DisplayName"):Connect(function()
        displayName.Text = localPlayer.DisplayName
        logger:debug("Updated cluster display name to: %s", displayName.Text)
    end)

    local timeLabel = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 155, 0, 0),
        Size = UDim2.new(0, 40, 0, 30),
        BackgroundTransparency = 1,
        Text = os.date("%H:%M"),
        ZIndex = 5
    })
    Styling:Apply(timeLabel, "TextLabel")
    logger:debug("Cluster time label created: Position: %s, Size: %s, ZIndex: %d, Text: %s", tostring(timeLabel.Position), tostring(timeLabel.Size), timeLabel.ZIndex, timeLabel.Text)

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
