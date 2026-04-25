--[[
--Created Date: Saturday April 25th 2026 12:37:39 pm CEST
--Author: Cosmovyz
-------
--Last Modified: Saturday April 25th 2026 12:54:30 pm CEST
--Modified By: Cosmovyz
--]]

_G.__DEV__ = false-- if RunService:IsStudio() then true else false

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local Sift = require(Packages.Sift)

local ClientLoaded = require(ReplicatedStorage.Shared.Remotes.Core.ClientLoaded):Client()

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
			if string.find(module.Name, whitelistedName) then
				pass = true
				break
			end
		end
		if not pass then
			continue
		end

		local realModuleName = module.Parent and module.Parent.Name
		if not realModuleName then
			warn("No real module name")
			continue
		end

		cache[realModuleName] = require(module)

		-- initialization before all modules - right after requiring the said module
		if cache[realModuleName] and cache[realModuleName].PreInit then
			task.spawn(cache[realModuleName].PreInit)
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