--[[
--Created Date: Friday April 25th 2026 12:00:00 pm CEST
--Author: Claude
-------
--Last Modified: Friday April 25th 2026 12:00:00 pm CEST
--Modified By: Claude
--]]

-- Packages
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local React = require(Packages.React)

local e = React.createElement

-- ErrorBoundary catches errors thrown in any descendant component tree.
-- React class components are required for componentDidCatch; functional components cannot do this.
local ErrorBoundary = React.Component:extend("ErrorBoundary")

function ErrorBoundary:init()
	self:setState({
		hasError = false,
		message = nil,
	})
end

function ErrorBoundary.getDerivedStateFromError(err)
	return {
		hasError = true,
		message = tostring(err),
	}
end

function ErrorBoundary:componentDidCatch(err, info)
	warn("[ErrorBoundary] Caught error:", tostring(err))
	if info and info.componentStack then
		warn("[ErrorBoundary] Component stack:", info.componentStack)
	end
end

function ErrorBoundary:render()
	if self.state.hasError then
		local fallback = self.props.fallback

		if type(fallback) == "function" then
			return fallback(self.state.message)
		elseif fallback ~= nil then
			return fallback
		end

		return e("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
		}, {
			Label = e("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text = "Something went wrong.",
				TextColor3 = Color3.fromRGB(255, 80, 80),
				TextScaled = true,
				Font = Enum.Font.GothamBold,
			}),
		})
	end

	return e(React.Fragment, nil, self.props.children)
end

return ErrorBoundary
