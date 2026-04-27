--[[
--Created Date: Sunday April 26th 2026 1:20:06 am CEST
--Author: Claude
-------
--Last Modified: Sunday April 26th 2026 1:20:06 am CEST
--Modified By: Claude
--]]

--[[
	Story: ExampleFeature ExampleTextLabel
	Mounts src/features/ExampleFeature/ui/Components/ExampleTextLabel for UI Labs hot-reload preview.
	Exposes text and color controls so the label can be tuned without entering Play mode.
--]]

-- Roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Packages = ReplicatedStorage.Packages
local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)
local UILabs = require(Packages["UI-labs"])

-- Component under test
local ExampleTextLabel = require(ReplicatedStorage.Client.Features.ExampleFeature.UI.Components.ExampleTextLabel)

return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		text = "Hello, world!",
		textColor = Color3.fromRGB(255, 255, 255),
	},
}, function(props)
	return React.createElement(ExampleTextLabel, {
		text = props.controls.text,
		textColor = props.controls.textColor,
		anchorPoint = Vector2.new(0.5, 0.5),
		position = UDim2.fromScale(0.5, 0.5),
	})
end)
