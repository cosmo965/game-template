--[[
--Created Date: Sunday April 26th 2026 1:20:06 am CEST
--Author: Claude
-------
--Last Modified: Sunday April 26th 2026 1:20:06 am CEST
--Modified By: Claude
--]]

--[[
	ExampleTextLabel — example feature-local text label primitive.
	Demonstrates a minimal styled TextLabel composed for the ExampleFeature UI; provides
	configurable text, color, and size props with sensible defaults used across the feature.
	Requires: React (Packages)
--]]

-- Roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Packages = ReplicatedStorage.Packages
local React = require(Packages.React)
local e = React.createElement

return function(props: {
	text: string,
	size: UDim2?,
	position: UDim2?,
	anchorPoint: Vector2?,
	textColor: Color3?,
	layoutOrder: number?,
})
	return e("TextLabel", {
		AnchorPoint = props.anchorPoint,
		BackgroundTransparency = 1,
		FontFace = Font.new(
			"rbxasset://fonts/families/GothamSSm.json",
			Enum.FontWeight.Bold,
			Enum.FontStyle.Normal
		),
		LayoutOrder = props.layoutOrder,
		Position = props.position,
		Size = props.size or UDim2.fromOffset(240, 48),
		Text = props.text,
		TextColor3 = props.textColor or Color3.new(1, 1, 1),
		TextScaled = true,
		TextStrokeColor3 = Color3.new(0, 0, 0),
		TextStrokeTransparency = 0.5,
	})
end
