--[[
--Created Date: Saturday February 15th 2025 3:33:10 pm CEST
--Author: Cosmovyz
-------
--Last Modified: Monday April 13th 2026 11:30:56 am CEST
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

local playSound = require(ReplicatedStorage.Shared.Modules.Util.playSound)

local UIClickSFX = ReplicatedStorage.Assets.Audio.UI.UIClick

return function(props: {
    name: string?,
    callback: () -> nil,
    position: UDim2,
    size: UDim2,
    keybind: Enum.KeyCode?,
    inactiveImage: string?,
    isVisible: boolean?,
    isActive: boolean?,
    zIndex: number?,
    image: string?,
    text: string?,
    cooldown: number?,
    tipPointText: string?,
    layoutOrder: number?,
    disableHoverEffect: boolean?,
    rotation: number?,
    imageColor: Color3?,
    hoverSizeDifference: number?,
    scaleType: Enum.ScaleType?,
    anchorPoint: Vector2?,
    key: any?,
    
    children: React.React_Node?
})
    if props.isActive == nil then
        props.isActive = true
    end
    local isHovering, setHovering = React.useState(false)
    local isPressing, setPressing = React.useState(false)
    local lastClick, setLastClick = React.useState(0)
    local producer = ReactReflex.useProducer()
    local difference = (props.hoverSizeDifference or 0.07)
    local buttonRef = React.useRef()

    local styles = ReactSpring.useSpring({
        iconSize = if isPressing and not props.disableHoverEffect then UDim2.fromScale(1 - difference, 1 - difference) elseif isHovering and not props.disableHoverEffect then UDim2.fromScale(1 + difference, 1 + difference) else UDim2.fromScale(1, 1),

        config = {
            duration = 0.05,
            easing = ReactSpring.easings.easeInQuad
        }
    }, { isHovering, isPressing })

    -- TODO: optimize all in a single handler
    React.useEffect(function()
        local conn
        conn = UserInputService.InputEnded:Connect(function(input, gpe)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if isPressing and not isHovering then
                    setPressing(false)
                end
            end

            if props.isActive and props.keybind and input.KeyCode == Enum.KeyCode[props.keybind] and props.isVisible ~= false then
                setPressing(false)

                if isPressing then
                    if (os.clock() - lastClick) >= (props.cooldown or 1/60) then
                        setLastClick(os.clock())
                        
                        if props.callback then
                            props.callback()

                            playSound(nil, UIClickSFX, nil, {0.9, 1.1})
                        end
                    end
                end

            end
        end)

        local conn2
        if props.keybind then
            conn2 = UserInputService.InputBegan:Connect(function(input, gpe)
                if not props.isActive or gpe then return end
                if input.KeyCode == Enum.KeyCode[props.keybind] then
                    setPressing(true)
                end
            end)
        end

        return function()
            conn:Disconnect()
            if props.keybind then
                conn2:Disconnect()
            end
        end
    end, { isPressing, isHovering })

    -- backer
    React.useEffect(function()
        if not props.isActive then
            setPressing(false)
            setHovering(false)
        end
    end, { props.isActive })
    
    local buttonProps = {
        Active = false,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Image =  if props.image and not (props.inactiveImage and props.isActive ~= nil and props.isActive == false) then props.image else props.inactiveImage or nil,
        ImageColor3 = props.image and( props.imageColor or Color3.fromRGB(255, 255, 255)),
        Text = if props.text then props.text else nil,
        Position = UDim2.fromScale(0.5, 0.5),
        Selectable = false,
        Size = styles.iconSize,
        Rotation = props.rotation or 0,
        ZIndex = (props.zIndex or 0),
    }

    if props.image and props.scaleType then
        buttonProps.ScaleType = props.scaleType
    end

    return e("TextButton", {
        ref = buttonRef,
        Visible = if props.isVisible ~= nil then props.isVisible else true,
        Name = props.name or "ButtonContainer",
        AnchorPoint = props.anchorPoint or Vector2.new(0.5, 0.5),
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
            if not props.isActive then
                return
            end

            setPressing(true)
        end,

        [React.Event.MouseButton1Up] = function()
            if not props.isActive then
                return
            end

            setPressing(false)
        end,

        [React.Event.Activated] = function()
            if isPressing and props.isActive then
                if (os.clock() - lastClick) >= (props.cooldown or 1/60) then
                    setLastClick(os.clock())

                    if props.callback then
                        props.callback()
                        playSound(nil, UIClickSFX, nil, {0.9, 1.1})
                    end
                end
                
            end
        end,

        [React.Event.MouseEnter] = function()
            if not props.isActive then
                return
            end

            setHovering(true)
        end,

        [React.Event.MouseLeave] = function()
            if not props.isActive then
                return
            end

            setHovering(false)
        end
    }, {
        Button = e(if props.image then "ImageLabel" else "TextLabel", buttonProps, props.children),
    })
end