--[[
--Created Date: Saturday April 25th 2026 12:00:00 pm CEST
--Author: Claude
-------
--Last Modified: Saturday April 25th 2026 12:00:00 pm CEST
--Modified By: Claude
--]]

-- Server-side Reflex producer slice for ExampleFeature.
-- Mapped to ServerScriptService.Server.Features.ExampleFeature in the Rojo tree.
-- Required by Service.luau (and nowhere else).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Packages = ReplicatedStorage.Packages
local Reflex = require(Packages.Reflex)

-- State

export type ExampleFeatureServerState = {}

local initialState: ExampleFeatureServerState = {}

local ExampleFeatureServerSlice = Reflex.createProducer(initialState, {
	-- exampleAction = function(state: ExampleFeatureServerState, ...): ExampleFeatureServerState
	-- 	return state
	-- end,
})

return ExampleFeatureServerSlice
