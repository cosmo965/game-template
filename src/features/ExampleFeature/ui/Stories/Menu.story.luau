--[[
--Created Date: Saturday April 25th 2026 12:30:00 pm CEST
--Author: Claude
-------
--Last Modified: Sunday April 26th 2026 12:55:43 am CEST
--Modified By: Cosmovyz
--]]

--[[
	Story: ExampleFeature Menu
	Mounts src/features/ExampleFeature/ui/Menu for UI Labs hot-reload preview.
	Replicates the runtime mount so the Menu can be iterated on without entering Play mode.
--]]

-- Roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Packages = ReplicatedStorage.Packages
local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)
local UILabs = require(Packages["UI-labs"])

-- Component under test
local Menu = require(ReplicatedStorage.Client.Features.ExampleFeature.UI.Menu)

return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {},
}, function(props)
	return React.createElement(Menu, {})
end)
