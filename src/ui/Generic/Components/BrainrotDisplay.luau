--[[
--Created Date: Monday April 14th 2026 12:00:00 pm CEST
--Author: Claude
-------
--Last Modified: Saturday April 18th 2026 10:31:44 pm CEST
--Modified By: Cosmovyz
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Packages

local Sift = require(Packages.Sift)
local React = require(Packages.React)
local e = React.createElement

local RarityData = require(ReplicatedStorage.Shared.Modules.Metadata.RarityData)
local TraitData = require(ReplicatedStorage.Shared.Modules.Metadata.TraitData)
local BrainrotModifierData = require(ReplicatedStorage.Shared.Modules.Metadata.BrainrotModifierData)
local ClaimableBrainrotData = require(ReplicatedStorage.Shared.Modules.Metadata.ClaimableBrainrotData)

local ViewportFrame = require(script.Parent.ViewportFrame)
local AlternatingColorText = require(script.Parent.AlternatingColorText)

local BRAINROT_MODELS = ReplicatedStorage.Assets.Models.Brainrots
local BRAINROT_ANIMATIONS = ReplicatedStorage.Assets.Animations.Brainrots

local LABEL_FONT = Font.new("rbxasset://fonts/families/FredokaOne.json")

local function makeColorLabel(text: string, position: UDim2, size: UDim2, data: {})
	if data.AlternatingColorTextData then
		local altData = data.AlternatingColorTextData
		return e(AlternatingColorText, {
			isVisible = true,
			color1 = altData.color1,
			color2 = altData.color2,
			speed = .7,
			strokeThickness = 1.5,
			native = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				FontFace = LABEL_FONT,
				Position = position,
				Size = size,
				Text = text,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Right,
			},
		})
	elseif data.ColorSequence then
		return e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = LABEL_FONT,
			Position = position,
			Size = size,
			Text = text,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Right,
		}, {
			UIGradient = e("UIGradient", {
				Color = data.ColorSequence,
			}),
			UIStroke = e("UIStroke", {
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.09,
			}),
		})
	else
		return e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = LABEL_FONT,
			Position = position,
			Size = size,
			Text = text,
			TextColor3 = data.StaticColor,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Right,
		}, {
			UIStroke = e("UIStroke", {
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.09,
			}),
		})
	end
end

return function(props: {
	brainrotName: string?,
	brainrotRarity: string?,
	brainrotTrait: string?,
	brainrotModifier: string?,
	native: {}?,

	children: {}
})
	local model = nil
	local animation = nil

	if props.brainrotName then
		local models = BRAINROT_MODELS[props.brainrotName]
		if props.brainrotTrait then
			model = models[props.brainrotTrait]
		else
			model = models:FindFirstChild("Normal") or models:GetChildren()[1]
		end
		animation = BRAINROT_ANIMATIONS[props.brainrotName].Idle
	end

	local rarityData = props.brainrotRarity and RarityData.Data[props.brainrotRarity]
	local traitData = props.brainrotTrait and TraitData.Data[props.brainrotTrait]
	local modifierData = props.brainrotModifier and BrainrotModifierData.Data[props.brainrotModifier]

	local brainrotRealName = props.brainrotName
		and ClaimableBrainrotData.FindBrainrotDataTable(props.brainrotName)
		and ClaimableBrainrotData.FindBrainrotDataTable(props.brainrotName).RealName

	local properties = Sift.Dictionary.merge({
		BackgroundTransparency = 1,
		Image = "rbxassetid://91127136481142",
		ScaleType = Enum.ScaleType.Stretch,
		SliceCenter = Rect.new(0, 0, 102, 85),
	}, props.native or {})
	
	return e("ImageLabel", properties, {
		ViewportFrame = model and e(ViewportFrame, {
			native = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.8, 0.8),
				ZIndex = 3,
			},
			cameraDistance = 25,
			modelScale = 1,
			cframeOffset = CFrame.Angles(0, -math.rad(20), 0),
			animation = animation,
			model = model,
		}) or nil,

		BrainrotName = brainrotRealName and e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			FontFace = LABEL_FONT,
			Position = UDim2.fromScale(0.432043, 0.93975),
			Size = UDim2.fromScale(0.83, 0.21),
			Text = brainrotRealName,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, {
			UIStroke = e("UIStroke", {
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.09,
			}),
		}) or nil,

		BrainrotRarity = rarityData and makeColorLabel(
			props.brainrotRarity,
			UDim2.fromScale(0.582672, 0.130825),
			UDim2.fromScale(0.720864, 0.160933),
			rarityData
		) or nil,

		BrainrotTrait = traitData and makeColorLabel(
			props.brainrotTrait,
			UDim2.fromScale(0.580355, 0.29324),
			UDim2.fromScale(0.716395, 0.113284),
			traitData
		) or nil,

		BrainrotModifierIcon = (modifierData and modifierData.Icon) and e("ImageLabel", {
			BackgroundTransparency = 1,
			Image = modifierData.Icon,
			Position = UDim2.fromScale(-0.0991638, -0.080444),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.32234, 0.32554),
		}) or nil,
	}, props.children)
end
