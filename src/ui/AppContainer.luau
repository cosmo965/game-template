--[[
--Created Date: Saturday April 25th 2026 12:05:37 pm CEST
--Author: Cosmovyz
-------
--Last Modified: Saturday April 26th 2026 12:00:00 am CEST
--Modified By: Claude
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local React = require(Packages.React)
local ReactReflex = require(Packages.ReactReflex)
local RootProducer = require(ReplicatedStorage.Client.Features.Reflex.ReflexController)

local Components = script.Parent.Generic.Components

local ContextStack = require(Components.ContextStack)
local ErrorBoundary = require(Components.ErrorBoundary)
local ScreenInsetsDisabledContainer = require(Components.ScreenInsetsDisabledContainer)

local e = React.createElement

-- Discover HUD and Menu components from all features that have a UI folder
local featureHUDs = {}
local featureMenus = {}

for _, featureFolder in ipairs(ReplicatedStorage.Client.Features:GetChildren()) do
	local uiFolder = featureFolder:FindFirstChild("UI")
	if not uiFolder then continue end

	local hudFolder = uiFolder:FindFirstChild("HUD")
	if hudFolder then
		table.insert(featureHUDs, require(hudFolder))
	end

	local menuFolder = uiFolder:FindFirstChild("Menu")
	if menuFolder then
		table.insert(featureMenus, require(menuFolder))
	end
end

local function AppContainer(props: {
	onLoaded: () -> ()
})
	local featureElements = {}
	for i, HUDComponent in ipairs(featureHUDs) do
		featureElements["HUD_" .. i] = e(HUDComponent)
	end
	for i, MenuComponent in ipairs(featureMenus) do
		featureElements["Menu_" .. i] = e(MenuComponent)
	end

	return e(React.Fragment, nil, {
		AppContainer = e("ScreenGui", {
			ref = props.onLoaded,
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		}, {
			ContextStack = e(ContextStack, {
				providers = {
					function()
						return ReactReflex.ReflexProvider({
							producer = RootProducer.Store,
						})
					end,
				},
			}, {
				ErrorBoundary = e(ErrorBoundary, nil, featureElements),
			}),
		}),

		ScreenInsetsDisabledContainer = e("ScreenGui", {
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			ScreenInsets = Enum.ScreenInsets.None,
		}, {
			ContextStack = e(ContextStack, {
				providers = {
					function()
						return ReactReflex.ReflexProvider({
							producer = RootProducer.Store,
						})
					end,
				},
			}, {
				ErrorBoundary = e(ErrorBoundary, nil, {
					ScreenInsetsDisabledContainer = e(ScreenInsetsDisabledContainer),
				}),
			}),
		}),
	})
end

return AppContainer
