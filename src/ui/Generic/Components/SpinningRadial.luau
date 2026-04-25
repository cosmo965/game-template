--[[
--Created Date: Wednesday March 5th 2025 7:53:20 pm CEST
--Author: Cosmovyz
-------
--Last Modified: Tuesday October 21st 2025 12:19:23 pm CEST
--Modified By: Cosmovyz
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Packages = ReplicatedStorage.Packages

local ReactReflex = require(Packages.ReactReflex)
local Store = require(ReplicatedStorage.Client.Reflex.Controller).Store

local Sift = require(ReplicatedStorage.Packages.Sift)
local React = require(ReplicatedStorage.Packages.React)
local ReactSpring = require(ReplicatedStorage.Packages.ReactSpring)
local e = React.createElement

return function(props: {
    isVisible: boolean,
    size: UDim2,
    position: UDim2,
    zIndex: number?,

    children: React.React_Node
})
    local currentRotation, setRotation = React.useState(0)

    local styles, api = ReactSpring.useSpring(function()
        return {
            size = UDim2.fromScale(0, 0),
        }
    end)

    React.useEffect(function()
        if props.isVisible == true then
            api.start({
                size = props.size,

                from = {
                    size = UDim2.fromScale(0, 0)
                },
                config = {
                    duration = 0.15,
                    easing = ReactSpring.easings.easeOutBack
                }
            })
            local accumulate = currentRotation
            local step = 0
            local conn = RunService.PreRender:Connect(function(deltaTime)
                step += deltaTime
                -- if step < 1/60 then
                --     return
                -- end
                step = 0
                
                accumulate += math.min((350 * deltaTime), 900)
                setRotation(accumulate)
            end)

            return function()
                conn:Disconnect()
            end
        else
            setRotation(math.random(-360, 360))
        end
    end, { props.isVisible })
    
    return e("ImageLabel", {
        AnchorPoint = Vector2.one / 2,
        Image = "rbxassetid://74176721533594", -- rbxassetid://87445832963212
        ZIndex = props.zIndex or 1,
        Position = props.position,
        Size = styles.size,
        Visible = props.isVisible,
        BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Fit,
        Rotation = currentRotation
    }, {
        UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
            AspectRatio = 1
        })
    }, props.children)
end