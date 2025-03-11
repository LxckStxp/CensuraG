-- CensuraG/src/components/grid.lua
local Config = _G.CensuraG.Config

return function(parent)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations

    local GridFrame = Instance.new("Frame", parent)
    GridFrame.Size = UDim2.new(1, -2 * Config.Math.Padding, 1, -30 - Config.Math.Padding) -- Adjust for title bar and padding
    GridFrame.Position = UDim2.new(0, Config.Math.Padding, 0, 30 + Config.Math.Padding) -- Below title bar
    GridFrame.BackgroundTransparency = 1
    GridFrame.BackgroundColor3 = theme.PrimaryColor
    GridFrame.BorderSizePixel = 0
    GridFrame.BackgroundTransparency = 1 -- Start hidden for animation

    local GridLayout = Instance.new("UIGridLayout", GridFrame)
    GridLayout.CellSize = UDim2.new(0, 150, 0, 50) -- Consistent size for components
    GridLayout.CellPadding = UDim2.new(0, Config.Math.ElementSpacing, 0, Config.Math.ElementSpacing) -- Correct property
    GridLayout.StartCorner = Enum.StartCorner.TopLeft
    GridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    GridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    -- Removed incorrect Padding property

    -- Animation
    _G.CensuraG.AnimationManager:Tween(GridFrame, {BackgroundTransparency = 0}, animConfig.FadeDuration)

    local Grid = {
        Instance = GridFrame,
        Layout = GridLayout,
        AddComponent = function(self, component)
            if component and component.Instance then
                component.Instance.Parent = self.Instance
                _G.CensuraG.Logger:info("Added component to grid")
            else
                _G.CensuraG.Logger:warn("Invalid component provided to grid")
            end
        end,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("grid", self.Instance)
            self.Layout:ApplyLayout() -- Ensure layout is reapplied
        end
    }

    _G.CensuraG.Logger:info("Grid created")
    return Grid
end
