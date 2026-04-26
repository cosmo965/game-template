--[[
--Created Date: Saturday April 25th 2026 12:00:00 pm CEST
--Author: Claude
-------
--Last Modified: Saturday April 25th 2026 12:00:00 pm CEST
--Modified By: Claude
--]]

-- Client-side Reflex producer slice for ExampleFeature.
-- Mapped to ReplicatedStorage.Client.Features.ExampleFeature in the Rojo tree.
-- Required by Controller.luau (and nowhere else).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Packages = ReplicatedStorage.Packages
local Reflex = require(Packages.Reflex)

-- State

export type ExampleFeatureClientState = {}

local initialState: ExampleFeatureClientState = {}

local ExampleFeatureClientSlice = Reflex.createProducer(initialState, {
	-- exampleAction = function(state: ExampleFeatureClientState, ...): ExampleFeatureClientState
	-- 	return state
	-- end,
})

-- Selectors

-- local function selectExampleValue(state: ExampleFeatureClientState)
-- 	return state.exampleValue
-- end

return {
	slice = ExampleFeatureClientSlice,
	-- selectExampleValue = selectExampleValue,
}
