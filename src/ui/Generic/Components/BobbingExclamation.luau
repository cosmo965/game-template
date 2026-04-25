--[[
--Created Date: Thursday October 9th 2025 9:05:12 pm CEST
--Author: Cosmovyz
-------
--Last Modified: Monday October 20th 2025 11:36:02 pm CEST
--Modified By: Cosmovyz
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Packages = ReplicatedStorage.Packages

local React = require(ReplicatedStorage.Packages.React)
local ReactSpring = require(ReplicatedStorage.Packages.ReactSpring)
local e = React.createElement

local usePx = require(script.Parent.Parent.Parent.Hooks.usePx)
local useEventConnection = require(script.Parent.Parent.Parent.Hooks.useEventConnection)

--[[
    Uses pixels
]]
return function(props: {
    isVisible: boolean,
    position: UDim2,
    baseSize: UDim2,
    bobDifference: number?,
    bobSpeed: number?,
    rotation: number?,
    zIndex: number?,

    anchorPoint: number?,
    children: React.React_Node?
})
    local px = usePx()

    local sizeBinding, setSizeBinding = React.useBinding(props.baseSize)
    props.bobDifference = props.bobDifference or UDim2.fromOffset(px(10), px(10))
    props.bobSpeed = props.bobSpeed or 2

    local elapsed = React.useRef(0)
    useEventConnection(RunService.PreRender, function(dt)
        if not props.isVisible then
            return
        end

        elapsed.current += dt

        local formula = math.sin(elapsed.current * props.bobSpeed)
        
        setSizeBinding(props.baseSize + UDim2.fromOffset( px(props.bobDifference.X.Offset * formula), px(props.bobDifference.Y.Offset * formula) ))
    end, { props.baseSize, props.bobDifference, props.bobSpeed, props.isVisible })
    
    return e("ImageLabel", {
        ZIndex = props.zIndex or 0,
        Visible = if props.isVisible ~= nil then props.isVisible else true,
        Size = sizeBinding,
        Position = props.position,
        AnchorPoint = props.anchorPoint or Vector2.one / 2,
        Image = "rbxassetid://131725401401526",
        BackgroundTransparency = 1,
        Rotation = props.rotation or 0
    }, {
        Gradient = e("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 64, 140)),
                ColorSequenceKeypoint.new(0.487889, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 66, 123)),
            }),
            Rotation = 90,
        })
    }, props.children)
end