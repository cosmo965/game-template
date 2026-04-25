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

local usePx = require(script.Parent.Parent.Parent.Hooks.usePx)
local useEventConnection = require(script.Parent.Parent.Parent.Hooks.useEventConnection)

return function(props: {
	speed: number?,
	amplitude: number?,
	phase: number?,
	native: { [string]: any }?,
	children: React.React_Node?,
})
	local px = usePx()

	local speed = props.speed or 2
	local amplitude = props.amplitude or 10
	local basePosition = (props.native and props.native.Position) or UDim2.fromScale(0, 0)
	local visible = not (props.native and props.native.Visible == false)

	local elapsed = React.useRef(props.phase or 0)
	local frameRef = React.useRef(nil :: Frame?)

	local speedRef = React.useRef(speed)
	local amplitudeRef = React.useRef(amplitude)
	local basePositionRef = React.useRef(basePosition)
	local pxRef = React.useRef(px)
	local visibleRef = React.useRef(visible)
	speedRef.current = speed
	amplitudeRef.current = amplitude
	basePositionRef.current = basePosition
	pxRef.current = px
	visibleRef.current = visible

	useEventConnection(RunService.PreRender, function(dt)
		if not visibleRef.current then return end
		local frame = frameRef.current
		if not frame then return end
		elapsed.current += dt
		frame.Position = basePositionRef.current
			+ UDim2.fromOffset(0, math.sin(elapsed.current * speedRef.current) * pxRef.current(amplitudeRef.current))
	end, {})

	return e("Frame", Sift.Dictionary.merge(props.native or {}, {
		BackgroundTransparency = 1,
		ref = frameRef,
	}), props.children)
end
