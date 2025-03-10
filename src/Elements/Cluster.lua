-- Elements/Cluster.lua: Enhanced taskbar cluster showing avatar, display name, and time
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
            task.wait(0.5) -- Delay between retries
        end
    end
    if content then
        logger:debug("Fetched avatar thumbnail for user %d: %s", userId, tostring(content))
        return content
    else
        logger:warn("All attempts failed to fetch avatar thumbnail for user %d, using fallback", userId)
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
        Position = UDim2.new(1, -210, 0, 5),
        Size = UDim2.new(0, 200, 0, 30),
        BackgroundTransparency = 0.6,
        BackgroundColor3 = Styling.Colors.Highlight,
        Visible = true,
        ZIndex = 2
    })
    Styling:Apply(frame, "Frame")
    logger:debug("Cluster frame created: Position: %s, Size: %s, ZIndex: %d, Visible: %s, Parent: %s", tostring(frame.Position), tostring(frame.Size), frame.ZIndex, tostring(frame.Visible), tostring(frame.Parent))

    local frameStroke = Utilities.createInstance("UIStroke", {
        Parent = frame,
        Thickness = 1,
        Color = Color3.fromRGB(200, 200, 200),
        Transparency = 0.4
    })

    -- Avatar image with retry logic
    local avatarImageUrl = getAvatarThumbnail(localPlayer.UserId)
    local avatarImage = _G.CensuraG.ImageLabel.new({Instance = frame}, avatarImageUrl, 5, 1, 28, 28, {Shadow = true, ZIndex = 3})
    if not avatarImage then
        logger:error("Failed to create avatar ImageLabel for cluster")
    else
        logger:debug("Cluster avatar image created with URL: %s", avatarImageUrl)
    end

    -- Display name with better truncation
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
        TextTruncate = Enum.TextTruncate.AtEnd,
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

    -- Time with smoother updates
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

    -- Update time every 10 seconds
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
