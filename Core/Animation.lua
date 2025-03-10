   -- Core/Animation.lua
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

       duration = duration or 0.3
       easingStyle = easingStyle or Enum.EasingStyle.Quad
       easingDirection = easingDirection or Enum.EasingDirection.Out

       local info = TweenInfo.new(duration, easingStyle, easingDirection)
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

   --- Add the HoverEffect method
   function Animation:HoverEffect(element, hoverProperties, defaultProperties)
       hoverProperties = hoverProperties or {}
       defaultProperties = defaultProperties or {}
       
       if element.MouseEnter and element.MouseLeave then
           element.MouseEnter:Connect(function()
               Animation:Tween(element, hoverProperties, 0.2)
           end)
           element.MouseLeave:Connect(function()
               Animation:Tween(element, defaultProperties, 0.2)
           end)
       else
           warn("HoverEffect could not be applied. The element does not support MouseEnter/MouseLeave events.")
       end
   end

   return Animation
