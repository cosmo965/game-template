--[[
--Created Date: Saturday April 25th 2026 12:37:39 pm CEST
--Author: Cosmovyz
-------
--Last Modified: Sunday April 26th 2026 12:00:00 pm CEST
--Modified By: Claude
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Packages = ReplicatedStorage.Packages

local Sift = require(Packages.Sift)

local ClientLoaded = require(ReplicatedStorage.Shared.ClientLoaded):Server()

local SharedDirectory = ReplicatedStorage.Shared.Features
local ServiceDirectory = ServerScriptService.Server.Features

local WHITELISTED_MODULE_NAMES = { "Service", "Handler" }

local cache = {}

ClientLoaded:On(function(player)
	player:SetAttribute("ClientLoaded", true)
end)

local function Start(container: {})
	for _, module in pairs(container) do
		if not module:IsA("ModuleScript") then
			continue
		end
		local pass = false
		for _, whitelistedName in WHITELISTED_MODULE_NAMES do
			if module.Name:sub(-#whitelistedName) == whitelistedName then
				pass = true
				break
			end
		end
		if not pass then
			continue
		end

		cache[module.Name] = require(module)

		if cache[module.Name] and cache[module.Name].PreInit then
			task.spawn(cache[module.Name].PreInit)
		end
	end

	-- After requiring
	for _, module in pairs(cache) do
		if module.PostInit then
			task.spawn(module.PostInit)
		end
	end
end

Start(Sift.Array.merge(ServiceDirectory:GetDescendants(), SharedDirectory:GetDescendants()))

ReplicatedStorage:SetAttribute("ServerIsLoaded", true)
warn('Server loaded [SERVER]')