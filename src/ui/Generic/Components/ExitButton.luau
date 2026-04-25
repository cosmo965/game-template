--[[
--Created Date: Sunday February 23rd 2025 4:16:31 pm CEST
--Author: Cosmovyz
-------
--Last Modified: Sunday April 12th 2026 11:13:09 pm CEST
--Modified By: Cosmovyz
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Packages = ReplicatedStorage.Packages

local ReactReflex = require(Packages.ReactReflex)

local Sift = require(ReplicatedStorage.Packages.Sift)
local React = require(ReplicatedStorage.Packages.React)
local ReactSpring = require(ReplicatedStorage.Packages.ReactSpring)
local e = React.createElement

local playSound = require(ReplicatedStorage.Shared.Modules.Util.playSound)
local UIClickSFX = ReplicatedStorage.Assets.Audio.UI.UIClick

return function(props: {
    position: UDim2,
    size: UDim2,
    callback: () -> nil?,
    zIndex: number?,
    scaleType: Enum.ScaleType?,
    image: string?,
    layoutOrder: number?,

    children: React.React_Node?
})

    local isHovering, setHovering = React.useState(false)
    local isPressing, setPressing = React.useState(false)
    local producer = ReactReflex.useProducer()

    local styles = ReactSpring.useSpring({
        iconSize = if isPressing then UDim2.fromScale(0.9, 0.9) elseif isHovering then UDim2.fromScale(1.1, 1.1) else UDim2.fromScale(1, 1),

        config = {
            duration = 0.05,
            easing = ReactSpring.easings.easeInQuad
        }
    }, { isHovering, isPressing })

    -- TODO: optimize all in a single handler
    React.useEffect(function()
        local conn
        conn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if isPressing and not isHovering then
                    setPressing(false)
                end
            end
        end)

        return function()
            conn:Disconnect()
        end
    end, { isPressing, isHovering })
    
    return e("TextButton", {
        Name = "ExitButtonContainer",
        AnchorPoint = props.anchorPoint or Vector2.zero,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Text = "",
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = props.position,
        Size = props.size,
        ZIndex = (props.zIndex or 0) + 1,
        LayoutOrder = props.layoutOrder or 0,

        [React.Event.MouseButton1Down] = function()
            setPressing(true)
        end,

        [React.Event.MouseButton1Up] = function()
            setPressing(false)
        end,

        [React.Event.Activated] = function()
            if isPressing then
                if props.callback then
                    props.callback()
                else
                    producer.changeMenu("")
                end
                playSound(nil, UIClickSFX, nil, {0.9, 1.1})
            end
        end,

        [React.Event.MouseEnter] = function()
            setHovering(true)
        end,

        [React.Event.MouseLeave] = function()
            setHovering(false)
        end
    }, {
        ExitButton = e("ImageLabel", {
            Active = false,
            AnchorPoint = Vector2.one / 2,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Image = props.image or "rbxassetid://100622165087747",
            Position = UDim2.fromScale(0.5, 0.5),
            Selectable = false,
            Size = styles.iconSize,
            ScaleType = if props.scaleType then props.scaleType else Enum.ScaleType.Stretch,
            ZIndex = props.zIndex or 0,
        }, props.children),
    })
end