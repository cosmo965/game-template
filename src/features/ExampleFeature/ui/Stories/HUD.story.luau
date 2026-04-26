--[[
--Created Date: Saturday April 25th 2026 12:30:00 pm CEST
--Author: Claude
-------
--Last Modified: Saturday April 25th 2026 12:45:00 pm CEST
--Modified By: Claude
--]]

--[[
	Story: ExampleFeature HUD
	Mounts src/features/ExampleFeature/ui/HUD for UI Labs hot-reload preview.
	Replicates the runtime mount so the HUD can be iterated on without entering Play mode.
--]]

-- Roblox services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Packages = ReplicatedStorage.Packages
local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)
local UILabs = require(Packages["UI-labs"])

-- Component under test
local HUD = require(ReplicatedStorage.Client.Features.ExampleFeature.UI.HUD)

return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {},
}, function(props)
	return React.createElement(HUD, {})
end)
