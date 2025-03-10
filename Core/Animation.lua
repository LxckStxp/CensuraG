-- Core/Animation.lua
-- Simplified animation system using TweenService

local TweenService = game:GetService("TweenService")
local Animation = {}
local activeTweens = {}

local function cleanupTweens()
	for i = #activeTweens, 1, -1 do
		if activeTweens[i].Completed then
			table.remove(activeTweens, i)
		end
	end
end

function Animation:Tween(element, properties, duration, easingStyle, easingDirection, callback)
	if not element or not element.Parent then
		return nil
	end

	local info = TweenInfo.new(duration or 0.3, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out)
	local tween = TweenService:Create(element, info, properties)
	local tweenData = { Instance = element, Tween = tween, Completed = false }
	table.insert(activeTweens, tweenData)
	tween.Completed:Connect(function()
		tweenData.Completed = true
		if callback then callback() end
		task.delay(1, cleanupTweens)
	end)
	tween:Play()
	return tween
end

function Animation:CancelTweens(element)
	for _, tweenData in ipairs(activeTweens) do
		if tweenData.Instance == element and not tweenData.Completed then
			tweenData.Tween:Cancel()
			tweenData.Completed = true
		end
	end
end

-- You can add additional effects (SlideY, FadeIn, FadeOut, Bounce, Shake, Pulse) as wrappers around Tween.
return Animation
