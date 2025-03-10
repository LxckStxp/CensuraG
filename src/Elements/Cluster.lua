-- Elements/Cluster.lua: Taskbar cluster with consistent styling
local Cluster = setmetatable({}, {__index = _G.CensuraG.UIElement})
Cluster.__index = Cluster

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local logger = _G.CensuraG.Logger
local Players = game:GetService("Players")

local function getAvatarThumbnail(userId)
    local success, result = pcall(function()
        return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size100x100)
    end)
    if success then return result end
    logger:warn("Failed to fetch avatar for user %d: %s", userId, tostring(result))
    return "rbxassetid://0"
end

function Cluster.new(parent)
    if not parent or not parent.Instance then return nil end

    local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(1, -210, 0, 5),
        Size = UDim2.new(0, 200, 0, 30),
        BackgroundTransparency = Styling.Transparency.ElementBackground,
        ZIndex = parent.Instance.ZIndex + 1
    })
    Styling:Apply(frame, "Frame")

    local avatarImage = _G.CensuraG.ImageLabel.new({Instance = frame}, getAvatarThumbnail(LocalPlayer.UserId), 5, 1, 28, 28, {ZIndex = frame.ZIndex + 1})
    avatarImage.Image.ImageTransparency = 0

    local displayName = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 40, 0, 0),
        Size = UDim2.new(0, 110, 0, 30),
        BackgroundTransparency = 1,
        Text = LocalPlayer.DisplayName,
        ZIndex = frame.ZIndex + 2
    })
    Styling:Apply(displayName, "TextLabel")

    LocalPlayer:GetPropertyChangedSignal("DisplayName"):Connect(function()
        displayName.Text = LocalPlayer.DisplayName
    end)

    local timeLabel = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 155, 0, 0),
        Size = UDim2.new(0, 40, 0, 30),
        BackgroundTransparency = 1,
        Text = os.date("%H:%M"),
        ZIndex = frame.ZIndex + 2
    })
    Styling:Apply(timeLabel, "TextLabel")

    task.spawn(function()
        while task.wait(10) do
            timeLabel.Text = os.date("%H:%M")
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
    if self.AvatarImage then self.AvatarImage:Destroy() end
    if self.Instance then self.Instance:Destroy() end
    logger:info("Cluster destroyed")
end

return Cluster
