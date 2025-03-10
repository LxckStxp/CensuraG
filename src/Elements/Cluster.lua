-- Elements/Cluster.lua: Taskbar cluster showing avatar, display name, and time
local Cluster = setmetatable({}, {__index = _G.CensuraG.UIElement})
Cluster.__index = Cluster

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local logger = _G.CensuraG.Logger
local Players = game:GetService("Players")

function Cluster.new(parent)
    if not parent or not parent.Instance then
        logger:error("Invalid parent for cluster: %s", tostring(parent))
        return nil
    end

    local localPlayer = Players.LocalPlayer
    if not localPlayer then
        logger:warn("No local player found for cluster")
        return nil
    end

    logger:debug("Creating cluster with parent: %s", tostring(parent.Instance))

    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(1, -200, 0, 5), -- Right side, with some padding
        Size = UDim2.new(0, 190, 0, 30),
        BackgroundTransparency = 0.5,
        BackgroundColor3 = Styling.Colors.Highlight,
        Visible = true,
        ZIndex = 2
    })
    Styling:Apply(frame, "Frame")
    logger:debug("Cluster frame created: Position: %s, Size: %s, ZIndex: %d, Visible: %s, Parent: %s", tostring(frame.Position), tostring(frame.Size), frame.ZIndex, tostring(frame.Visible), tostring(frame.Parent))

    -- Add a thin white border
    local frameStroke = Utilities.createInstance("UIStroke", {
        Parent = frame,
        Thickness = 1,
        Color = Color3.fromRGB(200, 200, 200),
        Transparency = 0.5
    })

    -- Avatar image
    local avatarImage = Utilities.createInstance("ImageLabel", {
        Parent = frame,
        Position = UDim2.new(0, 5, 0, 2),
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundTransparency = 1,
        Image = localPlayer and "rbxthumb://id=" .. localPlayer.UserId .. "?width=420&height=420" or "",
        Visible = true,
        ZIndex = 3
    })
    logger:debug("Cluster avatar image created: Position: %s, Size: %s, ZIndex: %d, Visible: %s", tostring(avatarImage.Position), tostring(avatarImage.Size), avatarImage.ZIndex, tostring(avatarImage.Visible))

    -- Display name
    local displayName = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 35, 0, 0),
        Size = UDim2.new(0, 100, 0, 30),
        BackgroundTransparency = 1,
        Text = localPlayer and localPlayer.DisplayName or "Unknown",
        TextColor3 = Styling.Colors.Text,
        Font = Enum.Font.Code,
        TextSize = 14,
        Visible = true,
        ZIndex = 3
    })
    Styling:Apply(displayName, "TextLabel")
    logger:debug("Cluster display name created: Position: %s, Size: %s, ZIndex: %d, Visible: %s, Text: %s", tostring(displayName.Position), tostring(displayName.Size), displayName.ZIndex, tostring(displayName.Visible), displayName.Text)

    -- Time
    local timeLabel = Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 140, 0, 0),
        Size = UDim2.new(0, 50, 0, 30),
        BackgroundTransparency = 1,
        Text = os.date("%H:%M"),
        TextColor3 = Styling.Colors.Text,
        Font = Enum.Font.Code,
        TextSize = 14,
        Visible = true,
        ZIndex = 3
    })
    Styling:Apply(timeLabel, "TextLabel")
    logger:debug("Cluster time label created: Position: %s, Size: %s, ZIndex: %d, Visible: %s, Text: %s", tostring(timeLabel.Position), tostring(timeLabel.Size), timeLabel.ZIndex, tostring(timeLabel.Visible), timeLabel.Text)

    -- Update time every minute
    spawn(function()
        while wait(60) do
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
    self.Instance:Destroy()
    logger:info("Cluster destroyed")
end

return Cluster
