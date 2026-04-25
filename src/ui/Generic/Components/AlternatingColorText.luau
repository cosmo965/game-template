--[[
--Created Date: Thursday April 2nd 2026 11:32:51 pm CEST
--Author: Cosmovyz
-------
--Last Modified: Friday April 24th 2026 12:00:00 pm CEST
--Modified By: Claude
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Packages = ReplicatedStorage.Packages

local Sift = require(Packages.Sift)

local React = require(ReplicatedStorage.Packages.React)
local ReactSpring = require(ReplicatedStorage.Packages.ReactSpring)
local e = React.createElement

local useEventConnection = require(script.Parent.Parent.Parent.Hooks.useEventConnection)
local usePx = require(script.Parent.Parent.Parent.Hooks.usePx)

local START_Y = -0.82
local END_Y = 0.1

return function(props: {
    isVisible: boolean,

    speed: number?,
    color1: Color3,
    color2: Color3,
    strokeThickness: number?,

    startY: number?,
    endY: number?,
    rotation: number?,

    native: {}?,
    
    anchorPoint: number?,
    children: React.React_Node?
})
    local px = usePx()

    local y = React.useRef(props.startY or START_Y)
    local offset, setOffset = React.useBinding(Vector2.zero)

    local currentCachedColorRef = React.useRef({ props.color1, props.color2 })
    local colorsBinding, setColorsBinding = React.useBinding({ props.color1, props.color2 })

    useEventConnection(RunService.PreRender, function(dt)
        if currentCachedColorRef.current[1] ~= props.color1 or currentCachedColorRef.current[2] ~= props.color2 then
            currentCachedColorRef.current = { props.color1, props.color2 }
            setColorsBinding({ props.color1, props.color2 })
        end

        if props.isVisible == false then
            return
        end

        if y.current >= (props.endY or END_Y) then
            y.current = (props.startY or START_Y)

            local color1 = colorsBinding:getValue()[1]
            local color2 = colorsBinding:getValue()[2]
            setColorsBinding({ color2, color1 })
        end

        local speed = props.speed and props.speed / 100 or 0.02
        y.current = math.clamp(
            y.current + speed * dt * 60,
            props.startY or START_Y,
            props.endY or END_Y
        )
        setOffset(Vector2.new(0, y.current))
    end, { props.isVisible, props.color1, props.color2 })
    
    return e("TextLabel", Sift.Dictionary.merge({
            BackgroundTransparency = 1,
            FontFace = Font.new(
                "rbxasset://fonts/families/GothamSSm.json",
                Enum.FontWeight.Bold,
                Enum.FontStyle.Normal
            ),
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            TextStrokeColor3 = Color3.new(1, 1, 1),
            TextStrokeTransparency = 0,
            Visible = props.isVisible ~= false
        }, props.native or {}), {
            UIStroke = e("UIStroke", {
                Color = Color3.new(1, 1, 1),
                Thickness = px(props.strokeThickness or 2),
            }, {
                UIGradient = e("UIGradient", {
                    Color = colorsBinding:map(function(value)
                        local color1, color2 = value[1], value[2]

                        return ColorSequence.new({
                            ColorSequenceKeypoint.new(0, color1),
                            ColorSequenceKeypoint.new(0.926, color1),
                            ColorSequenceKeypoint.new(1, color2),
                        })
                    end),
                    Rotation = props.rotation or 90,
                    Offset = offset,
                }),
            }),

            UIGradient = e("UIGradient", {
                Color = colorsBinding:map(function(value)
                    local color1, color2 = value[1], value[2]
                    
                    return ColorSequence.new({
                        ColorSequenceKeypoint.new(0, color2),
                        ColorSequenceKeypoint.new(0.926, color2),
                        ColorSequenceKeypoint.new(1, color1),
                    })
                end),
                Rotation = props.rotation or 90,
                Offset = offset,
            }),
        }, props.children or {})
end