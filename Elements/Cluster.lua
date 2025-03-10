-- Elements/Cluster.lua
-- Taskbar user info cluster

local Cluster = setmetatable({}, { __index = _G.CensuraG.UIElement })
Cluster.__index = Cluster

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager
local logger = _G.CensuraG.Logger
local Players = game:GetService("Players")

local function getAvatar(userId)
	return Utilities.getPlayerAvatar(userId, Enum.ThumbnailSize.Size100x100)
end

function Cluster.new(parent, options)
	if not parent or not parent.Instance then
		logger:error("Invalid parent for Cluster")
		return nil
	end
	options = options or {}
	local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	
	local frame = Utilities.createInstance("Frame", {
		Parent = parent.Instance,
		Position = options.Position or UDim2.new(1, -210, 0, 5),
		Size = UDim2.new(0, 200, 0, 30),
		BackgroundTransparency = Styling.Transparency.ElementBackground,
		ZIndex = parent.Instance.ZIndex + 1,
		Name = "Cluster"
	})
	Styling:Apply(frame, "Frame")
	
	-- Avatar image (assuming a helper ImageLabel constructor exists)
	local avatar = _G.CensuraG.ImageLabel.new({ Instance = frame }, getAvatar(LocalPlayer.UserId), 5, 1, 28, 28, {
		ZIndex = frame.ZIndex + 1, ScaleType = Enum.ScaleType.Crop, CornerRadius = 14
	})
	
	local nameLabel = Utilities.createInstance("TextLabel", {
		Parent = frame, Position = UDim2.new(0, 40, 0, 0), Size = UDim2.new(0, 110, 0, 30),
		Text = LocalPlayer.DisplayName, ZIndex = frame.ZIndex + 2, Name = "DisplayName"
	})
	Styling:Apply(nameLabel, "TextLabel")
	
	local timeLabel = Utilities.createInstance("TextLabel", {
		Parent = frame, Position = UDim2.new(0, 155, 0, 0), Size = UDim2.new(0, 40, 0, 30),
		Text = os.date("%H:%M"), ZIndex = frame.ZIndex + 2, Name = "TimeLabel"
	})
	Styling:Apply(timeLabel, "TextLabel")
	
	local self = setmetatable({
		Instance = frame, AvatarImage = avatar, DisplayName = nameLabel, TimeLabel = timeLabel, Connections = {}
	}, Cluster)
	
	table.insert(self.Connections, EventManager:Connect(LocalPlayer:GetPropertyChangedSignal("DisplayName"), function()
		nameLabel.Text = LocalPlayer.DisplayName
		logger:debug("Updated display name")
	end))
	
	task.spawn(function()
		while wait(10) do
			if self.TimeLabel and self.TimeLabel.Parent then
				self.TimeLabel.Text = os.date("%H:%M")
			else
				break
			end
		end
	end)
	
	avatar:OnClick(function()
		logger:debug("Avatar clicked")
		EventManager:FireEvent("AvatarClicked", LocalPlayer)
	end)
	
	Animation:HoverEffect(frame)
	logger:debug("Cluster created")
	return self
end

function Cluster:Destroy()
	for _, conn in ipairs(self.Connections) do
		conn:Disconnect()
	end
	self.Connections = {}
	if self.AvatarImage then self.AvatarImage:Destroy() end
	if self.Instance then self.Instance:Destroy() end
	logger:info("Cluster destroyed")
end

return Cluster
