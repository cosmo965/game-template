--[[
--Created Date: Saturday April 25th 2026 12:37:39 pm CEST
--Author: Cosmovyz
-------
--Last Modified: Sunday April 26th 2026 12:00:00 pm CEST
--Modified By: Claude
--]]

_G.__DEV__ = false-- if RunService:IsStudio() then true else false

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local Sift = require(Packages.Sift)

local ClientLoaded = require(ReplicatedStorage.Shared.ClientLoaded):Client()

local SharedDirectory = ReplicatedStorage.Shared.Features
local ControllersDirectory = ReplicatedStorage.Client.Features

local WHITELISTED_MODULE_NAMES = { "Controller", "Handler" }

local cache = {}
local player = Players.LocalPlayer

local function Start(container: {})
	repeat
		task.wait()
	until game:IsLoaded() and ReplicatedStorage:GetAttribute("ServerIsLoaded") == true

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

		-- initialization before all modules - right after requiring the said module
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

	-- character reinitialization
	local cleanupCache = {}
	player.CharacterAdded:Connect(function(character)
		for _, module in pairs(cache) do
			if module.CharacterReinitialization then
				local value = module.CharacterReinitialization(character)
				table.insert(cleanupCache, value)
			end
		end
	end)

	player.CharacterRemoving:Connect(function()
		for _, cleanupFunction in pairs(cleanupCache) do
			task.spawn(cleanupFunction)
		end
	end)
	
end

Start(Sift.Array.merge(ControllersDirectory:GetDescendants(), SharedDirectory:GetDescendants()))

-- fire player loaded event to let server know player has been loaded
-- check when ui has been loaded
if not ReplicatedFirst:GetAttribute("IsFinishedLoading") then
	ReplicatedFirst:GetAttributeChangedSignal("IsFinishedLoading"):Wait()
end

ClientLoaded:Fire()
warn('Client loaded [CLIENT]')