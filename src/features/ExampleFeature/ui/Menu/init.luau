local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local ReactReflex = require(Packages.ReactReflex)
local React = require(ReplicatedStorage.Packages.React)

local function ExampleFeatureMenu(props: {
	children: React.React_Node
})
	return nil
end

return ExampleFeatureMenu
