--[[
--Created Date: Thursday April 23rd 2026 12:00:00 pm CEST
--Author: Claude
-------
--Last Modified: Friday April 24th 2026 10:00:00 am CEST
--Modified By: Claude
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Sift = require(ReplicatedStorage.Packages.Sift)
local React = require(ReplicatedStorage.Packages.React)
local e = React.createElement

local useEventConnection = require(script.Parent.Parent.Parent.Hooks.useEventConnection)

return function(props: {
	interval: number?,
	shakeDuration: number?,
	speed: number?,
	amplitude: number?,
	native: { [string]: any }?,
	children: React.React_Node?,
})
	local interval = props.interval or 3
	local shakeDuration = props.shakeDuration or 0.5
	local speed = props.speed or 25
	local amplitude = props.amplitude or 8
	local baseRotation = (props.native and props.native.Rotation) or 0
	local visible = not (props.native and props.native.Visible == false)

	local rotationBinding, setRotationBinding = React.useBinding(baseRotation)

	local elapsed = React.useRef(0)
	local shakeElapsed = React.useRef(0)
	local isShaking = React.useRef(false)

	local intervalRef = React.useRef(interval)
	local shakeDurationRef = React.useRef(shakeDuration)
	local speedRef = React.useRef(speed)
	local amplitudeRef = React.useRef(amplitude)
	local baseRotationRef = React.useRef(baseRotation)
	local visibleRef = React.useRef(visible)
	intervalRef.current = interval
	shakeDurationRef.current = shakeDuration
	speedRef.current = speed
	amplitudeRef.current = amplitude
	baseRotationRef.current = baseRotation
	visibleRef.current = visible

	useEventConnection(RunService.PreRender, function(dt)
		if not visibleRef.current then return end
		if isShaking.current then
			shakeElapsed.current += dt
			if shakeElapsed.current >= shakeDurationRef.current then
				isShaking.current = false
				shakeElapsed.current = 0
				elapsed.current = 0
				setRotationBinding(baseRotationRef.current)
			else
				setRotationBinding(
					baseRotationRef.current
						+ math.sin(shakeElapsed.current * speedRef.current) * amplitudeRef.current
				)
			end
		else
			elapsed.current += dt
			if elapsed.current >= intervalRef.current then
				isShaking.current = true
				shakeElapsed.current = 0
			end
		end
	end, {})

	return e("Frame", Sift.Dictionary.merge(props.native or {}, {
		BackgroundTransparency = 1,
		Rotation = rotationBinding,
	}), props.children)
end
