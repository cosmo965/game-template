--[[
--Created Date: Sunday September 15th 2024 8:25:07 pm CEST
--Author: Cosmovyz
-------
--Last Modified: Tuesday August 12th 2025 3:26:54 pm CEST
--Modified By: Cosmovyz
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local React = require(Packages.React)

local e = React.createElement

local function ContextStack(props: {
	providers: {
		React.React_ComponentType<{
			children: React.React_Node,
		}>
	},

	children: React.React_Node,
})
	local mostRecent = e(props.providers[#props.providers], {}, props.children)

	for providerIndex = #props.providers - 1, 1, -1 do
		mostRecent = e(props.providers[providerIndex], {}, mostRecent)
	end
	
	return mostRecent
end

return ContextStack