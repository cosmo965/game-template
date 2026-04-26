--[[
--Created Date: Saturday April 25th 2026 12:00:00 pm CEST
--Author: Claude
-------
--Last Modified: Saturday April 25th 2026 12:00:00 pm CEST
--Modified By: Claude
--]]

-- Shared Reflex producer slice for ExampleFeature.
-- Mapped to ReplicatedStorage.Shared.Features.ExampleFeature in the Rojo tree.
-- Accessible from both server and client. Use for state that must be readable on both sides.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Packages = ReplicatedStorage.Packages
local Reflex = require(Packages.Reflex)

-- State

export type ExampleFeatureSharedState = {}

local initialState: ExampleFeatureSharedState = {}

local ExampleFeatureSharedSlice = Reflex.createProducer(initialState, {
	-- exampleAction = function(state: ExampleFeatureSharedState, ...): ExampleFeatureSharedState
	-- 	return state
	-- end,
})

return ExampleFeatureSharedSlice
