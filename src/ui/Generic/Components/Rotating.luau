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
	speed: number?,
	native: { [string]: any }?,
	children: React.React_Node?,
})
	local speed = props.speed or 90
	local visible = not (props.native and props.native.Visible == false)

	local accum = React.useRef((props.native and props.native.Rotation) or 0)
	local rotationBinding, setRotationBinding = React.useBinding(accum.current)

	local visibleRef = React.useRef(visible)
	visibleRef.current = visible

	useEventConnection(RunService.PreRender, function(dt)
		if not visibleRef.current then return end
		accum.current += speed * dt
		setRotationBinding(accum.current)
	end, { speed })

	return e("Frame", Sift.Dictionary.merge(props.native or {}, {
		BackgroundTransparency = 1,
		Rotation = rotationBinding,
	}), props.children)
end
